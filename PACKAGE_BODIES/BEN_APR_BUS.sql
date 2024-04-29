--------------------------------------------------------
--  DDL for Package Body BEN_APR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APR_BUS" as
/* $Header: beaprrhi.pkb 120.0 2005/05/28 00:26:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_apr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_actl_prem_id >------|
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
--   actl_prem_id PK of record being inserted or updated.
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
Procedure chk_actl_prem_id(p_actl_prem_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_actl_prem_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_apr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_actl_prem_id                => p_actl_prem_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_actl_prem_id,hr_api.g_number)
     <>  ben_apr_shd.g_old_rec.actl_prem_id) then
    --
    -- raise error as PK has changed
    --
    ben_apr_shd.constraint_error('BEN_ACTL_PREM_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_actl_prem_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_apr_shd.constraint_error('BEN_ACTL_PREM_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_actl_prem_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_organization_id >------|
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
--   p_actl_prem_id PK
--   p_organization_id ID of FK column
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
Procedure chk_organization_id (p_actl_prem_id          in number,
                            p_organization_id          in number,
                            p_pl_id                 in number,
                            p_oipl_id               in number,
                            p_effective_date        in date,
                            p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_all_organization_units org,
           ben_popl_org_f pop
    where  org.organization_id = p_organization_id
    and    pop.organization_id = org.organization_id
    and    pop.pl_id = p_pl_id
    and    p_effective_date between
           nvl(org.date_from, p_effective_date) and
           nvl(org.date_to, p_effective_date)
    and    p_effective_date between
           pop.effective_start_date and pop.effective_end_date
    and    pop.business_group_id = p_business_group_id
    and    org.business_group_id = p_business_group_id;
  --
  cursor c2 is
    select null
    from   hr_all_organization_units org,
           ben_popl_org_f pop,
           ben_oipl_f cop
    where  org.organization_id = p_organization_id
    and    pop.organization_id = org.organization_id
    and    cop.oipl_id = p_oipl_id
    and    cop.pl_id = pop.pl_id
    and    p_effective_date between
           nvl(org.date_from, p_effective_date) and
           nvl(org.date_to, p_effective_date)
    and    p_effective_date between
           pop.effective_start_date and pop.effective_end_date
    and    p_effective_date between
           cop.effective_start_date and cop.effective_end_date
    and    pop.business_group_id = p_business_group_id
    and    cop.business_group_id = p_business_group_id
    and    org.business_group_id = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_apr_shd.api_updating
     (p_actl_prem_id            => p_actl_prem_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(ben_apr_shd.g_old_rec.organization_id,hr_api.g_number)
     or not l_api_updating) and p_organization_id is not null then
     --
     -- check if organization_id value exists in hr_all_organization_units
     -- table
     --
     if p_pl_id is not null then
     --
       open c1;
        --
       fetch c1 into l_dummy;
       if c1%notfound then
          --
          close c1;
          --
          -- raise error as FK does not relate to PK in
          -- hr_all_organization_units table.
          --
          fnd_message.set_name('BEN','BEN_92549_NO_ORG_EXIST_PLN');
          fnd_message.set_token('PL_ID',to_char(p_pl_id));
          fnd_message.set_token('BG_ID',to_char(p_business_group_id));
          fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
          fnd_message.raise_error;
          --
       end if;
       --
       close c1;
       --
     elsif p_oipl_id is not null then
     --
       open c2;
        --
       fetch c2 into l_dummy;
       if c2%notfound then
          --
          close c2;
          --
          -- raise error as FK does not relate to PK in
          -- hr_all_organization_units table.
          --
          fnd_message.set_name('BEN','BEN_92550_NO_ORG_EXIST_OIPL');
          fnd_message.set_token('OIPL_ID',to_char(p_oipl_id));
          fnd_message.set_token('BG_ID',to_char(p_business_group_id));
          fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
          fnd_message.raise_error;
          --
       end if;
       --
       close c2;
       --
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;

--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   rndg_rl Value of formula rule id.
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
Procedure chk_rndg_rl(p_actl_prem_id                in number,
                      p_rndg_rl                     in number,
                      p_business_group_id           in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_rndg_rl
    and    ff.formula_type_id = -169
    and    pbg.business_group_id = p_business_group_id
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
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_apr_shd.g_old_rec.rndg_rl
      or not l_api_updating)
      and p_rndg_rl is not null then
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
        fnd_message.set_token('ID',p_rndg_rl);
        fnd_message.set_token('TYPE_ID',-169);
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
end chk_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_val_calc_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   val_calc_rl Value of formula rule id.
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
Procedure chk_val_calc_rl(p_actl_prem_id                in number,
                          p_val_calc_rl                 in number,
                          p_business_group_id           in number,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_val_calc_rl
    and    ff.formula_type_id = -507
    and    pbg.business_group_id = p_business_group_id
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
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_val_calc_rl,hr_api.g_number)
      <> ben_apr_shd.g_old_rec.val_calc_rl
      or not l_api_updating)
      and p_val_calc_rl is not null then
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
        fnd_message.set_token('ID',p_val_calc_rl);
        fnd_message.set_token('TYPE_ID',-507);
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
end chk_val_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_vrbl_rt_add_on_calc_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   vrbl_rt_add_on_calc_rl Value of formula rule id.
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
Procedure chk_vrbl_rt_add_on_calc_rl(p_actl_prem_id                in number,
                      p_vrbl_rt_add_on_calc_rl                     in number,
                      p_business_group_id           in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrbl_rt_add_on_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_vrbl_rt_add_on_calc_rl
    and    ff.formula_type_id = -529
    and    pbg.business_group_id = p_business_group_id
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
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_vrbl_rt_add_on_calc_rl,hr_api.g_number)
      <> ben_apr_shd.g_old_rec.vrbl_rt_add_on_calc_rl
      or not l_api_updating)
      and p_vrbl_rt_add_on_calc_rl is not null then
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
        fnd_message.set_token('ID',p_vrbl_rt_add_on_calc_rl);
        fnd_message.set_token('TYPE_ID',-529);
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
end chk_vrbl_rt_add_on_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   rndg_cd Value of lookup code.
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
Procedure chk_rndg_cd(p_actl_prem_id                in number,
                            p_rndg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_apr_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rndg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91041_INVALID_RNDG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prdct_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   prdct_cd Value of lookup code.
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
Procedure chk_prdct_cd(p_actl_prem_id                in number,
                            p_prdct_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prdct_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prdct_cd
      <> nvl(ben_apr_shd.g_old_rec.prdct_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prdct_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRDCT',
           p_lookup_code    => p_prdct_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91606_INVALID_PRODUCT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prdct_cd;
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
--   actl_prem_id PK of record being inserted or updated.
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
Procedure chk_mlt_cd(p_actl_prem_id                in number,
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
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mlt_cd
      <> nvl(ben_apr_shd.g_old_rec.mlt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mlt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTL_PREM_MLT',
           p_lookup_code    => p_mlt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91607_INVALID_MLT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
    -- if mlt_cd is 'TPLPC' then defer the action.
    if (p_mlt_cd = 'TPLPC') then
       fnd_message.set_name('BEN','BEN_92504_PREM_CALC_MTHD_DFRD');
       fnd_message.raise_error;
    end if;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mlt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtl_mo_det_mthd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   prtl_mo_det_mthd_cd Value of lookup code.
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
Procedure chk_prtl_mo_det_mthd_cd(p_actl_prem_id                in number,
                            p_prtl_mo_det_mthd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtl_mo_det_mthd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prtl_mo_det_mthd_cd
      <> nvl(ben_apr_shd.g_old_rec.prtl_mo_det_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtl_mo_det_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRTL_MO_DET_MTHD',
           p_lookup_code    => p_prtl_mo_det_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_92239_INVLD_PRTL_MO_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtl_mo_det_mthd_cd;
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
--   actl_prem_id PK of record being inserted or updated.
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
Procedure chk_rt_typ_cd(p_actl_prem_id                in number,
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
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_typ_cd
      <> nvl(ben_apr_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TYP',
           p_lookup_code    => p_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
	fnd_message.set_name('BEN','BEN_91192_RT_TYP_CD');
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
--   actl_prem_id PK of record being inserted or updated.
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
Procedure chk_bnft_rt_typ_cd(p_actl_prem_id                in number,
                            p_bnft_rt_typ_cd              in varchar2,
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
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnft_rt_typ_cd
      <> nvl(ben_apr_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnft_rt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNFT_RT_TYP',
           p_lookup_code    => p_bnft_rt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91608_INVALID_BNFT_RT_TYP');
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
--   actl_prem_id PK of record being inserted or updated.
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
Procedure chk_acty_ref_perd_cd(p_actl_prem_id                in number,
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
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_acty_ref_perd_cd
      <> nvl(ben_apr_shd.g_old_rec.acty_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_acty_ref_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_REF_PERD',
           p_lookup_code    => p_acty_ref_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91299_INV_ACTY_REF_PERD_CD');
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the name field is unique
--   on insert and on update.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   name that is beeing inserted ot updated to.
--   effective_date Effective Date of session
--   business group ID
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
--   HR Development Internal use only.
--
Procedure chk_name(p_actl_prem_id                in number,
                   p_name                        in varchar2,
                   p_effective_date              in date,
                   p_validation_start_date         in date,
                   p_validation_end_date           in date,
                   p_business_group_id           in number,
                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor csr_name is
     select null
        from ben_actl_prem_f
        where name = p_name
          and actl_prem_id <> nvl(p_actl_prem_id, hr_api.g_number)
          and business_group_id + 0 = p_business_group_id
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_name <> ben_apr_shd.g_old_rec.name) or
      not l_api_updating then
    --
    hr_utility.set_location('name is :'||p_name, 10);
    --
    -- check if this name already exist
    --
    open csr_name;
    fetch csr_name into l_exists;
    if csr_name%found then
      close csr_name;
      --
      -- raise error as UK1 is violated
      --
      hr_utility.set_location('before message'||p_name,10);
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_name;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mlt_cd_rt_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mlt_cd and rt_typ_cd
--   items are conditionally dependent.  The VALUE of mlt_cd can only
--   be CVG for Coverage or null and if rt_typ_cd = 'FLAT' then
--   mlt_cd must be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id PK of record being inserted or updated.
--   mlt_cd.
--   rt_typ_cd.
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
--Procedure chk_mlt_cd_rt_typ_cd(p_actl_prem_id             in number,
--                            p_mlt_cd                      in varchar2,
--		            p_rt_typ_cd                   in varchar2,
--                           p_effective_date              in date,
--                            p_object_version_number       in number) is
  --
--  l_proc         varchar2(72) := g_package||'chk_mlt_cd_rt_typ_cd';
--  l_api_updating boolean;
  --
--Begin
  --
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
--  l_api_updating := ben_apr_shd.api_updating
--    (p_actl_prem_id                => p_actl_prem_id,
--     p_effective_date              => p_effective_date,
--     p_object_version_number       => p_object_version_number);
  --
    -- Multiple Code must be equal to CVG or null.
--    If P_MLT_CD <> 'CVG' and P_MLT_CD is not null  then
--       fnd_message.set_name('BEN','BEN_91602_APR_MLT_CD');
--       fnd_message.raise_error;
--    end if;
--     If rate type code is flat then multiple code must be null.
--    If P_RT_TYP_CD = 'FLAT' and P_MLT_CD is not null  then
--       fnd_message.set_name('BEN','BEN_91603_APR_RT_TYP_MLT_CD');
--       fnd_message.raise_error;
--    end if;
    --
--  end if;
  --
--  hr_utility.set_location('Leaving:'||l_proc,10);
  --
--end chk_mlt_cd_rt_typ_cd;

--
-- ----------------------------------------------------------------------------
-- |------< chk_code_rule_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Rule is only allowed to
--   have a value if the value of the Code = 'Rule', and if code is
--   = RL then p_rule must have a value. If cd = 'WASHRULE' then num
--   must have a value otherwise num must be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   P_CODE value of code item.
--   P_RULE value of rule item
--   P_NUM value of rule item
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
Procedure chk_code_rule_num(p_code      in varchar2,
                            p_num       in number,
                            p_rule       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_code_rule_num';
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
  if p_code <> 'WASHRULE' and p_num is not null then
      --
      fnd_message.set_name('BEN','BEN_92270_NTWSHRL_NUM_NTNULL');
      fnd_message.raise_error;
      --
  elsif p_code = 'WASHRULE' and p_num is null then
      --
      fnd_message.set_name('BEN','BEN_92271_NTWSHRL_NUM_NULL');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_code_rule_num;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_asgnmt_cd_lvl_mlt_pyr >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the:
--   prem_asnmt_cd = ENRT then prem_asnmt_lvl_cd must be PRTT
--   prem_asnmt_cd = ENRT then mlt_cd can be FLFX,CVG,NSVU,RL
--   prem_asnmt_cd = PROC then prem_asnmt_lvl_cd cannot be PRTT
--   prem_asnmt_cd = PROC then mlt_cd can be NSVU, TPLPC, TTLPRTT or TTLCVG
--   mlt_cd = TPLC then prem_pyr_cd must be ER
--   prem_asnmt_cd <> ENRT then cr_lkbk_val must be null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_prem_asnmt_cd
--   p_prem_asnmt_lvl_cd
--    p_mlt_cd
--   p_cr_lkbk_val
--   p_prem_pyr_cd
--
-- Post Success
--   Processing continues
--
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_asgnmt_cd_lvl_mlt_pyr(p_prem_asnmt_cd        in varchar2,
				    p_prem_asnmt_lvl_cd    in varchar2,
				    p_mlt_cd               in varchar2,
                                    p_cr_lkbk_val          in number,
                                    p_prem_pyr_cd          in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_asgnmt_cd_lvl_mlt_pyr' ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_prem_asnmt_cd = 'ENRT' and p_prem_asnmt_lvl_cd <> 'PRTT')
  then
                fnd_message.set_name('BEN', 'BEN_92272_ASGN_ENRT_LVL_NPRTT');
                fnd_message.raise_error;
  end if;
   if (p_prem_asnmt_cd = 'ENRT'
       and p_mlt_cd not in ('NSVU', 'RL', 'FLFX','CVG'))  then
                fnd_message.set_name('BEN', 'BEN_92274_ASGN_PROC_MLT_BAD');
                fnd_message.raise_error;
  end if;

  if (p_prem_asnmt_cd = 'PROC' and p_prem_asnmt_lvl_cd = 'PRTT')  then
                fnd_message.set_name('BEN', 'BEN_92273_ASGN_PROC_LVL_PRTT');
                fnd_message.raise_error;
  end if;

   if (p_prem_asnmt_cd = 'PROC'
       and p_mlt_cd not in ('NSVU', 'TPLPC', 'TTLPRTT','TTLCVG'))  then
                fnd_message.set_name('BEN', 'BEN_92274_ASGN_PROC_MLT_BAD');
                fnd_message.raise_error;
  end if;

  if (p_mlt_cd = 'TPLC' and p_prem_pyr_cd <> 'ER')
  then
                fnd_message.set_name('BEN', 'BEN_92275_MLT_TPLC_PYR_NOTER');
                fnd_message.raise_error;
  end if;

  if (p_prem_asnmt_cd <> 'ENRT' and p_cr_lkbk_val is not null)
  then
                fnd_message.set_name('BEN', 'BEN_92276_ASGN_ENRT_LKBK_VAL');
                fnd_message.raise_error;
  end if;
  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_asgnmt_cd_lvl_mlt_pyr;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_lmt_rl_val >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the code/rule dependency as the
--   following:
--              If lwr_RL not null then lwr_val must be null.
--              If upr_RL not null then upr_val must be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   lwr_lmt_calc_rl
--   lwr_lmt_val
--   upr_lmt_calc_rl
--   upr_lmt_val
--
--
-- Post Success
--   Processing continues
--
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_lwr_lmt_rl_val(p_upr_lmt_calc_rl      in number,
			     p_upr_lmt_val         in number,
			     p_lwr_lmt_calc_rl      in number,
			     p_lwr_lmt_val         in number) is
   --
  l_proc         varchar2(72) := g_package||'chk_lwr_lmt_rl_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if    (p_upr_lmt_calc_rl is not null and p_upr_lmt_val is not null)
  then
                fnd_message.set_name('BEN', 'BEN_92277_UPR_LMT_RL_VAL');
                fnd_message.raise_error;
  end if;

  if    (p_lwr_lmt_calc_rl is not null and p_lwr_lmt_val is not null)
  then
                fnd_message.set_name('BEN', 'BEN_92278_LWR_LMT_RL_VAL');
                fnd_message.raise_error;
  end if;
  --
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_lwr_lmt_rl_val;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_lwr_lmt_upr_lmt >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the lwr_lmt value is
--   less than the upr_lmt value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_lwr_lmt_val  minimum value
--   p_upr_lmt_val  maximum value
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
Procedure chk_lwr_lmt_upr_lmt(p_lwr_lmt_val   in number,
                              p_upr_lmt_val   in number) is
  --
  l_proc varchar2(72) := g_package||'chk_lwr_lmt_upr_lmt';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check the values
  -- note: Don't want an error if either one is null
  --
  if (p_lwr_lmt_val is not null and p_upr_lmt_val is not null) and
     (p_lwr_lmt_val >= p_upr_lmt_val) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_92279_LWR_LESS_NOT_EQ_UPR');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_lwr_lmt_upr_lmt;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_asg_vrbl_prfl_mlt_tmt >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the mld_cd and vrbl_rt_trtmt_cd for
--   vrbl_rt_prfl assigned to this premium are valid values.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id          PK of record being inserted or updated.
--   prem_asnmt_cd
--   effective_date        Session date of record.
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_asg_vrbl_prfl_mlt_tmt(p_actl_prem_id             in number,
                                   p_prem_asnmt_cd             in varchar2,
                                   p_effective_date            in date,
                                   p_business_group_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_asg_vrbl_prfl_mlt_tmt';
  l_api_updating boolean;
  l_mlt_cd hr_lookups.lookup_code%TYPE; -- UTF varchar2(30);
  l_vrbl_rt_trtmt_cd hr_lookups.lookup_code%TYPE; -- UTF varchar2(30);
  --
  cursor c1 is
    select vpf.mlt_cd, vpf.vrbl_rt_trtmt_cd
    from   ben_vrbl_rt_prfl_f vpf,
           ben_actl_prem_vrbl_rt_f apv
    where  apv.business_group_id +0 = p_business_group_id
    and    vpf.business_group_id +0 = p_business_group_id
    and    apv.actl_prem_id 	    = p_actl_prem_id
    and    vpf.vrbl_rt_prfl_id      = apv.vrbl_rt_prfl_id
    and    p_effective_date
           between vpf.effective_start_date
           and     vpf.effective_end_date
    and    p_effective_date + 1
           between apv.effective_start_date
           and     apv.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_prem_asnmt_cd is not null then
    --
    -- Check if vrbl_rt_prfl is assigned to premium and do checks.
    --
    open c1;
      --
      fetch c1 into l_mlt_cd, l_vrbl_rt_trtmt_cd;
      if c1%found then
        --
        --
        --close c1;
        if p_prem_asnmt_cd = 'PROC' then
           if l_vrbl_rt_trtmt_cd <> 'RPLC' then
	--
        -- raise an error as invalid values.
        --
              fnd_message.set_name('BEN','BEN_92280_ASGNCD_VRBL_PRFL_TMT');
              fnd_message.raise_error;
           end if;
           if l_mlt_cd <> 'TTLPRTT' then
	--
        -- raise an error as invalid values.
        --
              fnd_message.set_name('BEN','BEN_92281_ASGNCD_VRBL_PRFL_ML1');
              fnd_message.raise_error;
           end if;
         elsif (p_prem_asnmt_cd = 'ENRT' and
                l_mlt_cd not in ('FLFX', 'CVG', 'NSVU', 'TPLPC', 'RL')) then
--
        -- raise an error as invalid values.
        --
                fnd_message.set_name('BEN','BEN_92282_ASGNCD_VRBL_PRFL_ML2');
                fnd_message.raise_error;

         end if;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_asg_vrbl_prfl_mlt_tmt;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_lookups >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup values are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id                 PK of record being inserted or updated.
--   p_prem_asnmt_cd              Value of lookup code.
--   p_prem_asnmt_lvl_cd          Value of lookup code.
--   p_actl_prem_typ_cd           Value of lookup code.
--   p_prem_pyr_cd                Value of lookup code.
--   p_prsptv_r_rtsptv_cd         Value of lookup code.
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
Procedure chk_lookups(p_actl_prem_id                     in number,
                          p_prem_asnmt_cd                in varchar2,
                          p_prem_asnmt_lvl_cd            in varchar2,
                          p_actl_prem_typ_cd             in varchar2,
                          p_prem_pyr_cd                  in varchar2,
                          p_prsptv_r_rtsptv_cd           in varchar2,
                          p_effective_date               in date,
                          p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_lookups';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prem_asnmt_cd
      <> nvl(ben_apr_shd.g_old_rec.prem_asnmt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prem_asnmt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PREM_ASNMT',
           p_lookup_code    => p_prem_asnmt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prem_asnmt_cd');
      fnd_message.set_token('TYPE', 'BEN_PREM_ASNMT');
      fnd_message.raise_error;
      --
      --
    end if;
    --
  end if;
  --
 if (l_api_updating
      and p_prem_asnmt_lvl_cd
      <> nvl(ben_apr_shd.g_old_rec.prem_asnmt_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prem_asnmt_lvl_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PREM_ASNMT_LVL',
           p_lookup_code    => p_prem_asnmt_lvl_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prem_asnmt_lvl_cd');
      fnd_message.set_token('TYPE', 'BEN_PREM_ASNMT_LVL');
      fnd_message.raise_error;
      --
      --
    end if;
    --
  end if;
--
 if (l_api_updating
      and p_actl_prem_typ_cd
      <> nvl(ben_apr_shd.g_old_rec.actl_prem_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_actl_prem_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PREM_TYP',
           p_lookup_code    => p_actl_prem_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_actl_prem_typ_cd');
      fnd_message.set_token('TYPE', 'BEN_PREM_TYP');
      fnd_message.raise_error;
      --
      --
    end if;
    --
  end if;
--
 if (l_api_updating
      and p_prem_pyr_cd
      <> nvl(ben_apr_shd.g_old_rec.prem_pyr_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prem_pyr_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PREM_PYR',
           p_lookup_code    => p_prem_pyr_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prem_pyr_cd');
      fnd_message.set_token('TYPE', 'BEN_PREM_PYR');
      fnd_message.raise_error;
      --
      --
    end if;
    --
  end if;
--
 if (l_api_updating
      and p_prsptv_r_rtsptv_cd
      <> nvl(ben_apr_shd.g_old_rec.prsptv_r_rtsptv_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prsptv_r_rtsptv_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRSPCTV_R_RTSPCTV',
           p_lookup_code    => p_prsptv_r_rtsptv_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prsptv_r_rtsptv_cd');
      fnd_message.set_token('TYPE', 'BEN_PRSPCTV_R_RTSPCTV');
      fnd_message.raise_error;
      --
      --
    end if;
    --
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_lookups;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_rules >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rules are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id               PK of record being inserted or updated.
--   lwr_lmt_calc_rl            Value of formula rule id.
--   upr_lmt_calc_rl            Value of formula rule id.
--   prtl_mo_det_mthd_rl        Value of formula rule id.
--   vrbl_rt_add_on_calc_rl     Value of formula rule id.
--   effective_date             effective date
--   object_version_number      Object version number of record being
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
Procedure chk_rules(p_actl_prem_id                      in number,
                        p_business_group_id          in number,
                        p_lwr_lmt_calc_rl            in number,
                        p_upr_lmt_calc_rl            in number,
                        p_prtl_mo_det_mthd_rl        in number,
--                        p_vrbl_rt_add_on_calc_rl     in number,
                        p_effective_date             in date,
                        p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rules';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1(p_rule number,p_rule_type_id number) is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_rule
    and    ff.formula_type_id = p_rule_type_id
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id,p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code,pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_apr_shd.api_updating
    (p_actl_prem_id                => p_actl_prem_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_lwr_lmt_calc_rl,hr_api.g_number)
      <> ben_apr_shd.g_old_rec.lwr_lmt_calc_rl
      or not l_api_updating)
      and p_lwr_lmt_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_lwr_lmt_calc_rl,-515);
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
        fnd_message.set_token('ID',p_lwr_lmt_calc_rl);
        fnd_message.set_token('TYPE_ID',-515);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_upr_lmt_calc_rl,hr_api.g_number)
      <> ben_apr_shd.g_old_rec.upr_lmt_calc_rl
      or not l_api_updating)
      and p_upr_lmt_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_upr_lmt_calc_rl,-512);
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
        fnd_message.set_token('ID',p_upr_lmt_calc_rl);
        fnd_message.set_token('TYPE_ID',-512);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  --
  if (l_api_updating
      and nvl(p_prtl_mo_det_mthd_rl,hr_api.g_number)
      <> ben_apr_shd.g_old_rec.prtl_mo_det_mthd_rl
      or not l_api_updating)
      and p_prtl_mo_det_mthd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_prtl_mo_det_mthd_rl,-165);
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
        fnd_message.set_token('ID',p_prtl_mo_det_mthd_rl);
        fnd_message.set_token('TYPE_ID',-165);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
--  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rules;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_child_data >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that
--   1) If parent actual premium has PREM_ASNMT_CD=PROC, then there should not
--      be any row in the child table(costing table).
--
--   2) There should not be any row in the child table (costing table ),
--      if default costing in parent is null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id          actl_prem_id.
--   business_group_id     Business group id of record being inserted.
--   prem_asnmt_cd         Premium assignment code
--   cost_allocation_keyflex_id      Default costing
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
--
Procedure chk_child_data(p_actl_prem_id               in number,
                          p_business_group_id         in number,
                          p_prem_asnmt_cd             in varchar2,
                          p_cost_allocation_keyflex_id in number) is

l_proc         varchar2(72) := g_package||'chk_child_data' ;
l_actl_prem_id  number;
  --
  cursor c1 is
    select a.actl_prem_id from ben_prem_cstg_by_sgmt_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.actl_prem_id = p_actl_prem_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    -- Check if prem_asnmt_cd  is 'PROC'
    --
    if p_prem_asnmt_cd = 'PROC'or  p_cost_allocation_keyflex_id  is null then
       --
        open c1;
        fetch c1 into l_actl_prem_id ;
        --
      if c1%found  then
        close c1;
        --
        -- raise an error
        --
        if p_prem_asnmt_cd = 'PROC' then
          fnd_message.set_name('BEN','BEN_92529_NO_COST');
          fnd_message.raise_error;
        else
          fnd_message.set_name('BEN','BEN_92530_DFLT_RQD');
          fnd_message.raise_error;
        end if;
        --
      end if;
      --
      close c1;
    end if;
      --

  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_child_data;

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
            (p_comp_lvl_fctr_id              in number default hr_api.g_number,
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
/*
    If ((nvl(p_comp_lvl_fctr_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_comp_lvl_fctr',
             p_base_key_column => 'comp_lvl_fctr_id',
             p_base_key_value  => p_comp_lvl_fctr_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_comp_lvl_fctr';
      Raise l_integrity_error;
    End If;
*/
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
    ben_utility.parent_integrity_error(p_table_name => l_table_name);
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
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
            (p_actl_prem_id		in number,
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
       p_argument       => 'actl_prem_id',
       p_argument_value => p_actl_prem_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_oipl_f',
           p_base_key_column => 'actl_prem_id',
           p_base_key_value  => p_actl_prem_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_oipl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_actl_prem_vrbl_rt_f',
           p_base_key_column => 'actl_prem_id',
           p_base_key_value  => p_actl_prem_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_actl_prem_vrbl_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtt_prem_f',
           p_base_key_column => 'actl_prem_id',
           p_base_key_value  => p_actl_prem_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtt_prem_f';
      Raise l_rows_exist;
    End If;

--    If (dt_api.rows_exist
--          (p_base_table_name => 'ben_actl_prem_vrbl_rt_rl_f',
--           p_base_key_column => 'actl_prem_id',
--           p_base_key_value  => p_actl_prem_id,
--           p_from_date       => p_validation_start_date,
--           p_to_date         => p_validation_end_date)) Then
--      l_table_name := 'ben_actl_prem_vrbl_rt_rl_f';
--      Raise l_rows_exist;
--    End If;
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
    ben_utility.child_exists_error(p_table_name => l_table_name);

  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
end dt_delete_validate;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_mlt_cd_dependencies >------|
-- ----------------------------------------------------------------------------
--
-- Description
--
--
-- In Parameters
--   mlt_cd
--   val
--   mn_val
--   mx_val
--   incrmt_val
--   dflt_val
--   rt_typ_cd
--   bnfts_rt_typ_cd
--   val_calc_rl
--   comp_lvl_fctr_id
--   acty_base_rt_id
--   effective_date
--   object_version_number
--
Procedure chk_mlt_cd_dependencies(p_mlt_cd                in varchar2,
                                  p_val                   in number,
                                  p_pl_id                 in number,
                                  p_oipl_id               in number,
                                  p_rt_typ_cd             in varchar2,
                                  p_bnft_rt_typ_cd        in varchar2,
                                  p_actl_prem_id          in number,
                                  p_comp_lvl_fctr_id      in number,
                                  p_business_group_id     in number,
                                  p_val_calc_rl           in number,
                                  p_effective_date        in date,
                                  p_object_version_number in number
                                 ) is
  l_proc  varchar2(72) := g_package||'chk_mlt_cd_dependencies';
  l_api_updating boolean;
  l_dummy        ben_cvg_amt_calc_mthd_f.name%type := null; --UTF8 Change Bug 2254683
  --
  -- Bug 2695254 changed the ben_pl to ben_pl_f and ben_oipl to ben_oipl_f
  --
  cursor c1 is
    select cvg.name
    from   ben_pl_f coa,ben_cvg_amt_calc_mthd_f cvg
    where  coa.pl_id = p_pl_id
    and    coa.pl_id = cvg.pl_id (+)
    and    coa.business_group_id = p_business_group_id
union
    select cvg.name
    from   ben_oipl_f coa,ben_cvg_amt_calc_mthd_f cvg
    where  coa.oipl_id = p_oipl_id
    and    coa.oipl_id = cvg.oipl_id (+)
    and    coa.business_group_id = p_business_group_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := ben_apr_shd.api_updating
     (p_actl_prem_id          => p_actl_prem_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  if (l_api_updating and
      (nvl(p_mlt_cd,hr_api.g_varchar2)
           <> nvl(ben_apr_shd.g_old_rec.mlt_cd,hr_api.g_varchar2) or
       nvl(p_val,hr_api.g_number)
           <> nvl(ben_apr_shd.g_old_rec.val,hr_api.g_number) or
       nvl(p_pl_id,hr_api.g_number)
           <> nvl(ben_apr_shd.g_old_rec.pl_id,hr_api.g_number) or
       nvl(p_oipl_id,hr_api.g_number)
           <> nvl(ben_apr_shd.g_old_rec.oipl_id,hr_api.g_number) or
       nvl(p_rt_typ_cd,hr_api.g_varchar2)
           <> nvl(ben_apr_shd.g_old_rec.rt_typ_cd,hr_api.g_varchar2) or
       nvl(p_bnft_rt_typ_cd,hr_api.g_varchar2)
           <> nvl(ben_apr_shd.g_old_rec.bnft_rt_typ_cd,hr_api.g_varchar2)
      ) or  not l_api_updating)
  then
    if p_mlt_cd is NULL then
      fnd_message.set_name('BEN','BEN_91535_MLT_CD_RQD');
      fnd_message.raise_error;
    end if;
    if p_val is NULL then
       if p_mlt_cd in ('FLFX','CVG','TTLCVG','TTLPRTT') then
          fnd_message.set_name('BEN','BEN_91536_VAL_RQD');
          fnd_message.raise_error;
       end if;
    end if;
    if p_rt_typ_cd is not NULL then
       if p_mlt_cd in ('FLFX','CVG','RL') then
            fnd_message.set_name('BEN','BEN_91545_RT_TYP_CD_SPEC');
            fnd_message.raise_error;
       end if;
    end if;
    if p_bnft_rt_typ_cd is NULL then
       if p_mlt_cd in ('CVG','TTLCVG','TTLPRTT') then
          fnd_message.set_name('BEN','BEN_91546_BNFTS_TYP_CD_RQD');
          fnd_message.raise_error;
      end if;
    else
       if p_mlt_cd in ('FLFX','RL') then
          fnd_message.set_name('BEN','BEN_91547_BNFTS_TYP_CD_SPEC');
          fnd_message.raise_error;
       end if;
    end if;
    if p_mlt_cd = 'CVG' then
       open c1;
       fetch c1 into l_dummy;
       if l_dummy is null then
          fnd_message.set_name('BEN','BEN_92473_COVERAGE_REQUIRED');
          fnd_message.raise_error;
       end if;
       close c1;
    end if;
    if p_mlt_cd = 'RL' and p_val_calc_rl is null then
          fnd_message.set_name('BEN','BEN_91548_VAL_CALC_RL_RQD');
          fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
end chk_mlt_cd_dependencies;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_apr_shd.g_rec_type,
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
  chk_actl_prem_id
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_organization_id       => p_rec.organization_id,
   p_pl_id                 => p_rec.pl_id,
   p_oipl_id               => p_rec.oipl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_rndg_rl               => p_rec.rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_calc_rl
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_val_calc_rl           => p_rec.val_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrbl_rt_add_on_calc_rl
  (p_actl_prem_id           => p_rec.actl_prem_id,
   p_vrbl_rt_add_on_calc_rl => p_rec.vrbl_rt_add_on_calc_rl,
   p_business_group_id      => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_rndg_cd               => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prdct_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_prdct_cd         => p_rec.prdct_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mlt_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_mlt_cd         => p_rec.mlt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtl_mo_det_mthd_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_prtl_mo_det_mthd_cd   => p_rec.prtl_mo_det_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_rt_typ_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_rt_typ_cd         => p_rec.rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_rt_typ_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_ref_perd_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_acty_ref_perd_cd         => p_rec.acty_ref_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
--
  chk_lookups(
  p_actl_prem_id            => p_rec.actl_prem_id,
  p_prem_asnmt_cd              => p_rec.prem_asnmt_cd,
  p_prem_asnmt_lvl_cd          => p_rec.prem_asnmt_lvl_cd,
  p_actl_prem_typ_cd           => p_rec.actl_prem_typ_cd,
  p_prem_pyr_cd                => p_rec.prem_pyr_cd,
  p_prsptv_r_rtsptv_cd         => p_rec.prsptv_r_rtsptv_cd,
  p_effective_date          => p_effective_date,
  p_object_version_number  => p_rec.object_version_number
     );
  --
  chk_rules(
  p_actl_prem_id            => p_rec.actl_prem_id,
  p_business_group_id      => p_rec.business_group_id,
  p_lwr_lmt_calc_rl         => p_rec.lwr_lmt_calc_rl,
  p_upr_lmt_calc_rl         => p_rec.upr_lmt_calc_rl,
  p_prtl_mo_det_mthd_rl     => p_rec.prtl_mo_det_mthd_rl,
  p_effective_date          => p_effective_date,
  p_object_version_number  => p_rec.object_version_number
     );
--
  chk_name
  (p_actl_prem_id            => p_rec.actl_prem_id,
   p_name                    => p_rec.name,
   p_effective_date          => p_effective_date,
   p_validation_start_date   => p_validation_start_date,
   p_validation_end_date     => p_validation_end_date,
   p_business_group_id       => p_rec.business_group_id,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_mlt_cd_dependencies
     (p_mlt_cd                 => p_rec.mlt_cd,
      p_val                    => p_rec.val,
      p_pl_id                  => p_rec.pl_id,
      p_oipl_id                => p_rec.oipl_id,
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
      p_actl_prem_id           => p_rec.actl_prem_id,
      p_business_group_id      => p_rec.business_group_id,
      p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );
--
  chk_code_rule_num
  (p_code                      => p_rec.prtl_mo_det_mthd_cd,
   p_num                       => p_rec.wsh_rl_dy_mo_num,
   p_rule                      => p_rec.prtl_mo_det_mthd_rl);
--
  chk_asgnmt_cd_lvl_mlt_pyr
  (p_prem_asnmt_cd              => p_rec.prem_asnmt_cd,
   p_prem_asnmt_lvl_cd          => p_rec.prem_asnmt_lvl_cd,
   p_mlt_cd                     => p_rec.mlt_cd,
   p_cr_lkbk_val                => p_rec.cr_lkbk_val,
   p_prem_pyr_cd                => p_rec.prem_pyr_cd);
--
  chk_lwr_lmt_rl_val
  (p_upr_lmt_calc_rl             => p_rec.upr_lmt_calc_rl,
   p_upr_lmt_val                => p_rec.upr_lmt_val,
   p_lwr_lmt_calc_rl             => p_rec.lwr_lmt_calc_rl,
   p_lwr_lmt_val                => p_rec.lwr_lmt_val);
--
  chk_lwr_lmt_upr_lmt
  (p_lwr_lmt_val                => p_rec.lwr_lmt_val,
   p_upr_lmt_val                => p_rec.upr_lmt_val);
--
  chk_asg_vrbl_prfl_mlt_tmt
  (p_actl_prem_id            => p_rec.actl_prem_id,
   p_prem_asnmt_cd           => p_rec.prem_asnmt_cd,
   p_effective_date          => p_effective_date,
   p_business_group_id       => p_rec.business_group_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_apr_shd.g_rec_type,
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
  chk_actl_prem_id
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_organization_id
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_organization_id       => p_rec.organization_id,
   p_pl_id                 => p_rec.pl_id,
   p_oipl_id               => p_rec.oipl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_rndg_rl               => p_rec.rndg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_calc_rl
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_val_calc_rl           => p_rec.val_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrbl_rt_add_on_calc_rl
  (p_actl_prem_id           => p_rec.actl_prem_id,
   p_vrbl_rt_add_on_calc_rl => p_rec.vrbl_rt_add_on_calc_rl,
   p_business_group_id      => p_rec.business_group_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prdct_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_prdct_cd         => p_rec.prdct_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mlt_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_mlt_cd         => p_rec.mlt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtl_mo_det_mthd_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_prtl_mo_det_mthd_cd   => p_rec.prtl_mo_det_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_rt_typ_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_rt_typ_cd         => p_rec.rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bnft_rt_typ_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_acty_ref_perd_cd
  (p_actl_prem_id          => p_rec.actl_prem_id,
   p_acty_ref_perd_cd         => p_rec.acty_ref_perd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
--
  chk_lookups(
  p_actl_prem_id            => p_rec.actl_prem_id,
  p_prem_asnmt_cd              => p_rec.prem_asnmt_cd,
  p_prem_asnmt_lvl_cd          => p_rec.prem_asnmt_lvl_cd,
  p_actl_prem_typ_cd           => p_rec.actl_prem_typ_cd,
  p_prem_pyr_cd                => p_rec.prem_pyr_cd,
  p_prsptv_r_rtsptv_cd         => p_rec.prsptv_r_rtsptv_cd,
  p_effective_date          => p_effective_date,
  p_object_version_number  => p_rec.object_version_number
     );
  --
  chk_rules(
  p_actl_prem_id            => p_rec.actl_prem_id,
  p_business_group_id      => p_rec.business_group_id,
  p_lwr_lmt_calc_rl         => p_rec.lwr_lmt_calc_rl,
  p_upr_lmt_calc_rl         => p_rec.upr_lmt_calc_rl,
  p_prtl_mo_det_mthd_rl     => p_rec.prtl_mo_det_mthd_rl,
  p_effective_date          => p_effective_date,
  p_object_version_number  => p_rec.object_version_number
     );
--
  chk_name
  (p_actl_prem_id            => p_rec.actl_prem_id,
   p_name                    => p_rec.name,
   p_effective_date          => p_effective_date,
   p_validation_start_date   => p_validation_start_date,
   p_validation_end_date     => p_validation_end_date,
   p_business_group_id       => p_rec.business_group_id,
   p_object_version_number   => p_rec.object_version_number);
  --
--  chk_mlt_cd_rt_typ_cd
--  (p_actl_prem_id          => p_rec.actl_prem_id,
--   p_mlt_cd                => p_rec.mlt_cd,
--   p_rt_typ_cd             => p_rec.rt_typ_cd,
--   p_effective_date        => p_effective_date,
--   p_object_version_number => p_rec.object_version_number);
--
  chk_code_rule_num
  (p_code                      => p_rec.prtl_mo_det_mthd_cd,
   p_num                       => p_rec.wsh_rl_dy_mo_num,
   p_rule                      => p_rec.prtl_mo_det_mthd_rl);
--
  chk_asgnmt_cd_lvl_mlt_pyr
  (p_prem_asnmt_cd              => p_rec.prem_asnmt_cd,
   p_prem_asnmt_lvl_cd          => p_rec.prem_asnmt_lvl_cd,
   p_mlt_cd                     => p_rec.mlt_cd,
   p_cr_lkbk_val                => p_rec.cr_lkbk_val,
   p_prem_pyr_cd                => p_rec.prem_pyr_cd);
--
  chk_lwr_lmt_rl_val
  (p_upr_lmt_calc_rl             => p_rec.upr_lmt_calc_rl,
   p_upr_lmt_val                => p_rec.upr_lmt_val,
   p_lwr_lmt_calc_rl             => p_rec.lwr_lmt_calc_rl,
   p_lwr_lmt_val                => p_rec.lwr_lmt_val);
--
  chk_lwr_lmt_upr_lmt
  (p_lwr_lmt_val                => p_rec.lwr_lmt_val,
   p_upr_lmt_val                => p_rec.upr_lmt_val);
--
  chk_asg_vrbl_prfl_mlt_tmt
  (p_actl_prem_id            => p_rec.actl_prem_id,
   p_prem_asnmt_cd           => p_rec.prem_asnmt_cd,
   p_effective_date          => p_effective_date,
   p_business_group_id       => p_rec.business_group_id);
--
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
     p_datetrack_mode            => p_datetrack_mode,
     p_validation_start_date	 => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  chk_mlt_cd_dependencies
     (p_mlt_cd                 => p_rec.mlt_cd,
      p_val                    => p_rec.val,
      p_pl_id                  => p_rec.pl_id,
      p_oipl_id                => p_rec.oipl_id,
      p_rt_typ_cd              => p_rec.rt_typ_cd,
      p_bnft_rt_typ_cd         => p_rec.bnft_rt_typ_cd,
      p_actl_prem_id           => p_rec.actl_prem_id,
      p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
      p_business_group_id      => p_rec.business_group_id,
      p_val_calc_rl            => p_rec.val_calc_rl,
      p_effective_date         => p_effective_date,
      p_object_version_number  => p_rec.object_version_number
     );
  --
  chk_child_data
  (p_actl_prem_id         =>p_rec.actl_prem_id,
   p_business_group_id      => p_rec.business_group_id,
   p_prem_asnmt_cd           => p_rec.prem_asnmt_cd,
   p_cost_allocation_keyflex_id => p_rec.cost_allocation_keyflex_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_apr_shd.g_rec_type,
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
     p_actl_prem_id		=> p_rec.actl_prem_id);
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
  (p_actl_prem_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_actl_prem_f b
    where b.actl_prem_id      = p_actl_prem_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.legislation_code%TYPE; -- UTF8 varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'actl_prem_id',
                             p_argument_value => p_actl_prem_id);
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
end ben_apr_bus;

/
