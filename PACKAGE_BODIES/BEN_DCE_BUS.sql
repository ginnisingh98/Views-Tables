--------------------------------------------------------
--  DDL for Package Body BEN_DCE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DCE_BUS" as
/* $Header: bedcerhi.pkb 120.0.12010000.2 2010/04/07 06:40:25 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_dce_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_eligy_prfl_id >------|
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
--   dpnt_cvg_eligy_prfl_id PK of record being inserted or updated.
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
Procedure chk_dpnt_cvg_eligy_prfl_id(p_dpnt_cvg_eligy_prfl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_eligy_prfl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_dce_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_dpnt_cvg_eligy_prfl_id      => p_dpnt_cvg_eligy_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dpnt_cvg_eligy_prfl_id,hr_api.g_number)
     <>  ben_dce_shd.g_old_rec.dpnt_cvg_eligy_prfl_id) then
    --
    -- raise error as PK has changed
    --
    ben_dce_shd.constraint_error('BEN_DPNT_CVG_ELG_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_dpnt_cvg_eligy_prfl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_dce_shd.constraint_error('BEN_DPNT_CVG_ELG_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dpnt_cvg_eligy_prfl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_elig_det_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dpnt_cvg_eligy_prfl_id PK of record being inserted or updated.
--   dpnt_cvg_elig_det_rl Value of formula rule id.
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
Procedure chk_dpnt_cvg_elig_det_rl(p_dpnt_cvg_eligy_prfl_id   	in number,
                             p_dpnt_cvg_elig_det_rl        	in number,
                             p_business_group_id                in number,
                             p_effective_date              	in date,
                             p_object_version_number       	in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_elig_det_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_dpnt_cvg_elig_det_rl
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
  l_api_updating := ben_dce_shd.api_updating
    (p_dpnt_cvg_eligy_prfl_id      => p_dpnt_cvg_eligy_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_elig_det_rl,hr_api.g_number)
      <> ben_dce_shd.g_old_rec.dpnt_cvg_elig_det_rl
      or not l_api_updating)
      and p_dpnt_cvg_elig_det_rl is not null then
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
        fnd_message.set_token('ID',p_dpnt_cvg_elig_det_rl);
        fnd_message.set_token('TYPE_ID',-35);
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
end chk_dpnt_cvg_elig_det_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_cvg_eligy_prfl_stat >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dpnt_cvg_eligy_prfl_id PK of record being inserted or updated.
--   dpnt_cvg_eligy_prfl_stat_cd Value of lookup code.
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
Procedure chk_dpnt_cvg_eligy_prfl_stat(p_dpnt_cvg_eligy_prfl_id    	in number,
                            p_dpnt_cvg_eligy_prfl_stat_cd               in varchar2,
                            p_effective_date              		in date,
                            p_object_version_number       		in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_cvg_eligy_prfl_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_dce_shd.api_updating
    (p_dpnt_cvg_eligy_prfl_id      => p_dpnt_cvg_eligy_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_cvg_eligy_prfl_stat_cd
      <> nvl(ben_dce_shd.g_old_rec.dpnt_cvg_eligy_prfl_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_cvg_eligy_prfl_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_dpnt_cvg_eligy_prfl_stat_cd,
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
end chk_dpnt_cvg_eligy_prfl_stat;

--
-- ----------------------------------------------------------------------------
-- |------< chk_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to make sure the name is unique..
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dpnt_cvg_eligy_prfl_id 	PK of record being inserted or updated.
--   name  			Value of name.
--   effective_date 		effective date
--   validate_start_date	Validation start date.
--   validate_end_date		Validation End Date.
--   business_group_id		Group ID
--   object_version_number 	Object version number of record being
--                         	inserted or updated.
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
Procedure chk_name(	p_dpnt_cvg_eligy_prfl_id    	in number,
			p_name				in varchar2,
                        p_effective_date              	in date,
			p_validate_start_date		in date,
			p_validate_end_date		in date,
			p_business_group_id		in number,
                   	p_object_version_number       	in number) is
  --
  l_proc          varchar2(72) := g_package||'chk_name';
  l_api_updating  boolean;
  l_exists	  varchar2(1);
  --
  cursor csr_name is
	select null
 		from BEN_DPNT_CVG_ELIGY_PRFL_F
		where name = p_name
		and dpnt_cvg_eligy_prfl_id <> nvl(p_dpnt_cvg_eligy_prfl_id, hr_api.g_number)
		and business_group_id + 0 = p_business_group_id
  		and p_validate_start_date <= effective_end_date
		and p_validate_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_dce_shd.api_updating
    (p_dpnt_cvg_eligy_prfl_id      => p_dpnt_cvg_eligy_prfl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_name <> ben_dce_shd.g_old_rec.name)
      or not l_api_updating then
 	hr_utility.set_location('Entering:' || l_proc,10);
 	--
	-- Check if this name already exists.
 	--
 	open csr_name;
	fetch csr_name into l_exists;
 	if csr_name%found then
		close csr_name;
		--
 		-- raise error as UK1 is violated.
		--
 		ben_dce_shd.constraint_error('BEN_DPNT_CVG_ELG_UK1');
 	end if;
 	close csr_name;
   --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,20);
  --
end chk_name;

--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_lookups >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
-- p_dpnt_cvg_eligy_prfl_id
-- p_dpnt_rlshp_flag
-- p_dpnt_age_flag
-- p_dpnt_stud_flag
-- p_dpnt_dsbld_flag
-- p_dpnt_mrtl_flag
-- p_dpnt_mltry_flag
-- p_dpnt_pstl_flag
-- p_dpnt_cvrd_in_anthr_pl_flag
-- p_dpnt_dsgnt_crntly_enrld_flag
-- p_effective_date
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_lookups(p_dpnt_cvg_eligy_prfl_id    in number,
			  p_dpnt_rlshp_flag                in  varchar2,
			  p_dpnt_age_flag                  in  varchar2,
			  p_dpnt_stud_flag                 in  varchar2,
			  p_dpnt_dsbld_flag                in  varchar2,
			  p_dpnt_mrtl_flag                 in  varchar2,
			  p_dpnt_mltry_flag                in  varchar2,
			  p_dpnt_pstl_flag                 in  varchar2,
			  p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2,
			  p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2,
                          p_effective_date                 in  date) is
--
  l_proc         varchar2(72) := g_package||'chk_lookups';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_rlshp_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_rlshp_flag ');
    fnd_message.raise_error;
    --
  end if;
--

  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_age_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_age_flag ');
    fnd_message.raise_error;
    --
  end if;
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_stud_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_stud_flag ');
    fnd_message.raise_error;
    --
  end if;
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_dsbld_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_dsbld_flag ');
    fnd_message.raise_error;
    --
  end if;
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_mrtl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_mrtl_flag ');
    fnd_message.raise_error;
    --
  end if;
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_mltry_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_mltry_flag ');
    fnd_message.raise_error;
    --
  end if;
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_pstl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_pstl_flag ');
    fnd_message.raise_error;
    --
  end if;
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_cvrd_in_anthr_pl_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_cvrd_in_anthr_pl_flag ');
    fnd_message.raise_error;
    --
  end if;
  if hr_api.not_exists_in_hr_lookups
        (p_lookup_type    => 'YES_NO',
         p_lookup_code    =>p_dpnt_dsgnt_crntly_enrld_flag,
         p_effective_date => p_effective_date) then
    --
    -- raise error as does not exist as lookup
    --
    fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
    fnd_message.set_token('TYPE','YES_NO');
    fnd_message.set_token('FIELD','dpnt_dsgnt_crntly_enrld_flag ');
    fnd_message.raise_error;
    --
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 5);
End Chk_lookups;
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
            (p_regn_id                       in number default hr_api.g_number,
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
    If ((nvl(p_regn_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_regn_f',
             p_base_key_column => 'regn_id',
             p_base_key_value  => p_regn_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_regn_f';
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
            (p_dpnt_cvg_eligy_prfl_id		in number,
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
       p_argument       => 'dpnt_cvg_eligy_prfl_id',
       p_argument_value => p_dpnt_cvg_eligy_prfl_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_dpnt_cvg_rqd_rlshp_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_dpnt_cvg_rqd_rlshp_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_age_cvg_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_age_cvg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_mrtl_stat_cvg_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_mrtl_stat_cvg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_mltry_stat_cvg_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_mltry_stat_cvg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_dsbld_stat_cvg_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_dsbld_stat_cvg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_stdnt_stat_cvg_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_stdnt_stat_cvg_f';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_dpnt_cvrd_anthr_pl_cvg_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_dpnt_cvrd_anthr_pl_cvg_f';
      Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_dsgntr_enrld_cvg_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_dsgntr_enrld_cvg_f';
      Raise l_rows_exist;
    End If;
    --
/*
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_apld_dpnt_cvg_elig_prfl_f',
           p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
           p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_apld_dpnt_cvg_elig_prfl_f';
      Raise l_rows_exist;
    End If;
*/
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
	(p_rec 			 in ben_dce_shd.g_rec_type,
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
  chk_dpnt_cvg_eligy_prfl_id
  (p_dpnt_cvg_eligy_prfl_id	=> p_rec.dpnt_cvg_eligy_prfl_id,
   p_effective_date        	=> p_effective_date,
   p_object_version_number 	=> p_rec.object_version_number);
  --
  chk_dpnt_cvg_elig_det_rl
  (p_dpnt_cvg_eligy_prfl_id   	=> p_rec.dpnt_cvg_eligy_prfl_id,
   p_dpnt_cvg_elig_det_rl    	=> p_rec.dpnt_cvg_elig_det_rl,
   p_business_group_id          => p_rec.business_group_id,
   p_effective_date        	=> p_effective_date,
   p_object_version_number 	=> p_rec.object_version_number);
  --
  chk_dpnt_cvg_eligy_prfl_stat
  (p_dpnt_cvg_eligy_prfl_id   		=> p_rec.dpnt_cvg_eligy_prfl_id,
   p_dpnt_cvg_eligy_prfl_stat_cd      	=> p_rec.dpnt_cvg_eligy_prfl_stat_cd,
   p_effective_date        		=> p_effective_date,
   p_object_version_number 		=> p_rec.object_version_number);
  --
  chk_name
  (p_dpnt_cvg_eligy_prfl_id		=> p_rec.dpnt_cvg_eligy_prfl_id,
   p_name				=> p_rec.name,
   p_effective_date			=> p_effective_date,
   p_validate_start_date		=> p_validation_start_date,
   p_validate_end_date 			=> p_validation_end_date,
   p_business_group_id 			=> p_rec.business_group_id,
   p_object_version_number		=> p_rec.object_version_number);
  --
   chk_lookups
    (p_dpnt_cvg_eligy_prfl_id          =>p_rec.dpnt_cvg_eligy_prfl_id,
     p_dpnt_rlshp_flag                 =>p_rec.dpnt_rlshp_flag,
     p_dpnt_age_flag                   =>p_rec.dpnt_age_flag,
     p_dpnt_stud_flag                  =>p_rec.dpnt_stud_flag,
     p_dpnt_dsbld_flag                 =>p_rec.dpnt_dsbld_flag,
     p_dpnt_mrtl_flag                  =>p_rec.dpnt_mrtl_flag,
     p_dpnt_mltry_flag                 =>p_rec.dpnt_mltry_flag,
     p_dpnt_pstl_flag                  =>p_rec.dpnt_pstl_flag,
     p_dpnt_cvrd_in_anthr_pl_flag      =>p_rec.dpnt_cvrd_in_anthr_pl_flag,
     p_dpnt_dsgnt_crntly_enrld_flag    =>p_rec.dpnt_dsgnt_crntly_enrld_flag,
     p_effective_date                  =>p_effective_date);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_dce_shd.g_rec_type,
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
  chk_dpnt_cvg_eligy_prfl_id
  (p_dpnt_cvg_eligy_prfl_id     => p_rec.dpnt_cvg_eligy_prfl_id,
   p_effective_date        	=> p_effective_date,
   p_object_version_number 	=> p_rec.object_version_number);
  --
  chk_dpnt_cvg_elig_det_rl
  (p_dpnt_cvg_eligy_prfl_id   	=> p_rec.dpnt_cvg_eligy_prfl_id,
   p_dpnt_cvg_elig_det_rl     	=> p_rec.dpnt_cvg_elig_det_rl,
   p_business_group_id          => p_rec.business_group_id,
   p_effective_date        	=> p_effective_date,
   p_object_version_number 	=> p_rec.object_version_number);
  --
  chk_dpnt_cvg_eligy_prfl_stat
  (p_dpnt_cvg_eligy_prfl_id       	=> p_rec.dpnt_cvg_eligy_prfl_id,
   p_dpnt_cvg_eligy_prfl_stat_cd      	=> p_rec.dpnt_cvg_eligy_prfl_stat_cd,
   p_effective_date        		=> p_effective_date,
   p_object_version_number 		=> p_rec.object_version_number);
  --
  chk_name
  (p_dpnt_cvg_eligy_prfl_id		=> p_rec.dpnt_cvg_eligy_prfl_id,
   p_name				=> p_rec.name,
   p_effective_date			=> p_effective_date,
   p_validate_start_date		=> p_validation_start_date,
   p_validate_end_date 			=> p_validation_end_date,
   p_business_group_id 			=> p_rec.business_group_id,
   p_object_version_number		=> p_rec.object_version_number);
  --
   chk_lookups
    (p_dpnt_cvg_eligy_prfl_id          =>p_rec.dpnt_cvg_eligy_prfl_id,
     p_dpnt_rlshp_flag                 =>p_rec.dpnt_rlshp_flag,
     p_dpnt_age_flag                   =>p_rec.dpnt_age_flag,
     p_dpnt_stud_flag                  =>p_rec.dpnt_stud_flag,
     p_dpnt_dsbld_flag                 =>p_rec.dpnt_dsbld_flag,
     p_dpnt_mrtl_flag                  =>p_rec.dpnt_mrtl_flag,
     p_dpnt_mltry_flag                 =>p_rec.dpnt_mltry_flag,
     p_dpnt_pstl_flag                  =>p_rec.dpnt_pstl_flag,
     p_dpnt_cvrd_in_anthr_pl_flag      =>p_rec.dpnt_cvrd_in_anthr_pl_flag,
     p_dpnt_dsgnt_crntly_enrld_flag    =>p_rec.dpnt_dsgnt_crntly_enrld_flag,
     p_effective_date                  =>p_effective_date);
--
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_regn_id                       => p_rec.regn_id,
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
	(p_rec 			 in ben_dce_shd.g_rec_type,
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
     p_dpnt_cvg_eligy_prfl_id		=> p_rec.dpnt_cvg_eligy_prfl_id);
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
  (p_dpnt_cvg_eligy_prfl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_dpnt_cvg_eligy_prfl_f b
    where b.dpnt_cvg_eligy_prfl_id      = p_dpnt_cvg_eligy_prfl_id
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
                             p_argument       => 'dpnt_cvg_eligy_prfl_id',
                             p_argument_value => p_dpnt_cvg_eligy_prfl_id);
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
end ben_dce_bus;

/
