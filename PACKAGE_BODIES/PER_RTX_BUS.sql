--------------------------------------------------------
--  DDL for Package Body PER_RTX_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RTX_BUS" as
/* $Header: pertxrhi.pkb 115.3 2004/06/28 23:22:17 kjagadee noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rtx_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_rating_level_id             number         default null;
g_language                    varchar2(4)    default null;
--
-- The following global vaiables are only to be used by the
-- validate_translation function.
--
g_rating_scale_id                 number default null;
g_competence_id                   number default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_rating_level_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- Get the businees group from the base table
  -- MB amended 16-Dec-2002

  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_rating_levels rt
         , per_rating_levels_tl rtx
     where rt.rating_level_id = p_rating_level_id
     and   rt.rating_level_id = rtx.rating_level_id
     and   pbg.business_group_id = rt.business_group_id;
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
    ,p_argument           => 'rating_level_id'
    ,p_argument_value     => p_rating_level_id
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
        => nvl(p_associated_column1,'RATING_LEVEL_ID')
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
  (p_rating_level_id                      in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- Get the legislation_code for current business group
  -- MB amedned on 16-Dec-2002
  --
   cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_rating_levels rt
         , per_rating_levels_tl rtx
     where rt.rating_level_id = p_rating_level_id
     and   rt.rating_level_id = rtx.rating_level_id
     and   rtx.language = p_language
     and   pbg.business_group_id = rt.business_group_id;
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
    ,p_argument           => 'rating_level_id'
    ,p_argument_value     => p_rating_level_id
    );
  --
  --
  if (( nvl(per_rtx_bus.g_rating_level_id, hr_api.g_number)
       = p_rating_level_id)
  and ( nvl(per_rtx_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_rtx_bus.g_legislation_code;
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
    per_rtx_bus.g_rating_level_id             := p_rating_level_id;
    per_rtx_bus.g_language                    := p_language;
    per_rtx_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_rtx_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_rtx_shd.api_updating
      (p_rating_level_id                   => p_rec.rating_level_id
      ,p_language                          => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
-------------------------------------------------------------------------------
-------------------------------< chk_name >------------------------------------
-------------------------------------------------------------------------------
--
--
--  Description:
--   - Validates that a valid rating level name is entered
--     and is unique for a rating scale or a competence
--
--
--  In Arguments:
--    p_rating_level_id
--    p_name
--    p_object_version_number
--    p_rating_scale_id
--    p_competence_id
--
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	- name is invalid
--	- name is not unique
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_name
(p_rating_level_id	     in	     per_rating_levels.rating_level_id%TYPE
,p_language                  in      per_rating_levels_tl.language%TYPE
--,p_object_version_number     in      per_rating_levels.object_version_number%TYPE
,p_name			     in      per_rating_levels_tl.name%TYPE
,p_rating_scale_id	     in	     per_rating_levels.rating_scale_id%TYPE
,p_competence_id	     in	     per_rating_levels.competence_id%TYPE
)
is
--
	l_exists             varchar2(1);
	l_api_updating	     boolean;
  	l_proc               varchar2(72)  :=  g_package||'chk_name';
	--
	-- Cursor to check if name is unique for rating scale or competence
        --
	cursor csr_chk_name_unique is
	  select 'Y'
	  from   per_rating_levels rtl
	     ,   per_rating_levels_tl rtx
	  where  rtl.rating_level_id = rtx.rating_level_id
          and    rtx.language        = p_language
          and    (   (p_rating_level_id is null)
		   or(p_rating_level_id <> rtx.rating_level_id)
		 )
	  and	 rtx.name = p_name
	  and    (  (nvl(rtl.competence_id,hr_api.g_number)
			= nvl(p_competence_id,hr_api.g_number) )
		  and(nvl(rtl.rating_scale_id,hr_api.g_number)
			= nvl(p_rating_scale_id,hr_api.g_number))
		 );
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
   --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for name has changed
  --
  l_api_updating := per_rtx_shd.api_updating
         (p_rating_level_id	   => p_rating_level_id
         ,p_language               => p_language);
  --
  if (  (l_api_updating and (per_rtx_shd.g_old_rec.name
		        <> nvl(p_name,hr_api.g_varchar2))
         ) or
        (NOT l_api_updating)
      ) then
     --
     hr_utility.set_location(l_proc, 2);
     --
     -- check if the user has entered a name, as name is
     -- is mandatory column.
     --
     if p_name is null then
       hr_utility.set_message(801,'HR_51475_RTL_NAME_MANDATORY');
       hr_utility.raise_error;
     end if;
     --
     -- check if name is unique
     --
     open csr_chk_name_unique;
     fetch csr_chk_name_unique into l_exists;
     if csr_chk_name_unique%found then
       hr_utility.set_location(l_proc, 3);
       -- name is not unique
       close csr_chk_name_unique;
       hr_utility.set_message(801,'HR_51474_RTL_NOT_UNIQUE');
       hr_utility.raise_error;
     end if;
     close csr_chk_name_unique;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
end chk_name;
--
-- ----------------------------------------------------------------------------
-- |------------------------<  validate_translation>--------------------------|
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_rec                          in per_rtx_shd.g_rec_type
  ,p_rating_level_id              in per_rating_levels_tl.rating_level_id%TYPE default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
  -- Declare cursor
  --
  cursor csr_rating_level is
    select rtl.rating_scale_id
         , rtl.competence_id
      from per_rating_levels rtl
     where rtl.rating_level_id = nvl(p_rec.rating_level_id, p_rating_level_id);
  --
  l_rtl_rec  csr_rating_level%ROWTYPE;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_rating_level;
  --
  fetch csr_rating_level into l_rtl_rec;
  --
  close csr_rating_level;
  --
  validate_translation
    (p_rating_level_id                => p_rec.rating_level_id
    ,p_language                       => p_rec.language
    ,p_name                           => p_rec.name
    ,p_behavioural_indicator          => p_rec.behavioural_indicator
    ,p_rating_scale_id                => l_rtl_rec.rating_scale_id
    ,p_competence_id                  => l_rtl_rec.competence_id
    );
END;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_rtx_shd.g_rec_type
  ,p_rating_level_id              in per_rating_levels_tl.rating_level_id%TYPE
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- MB amended 16-Dec-2002
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  validate_translation
    ( p_rec
    , p_rating_level_id
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
  (p_rec                          in per_rtx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- MB amedned 16-Dec-2002
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_rtx_shd.g_rec_type
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
  (p_rating_scale_id                in number
  ,p_competence_id                  in number
  ) IS
--
  l_proc  varchar2(72) := g_package||'set_translation_globals';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  g_rating_scale_id    := p_rating_scale_id;
  g_competence_id      := p_competence_id;
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
  (p_rating_level_id                in number
  ,p_language                       in varchar2
  ,p_name                           in varchar2
  ,p_behavioural_indicator          in varchar2
  ,p_rating_scale_id                in number default null
  ,p_competence_id                  in number default null
  ) IS
  --
  l_proc  varchar2(72) := g_package||'validate_translation';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  chk_name
    ( p_rating_level_id             => p_rating_level_id
    , p_language                    => p_language
    , p_name                        => p_name
    , p_rating_scale_id             => nvl(p_rating_scale_id, g_rating_scale_id)
    , p_competence_id               => nvl(p_competence_id, g_competence_id)
    );
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END;
--
end per_rtx_bus;

/
