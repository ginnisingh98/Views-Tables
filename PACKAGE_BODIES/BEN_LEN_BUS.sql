--------------------------------------------------------
--  DDL for Package Body BEN_LEN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LEN_BUS" as
/* $Header: belenrhi.pkb 120.1.12000000.2 2007/05/13 22:46:27 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_len_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_lee_rsn_id >------|
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
--   lee_rsn_id PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_lee_rsn_id(p_lee_rsn_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lee_rsn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_lee_rsn_id                => p_lee_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_lee_rsn_id,hr_api.g_number)
     <>  ben_len_shd.g_old_rec.lee_rsn_id) then
    --
    -- raise error as PK has changed
    --
    ben_len_shd.constraint_error('BEN_LEE_RSN_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_lee_rsn_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_len_shd.constraint_error('BEN_LEE_RSN_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_lee_rsn_id;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_inelig_and_dflts >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that Days after occurence of LE for
--   ineligibility is greater than Days after occurence of LE to apply defaults
--   if both are not null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dys_aftr_end_to_dflt_num   Days after occurence of LE to apply defaults
--   dys_no_enrl_not_elig_num   Days after occurence of LE for ineligibility
--
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
Procedure chk_inelig_and_dflts
                   (p_dys_aftr_end_to_dflt_num    in number,
                    p_dys_no_enrl_not_elig_num    in number) is
  --
  l_proc      varchar2(72) := g_package||'chk_inelig_and_dflts';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if     ((p_dys_aftr_end_to_dflt_num is not null and
           p_dys_no_enrl_not_elig_num is not null)and
          (p_dys_no_enrl_not_elig_num < p_dys_aftr_end_to_dflt_num)) then
        --
        -- raise error if both arguments are not null and p_dys_no_enrl_not_elig
        -- _num is less than p_dys_aftr_end_to_dflt_num
        --
        fnd_message.set_name('BEN','BEN_91618_DFLT_LS_THN_INELG');
        fnd_message.raise_error;
        --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_inelig_and_dflts;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_rl Value of formula rule id.
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
Procedure chk_enrt_cvg_strt_dt_rl(p_lee_rsn_id             in number,
                             p_enrt_cvg_strt_dt_rl         in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_len_shd.g_old_rec.enrt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_enrt_cvg_strt_dt_rl,
        p_formula_type_id   => -29,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_enrt_cvg_strt_dt_rl);
      fnd_message.set_token('TYPE_ID',-29);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_rl Value of formula rule id.
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
Procedure chk_enrt_cvg_end_dt_rl(p_lee_rsn_id              in number,
                             p_enrt_cvg_end_dt_rl          in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_len_shd.g_old_rec.enrt_cvg_end_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_enrt_cvg_end_dt_rl,
        p_formula_type_id   => -30,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_enrt_cvg_end_dt_rl);
      fnd_message.set_token('TYPE_ID',-30);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   rt_strt_dt_rl Value of formula rule id.
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
Procedure chk_rt_strt_dt_rl(p_lee_rsn_id                 in number,
                            p_rt_strt_dt_rl              in number,
                            p_business_group_id          in number,
                            p_effective_date             in date,
                            p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_strt_dt_rl,hr_api.g_number)
      <> ben_len_shd.g_old_rec.rt_strt_dt_rl
      or not l_api_updating)
      and p_rt_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_rt_strt_dt_rl,
        p_formula_type_id   => -66,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_rt_strt_dt_rl);
      fnd_message.set_token('TYPE_ID',-66);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   rt_strt_dt_cd Value of lookup code.
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
Procedure chk_rt_strt_dt_cd(p_lee_rsn_id                in number,
                            p_rt_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_strt_dt_cd
      <> nvl(ben_len_shd.g_old_rec.rt_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_STRT',
           p_lookup_code    => p_rt_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_rt_strt_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_RT_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_strt_dt_cd;
--

-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   rt_end_dt_rl Value of formula rule id.
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
Procedure chk_rt_end_dt_rl(p_lee_rsn_id                  in number,
                           p_rt_end_dt_rl                in number,
                           p_business_group_id           in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_end_dt_rl,hr_api.g_number)
      <> ben_len_shd.g_old_rec.rt_end_dt_rl
      or not l_api_updating)
      and p_rt_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_rt_end_dt_rl,
        p_formula_type_id   => -67,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_rt_end_dt_rl);
      fnd_message.set_token('TYPE_ID',-67);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   rt_end_dt_cd Value of lookup code.
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
Procedure chk_rt_end_dt_cd(p_lee_rsn_id                in number,
                            p_rt_end_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_end_dt_cd
      <> nvl(ben_len_shd.g_old_rec.rt_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_END',
           p_lookup_code    => p_rt_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_rt_end_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_RT_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_perd_end_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_perd_end_dt_rl Value of formula rule id.
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
Procedure chk_enrt_perd_end_dt_rl(p_lee_rsn_id                  in number,
                                  p_enrt_perd_end_dt_rl         in number,
                                  p_business_group_id           in number,
                                  p_effective_date              in date,
                                  p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_perd_end_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_perd_end_dt_rl,hr_api.g_number)
      <> ben_len_shd.g_old_rec.enrt_perd_end_dt_rl
      or not l_api_updating)
      and p_enrt_perd_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_enrt_perd_end_dt_rl,
        p_formula_type_id   => -503,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_enrt_perd_end_dt_rl);
      fnd_message.set_token('TYPE_ID',-503);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_perd_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_perd_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_perd_end_dt_cd Value of lookup code.
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
Procedure chk_enrt_perd_end_dt_cd(p_lee_rsn_id                in number,
                            p_enrt_perd_end_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_perd_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_perd_end_dt_cd
      <> nvl(ben_len_shd.g_old_rec.enrt_perd_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_perd_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_PERD_END',
           p_lookup_code    => p_enrt_perd_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_perd_end_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_PERD_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_perd_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_perd_strt_dt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_perd_strt_dt_rl Value of formula rule id.
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
Procedure chk_enrt_perd_strt_dt_rl(p_lee_rsn_id                  in number,
                                   p_enrt_perd_strt_dt_rl        in number,
                                   p_business_group_id           in number,
                                   p_effective_date              in date,
                                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_perd_strt_dt_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_enrt_perd_strt_dt_rl,hr_api.g_number)
      <> ben_len_shd.g_old_rec.enrt_perd_strt_dt_rl
      or not l_api_updating)
      and p_enrt_perd_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_enrt_perd_strt_dt_rl,
        p_formula_type_id   => -504,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_enrt_perd_strt_dt_rl);
      fnd_message.set_token('TYPE_ID',-504);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_perd_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_perd_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_perd_strt_dt_cd Value of lookup code.
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
Procedure chk_enrt_perd_strt_dt_cd(p_lee_rsn_id                in number,
                            p_enrt_perd_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_perd_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_perd_strt_dt_cd
      <> nvl(ben_len_shd.g_old_rec.enrt_perd_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_perd_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_PERD_STRT',
           p_lookup_code    => p_enrt_perd_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_perd_strt_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_PERD_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_perd_strt_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_cvg_strt_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_strt_dt_cd(p_lee_rsn_id                in number,
                            p_enrt_cvg_strt_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_strt_dt_cd
      <> nvl(ben_len_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_CVG_STRT',
           p_lookup_code    => p_enrt_cvg_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_cvg_strt_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_CVG_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_strt_dt_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_reinstate_ovrdn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   reinstate_ovrdn_cd Value of lookup code.
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
Procedure chk_reinstate_ovrdn_cd(p_lee_rsn_id                in number,
                            p_reinstate_ovrdn_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reinstate_ovrdn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_reinstate_ovrdn_cd
      <> nvl(ben_len_shd.g_old_rec.reinstate_ovrdn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_reinstate_ovrdn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REINSTATE_OVRDN',
           p_lookup_code    => p_reinstate_ovrdn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_reinstate_ovrdn_cd');
      fnd_message.set_token('VALUE', p_reinstate_ovrdn_cd);
      fnd_message.set_token('TYPE', 'BEN_REINSTATE_OVRDN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_reinstate_ovrdn_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_reinstate_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   reinstate_cd Value of lookup code.
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
Procedure chk_reinstate_cd(p_lee_rsn_id                in number,
                            p_reinstate_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reinstate_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_reinstate_cd
      <> nvl(ben_len_shd.g_old_rec.reinstate_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_reinstate_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REINSTATE',
           p_lookup_code    => p_reinstate_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_reinstate_cd');
      fnd_message.set_token('VALUE', p_reinstate_cd);
      fnd_message.set_token('TYPE', 'BEN_REINSTATE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_reinstate_cd;
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_cvg_end_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   enrt_cvg_end_dt_cd Value of lookup code.
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
Procedure chk_enrt_cvg_end_dt_cd(p_lee_rsn_id                in number,
                            p_enrt_cvg_end_dt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_cvg_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_cvg_end_dt_cd
      <> nvl(ben_len_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cvg_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_CVG_END',
           p_lookup_code    => p_enrt_cvg_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_cvg_end_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_CVG_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_cvg_end_dt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cls_enrt_dt_to_use_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lee_rsn_id PK of record being inserted or updated.
--   cls_enrt_dt_to_use_cd Value of lookup code.
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
Procedure chk_cls_enrt_dt_to_use_cd(p_lee_rsn_id                in number,
                            p_cls_enrt_dt_to_use_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cls_enrt_dt_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_len_shd.api_updating
    (p_lee_rsn_id                => p_lee_rsn_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cls_enrt_dt_to_use_cd
      <> nvl(ben_len_shd.g_old_rec.cls_enrt_dt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cls_enrt_dt_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CLS_ENRT_DT_TO_USE',
           p_lookup_code    => p_cls_enrt_dt_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_cls_enrt_dt_to_use_cd');
      fnd_message.set_token('TYPE', 'BEN_CLS_ENRT_DT_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cls_enrt_dt_to_use_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_code_rule_dpnd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Rule is only allowed to
--   have a value if the value of the Code = 'Rule', and if code is
--   = RL then p_rule must have a value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   P_CODE value of code item.
--   P_RULE value of rule item
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
Procedure chk_code_rule_dpnd(p_code      in varchar2,
                            p_rule       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_code_rule_dpnd';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_code <> 'RL' and p_rule is not null then
      --
      fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
      fnd_message.raise_error;
      --
  elsif p_code = 'RL' and p_rule is null then
      --
      fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_code_rule_dpnd;





Procedure chk_code_number_dpnd(p_code      in varchar2,
                               p_number    in number,
                               p_end_code  in varchar2,
                               p_end_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_code_number_dpnd';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  /* Bug-4331059, Commented following check because number of days from start and end can take
     any value ( Including zero)
 if p_number is not null then     -- remove the condition once the plan copy is done
    if p_code not  in  ( 'NUMDOE', 'NUMDON','NUMDOEN') and  nvl(p_number,0) <>  0   then
      --
      fnd_message.set_name('BEN','BEN_94232_CD_NUMBER_OF_DAYS');
      fnd_message.raise_error;
      --
    elsif p_code in  ( 'NUMDOE', 'NUMDON','NUMDOEN')  and  nvl(p_number,0) =  0  then
      --
      fnd_message.set_name('BEN','BEN_94232_CD_NUMBER_OF_DAYS');
      fnd_message.raise_error;
      --
    end if;

 end if ;


 if p_end_number is not null then     -- remove the condition once the plan copy is done
    if p_end_code not  in  ( 'NUMDOE', 'NUMDON','NUMDOEN') and  nvl(p_end_number,0) <>  0   then
      --
      fnd_message.set_name('BEN','BEN_94232_CD_NUMBER_OF_DAYS');
      fnd_message.raise_error;
      --
    elsif p_end_code in  ( 'NUMDOE', 'NUMDON','NUMDOEN')  and  nvl(p_end_number,0) =  0  then
      --
      fnd_message.set_name('BEN','BEN_94232_CD_NUMBER_OF_DAYS');
      fnd_message.raise_error;
      --
    end if ;
  end if;
  */
  if p_code  in  ( 'NUMDOE', 'NUMDON','NUMDOEN')
     and  p_end_code = p_code
     and nvl(p_end_number,0) <  nvl(p_number,0)  then

      fnd_message.set_name('BEN','BEN_94233_END_DT_MORE_STRT_DT');
      fnd_message.raise_error;

 end if ;


  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_code_number_dpnd;
--
-- CWBGLOBAL
procedure chk_cwb_ler_id
	( p_lee_rsn_id               in number,
	  p_ler_id                   in number,
	  p_popl_enrt_typ_cycl_id    in number,
	  p_effective_date           in date
	  )
is
cursor c_duplicate_ler is
  select 1
  from
       ben_popl_enrt_typ_cycl_f pet,
       ben_pl_f pln,
       ben_lee_rsn_f len1,
       ben_popl_enrt_typ_cycl_f pet1,
       ben_pl_f pln1
  where
      pet.popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id
  and p_effective_date between pet.effective_start_date
                           and pet.effective_end_date
  and pet.pl_id = pln.pl_id
  and p_effective_date between pln.effective_start_date
                           and pln.effective_end_date
  and
      ((    pln.group_pl_id = pln.pl_id
       and pln1.group_pl_id = pln.pl_id
       )
       or
      (    pln.group_pl_id <> pln.pl_id
       and pln1.pl_id = pln.group_pl_id
       )
       )
and p_effective_date between pln1.effective_start_date
                           and pln1.effective_end_date
and pln1.pl_id = pet1.pl_id
and p_effective_date between pet1.effective_start_date
                           and pet1.effective_end_date
and pet1.popl_enrt_typ_cycl_id = len1.popl_enrt_typ_cycl_id
and len1.ler_id = p_ler_id
and p_effective_date between len1.effective_start_date
                           and len1.effective_end_date;
l_lee_rsn_id number;
l_proc         varchar2(72) := g_package||'chk_cwb_ler_id';

begin


hr_utility.set_location('Entering:'||l_proc, 5);
--hr_utility.set_location('p_ler_id:'||p_ler_id, 5.5);
--hr_utility.set_location('p_lee_rsn_id:'||p_lee_rsn_id, 5.51);
--hr_utility.set_location('p_popl_enrt_typ_cycl_id:'||p_popl_enrt_typ_cycl_id, 5.52);

open c_duplicate_ler;
fetch c_duplicate_ler into l_lee_rsn_id;
if c_duplicate_ler%FOUND then
--  hr_utility.set_location('dupe found:', 5.53);
  close c_duplicate_ler;
  fnd_message.set_name ('PAY','VALUE IS NOT UNIQUE');
  fnd_message.raise_error;
end if;
--hr_utility.set_location('NOT found:', 5.54);
close c_duplicate_ler;
hr_utility.set_location('Leaving:'||l_proc, 10);
end chk_cwb_ler_id ;
--
--------------------------------------------------------------------------------
-- |----------------------< chk_defer_flag_set_pln_plip >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if defer_deenrol_flag can be set for PNIP
--   or if the Plan is in Program then can't be set at Plan Level.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--
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
 procedure chk_defer_flag_set_pln_plip
			(p_lee_rsn_id		  in number
			,p_popl_enrt_typ_cycl_id  in number
 		        ,p_object_version_number  in number
			,p_effective_date	  in date
			,p_defer_deenrol_flag     in varchar2
			,p_business_group_id      in number
			) is
  --
  cursor c_pl_cd is
     select pln.pl_cd
     from   ben_pl_f pln
  	   ,ben_popl_enrt_typ_cycl_f pet
    where   pet.popl_enrt_typ_cycl_id =  p_popl_enrt_typ_cycl_id
     and    pet.pl_id = pln.pl_id
     and    pln.business_group_id = p_business_group_id
     and    pet.business_group_id = pln.business_group_id
     and    p_effective_date between pln.effective_start_date and pln.effective_end_date
     and    p_effective_date between pet.effective_start_date and pet.effective_end_date;
  --
   l_pl_cd  ben_pl_f.pl_cd%TYPE;
   l_api_updating boolean;
   l_proc         varchar2(72) := g_package||'chk_defer_flag_set_pln_plip';
  --
  begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 9653);
   --
  l_api_updating := ben_len_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_lee_rsn_id                  => p_lee_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_defer_deenrol_flag <> nvl(ben_len_shd.g_old_rec.defer_deenrol_flag,hr_api.g_varchar2)
      or not l_api_updating)
       and p_defer_deenrol_flag is not null then
    --
      open c_pl_cd;
       fetch c_pl_cd into l_pl_cd;
      close c_pl_cd;
    --
   if l_pl_cd = 'MSTBPGM' then
    --
     if p_defer_deenrol_flag = 'Y' then
     --
      fnd_message.set_name('BEN','BEN_94880_DEFER_FLAG_VALID_LVL');
      fnd_message.raise_error;
     --
     end if;
   --
   end if;
   --
 end if;
  --
   hr_utility.set_location('Leaving:'|| l_proc, 9653);
   --
  end chk_defer_flag_set_pln_plip;
  --
---- ----------------------------------------------------------------------------
-- |----------------------< chk_defer_flag_lookup >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the flag lookup value is valid.
--
-- In Parameters
--   enrt_perd_id PK of record being inserted or updated.
--
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
 procedure chk_defer_flag_lookup
			(p_lee_rsn_id		  in number
			,p_effective_date	  in date
			,p_defer_deenrol_flag     in varchar2
			,p_object_version_number  in number
			) is
  --
   l_api_updating boolean;
   l_proc         varchar2(72) := g_package||'chk_defer_flag_lookup';
  --
  begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 9653);
   --
  l_api_updating := ben_len_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_lee_rsn_id                  => p_lee_rsn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_defer_deenrol_flag <> nvl(ben_len_shd.g_old_rec.defer_deenrol_flag,hr_api.g_varchar2)
       or not l_api_updating)
      and p_defer_deenrol_flag is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_defer_deenrol_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
    --
   end if;
   --
  end if;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 9653);
   --
  end chk_defer_flag_lookup;
  --
--
-- Bug 6000303
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
            (p_popl_enrt_typ_cycl_id         in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
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
    If ((nvl(p_popl_enrt_typ_cycl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_popl_enrt_typ_cycl_f',
             p_base_key_column => 'popl_enrt_typ_cycl_id',
             p_base_key_value  => p_popl_enrt_typ_cycl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_popl_enrt_typ_cycl_f';
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
            (p_lee_rsn_id		in number,
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
       p_argument       => 'lee_rsn_id',
       p_argument_value => p_lee_rsn_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_lee_rsn_rl_f',
           p_base_key_column => 'lee_rsn_id',
           p_base_key_value  => p_lee_rsn_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_lee_rsn_rl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_enrt_perd_for_pl_f',
           p_base_key_column => 'lee_rsn_id',
           p_base_key_value  => p_lee_rsn_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_enrt_perd_for_pl_f';
      Raise l_rows_exist;
    End If;
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
	(p_rec 			 in ben_len_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
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
  chk_lee_rsn_id
  (p_lee_rsn_id          => p_rec.lee_rsn_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inelig_and_dflts
  (p_dys_aftr_end_to_dflt_num  =>  p_rec.dys_aftr_end_to_dflt_num,
   p_dys_no_enrl_not_elig_num  =>  p_rec.dys_no_enrl_not_elig_num);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_strt_dt_rl   => p_rec.enrt_cvg_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_end_dt_rl    => p_rec.enrt_cvg_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_cd
  (p_lee_rsn_id          => p_rec.lee_rsn_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_rt_end_dt_cd          => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_end_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_end_dt_rl   => p_rec.enrt_perd_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_end_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_end_dt_cd   => p_rec.enrt_perd_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_strt_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_strt_dt_rl  => p_rec.enrt_perd_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_strt_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_strt_dt_cd  => p_rec.enrt_perd_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_strt_dt_cd   => p_rec.enrt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_end_dt_cd    => p_rec.enrt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cls_enrt_dt_to_use_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_cls_enrt_dt_to_use_cd => p_rec.cls_enrt_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_perd_strt_dt_cd,
   p_rule   => p_rec.enrt_perd_strt_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_perd_end_dt_cd,
   p_rule   => p_rec.enrt_perd_end_dt_rl);
 --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_cvg_strt_dt_cd,
   p_rule   => p_rec.enrt_cvg_strt_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_cvg_end_dt_cd,
   p_rule   => p_rec.enrt_cvg_end_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.rt_strt_dt_cd,
   p_rule   => p_rec.rt_strt_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.rt_end_dt_cd,
   p_rule   => p_rec.rt_end_dt_rl);
  --
  chk_cwb_ler_id
  (p_lee_rsn_id             => p_rec.lee_rsn_id,
   p_ler_id                 => p_rec.ler_id,
   p_popl_enrt_typ_cycl_id  => p_rec.popl_enrt_typ_cycl_id,
   p_effective_date         => p_effective_date
  -- p_business_group_id      => p_business_group_id
   );


  chk_code_number_dpnd(p_code      =>  p_rec.enrt_perd_strt_dt_cd,
                       p_number    =>  p_rec.ENRT_PERD_STRT_DAYS ,
                       p_end_code      =>  p_rec.enrt_perd_end_dt_cd,
                       p_end_number    =>  p_rec.ENRT_PERD_END_DAYS) ;
  --
  --Reinstate Lookup validations
   chk_reinstate_ovrdn_cd(p_lee_rsn_id => p_rec.lee_rsn_id,
                            p_reinstate_ovrdn_cd	=> p_rec.reinstate_ovrdn_cd,
                            p_effective_date		=> p_effective_date,
                            p_object_version_number	=> p_rec.object_version_number
			    );
chk_reinstate_cd(p_lee_rsn_id => p_rec.lee_rsn_id,
                            p_reinstate_cd	=> p_rec.reinstate_cd,
                            p_effective_date		=> p_effective_date,
                            p_object_version_number	=> p_rec.object_version_number
			    );

--
chk_defer_flag_set_pln_plip
			(p_lee_rsn_id		  => p_rec.lee_rsn_id
			,p_popl_enrt_typ_cycl_id  => p_rec.popl_enrt_typ_cycl_id
 		        ,p_object_version_number  => p_rec.object_version_number
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_business_group_id      => p_rec.business_group_id
			);
--
chk_defer_flag_lookup
			(p_lee_rsn_id		  => p_rec.lee_rsn_id
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_object_version_number  => p_rec.object_version_number
			);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_len_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_lee_rsn_id
  (p_lee_rsn_id          => p_rec.lee_rsn_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_inelig_and_dflts
  (p_dys_aftr_end_to_dflt_num  =>  p_rec.dys_aftr_end_to_dflt_num,
   p_dys_no_enrl_not_elig_num  =>  p_rec.dys_no_enrl_not_elig_num);
  --
  chk_enrt_cvg_strt_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_strt_dt_rl   => p_rec.enrt_cvg_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_end_dt_rl    => p_rec.enrt_cvg_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_strt_dt_cd
  (p_lee_rsn_id          => p_rec.lee_rsn_id,
   p_rt_strt_dt_cd         => p_rec.rt_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_rt_end_dt_rl          => p_rec.rt_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_end_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_rt_end_dt_cd          => p_rec.rt_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_end_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_end_dt_rl   => p_rec.enrt_perd_end_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_end_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_end_dt_cd   => p_rec.enrt_perd_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_strt_dt_rl
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_strt_dt_rl  => p_rec.enrt_perd_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_perd_strt_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_perd_strt_dt_cd  => p_rec.enrt_perd_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_strt_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_strt_dt_cd   => p_rec.enrt_cvg_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_cvg_end_dt_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_enrt_cvg_end_dt_cd    => p_rec.enrt_cvg_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cls_enrt_dt_to_use_cd
  (p_lee_rsn_id            => p_rec.lee_rsn_id,
   p_cls_enrt_dt_to_use_cd => p_rec.cls_enrt_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_perd_strt_dt_cd,
   p_rule   => p_rec.enrt_perd_strt_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_perd_end_dt_cd,
   p_rule   => p_rec.enrt_perd_end_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_cvg_strt_dt_cd,
   p_rule   => p_rec.enrt_cvg_strt_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.enrt_cvg_end_dt_cd,
   p_rule   => p_rec.enrt_cvg_end_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.rt_strt_dt_cd,
   p_rule   => p_rec.rt_strt_dt_rl);
  --
  chk_code_rule_dpnd
  (p_code   => p_rec.rt_end_dt_cd,
   p_rule   => p_rec.rt_end_dt_rl);
  --
    chk_cwb_ler_id
    (p_lee_rsn_id             => p_rec.lee_rsn_id,
     p_ler_id                 => p_rec.ler_id,
     p_popl_enrt_typ_cycl_id  => p_rec.popl_enrt_typ_cycl_id,
     p_effective_date         => p_effective_date
     --p_business_group_id      => p_business_group_id
     );

  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_popl_enrt_typ_cycl_id         => p_rec.popl_enrt_typ_cycl_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --

  chk_code_number_dpnd(p_code      =>  p_rec.enrt_perd_strt_dt_cd,
                       p_number    =>  p_rec.ENRT_PERD_STRT_DAYS ,
                       p_end_code      =>  p_rec.enrt_perd_end_dt_cd,
                       p_end_number    =>  p_rec.ENRT_PERD_END_DAYS) ;

  --Reinstate Lookup validations
   chk_reinstate_ovrdn_cd(p_lee_rsn_id => p_rec.lee_rsn_id,
                            p_reinstate_ovrdn_cd	=> p_rec.reinstate_ovrdn_cd,
                            p_effective_date		=> p_effective_date,
                            p_object_version_number	=> p_rec.object_version_number
			    );
chk_reinstate_cd(p_lee_rsn_id => p_rec.lee_rsn_id,
                            p_reinstate_cd	=> p_rec.reinstate_cd,
                            p_effective_date		=> p_effective_date,
                            p_object_version_number	=> p_rec.object_version_number
			    );

--
chk_defer_flag_set_pln_plip
			(p_lee_rsn_id		  => p_rec.lee_rsn_id
			,p_popl_enrt_typ_cycl_id  => p_rec.popl_enrt_typ_cycl_id
 		        ,p_object_version_number  => p_rec.object_version_number
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_business_group_id      => p_rec.business_group_id
			);
--
chk_defer_flag_lookup
			(p_lee_rsn_id		  => p_rec.lee_rsn_id
			,p_effective_date	  => p_effective_date
			,p_defer_deenrol_flag     => p_rec.defer_deenrol_flag
			,p_object_version_number  => p_rec.object_version_number
			);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_len_shd.g_rec_type,
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
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_lee_rsn_id		=> p_rec.lee_rsn_id);
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
  (p_lee_rsn_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_lee_rsn_f b
    where b.lee_rsn_id      = p_lee_rsn_id
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
                             p_argument       => 'lee_rsn_id',
                             p_argument_value => p_lee_rsn_id);
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
end ben_len_bus;

/
