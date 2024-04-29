--------------------------------------------------------
--  DDL for Package Body PER_RSL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RSL_BUS" as
/* $Header: perslrhi.pkb 120.1 2005/06/15 05:45:38 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rsl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_rating_scale_id             number         default null;
g_language                    varchar2(4)    default null;
--
--
-- The following global vaiables are only to be used by the
-- validate_translation function.
--
g_business_group_id                 number default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_rating_scale_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  -- Name : M. Burton
  -- Date  02-DEC-2002
  -- Description Amended to add MLS functionality
  -- In the following cursor statement add join(s) between
  -- per_rating_scales_tl and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
    cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_rating_scales_tl rsl_tl
         , per_rating_scales  rsl
      where  rsl.rating_scale_id = p_rating_scale_id
      and   rsl.rating_scale_id = rsl_tl.rating_scale_id
      and pbg.business_group_id = rsl.business_group_id;
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
    ,p_argument           => 'rating_scale_id'
    ,p_argument_value     => p_rating_scale_id
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'RATING_SCALE_ID')
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_rating_scale_id                      in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  -- Name : M. Burton
  -- Date  29-NOV-2002
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- per_rating_scales_tl and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.

  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_rating_scales_tl rsl_tl
         , per_rating_scales  rsl
     where
       rsl.rating_scale_id       = p_rating_scale_id
       and rsl_tl.language          = p_language
       and pbg.business_group_id = rsl.business_group_id
       and rsl.rating_scale_id   = rsl_tl.rating_scale_id;
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
    ,p_argument           => 'rating_scale_id'
    ,p_argument_value     => p_rating_scale_id
    );
  --
  --
  if (( nvl(per_rsl_bus.g_rating_scale_id, hr_api.g_number)
       = p_rating_scale_id)
  and ( nvl(per_rsl_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_rsl_bus.g_legislation_code;
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
    per_rsl_bus.g_rating_scale_id             := p_rating_scale_id;
    per_rsl_bus.g_language                    := p_language;
    per_rsl_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_rsl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_rsl_shd.api_updating
      (p_rating_scale_id                   => p_rec.rating_scale_id,
       p_language                          => p_rec.language )
   THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_name>-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description
--  - Validates that NAME exists
--  - Validates that NAME is UNIQUE for the BUSINESS_GROUP
--
-- Pre-conditions
--  - A valid BUSINESS_GROUP_ID
--
--
-- In Arguments:
--   p_rating_scale_id
--   p_business_group_id
--   p_name
--   p_object_version_number
--
-- Post Success:
--   Process continues if:
--   All the in parameters are valid.
--
-- Post Failure:
--   An application error is raised and processing is terminated if any of
--   the folowing cases are found:
--     - The NAME does not exist.
--     - The NAME is not UNIQUE for the BUSINESS_GROUP
--
-- Access Status
--   Internal Table Handler Use Only.
--
--

procedure chk_name
   (p_rating_scale_id        in   per_rating_scales_tl.rating_scale_id%TYPE
   ,p_language               in   per_rating_scales_tl.language%TYPE
   ,p_business_group_id      in   per_rating_scales.business_group_id%TYPE
   ,p_name                   in   per_rating_scales_tl.name%TYPE
   )
   is
--
   l_exists             per_rating_scales.business_group_id%TYPE;
   l_api_updating       boolean;
   l_proc               varchar2(72) := g_package||'chk_name';
   l_business_group_id  number(15);
--
--
-- Cursor to check name is unique within business group
   cursor csr_name_exists is
     select rsc.business_group_id
     from per_rating_scales    rsc
        , per_rating_scales_tl rsl
     where rsc.rating_scale_id = rsl.rating_scale_id
     and   rsl.language        = p_language
     and   (   (p_rating_scale_id is null)
              or(rsc.rating_scale_id <> p_rating_scale_id)
            )
     and rsl.name = p_name
     and p_business_group_id is null
     UNION
     select rsc.business_group_id
     from per_rating_scales    rsc
        , per_rating_scales_tl rsl
     where rsc.rating_scale_id = rsl.rating_scale_id
     and   rsl.language        = p_language
     and   (  (p_rating_scale_id is null)
	     or(rsc.rating_scale_id <> p_rating_scale_id)
           )
     and    rsl.name = p_name
     and    (rsc.business_group_id = p_business_group_id or
	     rsc.business_group_id is null)
     and    p_business_group_id is not null;
   --
begin
  hr_utility.set_location ('Entering:'|| l_proc, 1);
  --
  --
  if p_name is null then
     hr_utility.set_message(801, 'HR_51571_RSC_NAME_MANDATORY');
     hr_utility.raise_error;
  end if;
  --
  -- Only proceed with validation if:
  -- a) The current g_old_rec is current and
  -- b) The value for name has changed.
  --
  l_api_updating := per_rsl_shd.api_updating
        (p_rating_scale_id        => p_rating_scale_id
        ,p_language               => p_language
        );
  --
  hr_utility.set_location (l_proc, 3);
  --
  if (l_api_updating AND
     nvl(per_rsl_shd.g_old_rec.name, hr_api.g_varchar2)
     <> nvl(p_name, hr_api.g_varchar2)
  or not l_api_updating)
  then
  --
  hr_utility.set_location (l_proc, 4);
  --
  -- Check that NAME is UNIQUE
  --
  open csr_name_exists;
  hr_utility.set_location (l_proc, 100);
  fetch csr_name_exists into l_exists;
  if csr_name_exists%found then
     hr_utility.set_location(l_proc, 10);
     close csr_name_exists;
     hr_utility.set_location(to_char(l_exists), 99);
     if l_exists is null then
	fnd_message.set_name('PER', 'HR_52696_RSC_NAME_IN_GLOB');
	fnd_message.raise_error;
     else
        fnd_message.set_name('PER', 'HR_52697_RSC_NAME_IN_BUSGRP');
        fnd_message.raise_error;
     end if;
  end if;
  close csr_name_exists;
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc, 20);
end chk_name;
--
-- ----------------------------------------------------------------------------
-- |------------------------<  validate_translation>--------------------------|
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_rec                          in per_rsl_shd.g_rec_type
  ,p_rating_scale_id              in per_rating_scales_tl.rating_scale_id%TYPE default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
  -- Declare cursor
  --
  cursor csr_rating_scale is
    select rsc.business_group_id
      from per_rating_scales rsc
     where rsc.rating_scale_id = nvl(p_rec.rating_scale_id, p_rating_scale_id);
  --
  l_rsc_rec  csr_rating_scale%ROWTYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_rating_scale;
  --
  fetch csr_rating_scale into l_rsc_rec;
  --
  close csr_rating_scale;
  --
  validate_translation
    (p_rating_scale_id                => p_rec.rating_scale_id
    ,p_language                       => p_rec.language
    ,p_name                           => p_rec.name
    ,p_description                    => p_rec.description
    ,p_business_group_id              => l_rsc_rec.business_group_id
    );
END;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_rsl_shd.g_rec_type
  ,p_rating_scale_id              in per_rating_scales_tl.rating_scale_id%TYPE
  ) is
--
-- Name : M. Burton
-- Date  02-DEC-2002
-- Description Amended with comment
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  validate_translation
    ( p_rec
    , p_rating_scale_id
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
  (p_rec                          in per_rsl_shd.g_rec_type
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
  -- As this table does not have a mandatory business_group_id

  -- No business group context.  HR_STANDARD_LOOKUPS used for validation."

  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  validate_translation
    ( p_rec
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
  (p_rec                          in per_rsl_shd.g_rec_type
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
-- ----------------------------------------------------------------------------
-- |-----------------------< set_translation_globals >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure stores values required by validate_translations.
--
-- Prerequisites:
--   This procedure is called from from the MLS widget enabled forms.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget enabled forms only just before calling validate_translation.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE set_translation_globals
  (p_business_group_id              in number
  ) IS
--
  l_proc  varchar2(72) := g_package||'set_translation_globals';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  g_business_group_id    := p_business_group_id;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_translation >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs the validation for the MLS widget.
--
-- Prerequisites:
--   This procedure is called from from the MLS widget.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_rating_scale_id                in number
  ,p_language                       in varchar2
  ,p_name                           in varchar2
  ,p_description                    in varchar2
  ,p_business_group_id              in number default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  chk_name
    ( p_rating_scale_id             => p_rating_scale_id
    , p_language                    => p_language
    , p_name                        => p_name
    , p_business_group_id           => nvl(p_business_group_id, g_business_group_id)
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END;
--
end per_rsl_bus;

/
