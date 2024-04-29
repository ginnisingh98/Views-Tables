--------------------------------------------------------
--  DDL for Package Body BEN_CLF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLF_BUS" as
/* $Header: beclfrhi.pkb 120.0 2005/05/28 01:04:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_clf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_lvl_fctr_id >------|
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
--   comp_lvl_fctr_id PK of record being inserted or updated.
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
Procedure chk_comp_lvl_fctr_id(p_comp_lvl_fctr_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_fctr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_comp_lvl_fctr_id,hr_api.g_number)
     <>  ben_clf_shd.g_old_rec.comp_lvl_fctr_id) then
    --
    -- raise error as PK has changed
    --
    ben_clf_shd.constraint_error('BEN_COMP_LVL_FCTR_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_comp_lvl_fctr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_clf_shd.constraint_error('BEN_COMP_LVL_FCTR_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_comp_lvl_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_defined_balance_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the defined Balance is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   defined_balance_id Value of defined balance id.
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
Procedure chk_defined_balance_id(p_comp_lvl_fctr_id            in number,
                                 p_business_group_id           in number,
                                 p_defined_balance_id          in number,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_defined_balance_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   pay_defined_balances a
    where  a.defined_balance_id = p_defined_balance_id
    and    nvl(a.business_group_id,p_business_group_id) = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id            => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_defined_balance_id,hr_api.g_number)
      <> ben_clf_shd.g_old_rec.defined_balance_id
      or not l_api_updating)
      and p_defined_balance_id is not null then
    --
    -- check if value of defined_balance_id is valid.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        ben_clf_shd.constraint_error('BEN_COMP_LVL_FCTR_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_defined_balance_id;
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
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   rndg_rl Value of formula rule id.
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
Procedure chk_rndg_rl(p_comp_lvl_fctr_id            in number,
                      p_business_group_id           in number,
                      p_rndg_rl                     in number,
                      p_rndg_cd                     in varchar2,
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
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_clf_shd.g_old_rec.rndg_rl
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
        fnd_message.set_name('BEN','BEN_91042_INVALID_RNDG_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  -- Unless Rounding Code = Rule, Rounding rule must be blank.
  if  nvl(p_rndg_cd,hr_api.g_varchar2)  <> 'RL' and p_rndg_rl is not null then
      --
      fnd_message.set_name('BEN', 'BEN_91043_RNDG_RL_NOT_NULL');
      fnd_message.raise_error;
      --
  elsif nvl(p_rndg_cd,hr_api.g_varchar2) = 'RL' and p_rndg_rl is null then
      --
      fnd_message.set_name('BEN', 'BEN_92340_RNDG_RL_NULL');
      fnd_message.raise_error;
      --
  end if;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_rl;
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
--   comp_lvl_fctr_id PK of record being inserted or updated.
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
Procedure chk_rndg_cd(p_comp_lvl_fctr_id                in number,
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
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_clf_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
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
-- |------< chk_comp_lvl_det_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   comp_lvl_det_rl Value of formula rule id.
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
Procedure chk_comp_lvl_det_rl(p_comp_lvl_fctr_id                in number,
                             p_business_group_id        in number,
                             p_comp_lvl_det_rl              in number,
			     p_comp_lvl_det_cd         in varchar2,         -- Bug No 4242978
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_comp_lvl_det_rl
    and    ff.formula_type_id = -174
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
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_comp_lvl_det_rl,hr_api.g_number)
      <> ben_clf_shd.g_old_rec.comp_lvl_det_rl
      or not l_api_updating)
      and p_comp_lvl_det_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91050_INVALID_COMP_LVL_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  -- Bug No 4242978 Added validations for determination rule not null when
  --				det code is RL and det rule should be null when det code not RL
  --
  -- Unless comp_lvl determination  Code = Rule,  comp_lvl determination rule must be blank.
      if  nvl(p_comp_lvl_det_cd,hr_api.g_varchar2)  <> 'RL' and p_comp_lvl_det_rl is not null then
      --
      fnd_message.set_name('BEN', 'BEN_94207_COMP_DET_RL_NOT_NULL');
      fnd_message.raise_error;
      --
      elsif  nvl(p_comp_lvl_det_cd,hr_api.g_varchar2) = 'RL' and p_comp_lvl_det_rl is null then
      --
      fnd_message.set_name('BEN', 'BEN_94206_COMP_DET_RL_NULL');
      fnd_message.raise_error;
      --
     end if;
     --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comp_lvl_det_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_comp_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   no_mx_comp_flag Value of lookup code.
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
Procedure chk_no_mx_comp_flag(p_comp_lvl_fctr_id                in number,
                            p_no_mx_comp_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_comp_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_comp_flag
      <> nvl(ben_clf_shd.g_old_rec.no_mx_comp_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_comp_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_comp_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91051_INVALID_MIN_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_comp_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_comp_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   no_mn_comp_flag Value of lookup code.
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
Procedure chk_no_mn_comp_flag(p_comp_lvl_fctr_id                in number,
                            p_no_mn_comp_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_comp_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_comp_flag
      <> nvl(ben_clf_shd.g_old_rec.no_mn_comp_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_comp_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_comp_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91052_INVALID_MAX_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_comp_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_src_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   comp_src_cd Value of lookup code.
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
Procedure chk_comp_src_cd(p_comp_lvl_fctr_id                in number,
                            p_comp_src_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_src_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_src_cd
      <> nvl(ben_clf_shd.g_old_rec.comp_src_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_comp_src_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_COMP_SRC',
           p_lookup_code    => p_comp_src_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91053_INVALID_SRC_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comp_src_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_lvl_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   comp_lvl_uom Value of lookup code.
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
Procedure chk_comp_lvl_uom(p_comp_lvl_fctr_id                in number,
                            p_comp_lvl_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  cursor c1 is select currency_code
                      from fnd_currencies
                      where currency_code = p_comp_lvl_uom
                          and enabled_flag = 'Y' and
                          p_effective_date
                            between nvl(start_date_active, p_effective_date)
                            and  nvl(end_date_active, p_effective_date);
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_uom';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_lvl_uom
      <> nvl(ben_clf_shd.g_old_rec.comp_lvl_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_comp_lvl_uom is not null then
    --
    -- check if value of lookup falls within fnd_currencies.
    --
    /* if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'HR_UOM',
           p_lookup_code    => p_comp_lvl_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91048_INVALID_UOM');
      fnd_message.raise_error;
      --
    end if;  */
    open c1;
    fetch c1 into l_dummy;
    if c1%notfound then
       close c1;
       --
       -- raise error as currency not found
       --
       fnd_message.set_name('BEN','BEN_91048_INVALID_UOM');
       fnd_message.raise_error;
    end if;
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comp_lvl_uom;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_lvl_det_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   comp_lvl_det_cd Value of lookup code.
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
Procedure chk_comp_lvl_det_cd(p_comp_lvl_fctr_id                in number,
                            p_comp_lvl_det_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_det_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_lvl_det_cd
      <> nvl(ben_clf_shd.g_old_rec.comp_lvl_det_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_comp_lvl_det_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_COMP_LVL_DET',
           p_lookup_code    => p_comp_lvl_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      -- Bug 4129562 : Replaced hr_utility calls by fnd_message
      --
      -- hr_utility.set_message('BEN','BEN_91268_INV_COMP_LVL_DET_CD');
      -- hr_utility.raise_error;
      fnd_message.set_name('BEN','BEN_91268_INV_COMP_LVL_DET_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);  --
end chk_comp_lvl_det_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_sttd_sal_prdcty_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   sttd_sal_prdcty_cd Value of lookup code.
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
Procedure chk_sttd_sal_prdcty_cd(p_comp_lvl_fctr_id            in number,
                                 p_sttd_sal_prdcty_cd          in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sttd_sal_prdcty_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id            => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_sttd_sal_prdcty_cd
      <> nvl(ben_clf_shd.g_old_rec.sttd_sal_prdcty_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_sttd_sal_prdcty_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_REF_PERD',
           p_lookup_code    => p_sttd_sal_prdcty_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_sttd_sal_prdcty_cd');
      fnd_message.set_token('TYPE', 'BEN_ACTY_REF_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);  --
end chk_sttd_sal_prdcty_cd;
--
-- ----------------------------------------------------------------------------
-- |-----------------< chk_comp_alt_val_to_use_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   comp_alt_val_to_use_cd Value of lookup code.
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
Procedure chk_comp_alt_val_to_use_cd(p_comp_lvl_fctr_id        in number,
                                 p_comp_alt_val_to_use_cd      in varchar2,
                                 p_effective_date              in date,
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_alt_val_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id            => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_alt_val_to_use_cd
      <> nvl(ben_clf_shd.g_old_rec.comp_alt_val_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_comp_alt_val_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_COMP_ALT_VAL_TO_USE',
           p_lookup_code    => p_comp_alt_val_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_comp_alt_val_to_use_cd');
      fnd_message.set_token('TYPE', 'BEN_COMP_ALT_VAL_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);  --
end chk_comp_alt_val_to_use_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_comp_calc_rl >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   comp_calc_rl    Value of formula rule id.
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
Procedure chk_comp_calc_rl(p_comp_lvl_fctr_id            in number,
                           p_business_group_id           in number,
                           p_comp_calc_rl                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_comp_calc_rl
    and    ff.formula_type_id = -517
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
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id            => p_comp_lvl_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_comp_calc_rl,hr_api.g_number)
      <> ben_clf_shd.g_old_rec.comp_calc_rl
      or not l_api_updating)
      and p_comp_calc_rl is not null then
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
        fnd_message.set_token('ID',p_comp_calc_rl);
        fnd_message.set_token('TYPE_ID',-517);
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
end chk_comp_calc_rl;
--
------------------------------------------------------------------------
----
-- |------< chk_name >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Name is unique in a business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   name Value of Name.
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
Procedure chk_name(p_comp_lvl_fctr_id                in number,
                         p_business_group_id                in number,
                         p_name                    in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_comp_lvl_fctr  clf
    where  clf.business_group_id = p_business_group_id and
                 clf.name = p_name;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clf_shd.api_updating
    (p_comp_lvl_fctr_id                => p_comp_lvl_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_name,hr_api.g_varchar2)
      <> ben_clf_shd.g_old_rec.name
      or not l_api_updating)
      and p_name is not null then
    --
    -- check if name already used.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the

      -- name is invalid otherwise its valid
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_name;
  --
-----------------------------------------------------------------------------
-- |--------------------------------< chk_day_mo>---------------------------|
-----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the date format
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   day_mo Value of Minimum hours worked.
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
Procedure chk_day_mo(p_year                  in varchar2,
                     p_day_mo                in varchar2,
                     p_label                 in varchar2) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_day_mo';
  l_year  varchar2(4) := nvl(p_year,'2000'); --pick a leap year
  l_date  date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_day_mo '||p_day_mo, 5);
  hr_utility.set_location('p_year '||p_year, 5);
  --
  if p_day_mo is null then
     hr_api.mandatory_arg_error(p_api_name       => l_proc,
                                p_argument       => p_label,
                                p_argument_value => '');
  end if;
  l_date := to_date(substr('0'||p_day_mo,-4)||l_year,'ddmmyyyy');
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
Exception
   when others then
        fnd_message.set_name('BEN','BEN_92603_INVALID_DATE');
        fnd_message.raise_error;
End chk_day_mo;
--
-----------------------------------------------------------------------------
-- |--------------------------------< chk_date_range>------------------------|
-----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the date format
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   day_mo Value of Minimum hours worked.
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
Procedure chk_date_range(p_clf_rec     in ben_clf_shd.g_rec_type) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_date_range';
  l_start_year  varchar2(4) := nvl(p_clf_rec.start_year,'2000');
  l_end_year    varchar2(4) := nvl(p_clf_rec.end_year,'2000');
  l_date1  date;
  l_date2  date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_clf_rec.start_year is not null and
     p_clf_rec.end_year is not null then
     l_date1 := to_date(substr('0'||p_clf_rec.start_day_mo,-4)||l_start_year,'ddmmyyyy');
     l_date2 := to_date(substr('0'||p_clf_rec.end_day_mo,-4)||l_end_year,'ddmmyyyy');
     if l_date2 < l_date1 then
        fnd_message.set_name('BEN','BEN_91824_START_DT_AFTR_END_DT');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('START_DT',l_date1);
        fnd_message.set_token('END_DT',l_date2);
        fnd_message.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);

End chk_date_range;
--
-----------------------------------------------------------------------------
-- |-----------------< chk_mn_mx_comp_val>--------------------|
-----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that minimum compensation value is
--   always less than max compensation value .
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id PK of record being inserted or updated.
--   mn_hrs_num Value of Minimum hours worked.
--   mx_hrs_num Value of Maximum hours worked.
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
Procedure chk_mn_mx_comp_val(p_comp_lvl_fctr_id      in number,
                             p_no_mn_comp_flag       in varchar2,
                             p_mn_comp_val           in number,
                             p_no_mx_comp_flag       in varchar2,
                             p_mx_comp_val           in number,
                             p_object_version_number in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_comp_val';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Minimum compensation value must be < Maximum compensation value ,
  -- if both are used.
  --
  if p_mn_comp_val is not null and
    p_mx_comp_val is not null then
    --
    -- raise error if max value not greater than min value
    --
    -- Bug fix 1873685
    if p_mx_comp_val < p_mn_comp_val then
    -- if p_mx_comp_val <= p_mn_comp_val then
    -- end fix 1873685
      --
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- If No Minimum hours flag set to "on" (Y),
  --    then minimum hours number must be blank.
  --
  if p_no_mn_comp_flag = 'Y' and
    p_mn_comp_val is not null then
    --
    fnd_message.set_name('BEN','BEN_91054_MIN_VAL_NOT_NULL');
    fnd_message.raise_error;
    --
  elsif p_no_mn_comp_flag = 'N' and
    p_mn_comp_val is null then
    --
    fnd_message.set_name('BEN','BEN_91055_MIN_VAL_REQUIRED');
    fnd_message.raise_error;
    --
  end if;
  --
  -- If No Maximum comp flag set to "on" (Y),
  --    then maximum comp number and must be blank.
  --
  if p_no_mx_comp_flag = 'Y' and
    p_mx_comp_val is not null then
    --
    fnd_message.set_name('BEN','BEN_91056_MAX_VAL_NOT_NULL');
    fnd_message.raise_error;
    --
  elsif p_no_mx_comp_flag = 'N' and
    p_mx_comp_val is null then
    --
    fnd_message.set_name('BEN','BEN_91057_MAX_VAL_REQUIRED');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_comp_val;
--
-------------------------------------------------------------------------------
-- |--------------------------< chk_source >---------------------------------|
-------------------------------------------------------------------------------
----
--
-- Description
--  This procedure checks to make sure that the Defined Balance is not null
--  if the comp_src_cd = BALTYP and that the Benefits Balance Type is not null
--  if the comp_src_cd = BNFTBALTYP
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_src_cd           Source Code.
--   defined_balance_id    Defined Balance.
--   bnfts_bal_id          Benefits Balance Type.
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
Procedure chk_source(p_comp_src_cd                 in varchar2,
                     p_defined_balance_id          in number,
                     p_bnfts_bal_id                in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_source';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Defined Balance must be entered if "Balance Type" is selected for
  -- Source.
  --
  if p_comp_src_cd = 'BALTYP' and p_defined_balance_id is null then
     --
     fnd_message.set_name('BEN','BEN_91975_DEFINED_BALANCE');
     fnd_message.raise_error;
     --
  elsif p_comp_src_cd = 'BNFTBALTYP' and p_bnfts_bal_id is null then
     --
     fnd_message.set_name('BEN','BEN_91976_BNFTS_BALANCE_TYP');
     fnd_message.raise_error;
     --
  end if;
      --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_source;
--
-- Bug 2978945 begin

-- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that compensation level factor child records
--   do not exist when the user deletes the record in the
--   ben_comp_lvl_fctr table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id        PK of record being inserted or updated.
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
procedure chk_child_records(p_comp_lvl_fctr_id  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';
  v_dummy        varchar2(1);


begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --Used in Standard Rates
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'BEN_ACTY_BASE_RT_F',
             p_base_key_column => 'comp_lvl_fctr_id',
             p_base_key_value  => p_comp_lvl_fctr_id
            )) Then
	       ben_utility.child_exists_error('BEN_ACTY_BASE_RT_F');
  End If;

  --Used in Coverages Calculation Method
  If (ben_batch_utils.rows_exist
                (p_base_table_name => 'BEN_CVG_AMT_CALC_MTHD_F',
                 p_base_key_column => 'comp_lvl_fctr_id',
                 p_base_key_value  => p_comp_lvl_fctr_id
                )) Then
         	   ben_utility.child_exists_error('BEN_CVG_AMT_CALC_MTHD_F');
  End If;

  --Used in eligibility profiles
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'BEN_ELIG_COMP_LVL_PRTE_F',
             p_base_key_column => 'comp_lvl_fctr_id',
             p_base_key_value  => p_comp_lvl_fctr_id
            )) Then
               ben_utility.child_exists_error('BEN_ELIG_COMP_LVL_PRTE_F');
	   --Raise l_rows_exist;
  End If;

  --Used in variable rate profiles criteria
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'BEN_COMP_LVL_RT_F',
             p_base_key_column => 'comp_lvl_fctr_id',
             p_base_key_value  => p_comp_lvl_fctr_id
            )) Then
  	       ben_utility.child_exists_error('BEN_COMP_LVL_RT_F');
  End If;

  --Used in variable rate profiles
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'BEN_VRBL_RT_PRFL_F',
             p_base_key_column => 'comp_lvl_fctr_id',
             p_base_key_value  => p_comp_lvl_fctr_id
            )) Then
  	       ben_utility.child_exists_error('BEN_VRBL_RT_PRFL_F');
  End If;

  --Used in Period To Date limits
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'BEN_PTD_LMT_F',
             p_base_key_column => 'comp_lvl_fctr_id',
             p_base_key_value  => p_comp_lvl_fctr_id
            )) Then
	       ben_utility.child_exists_error('BEN_PTD_LMT_F');
  End If;


  --Used in Benefit Pools
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'BEN_BNFT_PRVDR_POOL_F',
             p_base_key_column => 'comp_lvl_fctr_id',
             p_base_key_value  => p_comp_lvl_fctr_id
            )) Then
	       ben_utility.child_exists_error('BEN_BNFT_PRVDR_POOL_F');
  End If;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_records;

-- Bug  2978945 end

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_clf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_comp_lvl_fctr_id
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_rndg_cd                   => p_rec.rndg_cd,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_defined_balance_id
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_defined_balance_id        => p_rec.defined_balance_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_rndg_rl                   => p_rec.rndg_rl,
   p_rndg_cd                   => p_rec.rndg_cd,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_comp_lvl_det_rl
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_comp_lvl_det_rl      => p_rec.comp_lvl_det_rl,
   p_comp_lvl_det_cd         => p_rec.comp_lvl_det_cd,         -- Bug No 4242978
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_no_mx_comp_flag
  (p_comp_lvl_fctr_id        => p_rec.comp_lvl_fctr_id,
   p_no_mx_comp_flag         => p_rec.no_mx_comp_flag,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_no_mn_comp_flag
  (p_comp_lvl_fctr_id        => p_rec.comp_lvl_fctr_id,
   p_no_mn_comp_flag         => p_rec.no_mn_comp_flag,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_comp_src_cd
  (p_comp_lvl_fctr_id        => p_rec.comp_lvl_fctr_id,
   p_comp_src_cd             => p_rec.comp_src_cd,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_comp_lvl_uom
  (p_comp_lvl_fctr_id        => p_rec.comp_lvl_fctr_id,
   p_comp_lvl_uom            => p_rec.comp_lvl_uom,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_mn_mx_comp_val
  (p_comp_lvl_fctr_id        => p_rec.comp_lvl_fctr_id,
   p_no_mn_comp_flag         => p_rec.no_mn_comp_flag,
   p_mn_comp_val             => p_rec.mn_comp_val,
   p_no_mx_comp_flag         => p_rec.no_mx_comp_flag,
   p_mx_comp_val             => p_rec.mx_comp_val,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_name
  (p_comp_lvl_fctr_id        => p_rec.comp_lvl_fctr_id,
   p_business_group_id       => p_rec.business_group_id,
   p_name                    => p_rec.name,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
 --
  chk_comp_lvl_det_cd
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_comp_lvl_det_cd         => p_rec.comp_lvl_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_sttd_sal_prdcty_cd
  (p_comp_lvl_fctr_id      => p_rec.comp_lvl_fctr_id,
   p_sttd_sal_prdcty_cd    => p_rec.sttd_sal_prdcty_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_comp_alt_val_to_use_cd
  (p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
   p_comp_alt_val_to_use_cd => p_rec.comp_alt_val_to_use_cd,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
 --
  chk_comp_calc_rl
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_comp_calc_rl              => p_rec.comp_calc_rl,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_source
  (p_comp_src_cd             => p_rec.comp_src_cd,
   p_defined_balance_id      => p_rec.defined_balance_id,
   p_bnfts_bal_id            => p_rec.bnfts_bal_id);
  --
  if p_rec.comp_src_cd in ('OICAMTEARNED','OICAMTPAID') then
     chk_day_mo
     (p_day_mo                  => p_rec.start_day_mo,
      p_year                    => p_rec.start_year,
      p_label                   => 'p_start_DDMM');
     --
     chk_day_mo
     (p_day_mo                  => p_rec.end_day_mo,
      p_year                    => p_rec.end_year,
      p_label                   => 'p_end_DDMM');
     --
     chk_date_range
     (p_clf_rec                  => p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_clf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_comp_lvl_fctr_id
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_defined_balance_id
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_defined_balance_id        => p_rec.defined_balance_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_rndg_rl        => p_rec.rndg_rl,
   p_rndg_cd        => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_det_rl
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_comp_lvl_det_rl        => p_rec.comp_lvl_det_rl,
   p_comp_lvl_det_cd         => p_rec.comp_lvl_det_cd,         -- Bug No 4242978
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_comp_flag
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_no_mx_comp_flag         => p_rec.no_mx_comp_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_comp_flag
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_no_mn_comp_flag         => p_rec.no_mn_comp_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_src_cd
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_comp_src_cd         => p_rec.comp_src_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_uom
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_comp_lvl_uom         => p_rec.comp_lvl_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --
  chk_mn_mx_comp_val
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_no_mn_comp_flag   => p_rec.no_mn_comp_flag,
   p_mn_comp_val        => p_rec.mn_comp_val,
   p_no_mx_comp_flag   => p_rec.no_mx_comp_flag,
   p_mx_comp_val        => p_rec.mx_comp_val,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_name         => p_rec.name,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  --
  chk_comp_lvl_det_cd
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_comp_lvl_det_cd         => p_rec.comp_lvl_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_sttd_sal_prdcty_cd
  (p_comp_lvl_fctr_id      => p_rec.comp_lvl_fctr_id,
   p_sttd_sal_prdcty_cd    => p_rec.sttd_sal_prdcty_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_alt_val_to_use_cd
  (p_comp_lvl_fctr_id       => p_rec.comp_lvl_fctr_id,
   p_comp_alt_val_to_use_cd => p_rec.comp_alt_val_to_use_cd,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
 --
  chk_comp_calc_rl
  (p_comp_lvl_fctr_id          => p_rec.comp_lvl_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_comp_calc_rl              => p_rec.comp_calc_rl,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_source
  (p_comp_src_cd             => p_rec.comp_src_cd,
   p_defined_balance_id      => p_rec.defined_balance_id,
   p_bnfts_bal_id            => p_rec.bnfts_bal_id);
  --
  if p_rec.comp_src_cd in ('OICAMTEARNED','OICAMTPAID') then
     chk_day_mo
     (p_day_mo                  => p_rec.start_day_mo,
      p_year                    => p_rec.start_year,
      p_label                   => 'p_start_DDMM');
     --
     chk_day_mo
     (p_day_mo                  => p_rec.end_day_mo,
      p_year                    => p_rec.end_year,
      p_label                   => 'p_end_DDMM');
     --
     chk_date_range
     (p_clf_rec                  => p_rec);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_clf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  chk_child_records(p_comp_lvl_fctr_id => p_rec.comp_lvl_fctr_id); -- Bug 2978945

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_comp_lvl_fctr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_comp_lvl_fctr b
    where b.comp_lvl_fctr_id      = p_comp_lvl_fctr_id
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
                             p_argument       => 'comp_lvl_fctr_id',
                             p_argument_value => p_comp_lvl_fctr_id);
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
end ben_clf_bus;

/
