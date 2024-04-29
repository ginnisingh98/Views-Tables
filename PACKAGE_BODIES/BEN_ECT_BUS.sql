--------------------------------------------------------
--  DDL for Package Body BEN_ECT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECT_BUS" as
/* $Header: beectrhi.pkb 120.0 2005/05/28 01:54:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ect_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_dsblty_ctg_prte_id >------|
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
--   elig_dsblty_ctg_prte_id PK of record being inserted or updated.
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
Procedure chk_elig_dsblty_ctg_prte_id(p_elig_dsblty_ctg_prte_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_dsblty_ctg_prte_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ect_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_dsblty_ctg_prte_id                => p_elig_dsblty_ctg_prte_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_dsblty_ctg_prte_id,hr_api.g_number)
     <>  ben_ect_shd.g_old_rec.elig_dsblty_ctg_prte_id) then
    --
    -- raise error as PK has changed
    --
    ben_ect_shd.constraint_error('BEN_ELIG_PER_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_elig_dsblty_ctg_prte_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ect_shd.constraint_error('BEN_ELIG_PER_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_dsblty_ctg_prte_id;
--
--
/*-- ----------------------------------------------------------------------------
-- |------< chk_person_type_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--   Additionally this procedure will check that person_type_id is unique
--   within the Eligibility profile.
--   This procedure will also check that Per type of 'not Employee'
--   can not be set for any profile for which the following eligibility
--   factors are present: grade, assignment set, org unit, barg unit,
--   percent full time, job, ....
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_elig_dsblty_ctg_prte_id PK
--   p_category   ID of FK column
--   p_eligy_prfl_id
--   p_business_group_id
--   p_effective_date session date
--   p_object_version_number object version number
--
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
Procedure chk_person_type_id (p_elig_dsblty_ctg_prte_id  in number,
                              p_category            in varchar2,
                              p_eligy_prfl_id         in number,
                              p_excld_flag            in varchar2,
                              p_validation_start_date in date,
                              p_validation_end_date   in date,
                              p_business_group_id     in number,
                              p_effective_date        in date,
                              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_type_id';
  l_api_updating boolean;
  l_system_person_type        varchar2(30);
  l_dummy                     varchar2(1);
  l_exists       varchar2(1);
  --
  --
  cursor c3 is
     select null
       from ben_elig_dsblty_ctg_prte_f
         where category = p_category
           and eligy_prfl_id = p_eligy_prfl_id
           and elig_dsblty_ctg_prte_id <> nvl(p_elig_dsblty_ctg_prte_id,hr_api.g_number)
           and business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date
           ;
  --
  cursor c1 is
    select system_person_type
    from   per_person_types a
    where  a.person_type_id =to_number( p_category)
           and a.business_group_id = p_business_group_id;
  --
  cursor c2 is
    select null from ben_elig_asnt_set_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_grd_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_org_unit_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_brgng_unit_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_pct_fl_tm_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_hrly_slrd_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_comp_lvl_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_los_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_cmbn_age_los_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_loa_rsn_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_hrs_wkd_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_wk_loc_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_lbr_mmbr_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_pyrl_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_schedd_hrs_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id
      union
    select null from ben_elig_py_bss_prte_f a where a.eligy_prfl_id = p_eligy_prfl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_ect_shd.api_updating
     (p_elig_dsblty_ctg_prte_id    => p_elig_dsblty_ctg_prte_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_category,hr_api.g_number)
     <> nvl(ben_ect_shd.g_old_rec.category,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if category value exists in per_person_types table
    --
    open c1;
      --
      fetch c1 into l_system_person_type;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_person_types
        -- table.
        --
        ben_ect_shd.constraint_error('BEN_ELIG_PER_TYP_PRTE_FK2');
        --
      end if;
      --
    close c1;
    --
    --
    open c3;
    fetch c3 into l_exists;
    if c3%found then
      close c3;
      --
      -- raise error as this per type already exists for this profile
    --
     fnd_message.set_name('BEN', 'BEN_91349_DUP_ELIG_CRITERIA');
     fnd_message.raise_error;
    --
    end if;
    close c3;
    --
    -- additionally check rules for not Employee
    --
    if (l_system_person_type <> 'EMP' and l_system_person_type <> 'EMP_APL'
        and p_excld_flag = 'N') then
       open c2;
       fetch c2 into l_dummy;
      if c2%found then
        --
        close c2;
        --
        -- raise error as person type can not be set to not employee
        -- need to create message
        -- ben_ect_shd.constraint_error('BEN_ELIG_PER_TYP_PRTE_FK2');
           fnd_message.set_name('BEN', 'BEN_91387_INV_PER_TYPE');
           fnd_message.raise_error;
        --
      end if;
      --
    close c2;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_type_id;
--*/
-- ----------------------------------------------------------------------------
-- |------< chk_category >---------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
-- None.
--
-- In Parameters
--   elig_dsblty_ctg_prte_id PK of record being inserted or updated.
--   category Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--  Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_category(p_elig_dsblty_ctg_prte_id	 in number,
		         p_category            in varchar2,
		         p_business_group_id     in number,
		         p_effective_date        in date,
		         p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_category';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_person_types ppt
    where  ppt.system_person_type = p_category
    and    ppt.active_flag = 'Y'
    and    ppt.business_group_id+0 = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ect_shd.api_updating
     (p_effective_date        =>p_effective_date,
      p_elig_dsblty_ctg_prte_id  => p_elig_dsblty_ctg_prte_id,
      p_object_version_number =>p_object_version_number);
  --
  if (l_api_updating
      and p_category
      <>nvl(ben_ect_shd.g_old_rec.category,hr_api.g_varchar2)
      or not l_api_updating)
      and p_category is not null then
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        -- Raise error as system person type can not be found
        --
        close c1;
        fnd_message.set_name('PER','HR_7513_PER_TYPE_INVALID');
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
end chk_category;
--
-- ----------------------------------------------------------------------------
-- |------< chk_excld_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_dsblty_ctg_prte_id PK of record being inserted or updated.
--   excld_flag Value of lookup code.
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
Procedure chk_excld_flag(p_elig_dsblty_ctg_prte_id                in number,
                            p_excld_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_excld_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ect_shd.api_updating
    (p_elig_dsblty_ctg_prte_id                => p_elig_dsblty_ctg_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_ect_shd.g_old_rec.excld_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_excld_flag,
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
end chk_excld_flag;
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
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
            (p_elig_dsblty_ctg_prte_id		in number,
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
       p_argument       => 'elig_dsblty_ctg_prte_id',
       p_argument_value => p_elig_dsblty_ctg_prte_id);
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
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
	(p_rec 			 in ben_ect_shd.g_rec_type,
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
  chk_elig_dsblty_ctg_prte_id
  (p_elig_dsblty_ctg_prte_id          => p_rec.elig_dsblty_ctg_prte_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  /*chk_person_type_id (p_elig_dsblty_ctg_prte_id  => p_rec.elig_dsblty_ctg_prte_id,
                      p_per_typ_cd            => p_rec.per_typ_cd,
                      p_eligy_prfl_id         => p_rec.eligy_prfl_id,
                      p_excld_flag            => p_rec.excld_flag,
                      p_validation_start_date => p_validation_start_date,
                      p_validation_end_date   => p_validation_end_date,
                      p_business_group_id     => p_rec.business_group_id,
                      p_effective_date        => p_effective_date,
                      p_object_version_number => p_rec.object_version_number);*/
  --
 /* --chk_category
  (p_elig_dsblty_ctg_prte_id		=> p_rec.elig_dsblty_ctg_prte_id,
   p_category				=> p_rec.category,
   p_business_group_id			=> p_rec.business_group_id,
   p_effective_date			=>p_effective_date,
   p_object_version_number		=>p_rec.object_version_number);
*/
  --
  chk_excld_flag
  (p_elig_dsblty_ctg_prte_id  => p_rec.elig_dsblty_ctg_prte_id,
   p_excld_flag            => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ect_shd.g_rec_type,
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
  chk_elig_dsblty_ctg_prte_id
  (p_elig_dsblty_ctg_prte_id          => p_rec.elig_dsblty_ctg_prte_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  /* chk_person_type_id (p_elig_per_typ_prte_id  => p_rec.elig_per_typ_prte_id,
                       p_per_typ_cd            => p_rec.per_typ_cd,
                       p_eligy_prfl_id         => p_rec.eligy_prfl_id,
                       p_excld_flag            => p_rec.excld_flag,
                       p_validation_start_date => p_validation_start_date,
                       p_validation_end_date   => p_validation_end_date,
                       p_business_group_id     => p_rec.business_group_id,
                       p_effective_date        => p_effective_date,
                       p_object_version_number => p_rec.object_version_number);*/

  /*chk_category
  (p_elig_dsblty_ctg_prte_id	=> p_rec.elig_dsblty_ctg_prte_id,
   p_category			=> p_rec.category,
   p_business_group_id		=> p_rec.business_group_id,
   p_effective_date		=>p_effective_date,
   p_object_version_number	=>p_rec.object_version_number);
  --
*/
  chk_excld_flag
     (p_elig_dsblty_ctg_prte_id          => p_rec.elig_dsblty_ctg_prte_id,
      p_excld_flag         => p_rec.excld_flag,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
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
	(p_rec 			 in ben_ect_shd.g_rec_type,
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
     p_elig_dsblty_ctg_prte_id		=> p_rec.elig_dsblty_ctg_prte_id);
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
  (p_elig_dsblty_ctg_prte_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_dsblty_ctg_prte_f b
    where b.elig_dsblty_ctg_prte_id      = p_elig_dsblty_ctg_prte_id
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
                             p_argument       => 'elig_dsblty_ctg_prte_id',
                             p_argument_value => p_elig_dsblty_ctg_prte_id);
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
end ben_ect_bus;

/
