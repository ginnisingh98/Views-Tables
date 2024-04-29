--------------------------------------------------------
--  DDL for Package Body BEN_EPA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPA_BUS" as
/* $Header: beeparhi.pkb 120.0 2005/05/28 02:35:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_epa_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_wait_perd_value >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--     Ensure if p_wait_perd_val is not null then p_prtn_strt_dt_rl must
--     have a value
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_wait_perd_val
--     p_prtn_eff_strt_dt_rl
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
-- ----------------------------------------------------------------------------
Procedure chk_wait_perd_value(p_wait_perd_val       in number,
                              p_prtn_eff_strt_dt_rl in number ) is
  --
  l_proc varchar2(72) := g_package||' chk_wait_perd_value ';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
/* DENISE IS THINKING ABOUT THIS RULE AND CHECKING CRUD FOR PGMDE
  if p_wait_perd_val is not null and p_prtn_eff_strt_dt_rl is null then
    --
    hr_utility.set_message(801,'wait_perd_eff_strt_rl');
    hr_utility.raise_error;
    --
  end if;
*/
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
  --
End chk_wait_perd_value;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_prtn_eff_strt_dt_cd_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the code/rule dependency as the
--   following:
--              If Code =  'Rule' then rule must be selected.
--              If Code <> 'Rule' thne rule must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_eff_strt_dt_cd        Value of look up value.
--   prtn_eff_strt_dt_rl        value of look up Value
--                              inserted or updated.
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
Procedure chk_prtn_eff_strt_dt_cd_rl(p_prtn_eff_strt_dt_cd      in varchar2,
                                     p_prtn_eff_strt_dt_rl      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_strt_dt_cd_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check dependency of Code and Rule.
        --
        if (p_prtn_eff_strt_dt_cd <> 'RL' and
            p_prtn_eff_strt_dt_rl is not null) then
            --
            fnd_message.set_name('BEN','BEN_91920_PRTN_STRT_DT_CD');
            fnd_message.raise_error;
            --
        end if;
            --
        if (p_prtn_eff_strt_dt_cd = 'RL'
            and p_prtn_eff_strt_dt_rl is null) then
            --
            fnd_message.set_name('BEN','BEN_91921_PRTN_STRT_DT_RL');
            fnd_message.raise_error;
            --
        end if;
  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_strt_dt_cd_rl;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_prtn_eff_end_dt_cd_rl >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the code/rule dependency as the
--   following:
--              If Code =  'Rule' then rule must be selected.
--              If Code <> 'Rule' thne rule must not be selected.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_eff_end_dt_cd        Value of look up value.
--   prtn_eff_end_dt_rl        value of look up Value
--                              inserted or updated.
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
Procedure chk_prtn_eff_end_dt_cd_rl(p_prtn_eff_end_dt_cd      in varchar2,
                                     p_prtn_eff_end_dt_rl      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_end_dt_cd_rl';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check dependency of Code and Rule.
        --
        if (p_prtn_eff_end_dt_cd <> 'RL' and
            p_prtn_eff_end_dt_rl is not null) then
            --
            fnd_message.set_name('BEN','BEN_91923_PRTN_END_DT_CD');
            fnd_message.raise_error;
            --
        end if;
            --
        if (p_prtn_eff_end_dt_cd = 'RL'
            and p_prtn_eff_end_dt_rl is null) then
            --
            fnd_message.set_name('BEN','BEN_91922_PRTN_END_DT_RL');
            fnd_message.raise_error;
            --
        end if;
  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_end_dt_cd_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_prtn_elig_id >---------------------------|
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
--   prtn_elig_id PK of record being inserted or updated.
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
Procedure chk_prtn_elig_id(p_prtn_elig_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_elig_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epa_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prtn_elig_id                => p_prtn_elig_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtn_elig_id,hr_api.g_number)
     <>  ben_epa_shd.g_old_rec.prtn_elig_id) then
    --
    -- raise error as PK has changed
    --
    ben_epa_shd.constraint_error('BEN_PRTN_ELIG_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prtn_elig_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_epa_shd.constraint_error('BEN_PRTN_ELIG_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prtn_elig_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_prtn_eff_end_dt_rl >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_elig_id PK of record being inserted or updated.
--   prtn_eff_end_dt_rl Value of formula rule id.
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
Procedure chk_prtn_eff_end_dt_rl
             (p_prtn_elig_id                in number,
              p_prtn_eff_end_dt_rl          in number,
              p_effective_date              in date,
              p_object_version_number       in number,
              p_business_group_id           in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_end_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_prtn_eff_end_dt_rl
    and    ff.formula_type_id = -83
    and    nvl(ff.business_group_id, p_business_group_id) =
               p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
               pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id                => p_prtn_elig_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtn_eff_end_dt_rl,hr_api.g_number)
      <> ben_epa_shd.g_old_rec.prtn_eff_end_dt_rl
      or not l_api_updating)
      and p_prtn_eff_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
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
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_end_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prtn_eff_strt_dt_rl >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_elig_id PK of record being inserted or updated.
--   prtn_eff_strt_dt_rl Value of formula rule id.
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
Procedure chk_prtn_eff_strt_dt_rl
                            (p_prtn_elig_id                in number,
                             p_prtn_eff_strt_dt_rl         in number,
                             p_effective_date              in date,
                             p_object_version_number       in number,
                             p_business_group_id           in number)
is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_strt_dt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff ,
           per_business_groups pbg
    where  ff.formula_id = p_prtn_eff_strt_dt_rl
    and    ff.formula_type_id = -82
    and    nvl(ff.business_group_id, p_business_group_id) =
               p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) =
               pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id                => p_prtn_elig_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_prtn_eff_strt_dt_rl,hr_api.g_number)
      <> ben_epa_shd.g_old_rec.prtn_eff_strt_dt_rl
      or not l_api_updating)
      and p_prtn_eff_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
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
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtn_eff_strt_dt_rl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_prtn_eff_end_dt_cd >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_elig_id PK of record being inserted or updated.
--   prtn_eff_end_dt_cd Value of lookup code.
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
Procedure chk_prtn_eff_end_dt_cd(p_prtn_elig_id           in number,
                                 p_prtn_eff_end_dt_cd     in varchar2,
                                 p_effective_date         in date,
                                 p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_end_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id                => p_prtn_elig_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_eff_end_dt_cd
      <> nvl(ben_epa_shd.g_old_rec.prtn_eff_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_eff_end_dt_cd is not null then
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
      hr_utility.set_message(801,'prtn_eff_end_dt_cd');
      hr_utility.raise_error;
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
--   prtn_elig_id PK of record being inserted or updated.
--   prtn_eff_strt_dt_cd Value of lookup code.
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
Procedure chk_prtn_eff_strt_dt_cd(p_prtn_elig_id                in number,
                                  p_prtn_eff_strt_dt_cd         in varchar2,
                                  p_effective_date              in date,
                                  p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eff_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id                => p_prtn_elig_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtn_eff_strt_dt_cd
      <> nvl(ben_epa_shd.g_old_rec.prtn_eff_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_eff_strt_dt_cd is not null then
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
      hr_utility.set_message(801,'prtn_eff_strt_dt_cd');
      hr_utility.raise_error;
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
  (p_prtn_elig_id             in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id                => p_prtn_elig_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wait_perd_dt_to_use_cd
      <> nvl(ben_epa_shd.g_old_rec.wait_perd_dt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating) and
      p_wait_perd_dt_to_use_cd is not null
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
--   wait_perd_dt_to_use_rl   Value of formula rule id.
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
  (p_prtn_elig_id           in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_prtn_elig_id          => p_prtn_elig_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_wait_perd_dt_to_use_rl,hr_api.g_number)
      <> ben_epa_shd.g_old_rec.wait_perd_dt_to_use_rl
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
--   prtn_elig_id PK of record being inserted or updated.
--   wait_perd_uom Value of lookup code.
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
Procedure chk_wait_perd_uom(p_prtn_elig_id                in number,
                            p_wait_perd_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_wait_perd_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id                => p_prtn_elig_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wait_perd_uom
      <> nvl(ben_epa_shd.g_old_rec.wait_perd_uom,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'wait_perd_uom');
      hr_utility.raise_error;
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
--   prtn_elig_id      PK of record being inserted or updated.
--   wait_perd_dt_to_use_rl   Value of formula rule id.
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
  (p_prtn_elig_id           in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prtn_elig_id          => p_prtn_elig_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_wait_perd_rl,hr_api.g_number)
      <> ben_epa_shd.g_old_rec.wait_perd_rl
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
--   prtn_elig_id             PK of record being inserted or updated.
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
  (p_prtn_elig_id           in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_prtn_elig_id          => p_prtn_elig_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mx_poe_det_dt_rl,hr_api.g_number)
      <> ben_epa_shd.g_old_rec.mx_poe_det_dt_rl
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
--   prtn_elig_id             PK of record being inserted or updated.
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
  (p_prtn_elig_id           in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_prtn_elig_id          => p_prtn_elig_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_mx_poe_rl,hr_api.g_number)
      <> ben_epa_shd.g_old_rec.mx_poe_rl
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
--   prtn_elig_id          PK of record being inserted or updated.
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
  (p_prtn_elig_id          in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id          => p_prtn_elig_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_mx_poe_apls_cd
      <> nvl(ben_epa_shd.g_old_rec.mx_poe_apls_cd,hr_api.g_varchar2)
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
--   prtn_elig_id          PK of record being inserted or updated.
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
  (p_prtn_elig_id          in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id          => p_prtn_elig_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_mx_poe_uom
      <> nvl(ben_epa_shd.g_old_rec.mx_poe_uom,hr_api.g_varchar2)
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
--   prtn_elig_id          PK of record being inserted or updated.
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
  (p_prtn_elig_id          in number
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
  l_api_updating := ben_epa_shd.api_updating
    (p_prtn_elig_id          => p_prtn_elig_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and p_mx_poe_det_dt_cd
      <> nvl(ben_epa_shd.g_old_rec.mx_poe_det_dt_cd,hr_api.g_varchar2)
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
-- |-----------------------< chk_only_one_fk >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that only one of the FKS is populated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   oipl_id FK
--   pl_id   FK
--   pgm_id  FK
--   ptip_id FK
--   plip_id FK
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
Procedure chk_only_one_fk(p_oipl_id       in number,
                          p_pl_id         in number,
                          p_pgm_id        in number,
                          p_ptip_id       in number,
                          p_plip_id       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oipl_pl_pgm_id';
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
end count_them;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check to ensure that only one of the FK's is populated.
  --
  if count_them(p_oipl_id) +
    count_them(p_pl_id) +
    count_them(p_pgm_id) +
    count_them(p_ptip_id) +
    count_them(p_plip_id) <> 1 then
    --
    fnd_message.set_name('BEN','BEN_92146_ONLY_ONE_FK');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_only_one_fk;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_pgm_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that elig is unique for a program
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtn_elig_id PK
--   p_pgm_id ID of FK column
--
--   p_effective_date session date
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_pgm_id(p_prtn_elig_id          in number,
                     p_pgm_id                in number,
                     p_validation_start_date in date,
                     p_validation_end_date   in date,
                     p_effective_date        in date,
                     p_business_group_id     in number,
                     p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c1 is
  select null
    from ben_prtn_elig_f
   where pgm_id = p_pgm_id
     and prtn_elig_id <> nvl(p_prtn_elig_id, hr_api.g_number)
     and business_group_id + 0 = p_business_group_id
     and p_validation_start_date <= effective_end_date
     and p_validation_end_date >= effective_start_date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epa_shd.api_updating
     (p_prtn_elig_id       => p_prtn_elig_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_pgm_id is not null then
  if (l_api_updating
     and nvl(p_pgm_id, hr_api.g_number)
             <> nvl(ben_epa_shd.g_old_rec.pgm_id, hr_api.g_number)
     or not l_api_updating) then
    --
    --
    open c1;
    fetch c1 into l_exists;
    if c1%found then
      close c1;
      --
      -- raise error as this elig already exists for this pgm
      --
      fnd_message.set_name('BEN', 'BEN_91848_DUP_ELIG_FOR_PGM');
      fnd_message.raise_error;
    --
    end if;
    close c1;
    --
  end if;
  --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pgm_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_pl_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that elig is unique for a plan
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtn_elig_id PK
--   p_pl_id ID of FK column
--
--   p_effective_date session date
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_pl_id(p_prtn_elig_id          in number,
                    p_pl_id                 in number,
                    p_validation_start_date in date,
                    p_validation_end_date   in date,
                    p_effective_date        in date,
                    p_business_group_id     in number,
                    p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c1 is
  select null
    from ben_prtn_elig_f
   where pl_id = p_pl_id
     and prtn_elig_id <> nvl(p_prtn_elig_id, hr_api.g_number)
     and business_group_id + 0 = p_business_group_id
     and p_validation_start_date <= effective_end_date
     and p_validation_end_date >= effective_start_date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epa_shd.api_updating
     (p_prtn_elig_id       => p_prtn_elig_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_pl_id is not null then
  if (l_api_updating
     and nvl(p_pl_id, hr_api.g_number)
             <> nvl(ben_epa_shd.g_old_rec.pl_id, hr_api.g_number)
     or not l_api_updating) then
    --
    --
    open c1;
    fetch c1 into l_exists;
    if c1%found then
      close c1;
      --
      -- raise error as this elig already exists for this pgm
      --
      fnd_message.set_name('BEN', 'BEN_91846_DUP_ELIG_FOR_PL');
      fnd_message.raise_error;
    --
    end if;
    close c1;
    --
  end if;
  --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pl_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_oipl_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that elig is unique for an oipl
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtn_elig_id PK
--   p_oipl_id ID of FK column
--
--   p_effective_date session date
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_oipl_id(p_prtn_elig_id          in number,
                      p_oipl_id               in number,
                      p_validation_start_date in date,
                      p_validation_end_date   in date,
                      p_effective_date        in date,
                      p_business_group_id     in number,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oipl_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c1 is
  select null
    from ben_prtn_elig_f
   where oipl_id = p_oipl_id
     and prtn_elig_id <> nvl(p_prtn_elig_id, hr_api.g_number)
     and business_group_id + 0 = p_business_group_id
     and p_validation_start_date <= effective_end_date
     and p_validation_end_date >= effective_start_date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epa_shd.api_updating
     (p_prtn_elig_id       => p_prtn_elig_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_oipl_id is not null then
  if (l_api_updating
     and nvl(p_oipl_id, hr_api.g_number)
             <> nvl(ben_epa_shd.g_old_rec.oipl_id, hr_api.g_number)
     or not l_api_updating) then
    --
    --
    open c1;
    fetch c1 into l_exists;
    if c1%found then
      close c1;
      --
      -- raise error as this elig already exists for this oipl
      --
      fnd_message.set_name('BEN', 'BEN_91847_DUP_ELIG_FOR_OIPL');
      fnd_message.raise_error;
    --
    end if;
    close c1;
    --
  end if;
  --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_oipl_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_ptip_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that elig is unique for a program
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtn_elig_id PK
--   p_ptip_id ID of FK column
--
--   p_effective_date session date
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_ptip_id(p_prtn_elig_id          in number,
                      p_ptip_id               in number,
                      p_validation_start_date in date,
                      p_validation_end_date   in date,
                      p_effective_date        in date,
                      p_business_group_id     in number,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptip_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c1 is
  select null
    from ben_prtn_elig_f
   where ptip_id = p_ptip_id
     and prtn_elig_id <> nvl(p_prtn_elig_id, hr_api.g_number)
     and business_group_id+0 = p_business_group_id
     and p_validation_start_date <= effective_end_date
     and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epa_shd.api_updating
     (p_prtn_elig_id            => p_prtn_elig_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_ptip_id is not null then
    --
    if (l_api_updating
      and nvl(p_ptip_id,hr_api.g_number)
      <> nvl(ben_epa_shd.g_old_rec.ptip_id,hr_api.g_number)
      or not l_api_updating) then
      --
      open c1;
        --
        fetch c1 into l_exists;
        if c1%found then
          --
          close c1;
          --
          -- raise error as this elig already exists for this pgm
          --
          fnd_message.set_name('BEN','BEN_92147_DUP_ELIG_FOR_PTIP');
          fnd_message.raise_error;
          --
        end if;
        --
      close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ptip_id;
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_plip_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that elig is unique for a program
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtn_elig_id PK
--   p_plip_id ID of FK column
--
--   p_effective_date session date
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_plip_id(p_prtn_elig_id          in number,
                      p_plip_id               in number,
                      p_validation_start_date in date,
                      p_validation_end_date   in date,
                      p_effective_date        in date,
                      p_business_group_id     in number,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_plip_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c1 is
  select null
    from ben_prtn_elig_f
   where plip_id = p_plip_id
     and prtn_elig_id <> nvl(p_prtn_elig_id, hr_api.g_number)
     and business_group_id+0 = p_business_group_id
     and p_validation_start_date <= effective_end_date
     and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epa_shd.api_updating
     (p_prtn_elig_id            => p_prtn_elig_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_plip_id is not null then
    --
    if (l_api_updating
      and nvl(p_plip_id,hr_api.g_number)
      <> nvl(ben_epa_shd.g_old_rec.plip_id,hr_api.g_number)
      or not l_api_updating) then
      --
      open c1;
        --
        fetch c1 into l_exists;
        if c1%found then
          --
          close c1;
          --
          -- raise error as this elig already exists for this pgm
          --
          fnd_message.set_name('BEN','BEN_92148_DUP_ELIG_FOR_PLIP');
          fnd_message.raise_error;
          --
        end if;
        --
      close c1;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_plip_id;
--
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
            (p_prtn_eff_end_dt_rl            in number default hr_api.g_number,
             p_oipl_id                       in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
             p_ptip_id                       in number default hr_api.g_number,
             p_plip_id                       in number default hr_api.g_number,
             p_datetrack_mode                in varchar2,
             p_validation_start_date         in date,
             p_validation_end_date           in date)
Is
--
  l_proc        varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name        all_tables.table_name%TYPE;
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
    If ((nvl(p_prtn_eff_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_prtn_eff_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
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
            (p_prtn_elig_id        in number,
             p_datetrack_mode        in varchar2,
         p_validation_start_date    in date,
         p_validation_end_date    in date) Is
--
  l_proc    varchar2(72)     := g_package||'dt_delete_validate';
  l_rows_exist    Exception;
  l_table_name    all_tables.table_name%TYPE;
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
       p_argument       => 'prtn_elig_id',
       p_argument_value => p_prtn_elig_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtn_eligy_rl_f',
           p_base_key_column => 'prtn_elig_id',
           p_base_key_value  => p_prtn_elig_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_eligy_rl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtn_elig_prfl_f',
           p_base_key_column => 'prtn_elig_id',
           p_base_key_value  => p_prtn_elig_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtn_elig_prfl_f';
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
    (p_rec              in ben_epa_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_prtn_elig_id
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_end_dt_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_end_dt_rl    => p_rec.prtn_eff_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_prtn_eff_strt_dt_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_strt_dt_rl   => p_rec.prtn_eff_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_prtn_eff_end_dt_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_end_dt_cd    => p_rec.prtn_eff_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_strt_dt_cd   => p_rec.prtn_eff_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_cd_rl
  (p_prtn_eff_strt_dt_cd   => p_rec.prtn_eff_strt_dt_cd,
   p_prtn_eff_strt_dt_rl   => p_rec.prtn_eff_strt_dt_rl);
  --
  chk_prtn_eff_end_dt_cd_rl
  (p_prtn_eff_end_dt_cd    => p_rec.prtn_eff_end_dt_cd,
   p_prtn_eff_end_dt_rl    => p_rec.prtn_eff_end_dt_rl);
  --
  chk_wait_perd_dt_to_use_cd
  (p_prtn_elig_id           => p_rec.prtn_elig_id,
   p_wait_perd_dt_to_use_cd => p_rec.wait_perd_dt_to_use_cd,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_wait_perd_dt_to_use_rl
  (p_prtn_elig_id            => p_rec.prtn_elig_id,
   p_wait_perd_dt_to_use_rl  => p_rec.wait_perd_dt_to_use_rl,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number,
   p_business_group_id       => p_rec.business_group_id);
  --
  chk_wait_perd_uom
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_wait_perd_uom         => p_rec.wait_perd_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wait_perd_value
  (p_wait_perd_val         => p_rec.wait_perd_val,
   p_prtn_eff_strt_dt_rl   => p_rec.prtn_eff_strt_dt_rl);
  --
  chk_wait_perd_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_wait_perd_rl          => p_rec.wait_perd_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_det_dt_rl      => p_rec.mx_poe_det_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_rl             => p_rec.mx_poe_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_apls_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_apls_cd        => p_rec.mx_poe_apls_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_uom
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_uom            => p_rec.mx_poe_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_det_dt_cd      => p_rec.mx_poe_det_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_only_one_fk
  (p_oipl_id               => p_rec.oipl_id,
   p_pl_id                 => p_rec.pl_id,
   p_pgm_id                => p_rec.pgm_id,
   p_ptip_id               => p_rec.ptip_id,
   p_plip_id               => p_rec.plip_id);
  --
  chk_pgm_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_pgm_id                => p_rec.pgm_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_pl_id                 => p_rec.pl_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_oipl_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_oipl_id               => p_rec.oipl_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_ptip_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_ptip_id               => p_rec.ptip_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_plip_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_plip_id               => p_rec.plip_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_validate
    (p_rec              in ben_epa_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_prtn_elig_id
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_end_dt_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_end_dt_rl    => p_rec.prtn_eff_end_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_prtn_eff_strt_dt_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_strt_dt_rl   => p_rec.prtn_eff_strt_dt_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_prtn_eff_end_dt_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_end_dt_cd    => p_rec.prtn_eff_end_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_prtn_eff_strt_dt_cd   => p_rec.prtn_eff_strt_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtn_eff_strt_dt_cd_rl
  (p_prtn_eff_strt_dt_cd   => p_rec.prtn_eff_strt_dt_cd,
   p_prtn_eff_strt_dt_rl   => p_rec.prtn_eff_strt_dt_rl);
  --
  chk_prtn_eff_end_dt_cd_rl
  (p_prtn_eff_end_dt_cd    => p_rec.prtn_eff_end_dt_cd,
   p_prtn_eff_end_dt_rl    => p_rec.prtn_eff_end_dt_rl);
  --
  chk_wait_perd_dt_to_use_cd
  (p_prtn_elig_id           => p_rec.prtn_elig_id,
   p_wait_perd_dt_to_use_cd => p_rec.wait_perd_dt_to_use_cd,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_wait_perd_dt_to_use_rl
  (p_prtn_elig_id            => p_rec.prtn_elig_id,
   p_wait_perd_dt_to_use_rl  => p_rec.wait_perd_dt_to_use_rl,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number,
   p_business_group_id       => p_rec.business_group_id);
  --
  chk_wait_perd_uom
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_wait_perd_uom         => p_rec.wait_perd_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wait_perd_value
  (p_wait_perd_val       => p_rec.wait_perd_val,
   p_prtn_eff_strt_dt_rl => p_rec.prtn_eff_strt_dt_rl);
  --
  chk_wait_perd_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_wait_perd_rl          => p_rec.wait_perd_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_det_dt_rl      => p_rec.mx_poe_det_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_rl
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_rl             => p_rec.mx_poe_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_apls_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_apls_cd        => p_rec.mx_poe_apls_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_uom
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_uom            => p_rec.mx_poe_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_poe_det_dt_cd
  (p_prtn_elig_id          => p_rec.prtn_elig_id,
   p_mx_poe_det_dt_cd      => p_rec.mx_poe_det_dt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_only_one_fk
  (p_oipl_id               => p_rec.oipl_id,
   p_pl_id                 => p_rec.pl_id,
   p_pgm_id                => p_rec.pgm_id,
   p_ptip_id               => p_rec.ptip_id,
   p_plip_id               => p_rec.plip_id);
  --
  chk_pgm_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_pgm_id                => p_rec.pgm_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_pl_id                 => p_rec.pl_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_oipl_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_oipl_id               => p_rec.oipl_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_ptip_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_ptip_id               => p_rec.ptip_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  chk_plip_id
   (p_prtn_elig_id          => p_rec.prtn_elig_id,
    p_plip_id               => p_rec.plip_id,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_effective_date        => p_effective_date,
    p_business_group_id     => p_rec.business_group_id,
    p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_prtn_eff_end_dt_rl            => p_rec.prtn_eff_end_dt_rl,
     p_oipl_id                       => p_rec.oipl_id,
     p_pl_id                         => p_rec.pl_id,
     p_pgm_id                        => p_rec.pgm_id,
     p_ptip_id                       => p_rec.ptip_id,
     p_plip_id                       => p_rec.plip_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date         => p_validation_start_date,
     p_validation_end_date         => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
    (p_rec              in ben_epa_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode        => p_datetrack_mode,
     p_validation_start_date    => p_validation_start_date,
     p_validation_end_date    => p_validation_end_date,
     p_prtn_elig_id        => p_rec.prtn_elig_id);
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
  (p_prtn_elig_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prtn_elig_f b
    where b.prtn_elig_id      = p_prtn_elig_id
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
                             p_argument       => 'prtn_elig_id',
                             p_argument_value => p_prtn_elig_id);
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
end ben_epa_bus;

/
