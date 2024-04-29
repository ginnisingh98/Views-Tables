--------------------------------------------------------
--  DDL for Package Body BEN_ECR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECR_BUS" as
/* $Header: beecrrhi.pkb 115.21 2002/12/27 20:59:56 pabodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ecr_bus.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_enrt_rt_id >----------------------------|
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
--   enrt_rt_id            PK of record being inserted or updated.
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
Procedure chk_enrt_rt_id(p_enrt_rt_id                  in number,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ecr_shd.api_updating
    (p_enrt_rt_id                  => p_enrt_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_enrt_rt_id,hr_api.g_number)
     <>  ben_ecr_shd.g_old_rec.enrt_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_ecr_shd.constraint_error('BEN_ENRT_RT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_enrt_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ecr_shd.constraint_error('BEN_ENRT_RT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_enrt_rt_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_elig_per_elctbl_chc_id >-------------------|
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
--   p_enrt_rt_id             PK
--   p_elig_per_elctbl_chc_id ID of FK column
--   p_object_version_number  object version number
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
Procedure chk_elig_per_elctbl_chc_id (p_enrt_rt_id             in number,
                                      p_elig_per_elctbl_chc_id in number,
                                      p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_per_elctbl_chc_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_elig_per_elctbl_chc a
    where  a.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_ecr_shd.api_updating
     (p_enrt_rt_id              => p_enrt_rt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_per_elctbl_chc_id,hr_api.g_number)
     <> nvl(ben_ecr_shd.g_old_rec.elig_per_elctbl_chc_id,hr_api.g_number)
     or not l_api_updating) and p_elig_per_elctbl_chc_id is not null then
    --
    -- check if elig_per_elctbl_chc_id value exists in
    -- ben_elig_per_elctbl_chc table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_elig_per_elctbl_chc
        -- table.
        --
        ben_ecr_shd.constraint_error('BEN_ENRT_RT_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_elig_per_elctbl_chc_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_enrt_bnft_id >-----------------------------|
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
--   p_enrt_rt_id             PK
--   p_enrt_bnft_id           ID of FK column
--   p_object_version_number  object version number
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
Procedure chk_enrt_bnft_id(p_enrt_rt_id             in number,
                           p_enrt_bnft_id           in number,
                           p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_bnft_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_enrt_bnft a
    where  a.enrt_bnft_id = p_enrt_bnft_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_ecr_shd.api_updating
     (p_enrt_rt_id              => p_enrt_rt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_enrt_bnft_id,hr_api.g_number)
     <> nvl(ben_ecr_shd.g_old_rec.enrt_bnft_id,hr_api.g_number)
     or not l_api_updating) and p_enrt_bnft_id is not null then
    --
    -- check if enrt_bnft_id value exists in
    -- ben_enrt_bnft table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_enrt_bnft
        -- table.
        --
        ben_ecr_shd.constraint_error('BEN_ENRT_RT_FK3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_enrt_bnft_id;
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
--   enrt_rt_id PK of record being inserted or updated.
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
Procedure chk_rt_strt_dt_rl(p_enrt_rt_id                 in number,
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
  l_api_updating := ben_ecr_shd.api_updating
    (p_enrt_rt_id                => p_enrt_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rt_strt_dt_rl,hr_api.g_number)
      <> ben_ecr_shd.g_old_rec.rt_strt_dt_rl
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
-- |---------------------------< chk_all_flags >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_rt_id                  PK of record being inserted or updated.
--   ctfn_rqd_flag               Value of lookup code.
--   dflt_flag                   Value of lookup code.
--   dflt_pndg_ctfn_flag         Value of lookup code.
--   dsply_on_enrt_flag          Value of lookup code.
--   use_to_calc_net_flx_cr_flag Value of lookup code.
--   entr_val_at_enrt_flag       Value of lookup code.
--   asn_on_enrt_flag            Value of lookup code.
--   rl_crs_only_flag            Value of lookup code.
--   p_entr_ann_val_flag
--   effective_date              effective date
--   object_version_number       Object version number of record being
--                               inserted or updated.
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
Procedure chk_all_flags(p_enrt_rt_id                  in number,
                        p_ctfn_rqd_flag               in varchar2,
                        p_dflt_flag                   in varchar2,
                        p_dflt_pndg_ctfn_flag         in varchar2,
                        p_dsply_on_enrt_flag          in varchar2,
                        p_use_to_calc_net_flx_cr_flag in varchar2,
                        p_entr_val_at_enrt_flag       in varchar2,
                        p_asn_on_enrt_flag            in varchar2,
                        p_rl_crs_only_flag            in varchar2,
                        p_effective_date              in date,
                        p_entr_ann_val_flag           in varchar2,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_flags';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ecr_shd.api_updating
    (p_enrt_rt_id                  => p_enrt_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_entr_ann_val_flag
      <> nvl(ben_ecr_shd.g_old_rec.entr_ann_val_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_entr_ann_val_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_entr_ann_val_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_ctfn_rqd_flag
      <> nvl(ben_ecr_shd.g_old_rec.ctfn_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ctfn_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_ctfn_rqd_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_ecr_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dflt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_dflt_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dflt_pndg_ctfn_flag
      <> nvl(ben_ecr_shd.g_old_rec.dflt_pndg_ctfn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dflt_pndg_ctfn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_dflt_pndg_ctfn_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dsply_on_enrt_flag
      <> nvl(ben_ecr_shd.g_old_rec.dsply_on_enrt_flag,hr_api.g_varchar2)
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
  if (l_api_updating
      and p_use_to_calc_net_flx_cr_flag
      <> nvl(ben_ecr_shd.g_old_rec.use_to_calc_net_flx_cr_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_to_calc_net_flx_cr_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_use_to_calc_net_flx_cr_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_entr_val_at_enrt_flag
      <> nvl(ben_ecr_shd.g_old_rec.entr_val_at_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_entr_val_at_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_entr_val_at_enrt_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_asn_on_enrt_flag
      <> nvl(ben_ecr_shd.g_old_rec.asn_on_enrt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_asn_on_enrt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_asn_on_enrt_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_rl_crs_only_flag
      <> nvl(ben_ecr_shd.g_old_rec.rl_crs_only_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rl_crs_only_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_rl_crs_only_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_flags;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_all_lookups >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup values are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_rt_id                   PK of record being inserted or updated.
--   acty_typ_cd                  Value of lookup code.
--   tx_typ_cd                    Value of lookup code.
--   nnmntry_uom                  Value of lookup code.
--   cmcd_acty_ref_perd_cd        Value of lookup code.
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_all_lookups(p_enrt_rt_id                   in number,
                          p_acty_typ_cd                  in varchar2,
                          p_tx_typ_cd                    in varchar2,
                          p_nnmntry_uom                  in varchar2,
                          p_cmcd_acty_ref_perd_cd        in varchar2,
                          p_effective_date               in date,
                          p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_lookups';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ecr_shd.api_updating
    (p_enrt_rt_id                  => p_enrt_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_typ_cd
      <> nvl(ben_ecr_shd.g_old_rec.acty_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
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
  if (l_api_updating
      and p_tx_typ_cd
      <> nvl(ben_ecr_shd.g_old_rec.tx_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
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
  if (l_api_updating
      and p_nnmntry_uom
      <> nvl(ben_ecr_shd.g_old_rec.nnmntry_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_nnmntry_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_NNMNTRY_UOM',
           p_lookup_code    => p_nnmntry_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_nnmntry_uom);
      fnd_message.set_token('TYPE','BEN_NNMNTRY_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_cmcd_acty_ref_perd_cd
      <> nvl(ben_ecr_shd.g_old_rec.cmcd_acty_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cmcd_acty_ref_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_INFO_RT_FREQ',
           p_lookup_code    => p_cmcd_acty_ref_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_cmcd_acty_ref_perd_cd);
      fnd_message.set_token('TYPE','BEN_ENRT_INFO_RT_FREQ');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_lookups;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_ecr_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
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
  --
  -- Call all supporting business operations
  --
  chk_enrt_rt_id
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_elig_per_elctbl_chc_id
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_elig_per_elctbl_chc_id      => p_rec.elig_per_elctbl_chc_id,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_enrt_bnft_id
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_enrt_bnft_id                => p_rec.enrt_bnft_id,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_enrt_rt_id            => p_rec.enrt_rt_id,
   p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_all_flags
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_ctfn_rqd_flag               => p_rec.ctfn_rqd_flag,
     p_dflt_flag                   => p_rec.dflt_flag,
     p_dflt_pndg_ctfn_flag         => p_rec.dflt_pndg_ctfn_flag,
     p_dsply_on_enrt_flag          => p_rec.dsply_on_enrt_flag,
     p_use_to_calc_net_flx_cr_flag => p_rec.use_to_calc_net_flx_cr_flag,
     p_entr_val_at_enrt_flag       => p_rec.entr_val_at_enrt_flag,
     p_asn_on_enrt_flag            => p_rec.asn_on_enrt_flag,
     p_rl_crs_only_flag            => p_rec.rl_crs_only_flag,
     p_entr_ann_val_flag           => p_rec.entr_ann_val_flag,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_all_lookups
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_acty_typ_cd                 => p_rec.acty_typ_cd,
     p_tx_typ_cd                   => p_rec.tx_typ_cd,
     p_nnmntry_uom                 => p_rec.nnmntry_uom,
     p_cmcd_acty_ref_perd_cd       => p_rec.cmcd_acty_ref_perd_cd,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_ecr_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
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
  --
  -- Call all supporting business operations
  --
  chk_enrt_rt_id
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_elig_per_elctbl_chc_id
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_elig_per_elctbl_chc_id      => p_rec.elig_per_elctbl_chc_id,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_enrt_bnft_id
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_enrt_bnft_id                => p_rec.enrt_bnft_id,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_rt_strt_dt_rl
  (p_enrt_rt_id            => p_rec.enrt_rt_id,
   p_rt_strt_dt_rl         => p_rec.rt_strt_dt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_all_flags
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_ctfn_rqd_flag               => p_rec.ctfn_rqd_flag,
     p_dflt_flag                   => p_rec.dflt_flag,
     p_dflt_pndg_ctfn_flag         => p_rec.dflt_pndg_ctfn_flag,
     p_dsply_on_enrt_flag          => p_rec.dsply_on_enrt_flag,
     p_use_to_calc_net_flx_cr_flag => p_rec.use_to_calc_net_flx_cr_flag,
     p_entr_val_at_enrt_flag       => p_rec.entr_val_at_enrt_flag,
     p_asn_on_enrt_flag            => p_rec.asn_on_enrt_flag,
     p_rl_crs_only_flag            => p_rec.rl_crs_only_flag,
     p_entr_ann_val_flag           => p_rec.entr_ann_val_flag,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_rec.object_version_number);
  --
  chk_all_lookups
    (p_enrt_rt_id                  => p_rec.enrt_rt_id,
     p_acty_typ_cd                 => p_rec.acty_typ_cd,
     p_tx_typ_cd                   => p_rec.tx_typ_cd,
     p_nnmntry_uom                 => p_rec.nnmntry_uom,
     p_cmcd_acty_ref_perd_cd       => p_rec.cmcd_acty_ref_perd_cd,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_ecr_shd.g_rec_type,
                          p_effective_date in date) is
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
  (p_enrt_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_enrt_rt b
    where b.enrt_rt_id        = p_enrt_rt_id
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
                             p_argument       => 'enrt_rt_id',
                             p_argument_value => p_enrt_rt_id);
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
--
end ben_ecr_bus;

/
