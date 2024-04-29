--------------------------------------------------------
--  DDL for Package Body BEN_ADE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ADE_BUS" as
/* $Header: beaderhi.pkb 120.2.12010000.3 2008/08/05 13:56:21 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ade_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_apld_dpnt_cvg_elig_prfl_id >------|
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
--   apld_dpnt_cvg_elig_prfl_id PK of record being inserted or updated.
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
Procedure chk_apld_dpnt_cvg_elig_prfl_id(p_apld_dpnt_cvg_elig_prfl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_apld_dpnt_cvg_elig_prfl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ade_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_apld_dpnt_cvg_elig_prfl_id                => p_apld_dpnt_cvg_elig_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_apld_dpnt_cvg_elig_prfl_id,hr_api.g_number)
     <>  ben_ade_shd.g_old_rec.apld_dpnt_cvg_elig_prfl_id) then
    --
    -- raise error as PK has changed
    --
    ben_ade_shd.constraint_error('BEN_APLD_DPNT_CVG_ELG_P_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_apld_dpnt_cvg_elig_prfl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ade_shd.constraint_error('BEN_APLD_DPNT_CVG_ELG_P_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_apld_dpnt_cvg_elig_prfl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_eligy_prfl_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that the value is unique within parent
--   and within bus grp. The FK check is done elsewhere in the dt logic.
--
-- Pre Conditions
--   None.
--
-- In Parameters
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
Procedure chk_dpnt_cvg_eligy_prfl_id(p_apld_dpnt_cvg_elig_prfl_id    in number,
                            p_dpnt_cvg_eligy_prfl_id in number,
                            p_pgm_id                 in number,
                            p_ptip_id                in number,
                            p_pl_id                   in number,
                            p_effective_date              in date,
				    p_validation_start_date         in date,
                            p_validation_end_date           in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is


 --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_eligy_prfl_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  l_effective_start_date date;

  --
  cursor chk_unique is
     select null,effective_start_date
        from ben_apld_dpnt_cvg_elig_prfl_f
        where dpnt_cvg_eligy_prfl_id = p_dpnt_cvg_eligy_prfl_id
          and apld_dpnt_cvg_elig_prfl_id <> nvl(p_apld_dpnt_cvg_elig_prfl_id, hr_api.g_number)
          and (ptip_id = p_ptip_id or pgm_id = p_pgm_id or pl_id = p_pl_id)
          and business_group_id + 0 = p_business_group_id
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date
 	  order by effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ade_shd.api_updating
    (p_apld_dpnt_cvg_elig_prfl_id               => p_apld_dpnt_cvg_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_cvg_eligy_prfl_id
      <> nvl(ben_ade_shd.g_old_rec.dpnt_cvg_eligy_prfl_id ,hr_api.g_number)
      or not l_api_updating) then
    --
    -- this value must be unique
    --
    open chk_unique;
    fetch chk_unique into l_exists,l_effective_start_date;
    if chk_unique%found then
      close chk_unique;
      --
      -- raise error as UK1 is violated
      --
  --Bug No 4999894 Message text has been edited

      fnd_message.set_name('BEN','BEN_91629_VALUE_NOT_UNIQUE');
      fnd_message.set_token('PARMA',fnd_date.date_to_displaydate(l_effective_start_date));
      fnd_message.raise_error;

 -- End of Bug 4999894
      --
      --
    end if;
    --
    close chk_unique;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_cvg_eligy_prfl_id ;
--


-- ----------------------------------------------------------------------------
-- |------< chk_mndtry_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   apld_dpnt_cvg_elig_prfl_id PK of record being inserted or updated.
--   mndtry_flag Value of lookup code.
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
Procedure chk_mndtry_flag(p_apld_dpnt_cvg_elig_prfl_id                in number,
                            p_mndtry_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mndtry_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ade_shd.api_updating
    (p_apld_dpnt_cvg_elig_prfl_id                => p_apld_dpnt_cvg_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mndtry_flag
      <> nvl(ben_ade_shd.g_old_rec.mndtry_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mndtry_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_mndtry_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_mndtry_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mndtry_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_apld_dpnt_cvg_elig_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   apld_dpnt_cvg_elig_prfl_id PK of record being inserted or updated.
--   apld_dpnt_cvg_elig_rl Value of formula rule id.
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
Procedure chk_apld_dpnt_cvg_elig_rl(p_apld_dpnt_cvg_elig_prfl_id                in number,
                             p_apld_dpnt_cvg_elig_rl              in number,
                             p_effective_date              in date,
                             p_business_group_id           in number,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_apld_dpnt_cvg_elig_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_apld_dpnt_cvg_elig_rl
    and    ff.formula_type_id = -35
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
  l_api_updating := ben_ade_shd.api_updating
    (p_apld_dpnt_cvg_elig_prfl_id                => p_apld_dpnt_cvg_elig_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_apld_dpnt_cvg_elig_rl,hr_api.g_number)
      <> ben_ade_shd.g_old_rec.apld_dpnt_cvg_elig_rl
      or not l_api_updating)
      and p_apld_dpnt_cvg_elig_rl is not null then
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
      fnd_message.set_name('BEN','BEN_91630_ELIG_RULE_NOT_VALID');
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
end chk_apld_dpnt_cvg_elig_rl;
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
            (p_apld_dpnt_cvg_elig_rl           in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
             p_ptip_id                       in number default hr_api.g_number,
             p_dpnt_cvg_eligy_prfl_id        in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
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
    If ((nvl(p_apld_dpnt_cvg_elig_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_apld_dpnt_cvg_elig_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
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
    If ((nvl(p_dpnt_cvg_eligy_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_dpnt_cvg_eligy_prfl_f',
             p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
             p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_dpnt_cvg_eligy_prfl_f';
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
            (p_apld_dpnt_cvg_elig_prfl_id		in number,
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
       p_argument       => 'apld_dpnt_cvg_elig_prfl_id',
       p_argument_value => p_apld_dpnt_cvg_elig_prfl_id);
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
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_ade_shd.g_rec_type,
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
  chk_apld_dpnt_cvg_elig_prfl_id
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_eligy_prfl_id
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_dpnt_cvg_eligy_prfl_id => p_rec.dpnt_cvg_eligy_prfl_id,
   p_pgm_id              => p_rec.pgm_id,
   p_ptip_id              => p_rec.ptip_id,
   p_pl_id              => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
--
  chk_mndtry_flag
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_mndtry_flag         => p_rec.mndtry_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_apld_dpnt_cvg_elig_rl
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_apld_dpnt_cvg_elig_rl        => p_rec.apld_dpnt_cvg_elig_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ade_shd.g_rec_type,
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
  chk_apld_dpnt_cvg_elig_prfl_id
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_cvg_eligy_prfl_id
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_dpnt_cvg_eligy_prfl_id          => p_rec.dpnt_cvg_eligy_prfl_id,
   p_pgm_id              => p_rec.pgm_id,
   p_ptip_id              => p_rec.ptip_id,
   p_pl_id              => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mndtry_flag
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_mndtry_flag         => p_rec.mndtry_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_apld_dpnt_cvg_elig_rl
  (p_apld_dpnt_cvg_elig_prfl_id          => p_rec.apld_dpnt_cvg_elig_prfl_id,
   p_apld_dpnt_cvg_elig_rl        => p_rec.apld_dpnt_cvg_elig_rl,
   p_effective_date        => p_effective_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_apld_dpnt_cvg_elig_rl           => p_rec.apld_dpnt_cvg_elig_rl,
             p_pgm_id                        => p_rec.pgm_id,
             p_ptip_id                       => p_rec.ptip_id,
             p_dpnt_cvg_eligy_prfl_id        => p_rec.dpnt_cvg_eligy_prfl_id,
             p_pl_id                         => p_rec.pl_id,
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
	(p_rec 			 in ben_ade_shd.g_rec_type,
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
     p_apld_dpnt_cvg_elig_prfl_id		=> p_rec.apld_dpnt_cvg_elig_prfl_id);
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
  (p_apld_dpnt_cvg_elig_prfl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_apld_dpnt_cvg_elig_prfl_f b
    where b.apld_dpnt_cvg_elig_prfl_id      = p_apld_dpnt_cvg_elig_prfl_id
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
                             p_argument       => 'apld_dpnt_cvg_elig_prfl_id',
                             p_argument_value => p_apld_dpnt_cvg_elig_prfl_id);
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
end ben_ade_bus;

/
