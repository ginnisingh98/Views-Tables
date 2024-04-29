--------------------------------------------------------
--  DDL for Package Body BEN_PRV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRV_BUS" as
/* $Header: beprvrhi.pkb 120.0.12000000.3 2007/07/01 19:16:05 mmudigon noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prv_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_rt_val_id >------|
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
--   prtt_rt_val_id PK of record being inserted or updated.
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
Procedure chk_prtt_rt_val_id(p_prtt_rt_val_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_rt_val_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtt_rt_val_id,hr_api.g_number)
     <>  ben_prv_shd.g_old_rec.prtt_rt_val_id) then
    --
    -- raise error as PK has changed
    --
    ben_prv_shd.constraint_error('BEN_PRTT_RT_VAL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prtt_rt_val_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_prv_shd.constraint_error('BEN_PRTT_RT_VAL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prtt_rt_val_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_enrt_rslt_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtt_rt_val_id PK
--   p_prtt_enrt_rslt_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_prtt_enrt_rslt_id (p_prtt_rt_val_id          in number,
                                 p_prtt_enrt_rslt_id          in number,
                                 p_effective_date        in date,
                                 p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_enrt_rslt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_prtt_enrt_rslt_f a
    where  a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_prv_shd.api_updating
     (p_prtt_rt_val_id            => p_prtt_rt_val_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtt_enrt_rslt_id,hr_api.g_number)
     <> nvl(ben_prv_shd.g_old_rec.prtt_enrt_rslt_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if prtt_enrt_rslt_id value exists in ben_prtt_enrt_rslt_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_prtt_enrt_rslt_f
        -- table.
        --
        ben_prv_shd.constraint_error('BEN_PRTT_RT_VAL_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_prtt_enrt_rslt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_element_entry_value_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtt_rt_val_id PK
--   p_element_entry_value_id ID of FK column
--   p_effective_date Session Date of record
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
Procedure chk_element_entry_value_id (p_prtt_rt_val_id          in number,
                            p_element_entry_value_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_element_entry_value_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_element_entry_values_f a
    where  a.element_entry_value_id = p_element_entry_value_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_prv_shd.api_updating
     (p_prtt_rt_val_id            => p_prtt_rt_val_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_element_entry_value_id,hr_api.g_number)
     <> nvl(ben_prv_shd.g_old_rec.element_entry_value_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if element_entry_value_id value exists in pay_element_entry_values_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in pay_element_entry_values_f
        -- table.
        --
        ben_prv_shd.constraint_error('BEN_PRTT_RT_VAL_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_element_entry_value_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cmcd_ref_perd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   cmcd_ref_perd_cd Value of lookup code.
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
Procedure chk_cmcd_ref_perd_cd(p_prtt_rt_val_id                in number,
                            p_cmcd_ref_perd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cmcd_ref_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cmcd_ref_perd_cd
      <> nvl(ben_prv_shd.g_old_rec.cmcd_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cmcd_ref_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_INFO_RT_FREQ',
           p_lookup_code    => p_cmcd_ref_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_cmcd_ref_perd_cd);
      fnd_message.set_token('TYPE','BEN_ENRT_INFO_RT_FREQ');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cmcd_ref_perd_cd;
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_rt_val_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   prtt_rt_val_stat_cd Value of lookup code.
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
Procedure chk_prtt_rt_val_stat_cd(p_prtt_rt_val_id                in number,
                            p_prtt_rt_val_stat_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_rt_val_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtt_rt_val_stat_cd
      <> nvl(ben_prv_shd.g_old_rec.prtt_rt_val_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtt_rt_val_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    -- The prtt-rt-val status code shares a lookup with the result status code.
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTT_ENRT_RSLT_STAT',
           p_lookup_code    => p_prtt_rt_val_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_prtt_rt_val_stat_cd);
      fnd_message.set_token('TYPE','BEN_PRTT_ENRT_RSLT_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtt_rt_val_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnft_rt_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   bnft_rt_typ_cd Value of lookup code.
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
Procedure chk_bnft_rt_typ_cd(p_prtt_rt_val_id                in number,
                            p_bnft_rt_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_rt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_rt_typ_cd
      <> nvl(ben_prv_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TYP',
           p_lookup_code    => p_bnft_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_bnft_rt_typ_cd);
      fnd_message.set_token('TYPE','BEN_RT_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bnft_rt_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_acty_ref_perd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   acty_ref_perd_cd Value of lookup code.
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
Procedure chk_acty_ref_perd_cd(p_prtt_rt_val_id                in number,
                            p_acty_ref_perd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_ref_perd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_ref_perd_cd
      <> nvl(ben_prv_shd.g_old_rec.acty_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_ref_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_REF_PERD',
           p_lookup_code    => p_acty_ref_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_acty_ref_perd_cd);
      fnd_message.set_token('TYPE','BEN_ACTY_REF_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_acty_ref_perd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mlt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   mlt_cd Value of lookup code.
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
Procedure chk_mlt_cd(p_prtt_rt_val_id                in number,
                            p_mlt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mlt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mlt_cd
      <> nvl(ben_prv_shd.g_old_rec.mlt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mlt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MLT',
           p_lookup_code    => p_mlt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_mlt_cd);
      fnd_message.set_token('TYPE','BEN_MLT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mlt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_acty_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   acty_typ_cd Value of lookup code.
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
Procedure chk_acty_typ_cd(p_prtt_rt_val_id                in number,
                            p_acty_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_typ_cd
      <> nvl(ben_prv_shd.g_old_rec.acty_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_TYP',
           p_lookup_code    => p_acty_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_acty_typ_cd);
      fnd_message.set_token('TYPE','BEN_ACTY_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_acty_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_tx_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   tx_typ_cd Value of lookup code.
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
Procedure chk_tx_typ_cd(p_prtt_rt_val_id                in number,
                            p_tx_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tx_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tx_typ_cd
      <> nvl(ben_prv_shd.g_old_rec.tx_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tx_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TX_TYP',
           p_lookup_code    => p_tx_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_tx_typ_cd);
      fnd_message.set_token('TYPE','BEN_TX_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tx_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   rt_typ_cd Value of lookup code.
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
Procedure chk_rt_typ_cd(p_prtt_rt_val_id                in number,
                            p_rt_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_typ_cd
      <> nvl(ben_prv_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TYP',
           p_lookup_code    => p_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_rt_typ_cd);
      fnd_message.set_token('TYPE','BEN_RT_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_ovridn_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   rt_ovridn_flag Value of lookup code.
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
Procedure chk_rt_ovridn_flag(p_prtt_rt_val_id                in number,
                            p_rt_ovridn_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_ovridn_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_ovridn_flag
      <> nvl(ben_prv_shd.g_old_rec.rt_ovridn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rt_ovridn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_rt_ovridn_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_ovridn_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dsply_on_enrt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
--   dsply_on_enrt_flag Value of lookup code.
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
Procedure chk_dsply_on_enrt_flag(p_prtt_rt_val_id                in number,
                            p_dsply_on_enrt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dsply_on_enrt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dsply_on_enrt_flag
      <> nvl(ben_prv_shd.g_old_rec.dsply_on_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dsply_on_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_dsply_on_enrt_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dsply_on_enrt_flag;

--
-- ----------------------------------------------------------------------------
-- |------< chk_ann_min_max_val >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the value is in the range and
--   checks if the min and max should be updated.
--
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_ann_min_max_val(
            p_enrt_rt_id                  in number default null,
            p_prtt_rt_val_id              in number,
            p_ann_rt_val                  in number,
            p_rt_strt_dt                  in date,
            p_effective_date              in date,
            p_object_version_number       in number) is
  --
  l_proc             varchar2(72) := g_package||'chk_ann_min_max_val';
  l_api_updating     boolean;
  l_ann_mn_elcn_val  number := null;
  l_ann_mx_elcn_val  number := null;
  l_pln_name	     varchar2(600) :=null;
  --
  cursor c1 is
    select ecr.ann_mn_elcn_val, ecr.ann_mx_elcn_val, ecr.acty_base_rt_id,
           ecr.elig_per_elctbl_chc_id, ecr.enrt_bnft_id, ecr.object_version_number,
           ecr.entr_ann_val_flag, dsply_mn_elcn_val, dsply_mx_elcn_val,incrmt_elcn_val
      From ben_enrt_rt ecr
     where ecr.enrt_rt_id=p_enrt_rt_id;
   l_c1 c1%rowtype;

  cursor c2 (p_enrt_bnft_id number) is
    select enb.elig_per_elctbl_chc_id
    from   ben_enrt_bnft enb
    where  enb.enrt_bnft_id = p_enrt_bnft_id;

  cursor c3 (p_elig_per_elctbl_chc_id number) is
    select pil.person_id
    from   ben_elig_per_elctbl_chc epe, ben_per_in_ler pil
    where  epe.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id
    and    epe.per_in_ler_id = pil.per_in_ler_id;
  l_c3 c3%rowtype;

  cursor c_chc is
     select decode (ecr.elig_per_elctbl_chc_id ,
                null,
                enb.elig_per_elctbl_chc_id,
                ecr.elig_per_elctbl_chc_id
               )
     from   ben_enrt_rt ecr,
      	    ben_enrt_bnft enb
     where  ecr.enrt_rt_id = p_enrt_rt_id and
            enb.enrt_bnft_id(+) = ecr.enrt_bnft_id;

  cursor c_pln
          (c_elig_per_elctbl_chc_id  in number )
     is
          select pln.name || ' '|| opt.name
     from   ben_elig_per_elctbl_chc epe,
            ben_pl_f                pln,
            ben_oipl_f              oipl,
            ben_opt_f               opt
     where  epe.elig_per_elctbl_chc_id =c_elig_per_elctbl_chc_id
     and    epe.pl_id                  = pln.pl_id
     and    epe.oipl_id                = oipl.oipl_id(+)
     and    oipl.opt_id                = opt.opt_id(+)
     and    p_effective_date between
            pln.effective_start_date and pln.effective_end_date
     and    p_effective_date between
            oipl.effective_start_date(+) and oipl.effective_end_date(+)
     and    p_effective_date between
            opt.effective_start_date(+) and opt.effective_end_date(+);

  -- 4272271
/*
  cursor c_abr(c_acty_base_rt_id number) is
    select abr.ann_mn_elcn_val, abr.ann_mx_elcn_val
      from ben_acty_base_rt_f abr
     where abr.acty_base_rt_id = c_acty_base_rt_id
       and p_effective_date between abr.effective_start_date
                                and abr.effective_end_date;
*/

  l_ptd_balance number := 0;
  l_clm_balance number := 0;
  l_elig_per_elctbl_chc_id number :=0;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id           => p_prtt_rt_val_id,
     p_object_version_number    => p_object_version_number);
  --
  If (l_api_updating
      and p_ann_rt_val
      <> nvl(ben_prv_shd.g_old_rec.ann_rt_val,hr_api.g_number)
      or not l_api_updating)
      and p_ann_rt_val is not null then
    --
    -- get the annual min max values from enrt_rt If enrt_rt_id is not NULL
    --
    If (p_enrt_rt_id is not NULL) then
      open c1;
      fetch c1 into l_c1 ;
      close c1;
      --
      l_ann_mn_elcn_val := l_c1.ann_mn_elcn_val;
      l_ann_mx_elcn_val := l_c1.ann_mx_elcn_val;
      --
      if l_c1.entr_ann_val_flag = 'Y' then
        -- re-prorate and check balances as these could have changed since enrt_rt
        -- was created.
        -- Bug: 4272271. Commented out the prorate_min_max as proration was happening on already prorated values.
/*
        -- Bug: 4272271. Pick l_ann_mn_elcn_val, l_ann_mx_elcn_val from
        -- ben_acty_base_rt_f, rather than enrt_rt to avoid proration happening on already prorated value.
        open c_abr(l_c1.acty_base_rt_id);
        fetch c_abr into l_ann_mn_elcn_val, l_ann_mx_elcn_val;
        if c_abr%notfound then
          l_ann_mn_elcn_val := l_c1.ann_mn_elcn_val;
          l_ann_mx_elcn_val := l_c1.ann_mx_elcn_val;
        end if;
        close c_abr;
        -- End 4272271
*/

        if l_c1.elig_per_elctbl_chc_id is null then
           -- get the chc id from the bnft row
           open c2(p_enrt_bnft_id => l_c1.enrt_bnft_id);
           fetch c2 into l_c1.elig_per_elctbl_chc_id;
           close c2;
        end if;

        -- get the person id
        open c3(p_elig_per_elctbl_chc_id => l_c1.elig_per_elctbl_chc_id);
        fetch c3 into l_c3;
        close c3;

       -- Bug: 4272271. Commented out the prorate_min_max as proration was happening on already prorated values.
      /*  ben_distribute_rates.prorate_min_max
            (p_person_id                => l_c3.person_id
            ,p_effective_date           => p_effective_date
            ,p_elig_per_elctbl_chc_id   => l_c1.elig_per_elctbl_chc_id
            ,p_acty_base_rt_id          => l_c1.acty_base_rt_id
            ,p_rt_strt_dt               => p_rt_strt_dt
            ,p_ann_mn_val               => l_ann_mn_elcn_val
            ,p_ann_mx_val               => l_ann_mx_elcn_val ) ;
       */

        -- Also, check that their period-to-date payments and claims do not
        -- force the minimum and maximum to be different.
        ben_distribute_rates.compare_balances
            (p_person_id            => l_c3.person_id
            ,p_effective_date       => p_effective_date
            ,p_elig_per_elctbl_chc_id  => l_c1.elig_per_elctbl_chc_id
            ,p_acty_base_rt_id      => l_c1.acty_base_rt_id
            ,p_ann_mn_val           => l_ann_mn_elcn_val
            ,p_ann_mx_val           => l_ann_mx_elcn_val
            ,p_perform_edit_flag    => 'Y'
            ,p_entered_ann_val      => p_ann_rt_val
            ,p_ptd_balance          => l_ptd_balance
            ,p_clm_balance          => l_clm_balance ) ;

        -- Bug: 4272271. Since prorate_min_max is not called, no need to call update_enrollment_rate

        -- If the values changed, update ben_enrt_rt so that the display will be
        -- correct.
       /*
        if l_ann_mn_elcn_val <> l_c1.ann_mn_elcn_val or
           l_ann_mx_elcn_val <> l_c1.ann_mx_elcn_val then
            l_c1.dsply_mn_elcn_val := l_ann_mn_elcn_val;
            l_c1.dsply_mx_elcn_val := l_ann_mx_elcn_val;

            ben_enrollment_rate_api.update_enrollment_rate
              (p_VALIDATE              => false
              ,p_ENRT_RT_ID            => p_enrt_rt_id
              ,p_ANN_MN_ELCN_VAL       => l_ann_mn_elcn_val
              ,p_ANN_MX_ELCN_VAL       => l_ann_mx_elcn_val
              ,p_DSPLY_MN_ELCN_VAL     => l_c1.dsply_mn_elcn_val
              ,p_DSPLY_MX_ELCN_VAL     => l_c1.dsply_mx_elcn_val
              ,p_OBJECT_VERSION_NUMBER => l_c1.object_version_number
              ,p_EFFECTIVE_DATE        => p_EFFECTIVE_DATE);
        end if; */

      end if;
      --
      -- check if the value is in range.
      --
      If (l_ann_mn_elcn_val is not NULL and p_ann_rt_val < l_ann_mn_elcn_val)
          or (l_ann_mx_elcn_val is not NULL and p_ann_rt_val > l_ann_mx_elcn_val) then

        -- Bug 2385186 add pl-opt name to error message
        open c_chc;
        fetch c_chc into l_elig_per_elctbl_chc_id;
        close c_chc;
        open c_pln (c_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id);
        fetch c_pln into l_pln_name;
        close c_pln;
        fnd_message.set_name('BEN','BEN_91939_NOT_IN_RANGE');
        fnd_message.set_token('MIN',l_ann_mn_elcn_val);
        fnd_message.set_token('MAX',l_ann_mx_elcn_val);
        fnd_message.set_token('PLOPT',l_pln_name);
        fnd_message.raise_error;
      END IF;
      --
      -- Bug 2438533 Added this for checking annual increment values
      --
      IF (mod(p_ann_rt_val,l_c1.incrmt_elcn_val)<>0) then
        -- bug # 1699585 passing the plan name in the error message
       open c_chc;
               fetch c_chc into l_elig_per_elctbl_chc_id;
               close c_chc;
               open c_pln (c_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id);
               fetch c_pln into l_pln_name;
        close c_pln;
	-- end # 1699585

        --
        -- raise error is not multiple of increment
        --
        fnd_message.set_name('BEN','BEN_91932_NOT_INCREMENT');
        fnd_message.set_token('INCREMENT', l_c1.incrmt_elcn_val);
        fnd_message.set_token('PLAN', l_pln_name);

        fnd_message.raise_error;
      END IF;
    End if;
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ann_min_max_val;
-- ----------------------------------------------------------------------------
-- |------< chk_min_max_incrt_val >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the value is in the range and
--   conforms to the increment value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_rt_id FK of enrolment rate to ckeck against.
--   prtt_rt_val_id PK of record being inserted or updated.
--   rt_val Value of lookup code.
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
Procedure chk_min_max_incrt_val(
			    p_enrt_rt_id                  in number default null,
			    p_prtt_rt_val_id              in number,
                            p_rt_val                      in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_min_max_incrt_val';
  l_api_updating boolean;
  l_min number;
  l_ann_min number;
  l_ann_max number;
  l_max number;
  l_incrt number;
  l_acty_base_rt_id number ;
  l_entr_val_at_enrt_flag varchar2(30) ;
  l_rt_mlt_cd             varchar2(30) ;
  l_entr_ann_val_flag     varchar2(30) ;
  l_pln_name 		 varchar2(600);
  --
  cursor c_enrt_rt is
     select mn_elcn_val,
	mx_elcn_val,
	ann_mn_elcn_val,
	ann_mx_elcn_val,
	incrmt_elcn_val,
        acty_base_rt_id,
        rt_mlt_cd ,
        entr_val_at_enrt_flag,
        entr_ann_val_flag
     from ben_enrt_rt
	where enrt_rt_id=p_enrt_rt_id  ;


   cursor c_abr (p_acty_base_rt_id number , p_effective_date date)  is
      select use_calc_acty_bs_rt_flag
      from ben_acty_base_rt_f
      where  acty_base_rt_id = p_acty_base_rt_id
      and p_effective_date between effective_start_date and effective_end_date ;

    cursor c_chc is
     select decode (ecr.elig_per_elctbl_chc_id ,
                    null,
                    enb.elig_per_elctbl_chc_id,
                    ecr.elig_per_elctbl_chc_id
                   )
    from ben_enrt_rt ecr,
         ben_enrt_bnft enb
    where ecr.enrt_rt_id = p_enrt_rt_id and
          enb.enrt_bnft_id (+) = ecr.enrt_bnft_id;

   cursor c_pln
           (c_elig_per_elctbl_chc_id  in number )
      is
   select pln.name || ' '|| opt.name
   from   ben_elig_per_elctbl_chc epe,
                ben_pl_f                pln,
                ben_oipl_f              oipl,
                ben_opt_f               opt
   where  epe.elig_per_elctbl_chc_id =c_elig_per_elctbl_chc_id
   and    epe.pl_id                  = pln.pl_id
   and    epe.oipl_id                = oipl.oipl_id(+)
   and    oipl.opt_id                = opt.opt_id(+)
   and    p_effective_date between
          pln.effective_start_date and pln.effective_end_date
   and    p_effective_date between
          oipl.effective_start_date(+) and oipl.effective_end_date(+)
   and    p_effective_date between
          opt.effective_start_date(+) and opt.effective_end_date(+);

  l_use_calc_acty_bs_rt_flag  varchar2(30) ;
  l_elig_per_elctbl_chc_id number :=0;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_val
      <> nvl(ben_prv_shd.g_old_rec.rt_val,hr_api.g_number)
      or not l_api_updating)
      and p_rt_val is not null then
    --
    -- get the min max and incrt values from enrt_rt
    --
    open c_enrt_rt;
    fetch c_enrt_rt into
	l_min,
	l_max,
	l_ann_min,
	l_ann_max,
	l_incrt,
        l_acty_base_rt_id,
        l_rt_mlt_cd ,
        l_entr_val_at_enrt_flag,
        l_entr_ann_val_flag ;

    close c_enrt_rt;

    open c_abr(l_acty_base_rt_id , p_effective_Date);
    fetch c_abr into l_use_calc_acty_bs_rt_flag;
    close c_abr ;
    --
    -- check if value is in range.
    --
    -- if the entr_at_enrt and calc value tne dont check the min and max
    --- the chekc is done at benactbr the calc result is higher than the min and max
    --
    --Bug 2438533 If enter annual flag is 'Y' then we have another check procedure
    -- for annual min and max. we can bipass this
    -- this is handled in the chk procedure chk_ann_min_max_val
    --
    If ( l_use_calc_acty_bs_rt_flag = 'Y' and l_entr_val_at_enrt_flag = 'Y'
         and l_rt_mlt_cd <> 'FLFX') or l_entr_ann_val_flag = 'Y'  then
      null  ;
      -- bug   1480407
    else
       if ((l_min is not null and p_rt_val <l_min) or
       	(l_max is not null and p_rt_val >l_max)) then
        --
        -- raise error as is not in range
        -- Bug 2385186 add pl-opt name to error message

        open c_chc;
	        fetch c_chc into l_elig_per_elctbl_chc_id;
	        close c_chc;
	        open c_pln (c_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id);
	        fetch c_pln into l_pln_name;
        close c_pln;
        fnd_message.set_name('BEN','BEN_91939_NOT_IN_RANGE');
        fnd_message.set_token('MIN', l_min);
        fnd_message.set_token('MAX', l_max);
        fnd_message.set_token('PLOPT', l_pln_name);
        fnd_message.raise_error;
        --
      elsif (mod(p_rt_val,l_incrt)<>0) then
        --
        -- raise error is not multiple of increment
        --
      open c_chc;
              fetch c_chc into l_elig_per_elctbl_chc_id;
              close c_chc;
              open c_pln (c_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id);
              fetch c_pln into l_pln_name;
      close c_pln;
	-- end # 1699585

        --
        -- raise error is not multiple of increment
        --
        fnd_message.set_name('BEN','BEN_91932_NOT_INCREMENT');
        fnd_message.set_token('INCREMENT', l_incrt);
        fnd_message.set_token('PLAN', l_pln_name);
        fnd_message.raise_error;
      end if;
    end if ;
  elsif p_enrt_rt_id is not null and p_rt_val is null  then
    --
    -- Bug : 3649575
    -- Raise an error even when p_rt_val is null and Enter Value At Enrollment is checked.
    --
    open c_enrt_rt;
    fetch c_enrt_rt into
	l_min,
	l_max,
	l_ann_min,
	l_ann_max,
	l_incrt,
        l_acty_base_rt_id,
        l_rt_mlt_cd ,
        l_entr_val_at_enrt_flag,
        l_entr_ann_val_flag ;
    close c_enrt_rt;
    --
    if l_entr_val_at_enrt_flag = 'Y' then
      --
      open c_chc;
        fetch c_chc into l_elig_per_elctbl_chc_id;
      close c_chc;
      --
      open c_pln (c_elig_per_elctbl_chc_id => l_elig_per_elctbl_chc_id);
        fetch c_pln into l_pln_name;
      close c_pln;
      --
      fnd_message.set_name('BEN','BEN_91939_NOT_IN_RANGE');
      fnd_message.set_token('PLOPT', l_pln_name);
      --
      if l_entr_ann_val_flag = 'N' then
        --
	fnd_message.set_token('MIN',l_min);
	fnd_message.set_token('MAX',l_max);
	--
      elsif l_entr_ann_val_flag = 'Y' then
        --
	fnd_message.set_token('MIN',l_ann_min);
	fnd_message.set_token('MAX',l_ann_max);
	--
      end if;
      --
      fnd_message.raise_error;
    --
    end if;
  --
  end if;

  hr_utility.set_location('Leaving:'||l_proc,10);

end chk_min_max_incrt_val;
--
-- ----------------------------------------------------------------------------
-- |------< chk_acty_base_rt_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that abr is valid
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_rt_val_id PK of record being inserted or updated.
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
Procedure chk_acty_base_rt_id(p_prtt_rt_val_id            in number,
                              p_object_version_number     in number,
                              p_acty_base_rt_id           in number,
                              p_effective_date            in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_base_rt_id';
  l_api_updating boolean;
  l_error        boolean := false;
  l_dummy        varchar2(1);
  --
  cursor c_abr is
  select null
    from ben_acty_base_rt_f
   where acty_base_rt_id = p_acty_base_rt_id
     and p_effective_date between effective_start_date
     and effective_end_date;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prv_shd.api_updating
    (p_prtt_rt_val_id                => p_prtt_rt_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_acty_base_rt_id,-1)
      <> nvl(ben_prv_shd.g_old_rec.acty_base_rt_id,hr_api.g_number)
      or not l_api_updating) then

      if p_acty_base_rt_id is not null then
         open c_abr;
         fetch c_abr into l_dummy;
         l_error := c_abr%notfound;
         close c_abr;
      else
         l_error := true;
      end if;
      --
      if l_error then
         fnd_message.set_name('BEN','BEN_91723_NO_ENRT_RT_ABR_FOUND');
         fnd_message.set_token('PROC',l_proc);
         fnd_message.set_token('ACTY_BASE_RT_ID',to_char(p_acty_base_rt_id));
         fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
         fnd_message.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_acty_base_rt_id;
--
/*--Bug#5088571
-- ----------------------------------------------------------------------------
-- |-------------< chk_rt_strt_end_dt >----------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check whether the Rate Start date is later than Rate End date.
--
procedure chk_rt_strt_end_dt
                         (p_rt_strt_dt                in date,
                       	  p_rt_end_dt                 in date,
			  p_prtt_enrt_rslt_id         in number
        		  ) is
--
  l_proc         varchar2(72) := g_package||'chk_rt_strt_end_dt';
  l_person_id    number;
  l_message_name varchar2(500) := 'BEN_94592_RT_STRT_GT_END_DT';
--
cursor c_person_id is
 select person_id
 from   ben_prtt_enrt_rslt_f pen
 where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_person_id;
  fetch c_person_id into l_person_id;
  close c_person_id;
  --
  if p_rt_strt_dt > p_rt_end_dt then
     benutils.write(p_text=>fnd_message.get);
     ben_warnings.load_warning
           (p_application_short_name  => 'BEN'
            ,p_message_name            => l_message_name
            ,p_parma                   => 'Rate End Date' || ' ' || fnd_date.date_to_displaydate(p_rt_end_dt)
	    ,p_parmb    	       => 'Rate Start Date' ||' '|| fnd_date.date_to_displaydate(p_rt_strt_dt)
	    ,p_person_id               =>  l_person_id
	    );
  end if;
 --
  hr_utility.set_location('Leaving:'||l_proc,10);
 --
end chk_rt_strt_end_dt;
--
--Bug#5088571 */
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_prv_shd.g_rec_type,p_effective_date in date ) is

  l_proc  varchar2(72) := g_package||'insert_validate';
--  p_effective_date date := sysdate;
  l_global_pil_rec   ben_global_enrt.g_global_pil_rec_type;
  l_effective_date   date;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call context sensitive validate bgp cache routine
  --
  ben_batch_dt_api.batch_validate_bgp_id
    (p_business_group_id => p_rec.business_group_id
    );
  --
/*
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
*/

  if ben_manage_life_events.fonm = 'Y' then
     l_effective_date  := ben_manage_life_events.g_fonm_rt_strt_dt;
  else
     ben_global_enrt.get_pil
       (p_per_in_ler_id          => p_rec.per_in_ler_id
       ,p_global_pil_rec         => l_global_pil_rec);
     l_effective_date  := l_global_pil_rec.lf_evt_ocrd_dt;
  end if;

  l_effective_date := nvl(l_effective_date,p_effective_date);

  chk_prtt_rt_val_id
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_object_version_number => p_rec.object_version_number);

  chk_cmcd_ref_perd_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_cmcd_ref_perd_cd         => p_rec.cmcd_ref_perd_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_prtt_rt_val_stat_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_prtt_rt_val_stat_cd         => p_rec.prtt_rt_val_stat_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);


  chk_bnft_rt_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_acty_ref_perd_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_acty_ref_perd_cd         => p_rec.acty_ref_perd_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_mlt_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_mlt_cd         => p_rec.mlt_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_acty_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_acty_typ_cd         => p_rec.acty_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_tx_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_tx_typ_cd         => p_rec.tx_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_rt_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_rt_typ_cd         => p_rec.rt_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_min_max_incrt_val(
	p_enrt_rt_id			=>p_rec.enrt_rt_id,
	p_prtt_rt_val_id 		=>p_rec.prtt_rt_val_id,
	p_rt_val 			=>p_rec.rt_val,
        p_effective_date 		=>l_effective_date,
        p_object_version_number 	=>p_rec.object_version_number
  );

  chk_ann_min_max_val
  (p_enrt_rt_id            => p_rec.enrt_rt_id,
   p_prtt_rt_val_id        => p_rec.prtt_rt_val_id,
   p_ann_rt_val            => p_rec.ann_rt_val,
   p_rt_strt_dt            => p_rec.rt_strt_dt,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number
  );

  chk_rt_ovridn_flag
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_rt_ovridn_flag         => p_rec.rt_ovridn_flag,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_dsply_on_enrt_flag
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_dsply_on_enrt_flag         => p_rec.dsply_on_enrt_flag,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_acty_base_rt_id
  (p_prtt_rt_val_id        => p_rec.prtt_rt_val_id,
   p_acty_base_rt_id       => p_rec.acty_base_rt_id,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

/* chk_rt_strt_end_dt
  (p_rt_strt_dt             => p_rec.rt_strt_dt,
   p_rt_end_dt              => p_rec.rt_end_dt,
   p_prtt_enrt_rslt_id      => p_rec.prtt_enrt_rslt_id
  );*/
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;

-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_prv_shd.g_rec_type,p_effective_date  in date) is

  l_proc  varchar2(72) := g_package||'update_validate';
--  p_effective_date date := sysdate;
  l_global_pil_rec   ben_global_enrt.g_global_pil_rec_type;
  l_effective_date   date;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call context sensitive validate bgp cache routine
  --
  ben_batch_dt_api.batch_validate_bgp_id
    (p_business_group_id => p_rec.business_group_id
    );
  --
/*
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
*/
  if ben_manage_life_events.fonm = 'Y' then
     l_effective_date  := ben_manage_life_events.g_fonm_rt_strt_dt;
  else
     ben_global_enrt.get_pil
       (p_per_in_ler_id          => p_rec.per_in_ler_id
       ,p_global_pil_rec         => l_global_pil_rec);
     l_effective_date  := l_global_pil_rec.lf_evt_ocrd_dt;
  end if;

  l_effective_date := nvl(l_effective_date,p_effective_date);

  chk_prtt_rt_val_id
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_object_version_number => p_rec.object_version_number);

  chk_cmcd_ref_perd_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_cmcd_ref_perd_cd         => p_rec.cmcd_ref_perd_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_prtt_rt_val_stat_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_prtt_rt_val_stat_cd         => p_rec.prtt_rt_val_stat_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_bnft_rt_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_acty_ref_perd_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_acty_ref_perd_cd         => p_rec.acty_ref_perd_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_mlt_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_mlt_cd         => p_rec.mlt_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_acty_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_acty_typ_cd         => p_rec.acty_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_tx_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_tx_typ_cd         => p_rec.tx_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_rt_typ_cd
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_rt_typ_cd         => p_rec.rt_typ_cd,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_min_max_incrt_val(
	p_enrt_rt_id			=>p_rec.enrt_rt_id,
	p_prtt_rt_val_id 		=>p_rec.prtt_rt_val_id,
	p_rt_val 			=>p_rec.rt_val,
        p_effective_date 		=>l_effective_date,
        p_object_version_number 	=>p_rec.object_version_number
  );

  chk_ann_min_max_val
  (p_enrt_rt_id            => p_rec.enrt_rt_id,
   p_prtt_rt_val_id        => p_rec.prtt_rt_val_id,
   p_ann_rt_val            => p_rec.ann_rt_val,
   p_rt_strt_dt            => p_rec.rt_strt_dt,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number
  );

  chk_rt_ovridn_flag
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_rt_ovridn_flag         => p_rec.rt_ovridn_flag,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_dsply_on_enrt_flag
  (p_prtt_rt_val_id          => p_rec.prtt_rt_val_id,
   p_dsply_on_enrt_flag         => p_rec.dsply_on_enrt_flag,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_acty_base_rt_id
  (p_prtt_rt_val_id        => p_rec.prtt_rt_val_id,
   p_acty_base_rt_id       => p_rec.acty_base_rt_id,
   p_effective_date        => l_effective_date,
   p_object_version_number => p_rec.object_version_number);

/* chk_rt_strt_end_dt
   (p_rt_strt_dt             => p_rec.rt_strt_dt,
   p_rt_end_dt              => p_rec.rt_end_dt,
   p_prtt_enrt_rslt_id      => p_rec.prtt_enrt_rslt_id
   );*/
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;

-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_prv_shd.g_rec_type) is
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_prtt_rt_val_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prtt_rt_val b
    where b.prtt_rt_val_id      = p_prtt_rt_val_id
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
                             p_argument       => 'prtt_rt_val_id',
                             p_argument_value => p_prtt_rt_val_id);
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
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
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


end ben_prv_bus;

/
