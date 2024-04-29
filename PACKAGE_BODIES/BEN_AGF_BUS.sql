--------------------------------------------------------
--  DDL for Package Body BEN_AGF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AGF_BUS" as
/* $Header: beagfrhi.pkb 120.0 2005/05/28 00:23:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_agf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_age_fctr_id >------|
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
--   age_fctr_id PK of record being inserted or updated.
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
Procedure chk_age_fctr_id(p_age_fctr_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_fctr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_age_fctr_id,hr_api.g_number)
     <>  ben_agf_shd.g_old_rec.age_fctr_id) then
    --
    -- raise error as PK has changed
    --
    ben_agf_shd.constraint_error('BEN_AGE_FCTR_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_age_fctr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_agf_shd.constraint_error('BEN_AGE_FCTR_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_age_fctr_id;
--
/*
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
--   p_age_fctr_id PK
--   p_organization_id ID of FK column
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
Procedure chk_organization_id (p_age_fctr_id          in number,
                            p_organization_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_organization_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_all_organization_units a
    where  a.organization_id = p_organization_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_agf_shd.api_updating
     (p_age_fctr_id            => p_age_fctr_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_organization_id,hr_api.g_number)
     <> nvl(ben_agf_shd.g_old_rec.organization_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if organization_id value exists in hr_all_organization_units table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in hr_all_organization_units
        -- table.
        --
        ben_agf_shd.constraint_error('BEN_AGE_FCTR_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_organization_id;
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_age_to_use_cd >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   age_to_use_cd Value of lookup code.
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
Procedure chk_age_to_use_cd(p_age_fctr_id                in number,
                            p_age_to_use_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_age_to_use_cd
      <> nvl(ben_agf_shd.g_old_rec.age_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating) and p_age_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_AGE_TO_USE_CD',
           p_lookup_code    => p_age_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_age_to_use_cd');
      fnd_message.set_token('TYPE', 'BEN_AGE_TO_USE_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_age_to_use_cd;
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
--   age_fctr_id PK of record being inserted or updated.
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
Procedure chk_rndg_rl(p_age_fctr_id                 in number,
                      p_rndg_rl                     in number,
   	              p_rndg_cd                in varchar2,                -- Bug No 4242978
                      p_business_group_id           in number,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                 => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_agf_shd.g_old_rec.rndg_rl
      or not l_api_updating)
      and p_rndg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_rndg_rl,
        p_formula_type_id   => -169,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
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
  end if;
  --
  --  Bug No 4242978
  -- Unless Rounding Code = Rule, Rounding rule must be blank.
  if  nvl(p_rndg_cd,hr_api.g_varchar2)  <> 'RL' and p_rndg_rl is not null then
      --
      fnd_message.set_name('BEN', 'BEN_91043_RNDG_RL_NOT_NULL');
      fnd_message.raise_error;
      --
  elsif  nvl(p_rndg_cd,hr_api.g_varchar2) = 'RL' and p_rndg_rl is null then
      --
      fnd_message.set_name('BEN', 'BEN_92340_RNDG_RL_NULL');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_age_calc_rl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   age_calc_rl Value of formula rule id.
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
Procedure chk_age_calc_rl(p_age_fctr_id                 in number,
                          p_age_calc_rl                 in number,
                          p_business_group_id           in number,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_calc_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                 => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_age_calc_rl,hr_api.g_number)
      <> ben_agf_shd.g_old_rec.age_calc_rl
      or not l_api_updating)
      and p_age_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_age_calc_rl,
        p_formula_type_id   => -500,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_age_calc_rl);
      fnd_message.set_token('TYPE_ID',-169);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_age_calc_rl;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_age_code_rule >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the age_to_use_cd is populated or
--   the age_calc_rl is populated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_to_use_cd value of lookup
--   age_calc_rl Value of formula rule id.
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
Procedure chk_age_code_rule(p_age_to_use_cd               in varchar2,
                            p_age_calc_rl                 in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_code_rule';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_age_to_use_cd is null and
    p_age_calc_rl is null or
    p_age_to_use_cd is not null and
    p_age_calc_rl is not null then
    --
    -- raise error
    --
    fnd_message.set_name('BEN','BEN_92557_CODE_AGE_RULE');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_age_code_rule;
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
--   age_fctr_id PK of record being inserted or updated.
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
Procedure chk_rndg_cd(p_age_fctr_id                in number,
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
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_agf_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_rndg_cd');
      fnd_message.set_token('TYPE', 'BEN_RNDG');
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
-- |------< chk_age_det_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   age_det_cd Determination Code
--   age_det_rl Value of formula rule id.
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
Procedure chk_age_det_rl(p_age_fctr_id                 in number,
                         p_age_det_rl                  in number,
                         p_age_det_cd                in varchar2,                          -- Bug No 4242978
                         p_business_group_id           in number,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_det_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                 => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_age_det_rl,hr_api.g_number)
      <> ben_agf_shd.g_old_rec.age_det_rl
      or not l_api_updating)
      and p_age_det_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_age_det_rl,
        p_formula_type_id   => -145,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_age_det_rl);
      fnd_message.set_token('TYPE_ID',-145);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- Bug No 4242978 Added validations for determination rule not null when
  --				det code is RL and det rule should be null when det code not RL
  --
  -- Unless AGE determination  Code = Rule,  AGE determination rule must be blank.
      if  nvl(p_age_det_cd,hr_api.g_varchar2)  <> 'RL' and p_age_det_rl is not null then
      --
      fnd_message.set_name('BEN', 'BEN_91046_AGE_DET_RL_NOT_NULL');
      fnd_message.raise_error;
      --
      elsif  nvl(p_age_det_cd,hr_api.g_varchar2) = 'RL' and p_age_det_rl is null then
      --
      fnd_message.set_name('BEN', 'BEN_91096_AGE_DET_RL_NULL');
      fnd_message.raise_error;
      --
     end if;
     --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_age_det_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_age_det_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   age_det_cd Value of lookup code.
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
Procedure chk_age_det_cd(p_age_fctr_id                in number,
                            p_age_det_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_det_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_age_det_cd
      <> nvl(ben_agf_shd.g_old_rec.age_det_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_age_det_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_AGE_DET',
           p_lookup_code    => p_age_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_age_det_cd');
      fnd_message.set_token('TYPE', 'AGE_DET');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_age_det_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_age_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   no_mx_age_flag Value of lookup code.
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
Procedure chk_no_mx_age_flag(p_age_fctr_id                in number,
                            p_no_mx_age_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_age_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_age_flag
      <> nvl(ben_agf_shd.g_old_rec.no_mx_age_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_age_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_no_mx_age_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_age_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_age_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   no_mn_age_flag Value of lookup code.
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
Procedure chk_no_mn_age_flag(p_age_fctr_id                in number,
                            p_no_mn_age_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_age_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_age_flag
      <> nvl(ben_agf_shd.g_old_rec.no_mn_age_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_age_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_no_mn_age_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_age_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_age_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   age_uom Value of lookup code.
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
Procedure chk_age_uom(p_age_fctr_id                in number,
                            p_age_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_age_uom
      <> nvl(ben_agf_shd.g_old_rec.age_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_age_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_age_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_age_uom');
      fnd_message.set_token('TYPE', 'BEN_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_age_uom;
--
------------------------------------------------------------------------
----
-- |------< chk_mn_mx_age_num >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that minimum age nuumber is always less than
--    max age number.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id PK of record being inserted or updated.
--   mn_age_num Value of Minimum age.
--   mx_age_num Value of Maximum age.
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
Procedure chk_mn_mx_age_num(p_age_fctr_id                in number,
                         p_no_mn_age_flag  in varchar2,
                         p_mn_age_num                 in number,
                         p_no_mx_age_flag  in varchar2,
                         p_mx_age_num                   in number,
                         p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_age_num';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Minimum Age Number must be < Maximum Age Number,
  -- if both are used.
  --
  if p_mn_age_num is not null and p_mx_age_num is not null then
      --
      -- raise error if max value not greater than min value
      --
    -- Bug fix 1873685 : UNABLE TO DEFINE AGE BANDS OF ONLY ONE YEAR AFTER BEN D APPLIED
    --
    -- if  (p_mx_age_num <= p_mn_age_num)  then
    if  (p_mx_age_num < p_mn_age_num)  then
    -- end of fix 1873685
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
    end if;
      --
      --
  end if;
    --
      -- If No Minimum age flag set to "on" (Y),
      --    then minimum age number must be blank.
      --
    if  nvl( p_no_mn_age_flag, hr_api.g_varchar2)  = 'Y'
         and p_mn_age_num is not null
    then
      fnd_message.set_name('BEN','BEN_91054_MIN_VAL_NOT_NULL');
      fnd_message.raise_error;
    elsif  nvl( p_no_mn_age_flag, hr_api.g_varchar2)  = 'N'
         and p_mn_age_num is null
    then
      fnd_message.set_name('BEN','BEN_91055_MIN_VAL_REQUIRED');
      fnd_message.raise_error;
    end if;
      --
      -- If No Maximum age flag set to "on" (Y),
      --    then maximum age number must be blank.
      --
    if  nvl( p_no_mx_age_flag, hr_api.g_varchar2)  = 'Y'
         and p_mx_age_num is not null
    then
      fnd_message.set_name('BEN','BEN_91056_MAX_VAL_NOT_NULL');
      fnd_message.raise_error;
    elsif  nvl( p_no_mx_age_flag, hr_api.g_varchar2)  = 'N'
         and p_mx_age_num is null
    then
      fnd_message.set_name('BEN','BEN_91057_MAX_VAL_REQUIRED');
      fnd_message.raise_error;
    end if;
   --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_age_num;
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
--   age_fctr_id PK of record being inserted or updated.
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
Procedure chk_name(p_age_fctr_id                in number,
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
    from   ben_age_fctr  agf
    where  agf.business_group_id = p_business_group_id and
                 agf.name = p_name;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_agf_shd.api_updating
    (p_age_fctr_id                => p_age_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_name,hr_api.g_varchar2)
      <> ben_agf_shd.g_old_rec.name
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

-- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that age factor records do not exist in the
--   ben_cmbn_age_los_fctr table when the user deletes the record in the ben_
--   age_fctr table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   age_fctr_id        PK of record being inserted or updated.
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
procedure chk_child_records(p_age_fctr_id  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';

  --
   cursor chk_cmbn_age_los_fctr is select null
                                   from   ben_cmbn_age_los_fctr cla
                                   where  cla.age_fctr_id = p_age_fctr_id;

begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- check if age factor record exists in the ben_cmbn_age_los_fctr table
    --
  /* open chk_cmbn_age_los_fctr;
     --
     -- fetch value from cursor if it returns a record then the
     -- the user cannot delete the age factor
     --
   fetch chk_cmbn_age_los_fctr into v_dummy;
   if chk_cmbn_age_los_fctr%found then
        close chk_cmbn_age_los_fctr;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91738_AGE_CHLD_RCD_EXISTS');
        fnd_message.raise_error;
        --
   end if;
   --
   close chk_cmbn_age_los_fctr;*/ --Bug 2978945 used the common function rows_exist
   --
--Bug 2978945
  If (ben_batch_utils.rows_exist
          (p_base_table_name => 'ben_cmbn_age_los_fctr',
           p_base_key_column => 'age_fctr_id',
           p_base_key_value  => p_age_fctr_id
          )) Then
	     ben_utility.child_exists_error('ben_cmbn_age_los_fctr');
  End If;

  If (ben_batch_utils.rows_exist
          (p_base_table_name => 'ben_age_rt_f',
           p_base_key_column => 'age_fctr_id',
           p_base_key_value  => p_age_fctr_id
          )) Then
	     ben_utility.child_exists_error('ben_age_rt_f');
  End If;

  If (ben_batch_utils.rows_exist
          (p_base_table_name => 'ben_elig_age_cvg_f',
           p_base_key_column => 'age_fctr_id',
           p_base_key_value  => p_age_fctr_id
          )) Then
	     ben_utility.child_exists_error('ben_elig_age_cvg_f');
  End If;

  If (ben_batch_utils.rows_exist
          (p_base_table_name => 'ben_elig_age_prte_f',
           p_base_key_column => 'age_fctr_id',
           p_base_key_value  => p_age_fctr_id
          )) Then
	     ben_utility.child_exists_error('ben_elig_age_prte_f');
  End If;

  If (ben_batch_utils.rows_exist
          (p_base_table_name => 'ben_vstg_age_rqmt',
           p_base_key_column => 'age_fctr_id',
           p_base_key_value  => p_age_fctr_id
          )) Then
	     ben_utility.child_exists_error('ben_vstg_age_rqmt');
  End If;


--Bug 2978945

  hr_utility.set_location('Leaving:'||l_proc,10);
  --

end chk_child_records;



--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_agf_shd.g_rec_type
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
  chk_age_fctr_id
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_organization_id
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_age_to_use_cd
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_age_to_use_cd         => p_rec.age_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_rndg_rl               => p_rec.rndg_rl,
   p_rndg_cd     =>  p_rec.rndg_cd,                              -- Bug 4242978
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_calc_rl
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_age_calc_rl           => p_rec.age_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_det_rl
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_age_det_rl            => p_rec.age_det_rl,
   p_age_det_cd            => p_rec.age_det_cd,               -- Bug No 4242978
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_det_cd
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_age_det_cd         => p_rec.age_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_age_flag
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_no_mx_age_flag         => p_rec.no_mx_age_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_age_flag
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_no_mn_age_flag         => p_rec.no_mn_age_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_uom
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_age_uom         => p_rec.age_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_mn_mx_age_num
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_no_mn_age_flag   => p_rec.no_mn_age_flag,
   p_mn_age_num        => p_rec.mn_age_num,
   p_no_mx_age_flag   => p_rec.no_mx_age_flag,
   p_mx_age_num        => p_rec.mx_age_num,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_name         => p_rec.name,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_code_rule
  (p_age_to_use_cd         => p_rec.age_to_use_cd,
   p_age_calc_rl           => p_rec.age_calc_rl);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_agf_shd.g_rec_type
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
  chk_age_fctr_id
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_organization_id
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_organization_id          => p_rec.organization_id,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_age_to_use_cd
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_age_to_use_cd         => p_rec.age_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_rndg_rl               => p_rec.rndg_rl,
   p_rndg_cd     =>  p_rec.rndg_cd,                                 -- Bug 4242978
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_calc_rl
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_age_calc_rl           => p_rec.age_calc_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_rndg_cd               => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_det_rl
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_age_det_rl            => p_rec.age_det_rl,
   p_age_det_cd            => p_rec.age_det_cd,               -- Bug No 4242978
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_det_cd
  (p_age_fctr_id           => p_rec.age_fctr_id,
   p_age_det_cd            => p_rec.age_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_age_flag
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_no_mx_age_flag         => p_rec.no_mx_age_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_age_flag
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_no_mn_age_flag         => p_rec.no_mn_age_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_uom
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_age_uom         => p_rec.age_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_mn_mx_age_num
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_no_mn_age_flag   => p_rec.no_mn_age_flag,
   p_mn_age_num        => p_rec.mn_age_num,
   p_no_mx_age_flag   => p_rec.no_mx_age_flag,
   p_mx_age_num        => p_rec.mx_age_num,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_name
  (p_age_fctr_id          => p_rec.age_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_name         => p_rec.name,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_code_rule
  (p_age_to_use_cd         => p_rec.age_to_use_cd,
   p_age_calc_rl           => p_rec.age_calc_rl);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_agf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  chk_child_records(p_age_fctr_id => p_rec.age_fctr_id);
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
  (p_age_fctr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_age_fctr b
    where b.age_fctr_id      = p_age_fctr_id
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
                             p_argument       => 'age_fctr_id',
                             p_argument_value => p_age_fctr_id);
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
end ben_agf_bus;

/
