--------------------------------------------------------
--  DDL for Package Body BEN_RTS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RTS_BUS" as
/* $Header: bertsrhi.pkb 120.1 2006/01/09 14:37 maagrawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_rts_bus.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_group_per_in_ler_id         number         default null;
g_pl_id                       number         default null;
g_oipl_id                     number         default null;
/* Commenting the following procedures thinking that they are not required.
   If these are required, this could should be un-commented and modified
   to fetch the right values.
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_group_per_in_ler_id                  in number
  ,p_pl_id                                in number
  ,p_oipl_id                              in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ,p_associated_column3                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ben_cwb_person_rates and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_cwb_person_rates rts
      --   , EDIT_HERE table_name(s) 333
     where rts.group_per_in_ler_id = p_group_per_in_ler_id
       and rts.pl_id = p_pl_id
       and rts.oipl_id = p_oipl_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
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
    ,p_argument           => 'group_per_in_ler_id'
    ,p_argument_value     => p_group_per_in_ler_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pl_id'
    ,p_argument_value     => p_pl_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'oipl_id'
    ,p_argument_value     => p_oipl_id
    );
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
        => nvl(p_associated_column1,'GROUP_PER_IN_LER_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'PL_ID')
      ,p_associated_column3
        => nvl(p_associated_column3,'OIPL_ID')
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
  (p_group_per_in_ler_id                  in     number
  ,p_pl_id                                in     number
  ,p_oipl_id                              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ben_cwb_person_rates and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ben_cwb_person_rates rts
      --   , EDIT_HERE table_name(s) 333
     where rts.group_per_in_ler_id = p_group_per_in_ler_id
       and rts.pl_id = p_pl_id
       and rts.oipl_id = p_oipl_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'group_per_in_ler_id'
    ,p_argument_value     => p_group_per_in_ler_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pl_id'
    ,p_argument_value     => p_pl_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'oipl_id'
    ,p_argument_value     => p_oipl_id
    );
  --
  if (( nvl(ben_rts_bus.g_group_per_in_ler_id, hr_api.g_number)
       = p_group_per_in_ler_id)
  and ( nvl(ben_rts_bus.g_pl_id, hr_api.g_number)
       = p_pl_id)
  and ( nvl(ben_rts_bus.g_oipl_id, hr_api.g_number)
       = p_oipl_id)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_rts_bus.g_legislation_code;
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
    ben_rts_bus.g_group_per_in_ler_id         := p_group_per_in_ler_id;
    ben_rts_bus.g_pl_id                       := p_pl_id;
    ben_rts_bus.g_oipl_id                     := p_oipl_id;
    ben_rts_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
     End of commented code. */
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
  (p_rec in ben_rts_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_rts_shd.api_updating
      (p_group_per_in_ler_id               => p_rec.group_per_in_ler_id
      ,p_pl_id                             => p_rec.pl_id
      ,p_oipl_id                           => p_rec.oipl_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.group_per_in_ler_id, hr_api.g_number) <>
                                ben_rts_shd.g_old_rec.group_per_in_ler_id then
      hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'GROUP_PER_IN_LER_ID'
      ,p_base_table => ben_rts_shd.g_tab_nam
      );
  end if;
  --
  if nvl(p_rec.pl_id, hr_api.g_number) <>
                                ben_rts_shd.g_old_rec.pl_id then
      hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'PL_ID'
      ,p_base_table => ben_rts_shd.g_tab_nam
      );
  end if;
  --
  if nvl(p_rec.oipl_id, hr_api.g_number) <>
                                ben_rts_shd.g_old_rec.oipl_id then
      hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'OIPL_ID'
      ,p_base_table => ben_rts_shd.g_tab_nam
      );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- No validations are required.
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ben_rts_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- No validations required
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end ben_rts_bus;

/
