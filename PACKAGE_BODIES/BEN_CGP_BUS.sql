--------------------------------------------------------
--  DDL for Package Body BEN_CGP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CGP_BUS" as
/* $Header: becgprhi.pkb 120.0 2005/05/28 01:01:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cgp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_cntng_prtn_elig_prfl_id >------|
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
--   cntng_prtn_elig_prfl_id PK of record being inserted or updated.
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
Procedure chk_cntng_prtn_elig_prfl_id(p_cntng_prtn_elig_prfl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cntng_prtn_elig_prfl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cgp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_cntng_prtn_elig_prfl_id                => p_cntng_prtn_elig_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cntng_prtn_elig_prfl_id,hr_api.g_number)
     <>  ben_cgp_shd.g_old_rec.cntng_prtn_elig_prfl_id) then
    --
    -- raise error as PK has changed
    --
    ben_cgp_shd.constraint_error('BEN_CNTNG_PRTN_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cntng_prtn_elig_prfl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cgp_shd.constraint_error('BEN_CNTNG_PRTN_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cntng_prtn_elig_prfl_id;
--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_cntng_frmr_prtt_dsge_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cntng_prtn_elig_prfl_id PK of record being inserted or updated.
--   cntng_frmr_prtt_dsge_rl Value of formula rule id.
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
Procedure chk_cntng_frmr_prtt_dsge_rl(p_cntng_prtn_elig_prfl_id     in number,
                             p_cntng_frmr_prtt_dsge_rl              in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cntng_frmr_prtt_dsge_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_cntng_frmr_prtt_dsge_rl
    and    ff.formula_type_id = -160
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
  l_api_updating := ben_cgp_shd.api_updating
    (p_cntng_prtn_elig_prfl_id                => p_cntng_prtn_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cntng_frmr_prtt_dsge_rl,hr_api.g_number)
      <> ben_cgp_shd.g_old_rec.cntng_frmr_prtt_dsge_rl
      or not l_api_updating)
      and p_cntng_frmr_prtt_dsge_rl is not null then
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
        fnd_message.set_name('PAY','FORMULA_DOES_NOT_EXIST');
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
end chk_cntng_frmr_prtt_dsge_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cntng_frmr_prtt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cntng_prtn_elig_prfl_id PK of record being inserted or updated.
--   cntng_frmr_prtt_rl Value of formula rule id.
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
Procedure chk_cntng_frmr_prtt_rl(p_cntng_prtn_elig_prfl_id                in number,
                             p_cntng_frmr_prtt_rl              in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cntng_frmr_prtt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
    where  ff.formula_id = p_cntng_frmr_prtt_rl
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cgp_shd.api_updating
    (p_cntng_prtn_elig_prfl_id                => p_cntng_prtn_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_cntng_frmr_prtt_rl,hr_api.g_number)
      <> ben_cgp_shd.g_old_rec.cntng_frmr_prtt_rl
      or not l_api_updating)
      and p_cntng_frmr_prtt_rl is not null then
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
        fnd_message.set_name('PAY','FORMULA_DOES_NOT_EXIST');
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
end chk_cntng_frmr_prtt_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dsge_must_be_redsgd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cntng_prtn_elig_prfl_id PK of record being inserted or updated.
--   dsge_must_be_redsgd_flag Value of lookup code.
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
Procedure chk_dsge_must_be_redsgd_flag(p_cntng_prtn_elig_prfl_id                in number,
                            p_dsge_must_be_redsgd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dsge_must_be_redsgd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cgp_shd.api_updating
    (p_cntng_prtn_elig_prfl_id                => p_cntng_prtn_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dsge_must_be_redsgd_flag
      <> nvl(ben_cgp_shd.g_old_rec.dsge_must_be_redsgd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'ENTER-LKP-TYPE',
           p_lookup_code    => p_dsge_must_be_redsgd_flag,
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
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dsge_must_be_redsgd_flag;
--
*/
-- ----------------------------------------------------------------------------
-- |------< chk_pymt_must_be_rcvd_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cntng_prtn_elig_prfl_id PK of record being inserted or updated.
--   pymt_must_be_rcvd_rl Value of formula rule id.
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
Procedure chk_pymt_must_be_rcvd_rl(p_cntng_prtn_elig_prfl_id                in number,
                             p_pymt_must_be_rcvd_rl        in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pymt_must_be_rcvd_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           , per_business_groups pbg
    where  ff.formula_id = p_pymt_must_be_rcvd_rl
    and    ff.formula_type_id = -142
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
  l_api_updating := ben_cgp_shd.api_updating
    (p_cntng_prtn_elig_prfl_id                => p_cntng_prtn_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_pymt_must_be_rcvd_rl,hr_api.g_number)
      <> ben_cgp_shd.g_old_rec.pymt_must_be_rcvd_rl
      or not l_api_updating)
      and p_pymt_must_be_rcvd_rl is not null then
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
        fnd_message.set_token('ID',p_pymt_must_be_rcvd_rl);
        fnd_message.set_token('TYPE_ID',-142);
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
end chk_pymt_must_be_rcvd_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pymt_must_be_rcvd_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cntng_prtn_elig_prfl_id PK of record being inserted or updated.
--   pymt_must_be_rcvd_uom Value of lookup code.
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
Procedure chk_pymt_must_be_rcvd_uom
          (p_cntng_prtn_elig_prfl_id     in number,
           p_pymt_must_be_rcvd_uom       in varchar2,
           p_effective_date              in date,
           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pymt_must_be_rcvd_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cgp_shd.api_updating
    (p_cntng_prtn_elig_prfl_id     => p_cntng_prtn_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pymt_must_be_rcvd_uom
      <> nvl(ben_cgp_shd.g_old_rec.pymt_must_be_rcvd_uom,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_pymt_must_be_rcvd_uom is not null then
       if hr_api.not_exists_in_hr_lookups
             (p_lookup_type    => 'BEN_TM_UOM',
              p_lookup_code    => p_pymt_must_be_rcvd_uom,
              p_effective_date => p_effective_date) then
         --
         -- raise error as does not exist as lookup
         --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pymt_must_be_rcvd_uom');
      fnd_message.set_token('TYPE','BEN_TM_UOM');
      fnd_message.raise_error;
         --
       end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pymt_must_be_rcvd_uom;
--
-- ----------------------------------------------------------------------------
-- |------<chk_pymt_must_be_rcvd_dep>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check NUM/UOM/Rule dependency.
--      1)If NUM os specified then must specify UOM
--      2)If Rule is specified then can not specify NUM or UOM
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cntng_prtn_elig_prfl_id PK of record being inserted or updated.
--   pymt_must_be_rcvd_rl Value of formula rule id.
--   pymt_must_be_rcvd_num
--   pymt_must_be_rcvd_uom
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
Procedure chk_pymt_must_be_rcvd_dep(p_cntng_prtn_elig_prfl_id     in number,
                                           p_pymt_must_be_rcvd_rl        in number,
                                           p_pymt_must_be_rcvd_num       in number,
                                           p_pymt_must_be_rcvd_uom       in varchar2,
                                           p_business_group_id           in number,
                                           p_effective_date              in date,
                                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pymt_must_be_rcvd_dep';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cgp_shd.api_updating
    (p_cntng_prtn_elig_prfl_id                => p_cntng_prtn_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_pymt_must_be_rcvd_rl,hr_api.g_number)
      <> nvl(ben_cgp_shd.g_old_rec.pymt_must_be_rcvd_rl, hr_api.g_number) or
         nvl(p_pymt_must_be_rcvd_num,hr_api.g_number)
      <> nvl(ben_cgp_shd.g_old_rec.pymt_must_be_rcvd_num, hr_api.g_number) or
         nvl(p_pymt_must_be_rcvd_uom,hr_api.g_varchar2)
      <> nvl(ben_cgp_shd.g_old_rec.pymt_must_be_rcvd_uom, hr_api.g_varchar2)
      or not l_api_updating) then
    --
    if (p_pymt_must_be_rcvd_num is not null and p_pymt_must_be_rcvd_uom is null) then
       -- num without uom - raise error
        --
        fnd_message.set_name('BEN','BEN_12345_NEED_UOM');
        fnd_message.raise_error;
        --
    end if;
    --
    if (p_pymt_must_be_rcvd_rl is not null and (p_pymt_must_be_rcvd_uom is not null or
                                                   p_pymt_must_be_rcvd_num is not null))
    then
       -- can not have num/uom with rule - raise error
        --
        fnd_message.set_name('BEN','BEN_98765_UOM_AND_RL_CHOSEN');
        fnd_message.raise_error;
        --
    end if;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pymt_must_be_rcvd_dep;
--
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
            (p_eligy_prfl_id                 in number default hr_api.g_number,
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
    If ((nvl(p_eligy_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_eligy_prfl_f',
             p_base_key_column => 'eligy_prfl_id',
             p_base_key_value  => p_eligy_prfl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_eligy_prfl_f';
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
       ben_utility.parent_integrity_error(p_table_name => l_table_name);
    --
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
            (p_cntng_prtn_elig_prfl_id		in number,
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
       p_argument       => 'cntng_prtn_elig_prfl_id',
       p_argument_value => p_cntng_prtn_elig_prfl_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cntnu_prtn_ctfn_typ_f',
           p_base_key_column => 'cntng_prtn_elig_prfl_id',
           p_base_key_value  => p_cntng_prtn_elig_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cntnu_prtn_ctfn_typ_f';
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
       ben_utility.child_exists_error(p_table_name => l_table_name);
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_cgp_shd.g_rec_type,
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
  chk_cntng_prtn_elig_prfl_id
  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
--  chk_cntng_frmr_prtt_dsge_rl
--  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
--   p_cntng_frmr_prtt_dsge_rl        => p_rec.cntng_frmr_prtt_dsge_rl,
--   p_effective_date        => p_effective_date,
--   p_object_version_number => p_rec.object_version_number);
  --
--  chk_cntng_frmr_prtt_rl
--  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
--   p_cntng_frmr_prtt_rl        => p_rec.cntng_frmr_prtt_rl,
--   p_effective_date        => p_effective_date,
--   p_object_version_number => p_rec.object_version_number);
  --
--  chk_dsge_must_be_redsgd_flag
--  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
--   p_dsge_must_be_redsgd_flag         => p_rec.dsge_must_be_redsgd_flag,
--   p_effective_date        => p_effective_date,
--   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pymt_must_be_rcvd_rl
  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
   p_pymt_must_be_rcvd_rl        => p_rec.pymt_must_be_rcvd_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pymt_must_be_rcvd_uom
  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
   p_pymt_must_be_rcvd_uom         => p_rec.pymt_must_be_rcvd_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pymt_must_be_rcvd_dep(p_cntng_prtn_elig_prfl_id  => p_rec.cntng_prtn_elig_prfl_id,
                                   p_pymt_must_be_rcvd_rl     => p_rec.pymt_must_be_rcvd_rl,
                                   p_pymt_must_be_rcvd_num    => p_rec.pymt_must_be_rcvd_num,
                                   p_pymt_must_be_rcvd_uom    => p_rec.pymt_must_be_rcvd_uom,
                                   p_business_group_id        => p_rec.business_group_id,
                                   p_effective_date           => p_effective_date,
                                   p_object_version_number    => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cgp_shd.g_rec_type,
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
  chk_cntng_prtn_elig_prfl_id
  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
/*
--  chk_cntng_frmr_prtt_dsge_rl
--  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
--   p_cntng_frmr_prtt_dsge_rl        => p_rec.cntng_frmr_prtt_dsge_rl,
--   p_effective_date        => p_effective_date,
--   p_object_version_number => p_rec.object_version_number);
  --
--  chk_cntng_frmr_prtt_rl
--  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
--   p_cntng_frmr_prtt_rl        => p_rec.cntng_frmr_prtt_rl,
--   p_effective_date        => p_effective_date,
--   p_object_version_number => p_rec.object_version_number);
  --
--  chk_dsge_must_be_redsgd_flag
--  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
--   p_dsge_must_be_redsgd_flag         => p_rec.dsge_must_be_redsgd_flag,
--   p_effective_date        => p_effective_date,
--   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_pymt_must_be_rcvd_rl
  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
   p_pymt_must_be_rcvd_rl        => p_rec.pymt_must_be_rcvd_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pymt_must_be_rcvd_uom
  (p_cntng_prtn_elig_prfl_id          => p_rec.cntng_prtn_elig_prfl_id,
   p_pymt_must_be_rcvd_uom         => p_rec.pymt_must_be_rcvd_uom,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_pymt_must_be_rcvd_dep(p_cntng_prtn_elig_prfl_id  => p_rec.cntng_prtn_elig_prfl_id,
                                   p_pymt_must_be_rcvd_rl     => p_rec.pymt_must_be_rcvd_rl,
                                   p_pymt_must_be_rcvd_num    => p_rec.pymt_must_be_rcvd_num,
                                   p_pymt_must_be_rcvd_uom    => p_rec.pymt_must_be_rcvd_uom,
                                   p_business_group_id        => p_rec.business_group_id,
                                   p_effective_date           => p_effective_date,
                                   p_object_version_number    => p_rec.object_version_number);
  --
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_eligy_prfl_id                 => p_rec.eligy_prfl_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_cgp_shd.g_rec_type,
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
     p_cntng_prtn_elig_prfl_id		=> p_rec.cntng_prtn_elig_prfl_id);
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
  (p_cntng_prtn_elig_prfl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cntng_prtn_elig_prfl_f b
    where b.cntng_prtn_elig_prfl_id      = p_cntng_prtn_elig_prfl_id
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
                             p_argument       => 'cntng_prtn_elig_prfl_id',
                             p_argument_value => p_cntng_prtn_elig_prfl_id);
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
end ben_cgp_bus;

/
