--------------------------------------------------------
--  DDL for Package Body BEN_PEO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEO_BUS" as
/* $Header: bepeorhi.pkb 120.0 2005/05/28 10:38:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_peo_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_elig_to_prte_rsn_id >----------------------|
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
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   effective_date        Effective Date of session
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
Procedure chk_elig_to_prte_rsn_id(p_elig_to_prte_rsn_id   in number,
                                  p_effective_date        in date,
                                  p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_to_prte_rsn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_to_prte_rsn_id,hr_api.g_number)
     <>  ben_peo_shd.g_old_rec.elig_to_prte_rsn_id) then
    --
    -- raise error as PK has changed
    --
    ben_peo_shd.constraint_error('BEN_ELIG_TO_PRTE_RSN_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_elig_to_prte_rsn_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_peo_shd.constraint_error('BEN_ELIG_TO_PRTE_RSN_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_to_prte_rsn_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_ignr_prtn_ovrid_flag >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   ignr_prtn_ovrid_flag  Value of lookup code.
--   effective_date        effective date
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
Procedure chk_ignr_prtn_ovrid_flag(p_elig_to_prte_rsn_id    in number,
                                   p_ignr_prtn_ovrid_flag   in varchar2,
                                   p_effective_date         in date,
                                   p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ignr_prtn_ovrid_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ignr_prtn_ovrid_flag
      <> nvl(ben_peo_shd.g_old_rec.ignr_prtn_ovrid_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ignr_prtn_ovrid_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ignr_prtn_ovrid_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_ignr_prtn_ovrid_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ignr_prtn_ovrid_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_prtn_ovridbl_flag >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   prtn_ovridbl_flag     Value of lookup code.
--   effective_date        effective date
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
Procedure chk_prtn_ovridbl_flag  (p_elig_to_prte_rsn_id     in number,
                                  p_prtn_ovridbl_flag       in varchar2,
                                  p_effective_date          in date,
                                  p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_ovridbl_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_ovridbl_flag
      <> nvl(ben_peo_shd.g_old_rec.prtn_ovridbl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_ovridbl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prtn_ovridbl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prtn_ovridbl_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_ovridbl_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_elig_inelig_cd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id PK of record being inserted or updated.
--   elig_inelig_cd Value of lookup code.
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
Procedure chk_vrfy_fmly_mmbr_cd(p_elig_to_prte_rsn_id         in number,
                                p_vrfy_fmly_mmbr_cd           in varchar2,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrfy_fmly_mmbr_cd
      <> nvl(ben_peo_shd.g_old_rec.vrfy_fmly_mmbr_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_vrfy_fmly_mmbr_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FMLY_MMBR',
           p_lookup_code    => p_vrfy_fmly_mmbr_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_vrfy_fmly_mmbr_cd');
      fnd_message.set_token('TYPE','BEN_FMLY_MMBR');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrfy_fmly_mmbr_cd;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_elig_inelig_cd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id PK of record being inserted or updated.
--   elig_inelig_cd Value of lookup code.
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
Procedure chk_elig_inelig_cd(p_elig_to_prte_rsn_id         in number,
                             p_elig_inelig_cd              in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_inelig_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_elig_inelig_cd
      <> nvl(ben_peo_shd.g_old_rec.elig_inelig_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_elig_inelig_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ELIG_INELIG',
           p_lookup_code    => p_elig_inelig_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_elig_inelig_cd');
      fnd_message.set_token('TYPE','BEN_ELIG_INELIG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elig_inelig_cd;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prtn_eff_strt_dt_cd >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   prtn_eff_strt_dt_cd   Value of lookup code.
--   effective_date        effective date
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
Procedure chk_prtn_eff_strt_dt_cd(p_elig_to_prte_rsn_id      in number,
                             p_prtn_eff_strt_dt_cd           in varchar2,
                             p_effective_date                in date,
                             p_object_version_number         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_eff_strt_dt_cd
      <> nvl(ben_peo_shd.g_old_rec.prtn_eff_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_prtn_eff_strt_dt_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTN_ELIG_STRT',
           p_lookup_code    => p_prtn_eff_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prtn_eff_strt_dt_cd');
      fnd_message.set_token('TYPE','BEN_PRTN_ELIG_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_prtn_eff_strt_dt_rl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   prtn_eff_strt_dt_rl   Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_vrfy_fmly_mmbr_rl
  (p_elig_to_prte_rsn_id   in number
  ,p_vrfy_fmly_mmbr_rl     in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_vrfy_fmly_mmbr_rl,hr_api.g_number)
      <> ben_peo_shd.g_old_rec.vrfy_fmly_mmbr_rl
      or not l_api_updating)
      and p_vrfy_fmly_mmbr_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_vrfy_fmly_mmbr_rl,
        p_formula_type_id   => -21,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_vrfy_fmly_mmbr_rl);
      fnd_message.set_token('TYPE_ID',-21);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrfy_fmly_mmbr_rl;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_prtn_eff_strt_dt_rl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   prtn_eff_strt_dt_rl   Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_prtn_eff_strt_dt_rl
  (p_elig_to_prte_rsn_id   in number
  ,p_prtn_eff_strt_dt_rl   in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_strt_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtn_eff_strt_dt_rl,hr_api.g_number)
      <> ben_peo_shd.g_old_rec.prtn_eff_strt_dt_rl
      or not l_api_updating)
      and p_prtn_eff_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_prtn_eff_strt_dt_rl,
        p_formula_type_id   => -82,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_prtn_eff_strt_dt_rl);
      fnd_message.set_token('TYPE_ID',-82);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prtn_eff_end_dt_cd >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   prtn_eff_end_dt_cd    Value of lookup code.
--   effective_date        effective date
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
Procedure chk_prtn_eff_end_dt_cd(p_elig_to_prte_rsn_id      in number,
                             p_prtn_eff_end_dt_cd           in varchar2,
                             p_effective_date                in date,
                             p_object_version_number         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_eff_end_dt_cd
      <> nvl(ben_peo_shd.g_old_rec.prtn_eff_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_prtn_eff_end_dt_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTN_ELIG_END',
           p_lookup_code    => p_prtn_eff_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prtn_eff_end_dt_cd');
      fnd_message.set_token('TYPE','BEN_PRTN_ELIG_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_prtn_eff_end_dt_rl >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   prtn_eff_end_dt_rl    Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_prtn_eff_end_dt_rl(p_elig_to_prte_rsn_id      in number,
                                 p_prtn_eff_end_dt_rl       in number,
                                 p_business_group_id        in number,
                                 p_effective_date           in date,
                                 p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_end_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtn_eff_end_dt_rl,hr_api.g_number)
      <> ben_peo_shd.g_old_rec.prtn_eff_end_dt_rl
      or not l_api_updating)
      and p_prtn_eff_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_prtn_eff_end_dt_rl,
        p_formula_type_id   => -83,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_prtn_eff_end_dt_rl);
      fnd_message.set_token('TYPE_ID',-83);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_wait_perd_dt_to_use_cd >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id      PK of record being inserted or updated.
--   wait_perd_dt_to_use_cd   Value of lookup code.
--   effective_date           effective date
--   object_version_number    Object version number of record being
--                            inserted or updated.
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
Procedure chk_wait_perd_dt_to_use_cd
  (p_elig_to_prte_rsn_id      in number
  ,p_wait_perd_dt_to_use_cd   in varchar2
  ,p_effective_date           in date
  ,p_object_version_number    in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_wait_perd_dt_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wait_perd_dt_to_use_cd
      <> nvl(ben_peo_shd.g_old_rec.wait_perd_dt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_wait_perd_dt_to_use_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MX_WTG_DT_TO_USE'
          ,p_lookup_code    => p_wait_perd_dt_to_use_cd
          ,p_effective_date => p_effective_date)
    then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_wait_perd_dt_to_use_cd');
      fnd_message.set_token('TYPE','BEN_MX_WTG_DT_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wait_perd_dt_to_use_cd;
--

-- --------------------------------chk_cd_rl_combination >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code is RULE then the rule must be
--   defined else it should not be.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_vrfy_fmly_mmbr_cd         in varchar2,
--   p_vrfy_fmly_mmbr_rl         in number
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
procedure chk_cd_rl_combination
(
    p_vrfy_fmly_mmbr_cd     in varchar2,
    p_vrfy_fmly_mmbr_rl     in number ) IS
   l_proc         varchar2(72) := g_package||'chk_cd_rl_combination';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if    ( p_vrfy_fmly_mmbr_cd <> 'RL' and  p_vrfy_fmly_mmbr_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if ( p_vrfy_fmly_mmbr_cd = 'RL' and p_vrfy_fmly_mmbr_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
--leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cd_rl_combination;

--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------< chk_wait_perd_dt_to_use_rl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id      PK of record being inserted or updated.
--   wait_perd_dt_to_userrl   Value of formula rule id.
--   effective_date           effective date
--   object_version_number    Object version number of record being
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
Procedure chk_wait_perd_dt_to_use_rl
  (p_elig_to_prte_rsn_id    in number
  ,p_wait_perd_dt_to_use_rl in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_object_version_number  in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_wait_perd_dt_to_use_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_wait_perd_dt_to_use_rl,hr_api.g_number)
      <> ben_peo_shd.g_old_rec.wait_perd_dt_to_use_rl
      or not l_api_updating)
      and p_wait_perd_dt_to_use_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_wait_perd_dt_to_use_rl,
        p_formula_type_id   => -162,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_wait_perd_dt_to_use_rl);
      fnd_message.set_token('TYPE_ID',-162);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wait_perd_dt_to_use_rl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_wait_perd_uom >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   wait_perd_uom         Value of lookup code.
--   effective_date        effective date
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
Procedure chk_wait_perd_uom(p_elig_to_prte_rsn_id         in number,
                            p_wait_perd_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_wait_perd_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wait_perd_uom
      <> nvl(ben_peo_shd.g_old_rec.wait_perd_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_wait_perd_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_wait_perd_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_wait_perd_uom');
      fnd_message.set_token('TYPE','BEN_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wait_perd_uom;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_wait_perd_rl >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id      PK of record being inserted or updated.
--   wait_perd_dt_to_userrl   Value of formula rule id.
--   effective_date           effective date
--   object_version_number    Object version number of record being
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
Procedure chk_wait_perd_rl
  (p_elig_to_prte_rsn_id    in number
  ,p_wait_perd_rl           in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_object_version_number  in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_wait_perd_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_wait_perd_rl,hr_api.g_number)
      <> ben_peo_shd.g_old_rec.wait_perd_rl
      or not l_api_updating)
      and p_wait_perd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_wait_perd_rl,
        p_formula_type_id   => -518,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_wait_perd_rl);
      fnd_message.set_token('TYPE_ID',-518);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wait_perd_rl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_mx_poe_uom >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   mx_poe_uom            Value of lookup code.
--   effective_date        effective date
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
Procedure chk_mx_poe_uom
  (p_elig_to_prte_rsn_id   in number
  ,p_mx_poe_uom            in varchar2
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_mx_poe_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id         => p_elig_to_prte_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mx_poe_uom
      <> nvl(ben_peo_shd.g_old_rec.mx_poe_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mx_poe_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RQD_PERD_ENRT_NENRT_TM_UOM',
           p_lookup_code    => p_mx_poe_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_mx_poe_uom');
      fnd_message.set_token('TYPE','BEN_RQD_PERD_ENRT_NENRT_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_poe_uom;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mx_poe_det_dt_rl >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id      PK of record being inserted or updated.
--   mx_poe_det_dt_rl         Value of formula rule id.
--   effective_date           effective date
--   object_version_number    Object version number of record being
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
Procedure chk_mx_poe_det_dt_rl
  (p_elig_to_prte_rsn_id    in number
  ,p_mx_poe_det_dt_rl       in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_object_version_number  in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_mx_poe_det_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_elig_to_prte_rsn_id   => p_elig_to_prte_rsn_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mx_poe_det_dt_rl,hr_api.g_number)
      <> ben_peo_shd.g_old_rec.mx_poe_det_dt_rl
      or not l_api_updating)
      and p_mx_poe_det_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_mx_poe_det_dt_rl,
        p_formula_type_id   => -527,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_mx_poe_det_dt_rl);
      fnd_message.set_token('TYPE_ID',-527);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_poe_det_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mx_poe_rl >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id      PK of record being inserted or updated.
--   mx_poe_rl                Value of formula rule id.
--   effective_date           effective date
--   object_version_number    Object version number of record being
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
Procedure chk_mx_poe_rl
  (p_elig_to_prte_rsn_id    in number
  ,p_mx_poe_rl              in number
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_object_version_number  in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_mx_poe_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_elig_to_prte_rsn_id   => p_elig_to_prte_rsn_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mx_poe_rl,hr_api.g_number)
      <> ben_peo_shd.g_old_rec.mx_poe_rl
      or not l_api_updating)
      and p_mx_poe_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_mx_poe_rl,
        p_formula_type_id   => -526,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_mx_poe_rl);
      fnd_message.set_token('TYPE_ID',-526);
      fnd_message.raise_error;
      --
    end if;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_poe_rl;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_mx_poe_det_dt_cd >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   mx_poe_det_dt_cd      Value of lookup code.
--   effective_date        effective date
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
Procedure chk_mx_poe_det_dt_cd
  (p_elig_to_prte_rsn_id   in number
  ,p_mx_poe_det_dt_cd      in varchar2
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_mx_poe_det_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id   => p_elig_to_prte_rsn_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_mx_poe_det_dt_cd
      <> nvl(ben_peo_shd.g_old_rec.mx_poe_det_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mx_poe_det_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MX_POE_DET_DT',
           p_lookup_code    => p_mx_poe_det_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_mx_poe_det_dt_cd');
      fnd_message.set_token('TYPE','BEN_MX_POE_DET_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_poe_det_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_mx_poe_apls_cd >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_to_prte_rsn_id   PK of record being inserted or updated.
--   mx_poe_apls_cd        Value of lookup code.
--   effective_date        effective date
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
Procedure chk_mx_poe_apls_cd
  (p_elig_to_prte_rsn_id   in number
  ,p_mx_poe_apls_cd        in varchar2
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package || 'chk_mx_poe_apls_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_peo_shd.api_updating
    (p_elig_to_prte_rsn_id   => p_elig_to_prte_rsn_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_mx_poe_apls_cd
      <> nvl(ben_peo_shd.g_old_rec.mx_poe_apls_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mx_poe_apls_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MX_POE_APLS',
           p_lookup_code    => p_mx_poe_apls_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_mx_poe_apls_cd');
      fnd_message.set_token('TYPE','BEN_MX_POE_APLS');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_poe_apls_cd;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_only_one_fk >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the oipl_id or pgm_id or pl_id or
--   ptip_id or plip_id is populated and not more than one of them.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id Option in plan id of option.
--   pgm_id  program id of program.
--   pl_id   plan id of plan
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
Procedure chk_only_one_fk(p_oipl_id         in number,
                          p_pgm_id          in number,
                          p_pl_id           in number,
                          p_ptip_id         in number,
                          p_plip_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_only_one_fk';
  l_api_updating boolean;
  --
function count_them(p_id in number) return number is
  --
begin
  --
  if p_id is not null then
    --
    return 1;
    --
  else
    --
    return 0;
    --
  end if;
  --
end;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check that only one of the ID's is populated.
  --
  if count_them(p_id => p_pgm_id) +
     count_them(p_id => p_pl_id) +
     count_them(p_id => p_oipl_id) +
     count_them(p_id => p_ptip_id) +
     count_them(p_id => p_plip_id) <> 1 then
    --
    fnd_message.set_name('BEN','BEN_92146_ONLY_ONE_FK');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_only_one_fk;
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_oipl_id                       in number default hr_api.g_number,
             p_ler_id                        in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
             p_ptip_id                       in number default hr_api.g_number,
             p_plip_id                       in number default hr_api.g_number,
             p_datetrack_mode                in varchar2,
             p_validation_start_date         in date,
             p_validation_end_date           in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_oipl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_oipl_f',
             p_base_key_column => 'oipl_id',
             p_base_key_value  => p_oipl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_oipl_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pl_f',
             p_base_key_column => 'pl_id',
             p_base_key_value  => p_pl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pl_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pgm_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pgm_f',
             p_base_key_column => 'pgm_id',
             p_base_key_value  => p_pgm_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pgm_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ptip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ptip_f',
             p_base_key_column => 'ptip_id',
             p_base_key_value  => p_ptip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ptip_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_plip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_plip_f',
             p_base_key_column => 'plip_id',
             p_base_key_value  => p_plip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_plip_f';
      Raise l_integrity_error;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_elig_to_prte_rsn_id		in number,
             p_datetrack_mode		in varchar2,
             p_validation_start_date	in date,
             p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'elig_to_prte_rsn_id',
       p_argument_value => p_elig_to_prte_rsn_id);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ben_peo_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_to_prte_rsn_id
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ignr_prtn_ovrid_flag
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_ignr_prtn_ovrid_flag  => p_rec.ignr_prtn_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_ovridbl_flag
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_ovridbl_flag     => p_rec.prtn_ovridbl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_inelig_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_elig_inelig_cd        => p_rec.elig_inelig_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_vrfy_fmly_mmbr_cd     => p_rec.vrfy_fmly_mmbr_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_strt_dt_cd   => p_rec.prtn_eff_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_strt_dt_rl   => p_rec.prtn_eff_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_end_dt_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_end_dt_cd    => p_rec.prtn_eff_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_end_dt_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_end_dt_rl    => p_rec.prtn_eff_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wait_perd_dt_to_use_cd
  (p_elig_to_prte_rsn_id    => p_rec.elig_to_prte_rsn_id,
   p_wait_perd_dt_to_use_cd => p_rec.wait_perd_dt_to_use_cd,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_wait_perd_dt_to_use_rl
  (p_elig_to_prte_rsn_id    => p_rec.elig_to_prte_rsn_id,
   p_wait_perd_dt_to_use_rl => p_rec.wait_perd_dt_to_use_rl,
   p_business_group_id      => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_wait_perd_uom
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_wait_perd_uom         => p_rec.wait_perd_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wait_perd_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_wait_perd_rl          => p_rec.wait_perd_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_uom
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_uom            => p_rec.mx_poe_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_det_dt_rl      => p_rec.mx_poe_det_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_rl             => p_rec.mx_poe_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_det_dt_cd      => p_rec.mx_poe_det_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_apls_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_apls_cd        => p_rec.mx_poe_apls_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_only_one_fk
  (p_oipl_id => p_rec.oipl_id,
   p_pgm_id  => p_rec.pgm_id,
   p_pl_id   => p_rec.pl_id,
   p_ptip_id => p_rec.ptip_id,
   p_plip_id => p_rec.plip_id);
  --

chk_cd_rl_combination
  (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                   in ben_peo_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date)
--
is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_to_prte_rsn_id
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ignr_prtn_ovrid_flag
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_ignr_prtn_ovrid_flag  => p_rec.ignr_prtn_ovrid_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_ovridbl_flag
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_ovridbl_flag     => p_rec.prtn_ovridbl_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_elig_inelig_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_elig_inelig_cd        => p_rec.elig_inelig_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_vrfy_fmly_mmbr_cd     => p_rec.vrfy_fmly_mmbr_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_strt_dt_cd   => p_rec.prtn_eff_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_strt_dt_rl   => p_rec.prtn_eff_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_end_dt_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_end_dt_cd    => p_rec.prtn_eff_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_end_dt_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_prtn_eff_end_dt_rl    => p_rec.prtn_eff_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wait_perd_dt_to_use_cd
  (p_elig_to_prte_rsn_id    => p_rec.elig_to_prte_rsn_id,
   p_wait_perd_dt_to_use_cd => p_rec.wait_perd_dt_to_use_cd,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_wait_perd_dt_to_use_rl
  (p_elig_to_prte_rsn_id    => p_rec.elig_to_prte_rsn_id,
   p_wait_perd_dt_to_use_rl => p_rec.wait_perd_dt_to_use_rl,
   p_business_group_id      => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
 --
  chk_wait_perd_uom
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_wait_perd_uom         => p_rec.wait_perd_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_uom
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_uom            => p_rec.mx_poe_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_det_dt_rl      => p_rec.mx_poe_det_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_rl
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_rl             => p_rec.mx_poe_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_det_dt_cd      => p_rec.mx_poe_det_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_apls_cd
  (p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id,
   p_mx_poe_apls_cd        => p_rec.mx_poe_apls_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_only_one_fk
  (p_oipl_id => p_rec.oipl_id,
   p_pgm_id  => p_rec.pgm_id,
   p_pl_id   => p_rec.pl_id,
   p_ptip_id => p_rec.ptip_id,
   p_plip_id => p_rec.plip_id);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_oipl_id                       => p_rec.oipl_id,
     p_ler_id                        => p_rec.ler_id,
     p_pl_id                         => p_rec.pl_id,
     p_pgm_id                        => p_rec.pgm_id,
     p_ptip_id                       => p_rec.ptip_id,
     p_plip_id                       => p_rec.plip_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --

chk_cd_rl_combination
  (p_vrfy_fmly_mmbr_cd        => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl        => p_rec.vrfy_fmly_mmbr_rl);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_peo_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date,
     p_elig_to_prte_rsn_id   => p_rec.elig_to_prte_rsn_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_elig_to_prte_rsn_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_to_prte_rsn_f b
    where b.elig_to_prte_rsn_id      = p_elig_to_prte_rsn_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'elig_to_prte_rsn_id',
                             p_argument_value => p_elig_to_prte_rsn_id);
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
end ben_peo_bus;

/
