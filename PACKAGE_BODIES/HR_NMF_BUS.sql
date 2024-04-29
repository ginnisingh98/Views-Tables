--------------------------------------------------------
--  DDL for Package Body HR_NMF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NMF_BUS" as
/* $Header: hrnmfrhi.pkb 120.0 2005/05/31 01:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_nmf_bus.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_name_format_id              number         default null;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_name_format_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select nmf.legislation_code
      from hr_name_formats nmf
     where nmf.name_format_id = p_name_format_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'name_format_id'
    ,p_argument_value     => p_name_format_id
    );
  --
  if ( nvl(hr_nmf_bus.g_name_format_id, hr_api.g_number)
       = p_name_format_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_nmf_bus.g_legislation_code;
    if g_debug then
       hr_utility.set_location(l_proc, 20);
    end if;
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
    if g_debug then
       hr_utility.set_location(l_proc,30);
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hr_nmf_bus.g_name_format_id              := p_name_format_id;
    hr_nmf_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
     hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_delete >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that rows may be deleted from per_all_people_f
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_name_format_id
--
--  Post Success:
--    If a row may be deleted then
--    processing continues
--
--  Post Failure:
--    If row is seeded an application error will be raised and processing
--    is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
Procedure chk_delete(p_name_format_id  in hr_name_formats.name_format_id%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_delete';
  l_created_by hr_name_formats.created_by%TYPE;
  --
  cursor csr_get_created_by(p_id hr_name_formats.name_format_id%TYPE) is
     select created_by
       from hr_name_formats
      where name_format_id = p_id;
--
Begin
  --
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  -- Raise error if row is seeded
  --
  open csr_get_created_by(p_name_format_id);
  fetch csr_get_created_by into l_created_by;
  close csr_get_created_by;
  if l_created_by is not null and l_created_by = 2 then
     fnd_message.set_name('PER','HR_449576_SEED_NMF_DEL');
     fnd_message.raise_error;
  end if;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'||l_proc, 100);
  end if;
End chk_delete;
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
  ,p_rec in hr_nmf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_argument varchar2(30);
  l_error    exception;
--
Begin
  --
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_nmf_shd.api_updating
      (p_name_format_id                    => p_rec.name_format_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.format_name,hr_api.g_varchar2) <> hr_nmf_shd.g_old_rec.format_name then
     l_argument := 'format_name';
     raise l_error;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(hr_nmf_shd.g_old_rec.legislation_code ,hr_api.g_varchar2)
  then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  if nvl(p_rec.user_format_choice,hr_api.g_varchar2) <>
     hr_nmf_shd.g_old_rec.user_format_choice then
     l_argument := 'user_format_choice';
     raise l_error;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 100);
  end if;
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;

End chk_non_updateable_args;
--
--
--  -----------------------------------------------------------------
--  |-----------------< chk_name_format_id >------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the name_format_id is not null.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_name_format_id
--
--  Post Success:
--    Processing continues if the name_format_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the name_format_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_name_format_id
       (p_name_format_id          in  hr_name_formats.name_format_id%TYPE
       ) is
--
--  Local declarations
  l_proc       varchar2(72) := g_package||' chk_name_format_id';
  l_name_format_id               number;
--
begin
   if g_debug then
      hr_utility.set_location('Entering: '||l_proc,5);
   end if;
   --
   -----------------------------------
   -- Check name format id not null --
   -----------------------------------
   hr_api.mandatory_arg_error
     (p_api_name => l_proc,
      p_argument =>  'p_name_format_id',
      p_argument_value => p_name_format_id);
   --
   if g_debug then
      hr_utility.set_location('Leaving: '||l_proc,10);
   end if;
end chk_name_format_id;
--
--  -----------------------------------------------------------------
--  |--------------------< chk_format_name >------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the format_name exists in FND_LOOKUP_VALUES.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_format_name
--
--  Post Success:
--    Processing continues if the format_name is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the format_name is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_format_name
       (p_name_format_id            in  hr_name_formats.name_format_id%TYPE
       ,p_format_name               in  hr_name_formats.format_name%TYPE
       ,p_object_version_number     in  hr_name_formats.object_version_number%TYPE
       ,p_effective_date            in  date
       ) is
--
--  Local declarations
  l_proc           varchar2(72) := g_package||' chk_format_name';
  l_api_updating   boolean;
  --
begin
   if g_debug then
      hr_utility.set_location('Entering: '||l_proc,5);
   end if;
   --
   -- Check mandatory parameters have been set
   --
   hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
   --
   hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'format name',
      p_argument_value => p_format_name);
   --
   l_api_updating := hr_nmf_shd.api_updating
             (p_name_format_id        => p_name_format_id
             ,p_object_version_number => p_object_version_number
              );
   --
   if ((l_api_updating and
        hr_nmf_shd.g_old_rec.format_name <> p_format_name) or
        (not l_api_updating)) then
      --
      if hr_api.not_exists_in_hrstanlookups
       (p_effective_date  => p_effective_date
       ,p_lookup_type     => 'PER_NAME_FORMATS'
       ,p_lookup_code     => p_format_name) then
       --
         fnd_message.set_name('PER', 'HR_449575_FORMAT_NAME_INV');
         fnd_message.raise_error;
      end if;
   end if;
   --
   if g_debug then
      hr_utility.set_location('Leaving: '||l_proc,70);
   end if;
  --
Exception
  when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1 => 'HR_NAME_FORMATS.FORMAT_NAME') then
         if g_debug then
            hr_utility.set_location(' Leaving:'||l_proc, 80);
         end if;
         raise;
      end if;
      if g_debug then
         hr_utility.set_location(' Leaving:'||l_proc,90);
      end if;
end chk_format_name;
--
--
--  -----------------------------------------------------------------
--  |-----------------< chk_legislation_code >----------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check if legislation code is not null, that the value exists in
--    FND_TERRITORIES table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_legislation_code(p_legislation_code    in  hr_name_formats.legislation_code%TYPE) is
--
--  Local declarations
  l_proc           varchar2(72) := g_package||' chk_legislation_code';
  l_value          varchar2(240) := 'DUMMY';
--
begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  IF p_legislation_code IS NOT NULL THEN
    l_value := hr_general.DECODE_TERRITORY(P_TERRITORY_CODE => p_legislation_code);

    IF l_value IS NULL then
      fnd_message.set_name('PER','PER_449075_CAL_LEG_CODE');
      fnd_message.raise_error;
    END IF;
   --
  END IF;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'||l_proc, 70);
  end if;
  --
Exception
  when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1 => 'HR_NAME_FORMATS.LEGISLATION_CODE') then
         if g_debug then
            hr_utility.set_location(' Leaving:'||l_proc, 80);
         end if;
         raise;
      end if;
      if g_debug then
         hr_utility.set_location(' Leaving:'||l_proc,90);
      end if;
end chk_legislation_code;
--
--  -----------------------------------------------------------------
--  |-----------------< chk_user_format_choice >----------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the user_format_choice exists in fnd_lookup_values.
--    The only acceptable values are 'G' and 'L'.
--    If format_name is DISPLAY_NAME or LIST_NAME then this is mandatory.
--    If format_name is FULL_NAME or ORDER_NAME then user_format_choice
--    must be 'L'.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_user_format_choice
--    p_format_name
--    p_effective_date
--
--  Post Success:
--    Processing continues if the user_format_choice is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the user_format_choice is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_user_format_choice
    (p_user_format_choice  in  hr_name_formats.user_format_choice%TYPE
    ,p_format_name         in  hr_name_formats.format_name%TYPE
    ,p_effective_date      in  date) is

--
--  Local declarations
  l_proc           varchar2(72) := g_package||' chk_user_format_choice';
  --
begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'user format choice'
    ,p_argument_value => p_user_format_choice
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'format name'
    ,p_argument_value => p_format_name
    );
  --
  if g_debug then
    hr_utility.set_location(l_proc, 10);
  end if;
  --
  if p_user_format_choice is not null then
     --
     -- validate the formart choice represents a valid lookup
     --
     if hr_api.not_exists_in_hrstanlookups
       (p_effective_date  => p_effective_date
       ,p_lookup_type     => 'PER_NAME_FORMAT_CHOICE'
       ,p_lookup_code     => p_user_format_choice) then

         fnd_message.set_name('PER', 'HR_449571_FORMAT_CHOICE_INV');
         fnd_message.raise_error;
     elsif p_user_format_choice not in ('G','L') then
        --
        -- ensure it only uses 'G' or 'L'
        --
         fnd_message.set_name('PER', 'HR_449571_FORMAT_CHOICE_INV');
         fnd_message.raise_error;
     end if;
  end if;
  --
  if p_format_name = 'DISPLAY_NAME' OR p_format_name = 'LIST_NAME' then
      --
      -- Ensure user_format_choice is not null
      --
      hr_api.mandatory_arg_error
        (p_api_name => l_proc,
         p_argument =>  'p_user_format_choice',
         p_argument_value => p_user_format_choice);
  end if;
  --
  if (p_format_name = 'FULL_NAME' OR p_format_name = 'ORDER_NAME')
     AND (p_user_format_choice is not null and p_user_format_choice <> 'L') then
      --
      fnd_message.set_name('PER', 'HR_449572_FORMAT_CHOICE_INV');
      fnd_message.raise_error;
  end if;
  --
  if g_debug then
     hr_utility.set_location('Leaving:'||l_proc, 70);
  end if;
Exception
  when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1 => 'HR_NAME_FORMATS.USER_FORMAT_CHOICE') then
         if g_debug then
            hr_utility.set_location(' Leaving:'||l_proc, 80);
         end if;
         raise;
      end if;
      if g_debug then
         hr_utility.set_location(' Leaving:'||l_proc,90);
      end if;
End chk_user_format_choice;
--
--  -----------------------------------------------------------------
--  |---------------------< chk_format_mask >-----------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the format_mask does not contain invalid tokens.
--    Valid tokens are stored in FND_LOOKUP_VALUES table
--     where LOOKUP TYPE = 'PER_FORMAT_MASK_TOKENS'
--
--    The format mask has been stored as follows:
--    [prefix] space $TOKEN space [suffix]
--
--    []: indicates argument is optional
--    Also, it can contain several occurrences of the above syntax:
--    [prefix] space $TOKEN space [suffix] space $TOKEN
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_format_mask
--    p_effective_date
--
--  Post Success:
--    Processing continues if the format_mask is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the format_mask is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_format_mask
    (p_format_mask        in hr_name_formats.format_mask%TYPE
    ,p_effective_date     in date) is
--
--  Local declarations
  l_proc             varchar2(72) := g_package||' chk_format_mask';
  l_format           hr_name_formats.format_mask%TYPE;
  l_token_start_pos  number;
  l_token_end_pos    number;
  l_token            fnd_lookup_values.lookup_code%TYPE;
  --
begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  l_format := p_format_mask;
  if l_format is null then
     fnd_message.set_name('PER','HR_449604_NMF_NULL_MASK');
     fnd_message.raise_error;
  end if;
  --
  -- Verify a token might exist
  -- Minimum required syntax: '|$token$|' where min(length(token)) = 1
  --
  l_token_start_pos := instr(l_format,'$');
  if l_token_start_pos = 0 or length(l_format) < 5 then
        fnd_message.set_name('PER','HR_449573_FORMAT_MASK_INV');
        fnd_message.raise_error;
  end if;
  while l_format is not null loop
     l_token_start_pos := instr(l_format,'$')+1;
     --
     if (l_token_start_pos-1) > 0 then
        l_token_end_pos   := instr(l_format,'$',l_token_start_pos);
        if nvl(l_token_end_pos,0) <> 0 then
           l_token := substr(l_format,l_token_start_pos, l_token_end_pos - l_token_start_pos);
           l_format := substr(l_format,l_token_end_pos+1);
        else
           l_token := substr(l_format,l_token_start_pos);
           l_format := null;
        end if;
        if l_token is null then
              fnd_message.set_name('PER','HR_449573_FORMAT_MASK_INV');
              fnd_message.raise_error;
        else
           if hr_api.not_exists_in_hrstanlookups
              (p_effective_date  => p_effective_date
              ,p_lookup_type     => 'PER_FORMAT_MASK_TOKENS'
              ,p_lookup_code     => l_token) then
           --
              fnd_message.set_name('PER','HR_449573_FORMAT_MASK_INV');
              fnd_message.raise_error;
           end if;
        end if;
     else
        l_format := null;
     end if;
  end loop;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc,70);
  end if;
Exception
  when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1 => 'HR_NAME_FORMATS.FORMAT_MASK') then
         if g_debug then
            hr_utility.set_location(' Leaving:'||l_proc, 80);
         end if;
         raise;
      end if;
      if g_debug then
         hr_utility.set_location(' Leaving:'||l_proc,90);
      end if;

End chk_format_mask;
--
--  -----------------------------------------------------------------
--  |--------------< chk_format_and_legislation >-------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the combination of format_name, legislation code and
--    user format choice is unique.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_format_name
--    p_legislation_code
--    p_user_format_choice
--
--  Post Success:
--    Processing continues if combination of all three parameters is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the combination of all three parameters is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_format_and_legislation
     (p_format_name         in  hr_name_formats.format_name%TYPE
     ,p_legislation_code    in  hr_name_formats.legislation_code%TYPE
     ,p_user_format_choice  in  hr_name_formats.user_format_choice%TYPE
     ) is
--
--  Local declarations
  l_proc             varchar2(72) := g_package||' chk_format_and_legislation';
  l_value_exists     varchar2(10);
  --
  cursor csr_validate_combination(p_format_name varchar2
                                 ,p_leg_code    varchar2
                                 ,p_user_choice varchar2) is
     select 'Y'
       from HR_NAME_FORMATS
      where format_name        = p_format_name
        and (p_leg_code is null and legislation_code is null
             or p_leg_code is not null and legislation_code   = p_leg_code)
        and user_format_choice = p_user_choice;
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'format name'
    ,p_argument_value => p_format_name
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'user format choice'
    ,p_argument_value => p_user_format_choice
    );
  open csr_validate_combination(p_format_name,p_legislation_code,p_user_format_choice);
  fetch csr_validate_combination into l_value_exists;
  if csr_validate_combination%FOUND then
     close csr_validate_combination;
     fnd_message.set_name('PER','HR_449574_NAME_LEG_INV');
    fnd_message.raise_error;
  else
     close csr_validate_combination;
  end if;
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc,70);
  end if;
Exception
  when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1 => 'HR_NAME_FORMATS.FORMAT_NAME'
      ,p_associated_column2 => 'HR_NAME_FORMATS.LEGISLATION_CODE'
      ,p_associated_column3 => 'HR_NAME_FORMATS.USER_FORMAT_CHOICE') then
         if g_debug then
            hr_utility.set_location(' Leaving:'||l_proc, 80);
         end if;
         raise;
      end if;
      if g_debug then
         hr_utility.set_location(' Leaving:'||l_proc,90);
      end if;

End chk_format_and_legislation;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hr_nmf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.
  --
  -- Validate format name
  --
  chk_format_name
       (p_name_format_id            => p_rec.name_format_id
       ,p_format_name               => p_rec.format_name
       ,p_object_version_number     => p_rec.object_version_number
       ,p_effective_date            => p_effective_date);
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Validate legislation code
  --
  chk_legislation_code(p_legislation_code  => p_rec.legislation_code);
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validate user format choice
  --
  chk_user_format_choice
    (p_user_format_choice  => p_rec.user_format_choice
    ,p_format_name         => p_rec.format_name
    ,p_effective_date      => p_effective_date);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Validate format mask
  --
  chk_format_mask(p_format_mask     => p_rec.format_mask
                 ,p_effective_date  => p_effective_date);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Validate format name, legislation code and user format choice
  --
  chk_format_and_legislation
     (p_format_name           => p_rec.format_name
     ,p_legislation_code      => p_rec.legislation_code
     ,p_user_format_choice    => p_rec.user_format_choice);
  --
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 100);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hr_nmf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
      ,p_rec              => p_rec
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validate format mask
  --
  chk_format_mask(p_format_mask      => p_rec.format_mask
                 ,p_effective_date   => p_effective_date);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 100);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_nmf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||' delete_validate';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  chk_delete(p_name_format_id  => p_rec.name_format_id);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hr_nmf_bus;

/
