--------------------------------------------------------
--  DDL for Package Body BEN_LSF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LSF_BUS" as
/* $Header: belsfrhi.pkb 120.0 2005/05/28 03:37:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lsf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_los_fctr_id >------|
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
--   los_fctr_id PK of record being inserted or updated.
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
Procedure chk_los_fctr_id(p_los_fctr_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_los_fctr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_los_fctr_id,hr_api.g_number)
     <>  ben_lsf_shd.g_old_rec.los_fctr_id) then
    --
    -- raise error as PK has changed
    --
    ben_lsf_shd.constraint_error('BEN_LOS_FCTR_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_los_fctr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_lsf_shd.constraint_error('BEN_LOS_FCTR_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_los_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_oab_fast_formula_id >------|
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
--   p_los_fctr_id PK
--   p_oab_fast_formula_id ID of FK column
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
/*         Procedure chk_oab_fast_formula_id (p_los_fctr_id          in number,
                            p_oab_fast_formula_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oab_fast_formula_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_oab_fast_formula_f a
    where  a.OAB_FAST_FORMULA_ID = p_oab_fast_formula_id     --  88888
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_lsf_shd.api_updating
     (p_los_fctr_id            => p_los_fctr_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_oab_fast_formula_id,hr_api.g_number)
     <> nvl(ben_lsf_shd.g_old_rec.oab_fast_formula_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if oab_fast_formula_id value exists in ben_oab_fast_formula_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_oab_fast_formula_f
        -- table.
        --
        ben_lsf_shd.constraint_error('{ForeignKeyConstraint}');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_oab_fast_formula_id;
--
*/
-- ----------------------------------------------------------------------------
-- |------< chk_los_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   los_uom Value of lookup code.
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
Procedure chk_los_uom(p_los_fctr_id                in number,
                            p_los_uom               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_los_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_los_uom
      <> nvl(ben_lsf_shd.g_old_rec.los_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_los_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_los_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91048_INVALID_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_los_uom;
--
------------------------------------------------------------------------
-- |----------------< chk_los_calc_rl >-----------------------------|
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   los_calc_rl Value of formula rule id.
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
Procedure chk_los_calc_rl(p_los_fctr_id              in number,
                          p_business_group_id        in number,
                          p_los_calc_rl              in number,
                          p_effective_date           in date,
                          p_object_version_number    in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_los_calc_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_los_calc_rl
    and    ff.formula_type_id = -510
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
  l_api_updating :=ben_lsf_shd.api_updating
    (p_los_fctr_id                 => p_los_fctr_id,
   --p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_los_calc_rl,hr_api.g_number)
      <>BEN_LSF_SHD.g_old_rec.los_calc_rl
      or not l_api_updating)
      and p_los_calc_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      --
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
        fnd_message.set_token('ID',p_los_calc_rl);
        fnd_message.set_token('TYPE_ID',-510);
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
end chk_los_calc_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_los_alt_val_to_use_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   los_alt_val_to_use_cd Value of lookup code.
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
Procedure chk_los_alt_val_to_use_cd(p_los_fctr_id         in number,
                            p_los_alt_val_to_use_cd       in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_los_alt_val_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                 => p_los_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_los_alt_val_to_use_cd
      <> nvl(ben_lsf_shd.g_old_rec.los_alt_val_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_los_alt_val_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LOS_ALT_VAL_TO_USE',
           p_lookup_code    => p_los_alt_val_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_los_alt_val_to_use_cd');
      fnd_message.set_token('TYPE', 'BEN_LOS_ALT_VAL_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_los_alt_val_to_use_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_los_dt_to_use_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   los_dt_to_use_cd Value of lookup code.
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
Procedure chk_los_dt_to_use_cd(p_los_fctr_id                in number,
                            p_los_dt_to_use_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_los_dt_to_use_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_los_dt_to_use_cd
      <> nvl(ben_lsf_shd.g_old_rec.los_dt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_los_dt_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LOS_DT_TO_USE',
           p_lookup_code    => p_los_dt_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91063_INVLD_LOS_DT_USE_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_los_dt_to_use_cd;
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
--   los_fctr_id PK of record being inserted or updated.
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
Procedure chk_rndg_cd(p_los_fctr_id                in number,
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
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_lsf_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
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
-- |------< chk_los_det_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   los_det_cd Value of lookup code.
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
Procedure chk_los_det_cd(p_los_fctr_id                in number,
                            p_los_det_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_los_det_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_los_det_cd
      <> nvl(ben_lsf_shd.g_old_rec.los_det_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_los_det_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_LOS_DET',
           p_lookup_code    => p_los_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91065_INVLD_LOS_DET_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_los_det_cd;
--
Procedure chk_no_mn_los_num_apls_flag(p_los_fctr_id                in number,
                         p_no_mn_los_num_apls_flag                  in varchar2,
                          p_effective_date              in date,
                         p_object_version_number       in number) is
  --
 --
  l_proc         varchar2(72) := g_package||'chk_no_mn_los_num_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_los_num_apls_flag
      <> nvl(ben_lsf_shd.g_old_rec.no_mn_los_num_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_los_num_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_los_num_apls_flag,
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
end chk_no_mn_los_num_apls_flag;


Procedure chk_no_mx_los_num_apls_flag(p_los_fctr_id                in number,
                         p_no_mx_los_num_apls_flag                  in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
 --
  l_proc         varchar2(72) := g_package||'chk_no_mx_los_num_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
    --  p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_los_num_apls_flag
      <> nvl(ben_lsf_shd.g_old_rec.no_mx_los_num_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_los_num_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_los_num_apls_flag,
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
end chk_no_mx_los_num_apls_flag;


--
------------------------------------------------------------------------
----
-- |------< chk_los_det_rl >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   los_det_rl Value of formula rule id.
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
Procedure chk_los_det_rl(p_los_fctr_id                in number,
                         p_business_group_id        in number,
                         p_los_det_rl                  in number,
                         p_los_det_cd                in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_los_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_los_det_rl
    and    ff.formula_type_id = -170
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
  l_api_updating :=ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
    --  p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_los_det_rl,hr_api.g_number)
      <>BEN_LSF_SHD.g_old_rec.los_det_rl
      or not l_api_updating)
      and p_los_det_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91066_INVLD_LOS_DET_RL');
        fnd_message.raise_error;
        --
      end if;
     --
    close c1;
    --
  end if;
  --
  -- Bug No 4242978 Moved out the following if conditions outside the outer if
  --                            as they have to called from insert_validate also
  --
  -- Unless LOS determination  Code = Rule,  LOS determination rule must be blank.
      if  nvl(p_los_det_cd,hr_api.g_varchar2)  <> 'RL' and p_los_det_rl is not null then
      --
      fnd_message.set_name('BEN', 'BEN_91071_LOS_DET_RL_NOT_NULL');
      fnd_message.raise_error;
      --
      elsif  nvl(p_los_det_cd,hr_api.g_varchar2) = 'RL' and p_los_det_rl is null then
      --
      fnd_message.set_name('BEN', 'BEN_91098_LOS_DET_RL_NULL');
      fnd_message.raise_error;
      --
     end if;
     --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_los_det_rl;


--
------------------------------------------------------------------------
----
-- |------< chk_rndg_rl >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
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
Procedure chk_rndg_rl(p_los_fctr_id            in number,
                      p_business_group_id      in number,
                      p_rndg_rl                in number,
                      p_rndg_cd                in varchar2,
                      p_effective_date         in date,
                      p_object_version_number  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_rndg_rl';
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
  l_api_updating :=ben_lsf_shd.api_updating              -- 888888
    (p_los_fctr_id                => p_los_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <>BEN_LSF_SHD.g_old_rec.rndg_rl
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
  elsif  nvl(p_rndg_cd,hr_api.g_varchar2) = 'RL' and p_rndg_rl is null then
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
------------------------------------------------------------------------
----
-- |------< chk_los_dt_to_use_rl >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   los_dt_to_use_rl Value of formula rule id.
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
Procedure chk_los_dt_to_use_rl(p_los_fctr_id              in number,
                               p_business_group_id        in number,
                               p_los_dt_to_use_rl         in number,
                               p_los_dt_to_use_cd         in varchar2,
                               p_effective_date           in date,
                               p_object_version_number    in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_los_dt_to_use_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_los_dt_to_use_rl
    and    ff.formula_type_id = -156
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
  l_api_updating :=ben_lsf_shd.api_updating   --   88888
    (p_los_fctr_id                => p_los_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_los_dt_to_use_rl,hr_api.g_number)
      <>BEN_LSF_SHD.g_old_rec.los_dt_to_use_rl
      or not l_api_updating)
      and p_los_dt_to_use_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91064_INVLD_LOS_DT_USE_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  --
  -- Unless los_dt_to_use Code = Rule,  los_dt_to_use rule must be blank.
  if  nvl(p_los_dt_to_use_cd,hr_api.g_varchar2)  <> 'RL' and p_los_dt_to_use_rl is not null then
        --
        fnd_message.set_name('BEN', 'BEN_91072_LOS_DT_RL_NOT_NULL');
        fnd_message.raise_error;
        --
  elsif  nvl(p_los_dt_to_use_cd,hr_api.g_varchar2)  = 'RL' and p_los_dt_to_use_rl is null then
        --
        fnd_message.set_name('BEN', 'BEN_91099_LOS_DT_RL_NULL');
        fnd_message.raise_error;
        --
  end if;
  --
 hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_los_dt_to_use_rl;

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
--   los_fctr_id PK of record being inserted or updated.
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
Procedure chk_name(p_los_fctr_id                in number,
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
    from   ben_los_fctr  lsf
    where  lsf.business_group_id = p_business_group_id and
                 lsf.name = p_name;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lsf_shd.api_updating
    (p_los_fctr_id                => p_los_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_name,hr_api.g_varchar2)
      <> ben_lsf_shd.g_old_rec.name
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
------------------------------------------------------------------------
----
-- |------< chk_mn_mx_los_num >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that minimum los num is always less than
--    max los num.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id PK of record being inserted or updated.
--   mn_los_num Value of Minimum percentage.
--   mx_los_num Value of Maximum percentage.
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
Procedure chk_mn_mx_los_num(p_los_fctr_id              in number,
                         p_no_mn_los_num_apls_flag     in varchar2,
                         p_mn_los_num                  in number,
                         p_no_mx_los_num_apls_flag     in varchar2,
                         p_mx_los_num                  in number,
                         p_los_calc_rl                 in number,
                         p_los_det_cd                  in varchar2,
                         p_los_dt_to_use_cd            in varchar2,
                         p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_los_num';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  /*--
  -- los_calc_rl and (los_det_cd and los_dt_to_use_cd together) are
  -- mutually exclusive.
  --
  if ( p_los_calc_rl is not null and (p_los_det_cd is not null or
                                    p_los_dt_to_use_cd is not null)) or
     ( p_los_calc_rl is null and (p_los_det_cd is null or
                                    p_los_dt_to_use_cd is null))
  then
      --
      fnd_message.set_name('BEN','BEN_9XXXX_INV_CALC_RL_N_CDS');
      fnd_message.raise_error;
      --
  end if;
  --  */
  if p_mn_los_num is not null and p_mx_los_num is not null then
      --
      -- raise error if max value not greater than min value
      --
     -- Bug Fix 1873685
     if  (p_mx_los_num < p_mn_los_num)  then
     -- if  (p_mx_los_num <= p_mn_los_num)  then
     -- End fix 1873685
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
    end if;
      --
      --
  end if;
    --
      -- If No Minimum Percent value flag set to "on" (Y),
      --    then minimum percent value and calc rule must be blank.
      --
     if  nvl( p_no_mn_los_num_apls_flag, hr_api.g_varchar2)  = 'Y'
         and (p_mn_los_num  is not null /*or p_los_calc_rl is not null*/) then
         --
         fnd_message.set_name('BEN','BEN_92350_MIN_VAL_RULE');
         fnd_message.raise_error;
         --
    end if;
    --
    if   nvl( p_no_mn_los_num_apls_flag, hr_api.g_varchar2)  = 'N'  and
         nvl(p_no_mx_los_num_apls_flag, hr_api.g_varchar2) = 'N' and
         p_mn_los_num  is null and p_mx_los_num is null /* and
         p_los_calc_rl is null*/ then
         --
         fnd_message.set_name('BEN','BEN_92300_MIN_VAL_OR_RULE_REQ');
         fnd_message.raise_error;
         --
    end if;
      --
      -- If No Maximum Percent value flag set to "on" (Y),
      --    then maximum percent value and calc rule must be blank.
      --
     if  nvl( p_no_mx_los_num_apls_flag, hr_api.g_varchar2)  = 'Y'
         and (p_mx_los_num  is not null /* or p_los_calc_rl is not null */) then
         --
         fnd_message.set_name('BEN','BEN_92301_MAX_VAL_RULE');
         fnd_message.raise_error;
         --
     end if;
     --
     -- if p_los_calc_rl is null then
        if p_no_mn_los_num_apls_flag = 'Y' or p_mn_los_num is not null then
           --
           if p_no_mx_los_num_apls_flag = 'N' and p_mx_los_num is null then
              --
              fnd_message.set_name('BEN','BEN_91057_MAX_VAL_REQUIRED');
              fnd_message.raise_error;
              --
           end if;
        elsif p_no_mx_los_num_apls_flag = 'Y' or p_mx_los_num is not null then
           --
           if p_no_mn_los_num_apls_flag = 'N' and p_mn_los_num is null then
              --
              fnd_message.set_name('BEN','BEN_91055_MIN_VAL_REQUIRED');
              fnd_message.raise_error;
              --
           end if;
        end if;
     -- end if;
   --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_los_num;

--

-- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that los factor child records do not exist
--   when the user deletes the record in the ben_los_fctr table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   los_fctr_id        PK of record being inserted or updated.
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
procedure chk_child_records(p_los_fctr_id  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';

  --
/*   cursor chk_cmbn_age_los_fctr is select null
                                   from   ben_cmbn_age_los_fctr cla
                                   where  cla.los_fctr_id = p_los_fctr_id;*/
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

    --
 /*  open chk_cmbn_age_los_fctr;
     --
     -- fetch value from cursor if it returns a record then the
     -- the user cannot delete the los factor
     --
   fetch chk_cmbn_age_los_fctr into v_dummy;
   if chk_cmbn_age_los_fctr%found then
        close chk_cmbn_age_los_fctr;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91739_LOS_CHLD_RCD_EXISTS');
        fnd_message.raise_error;
        --
   end if;
   --
   close chk_cmbn_age_los_fctr;*/  --Bug 2978945 Used the common function instead of cursor
   --

  -- check if los factor record exists in the ben_cmbn_age_los_fctr table
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'ben_cmbn_age_los_fctr',
             p_base_key_column => 'los_fctr_id',
             p_base_key_value  => p_los_fctr_id
            )) Then
	       ben_utility.child_exists_error('ben_cmbn_age_los_fctr');
  End If;

  -- check if los factor record exists in the variable rates
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'ben_los_rt_f',
             p_base_key_column => 'los_fctr_id',
             p_base_key_value  => p_los_fctr_id
            )) Then
	       ben_utility.child_exists_error('ben_los_rt_f');
  End If;


  -- check if los factor record exists in the eligibility rates
  If (ben_batch_utils.rows_exist
            (p_base_table_name => 'ben_elig_los_prte_f',
             p_base_key_column => 'los_fctr_id',
             p_base_key_value  => p_los_fctr_id
            )) Then
	       ben_utility.child_exists_error('ben_elig_los_prte_f');
  End If;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_records;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_lsf_shd.g_rec_type
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
  chk_los_fctr_id
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_name         => p_rec.name,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  --
  chk_los_uom
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_los_uom         => p_rec.los_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_calc_rl
  (p_los_fctr_id           => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_los_calc_rl           => p_rec.los_calc_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_alt_val_to_use_cd
  (p_los_fctr_id           => p_rec.los_fctr_id,
   p_los_alt_val_to_use_cd => p_rec.los_alt_val_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_dt_to_use_cd
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_los_dt_to_use_cd         => p_rec.los_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_dt_to_use_rl
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_los_dt_to_use_rl        => p_rec.los_dt_to_use_rl,
   p_los_dt_to_use_cd        => p_rec.los_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_rndg_rl        => p_rec.rndg_rl,
   p_rndg_cd     =>  p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_det_cd
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_los_det_cd         => p_rec.los_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
   --
  chk_los_det_rl
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_los_det_rl        => p_rec.los_det_rl,
   p_los_det_cd        => p_rec.los_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 --
chk_no_mn_los_num_apls_flag
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_no_mn_los_num_apls_flag         => p_rec.no_mn_los_num_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
chk_no_mx_los_num_apls_flag
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_no_mx_los_num_apls_flag         => p_rec.no_mx_los_num_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --
  chk_mn_mx_los_num
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_no_mn_los_num_apls_flag   => p_rec.no_mn_los_num_apls_flag,
   p_mn_los_num         => p_rec.mn_los_num,
   p_no_mx_los_num_apls_flag   => p_rec.no_mx_los_num_apls_flag,
   p_mx_los_num         => p_rec.mx_los_num,
   p_los_calc_rl           => p_rec.los_calc_rl,
   p_los_det_cd            => p_rec.los_det_cd,
   p_los_dt_to_use_cd      => p_rec.los_dt_to_use_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_lsf_shd.g_rec_type
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
  chk_los_fctr_id
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_name         => p_rec.name,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  --
  chk_los_uom
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_los_uom         => p_rec.los_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_calc_rl
  (p_los_fctr_id           => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_los_calc_rl           => p_rec.los_calc_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_alt_val_to_use_cd
  (p_los_fctr_id           => p_rec.los_fctr_id,
   p_los_alt_val_to_use_cd => p_rec.los_alt_val_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_dt_to_use_cd
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_los_dt_to_use_cd         => p_rec.los_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_dt_to_use_rl
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_los_dt_to_use_rl        => p_rec.los_dt_to_use_rl,
   p_los_dt_to_use_cd        => p_rec.los_dt_to_use_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_rndg_cd         => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_rl
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_rndg_rl        => p_rec.rndg_rl,
   p_rndg_cd     =>  p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_det_cd
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_los_det_cd         => p_rec.los_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_los_det_rl
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_los_det_rl        => p_rec.los_det_rl,
   p_los_det_cd        => p_rec.los_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
chk_no_mn_los_num_apls_flag
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_no_mn_los_num_apls_flag         => p_rec.no_mn_los_num_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
chk_no_mx_los_num_apls_flag
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_no_mx_los_num_apls_flag         => p_rec.no_mx_los_num_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --
  chk_mn_mx_los_num
  (p_los_fctr_id          => p_rec.los_fctr_id,
   p_no_mn_los_num_apls_flag   => p_rec.no_mn_los_num_apls_flag,
   p_mn_los_num         => p_rec.mn_los_num,
   p_no_mx_los_num_apls_flag   => p_rec.no_mx_los_num_apls_flag,
   p_mx_los_num         => p_rec.mx_los_num,
   p_los_calc_rl           => p_rec.los_calc_rl,
   p_los_det_cd            => p_rec.los_det_cd,
   p_los_dt_to_use_cd      => p_rec.los_dt_to_use_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_lsf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  chk_child_records(p_los_fctr_id => p_rec.los_fctr_id);
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
  (p_los_fctr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_los_fctr b
    where b.los_fctr_id      = p_los_fctr_id
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
                             p_argument       => 'los_fctr_id',
                             p_argument_value => p_los_fctr_id);
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
end ben_lsf_bus;

/
