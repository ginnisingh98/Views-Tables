--------------------------------------------------------
--  DDL for Package Body OTA_CTT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CTT_BUS" as
/* $Header: otcttrhi.pkb 120.0 2005/05/29 07:09:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_ctt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_category_usage_id           number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_category_usage_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
      select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_category_usages ctu
     where ctu.category_usage_id = p_category_usage_id
       and pbg.business_group_id = ctu.business_group_id;
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
    );
  --
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'CATEGORY_USAGE_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_category_usage_id                    in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf   pbg
         , ota_category_usages ctu
     where ctu.category_usage_id = p_category_usage_id
       and pbg.business_group_id = ctu.business_group_id;
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
    ,p_argument           => 'category_usage_id'
    ,p_argument_value     => p_category_usage_id
    );
  --
  --
  if (( nvl(ota_ctt_bus.g_category_usage_id, hr_api.g_number)
       = p_category_usage_id)
  and ( nvl(ota_ctt_bus.g_language, hr_api.g_varchar2)
       = p_language)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_ctt_bus.g_legislation_code;
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
    ota_ctt_bus.g_category_usage_id           := p_category_usage_id;
    ota_ctt_bus.g_language                    := p_language;
    ota_ctt_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date               in date
  ,p_rec in ota_ctt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_ctt_shd.api_updating
      (p_category_usage_id                 => p_rec.category_usage_id
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
--  ---------------------------------------------------------------------------
--  |--------------------------< Chk_unique_category >-------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure Chk_unique_category
  (p_category_usage_id                    in     number
  ,p_language                             in     varchar2
  ,p_category                             in     varchar2
  ,p_business_group_id                    in     number
  ,p_type                                 in     varchar2
  ,p_parent_cat_usage_id                  in     number
  )
  Is
  --
  -- Declare cursor
  --
  cursor csr_cat_name is
    select
	    distinct ctu.type
    from
        ota_category_usages_tl ctt,
        ota_category_usages ctu
    where
        ctt.category_usage_id = ctu.category_usage_id
        and (p_category_usage_id is null or ctt.category_usage_id <> p_category_usage_id)
        and ( ctu.parent_cat_usage_id = p_parent_cat_usage_id or ctu.type <> 'C')
        and ctu.business_group_id = p_business_group_id
        and ctu.type =   p_type
        and ctt.language = p_language
        and ctt.category = p_category;
/*
    select
	    distinct ctu.type
    from
        ota_category_usages_tl ctt
        , ota_category_usages ctu
    where
        ctt.category_usage_id = ctu.category_usage_id
        and (p_category_usage_id is null or ctt.category_usage_id <> p_category_usage_id)
	and ctu.business_group_id = p_business_group_id
	and ctu.type =   p_type
        and ctt.language = p_language
        and ctt.category = p_category;
*/

  --
  -- Declare local variables
  --
  l_dup_cat_type      varchar2(30);
  l_proc              varchar2(72)  :=  g_package||'Chk_unique_category';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_cat_name;
  fetch csr_cat_name into l_dup_cat_type;
  --
  if csr_cat_name%found then
    --
    -- The category name cannot be duplicated therefore we must error
    --
    close csr_cat_name;
    if l_dup_cat_type = 'DM' then
      fnd_message.set_name('OTA','OTA_443388_CTU_DUP_DM');
    else
      fnd_message.set_name('OTA','OTA_443337_CTU_DUP_NAME');
    end if;
    hr_utility.set_location(l_proc,20);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
  close csr_cat_name;

  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end Chk_unique_category;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< Chk_unique_category >-------------------------------|
--  ---------------------------------------------------------------------------
--
Procedure Chk_unique_category
  (p_category_usage_id                    in     number
  ,p_language                             in     varchar2
  ,p_category                             in     varchar2
  )
  Is
  --
  -- Declare cursor
  --
  cursor csr_cat_bg_type is
    select
	distinct ctu.type, ctu.business_group_id, ctu.parent_cat_usage_id
    from
        ota_category_usages ctu
    where
        ctu.category_usage_id = p_category_usage_id;


  --
  -- Declare local variables
  --
  l_type                varchar2(30);
  l_business_group_id   number(9);
  l_proc                varchar2(72)  :=  g_package||'Chk_unique_category';
  l_parent_cat_usage_id number(9);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_cat_bg_type;
  fetch csr_cat_bg_type into l_type, l_business_group_id, l_parent_cat_usage_id;
  --
  close csr_cat_bg_type;
  --
  --
  --
  Chk_unique_category
  (p_category_usage_id     =>      p_category_usage_id
  ,p_language              =>      p_language
  ,p_category              =>      p_category
  ,p_business_group_id     =>      l_business_group_id
  ,p_type                  =>      l_type
  ,p_parent_cat_usage_id   =>      l_parent_cat_usage_id
  );
  --
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end Chk_unique_category;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in     date
  ,p_rec                          in     ota_ctt_shd.g_rec_type
  ,p_category_usage_id            in     number
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  ota_ctu_bus.set_security_Group_id(p_category_usage_id);
  --
    Chk_unique_category
    (p_category_usage_id     =>      p_category_usage_id
    ,p_language              =>      p_rec.language
    ,p_category              =>      p_rec.category
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ctt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  ota_ctu_bus.set_security_Group_id(p_rec.category_usage_id);
  --
  --
    Chk_unique_category
    (p_category_usage_id     =>      p_rec.category_usage_id
    ,p_language              =>      p_rec.language
    ,p_category              =>      p_rec.category
    );
  --
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
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
  (p_rec                          in ota_ctt_shd.g_rec_type
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
end ota_ctt_bus;

/
