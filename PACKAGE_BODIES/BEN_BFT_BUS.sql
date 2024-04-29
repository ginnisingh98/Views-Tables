--------------------------------------------------------
--  DDL for Package Body BEN_BFT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BFT_BUS" as
/* $Header: bebftrhi.pkb 115.23 2003/08/18 05:05:29 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bft_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_benefit_action_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_benefit_action_id(p_benefit_action_id           in number,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_benefit_action_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_benefit_action_id,hr_api.g_number)
     <>  ben_bft_shd.g_old_rec.benefit_action_id) then
    --
    -- raise error as PK has changed
    --
    ben_bft_shd.constraint_error('BEN_BENEFIT_ACTIONS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_benefit_action_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bft_shd.constraint_error('BEN_BENEFIT_ACTIONS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_benefit_action_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_debug_messages_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   debug_messages_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_debug_messages_flag(p_benefit_action_id       in number,
                                  p_debug_messages_flag     in varchar2,
                                  p_effective_date          in date,
                                  p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_debug_messages_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_debug_messages_flag
      <> nvl(ben_bft_shd.g_old_rec.debug_messages_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if benutils.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_debug_messages_flag) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_debug_messages_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_debug_messages_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_person_selection_rl >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   person_selection_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_person_selection_rl(p_benefit_action_id     in number,
                                  p_person_selection_rl   in number,
                                  p_business_group_id     in number,
                                  p_effective_date        in date,
                                  p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_selection_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_person_selection_rl,hr_api.g_number)
      <> ben_bft_shd.g_old_rec.person_selection_rl
      or not l_api_updating)
      and p_person_selection_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_person_selection_rl,
        p_formula_type_id   => -214,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_person_selection_rl);
      fnd_message.set_token('TYPE_ID',-214);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_person_selection_rl;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_comp_selection_rl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   comp_selection_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_comp_selection_rl(p_benefit_action_id      in number,
                                p_comp_selection_rl      in number,
                                p_business_group_id      in number,
                                p_effective_date         in date,
                                p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_selection_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_comp_selection_rl,hr_api.g_number)
      <> ben_bft_shd.g_old_rec.comp_selection_rl
      or not l_api_updating)
      and p_comp_selection_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_comp_selection_rl,
        p_formula_type_id   => -213,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_comp_selection_rl);
      fnd_message.set_token('TYPE_ID',-213);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comp_selection_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_no_plans_flag >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   no_plans_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_no_plans_flag(p_benefit_action_id       in number,
                            p_no_plans_flag           in varchar2,
                            p_effective_date          in date,
                            p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_plans_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_plans_flag
      <> nvl(ben_bft_shd.g_old_rec.no_plans_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if benutils.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_plans_flag) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_debug_messages_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_plans_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_no_programs_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   no_programs_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_no_programs_flag(p_benefit_action_id           in number,
                               p_no_programs_flag            in varchar2,
                               p_effective_date              in date,
                               p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_programs_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_programs_flag
      <> nvl(ben_bft_shd.g_old_rec.no_programs_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if benutils.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_programs_flag) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_debug_messages_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_programs_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_validate_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   validate_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_validate_flag(p_benefit_action_id           in number,
                            p_validate_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_validate_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_validate_flag
      <> nvl(ben_bft_shd.g_old_rec.validate_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if benutils.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_validate_flag) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_debug_messages_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_validate_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_derivable_factors_flag >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   derivable_factors_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_derivable_factors_flag(p_benefit_action_id      in number,
                                     p_derivable_factors_flag in varchar2,
                                     p_effective_date         in date,
                                     p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_derivable_factors_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_derivable_factors_flag
      <> nvl(ben_bft_shd.g_old_rec.derivable_factors_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if benutils.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_derivable_factors_flag) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_debug_messages_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_derivable_factors_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_close_uneai_flag       >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   close_uneai_flag       Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_close_uneai_flag      (p_benefit_action_id      in number,
                                     p_close_uneai_flag       in varchar2,
                                     p_effective_date         in date,
                                     p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_close_uneai_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_close_uneai_flag
      <> nvl(ben_bft_shd.g_old_rec.close_uneai_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if benutils.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_close_uneai_flag      ) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_debug_messages_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_close_uneai_flag      ;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mode_cd >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benefit_action_id PK of record being inserted or updated.
--   mode_cd Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_mode_cd(p_benefit_action_id     in number,
                      p_mode_cd               in varchar2,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mode_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bft_shd.api_updating
    (p_benefit_action_id           => p_benefit_action_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mode_cd
      <> nvl(ben_bft_shd.g_old_rec.mode_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    -- The mode_cd is used by both BENMNGLE and BENTMPCM and each has
    -- it's own domain.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BENMNGLE_MD',
           p_lookup_code    => p_mode_cd,
           p_effective_date => p_effective_date) and
       hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BENTMPCM_MD',
           p_lookup_code    => p_mode_cd,
           p_effective_date => p_effective_date) and
       hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BENCLENR_MD',
           p_lookup_code    => p_mode_cd,
           p_effective_date => p_effective_date)  -- 1674123
   then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mode_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bft_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call lookup cache structure
  --
  benutils.init_lookups(p_lookup_type_1  => 'YES_NO',
                        p_effective_date => p_effective_date);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_benefit_action_id
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_debug_messages_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_debug_messages_flag   => p_rec.debug_messages_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_selection_rl
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_person_selection_rl   => p_rec.person_selection_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_selection_rl
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_comp_selection_rl     => p_rec.comp_selection_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_plans_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_no_plans_flag         => p_rec.no_plans_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_programs_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_no_programs_flag      => p_rec.no_programs_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_validate_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_validate_flag         => p_rec.validate_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_derivable_factors_flag
  (p_benefit_action_id      => p_rec.benefit_action_id,
   p_derivable_factors_flag => p_rec.derivable_factors_flag,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_close_uneai_flag
  (p_benefit_action_id      => p_rec.benefit_action_id,
   p_close_uneai_flag       => p_rec.close_uneai_flag,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_mode_cd
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_mode_cd               => p_rec.mode_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bft_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call lookup cache structure
  --
  benutils.init_lookups(p_lookup_type_1  => 'YES_NO',
                        p_effective_date => p_effective_date);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_benefit_action_id
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_debug_messages_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_debug_messages_flag   => p_rec.debug_messages_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_person_selection_rl
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_person_selection_rl   => p_rec.person_selection_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_selection_rl
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_comp_selection_rl     => p_rec.comp_selection_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_plans_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_no_plans_flag         => p_rec.no_plans_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_programs_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_no_programs_flag      => p_rec.no_programs_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_validate_flag
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_validate_flag         => p_rec.validate_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_derivable_factors_flag
  (p_benefit_action_id      => p_rec.benefit_action_id,
   p_derivable_factors_flag => p_rec.derivable_factors_flag,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_close_uneai_flag
  (p_benefit_action_id      => p_rec.benefit_action_id,
   p_close_uneai_flag       => p_rec.close_uneai_flag,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_mode_cd
  (p_benefit_action_id     => p_rec.benefit_action_id,
   p_mode_cd               => p_rec.mode_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bft_shd.g_rec_type
                         ,p_effective_date in date) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_benefit_action_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_benefit_actions b
    where b.benefit_action_id = p_benefit_action_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'benefit_action_id',
                             p_argument_value => p_benefit_action_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_bft_bus;

/
