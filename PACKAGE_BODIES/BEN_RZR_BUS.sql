--------------------------------------------------------
--  DDL for Package Body BEN_RZR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RZR_BUS" as
/* $Header: berzrrhi.pkb 120.0.12010000.1 2008/07/29 13:03:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_rzr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_pstl_zip_rng_id >------|
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
--   pstl_zip_rng_id PK of record being inserted or updated.
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
Procedure chk_pstl_zip_rng_id(p_pstl_zip_rng_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pstl_zip_rng_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_rzr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pstl_zip_rng_id                => p_pstl_zip_rng_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pstl_zip_rng_id,hr_api.g_number)
     <>  ben_rzr_shd.g_old_rec.pstl_zip_rng_id) then
    --
    -- raise error as PK has changed
    --
    ben_rzr_shd.constraint_error('BEN_PSTL_ZIP_RNG_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pstl_zip_rng_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_rzr_shd.constraint_error('BEN_PSTL_ZIP_RNG_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pstl_zip_rng_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pstl_zip_from_to_range >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the FROM_VALUE is numeric then
--   the TO_VALUE is allowed to have a value and the TO_VALUE must be
--   greater than the FROM_VALUE.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_from_value is the FROM_VALUE of record being inserted or updated.
--   p_to_value is the TO_VALUE of record being inserted or updated.
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
Procedure chk_pstl_zip_from_to_range(p_from_value     in varchar2,
                                     p_to_value       in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_pstl_zip_from_to_range';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  declare
    v_to_value  number;
    v_from_value number ;
  begin
     v_to_value := to_number(p_to_value);
     v_from_value := to_number(p_from_value);
     begin
        if v_from_value > v_to_value then
           fnd_message.set_name('BEN','BEN_91619_TO_VAL_NOT_GTR_FRM_V');
           fnd_message.raise_error;
        end if;
     exception
        when value_error then
           if p_to_value is not null then
              fnd_message.set_name('BEN','BEN_91620_TO_VAL_MST_BE_NULL');
              fnd_message.raise_error;
           end if;
     end;
  exception
    when value_error then
        -- fnd_message.set_name('BEN','BEN_91621_TO_VAL_MST_BE_NUM');
        -- fnd_message.raise_error;
        -- Bug 1612851 zip codes need not to be numberic .
        if p_from_value > p_to_value then
          --
          fnd_message.set_name('BEN','BEN_91619_TO_VAL_NOT_GTR_FRM_V');
          fnd_message.raise_error;
          --
        end if;
        --
  end;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pstl_zip_from_to_range;
--
-- ----------------------------------------------------------------------------
-- |------< chk_duplicate_rows >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if duplicate rows exist
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_from_value is the FROM_VALUE of record being inserted or updated.
--   p_to_value is the TO_VALUE of record being inserted or updated.
--   p_business_group_id

-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_duplicate_rows(p_pstl_zip_rng_id in number,
                                     p_from_value            in varchar2,
                                     p_to_value              in varchar2,
                                     p_business_group_id     in varchar2,
                                     p_effective_date        in date,
                                     p_validation_start_date in date,
                                     p_validation_end_date   in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_duplicate_rows';
  l_api_updating boolean;
  dummy varchar2(1);
  -- Bug 3297243
  cursor c1 is select null from ben_pstl_zip_rng_f
     where (pstl_zip_rng_id <> p_pstl_zip_rng_id or p_pstl_zip_rng_id is null) and
            from_value = p_from_value and
           (to_value = p_to_value or to_value is null) and
           business_group_id = p_business_group_id and
           p_validation_start_date <= effective_end_date and
           p_validation_end_date >= effective_start_date;

--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
  open c1;
  fetch c1 into dummy;
  if c1%found then
    close c1;
    fnd_message.set_name('BEN','BEN_92501_ZIP_RNG_NOT_UNIQUE');
    fnd_message.raise_error;
  end if;
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_duplicate_rows;
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
            (
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
    --
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
            (p_pstl_zip_rng_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
--  l_table_name	all_tables.table_name%TYPE;
  l_child_rec varchar2(50);
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
       p_argument       => 'pstl_zip_rng_id',
       p_argument_value => p_pstl_zip_rng_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_pstl_cd_r_rng_prte_f',
           p_base_key_column => 'pstl_zip_rng_id',
           p_base_key_value  => p_pstl_zip_rng_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      --   l_table_name := 'ben_elig_pstl_cd_r_rng_prte_f';
           l_child_rec := 'Participant Eligibility Profiles';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_pstl_cd_r_rng_cvg_f',
           p_base_key_column => 'pstl_zip_rng_id',
           p_base_key_value  => p_pstl_zip_rng_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      --   l_table_name := 'ben_elig_pstl_cd_r_rng_cvg_f';
           l_child_rec := 'Dependent Coverage Eligibility Profiles';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pstl_zip_rt_f',
           p_base_key_column => 'pstl_zip_rng_id',
           p_base_key_value  => p_pstl_zip_rng_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      --   l_table_name := 'ben_pstl_zip_rt_f';
           l_child_rec := 'Variable Rate Criteria';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_svc_area_pstl_zip_rng_f',
           p_base_key_column => 'pstl_zip_rng_id',
           p_base_key_value  => p_pstl_zip_rng_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      --   l_table_name := 'ben_svc_area_pstl_zip_rng_f';
           l_child_rec := 'Service Areas';
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
    -- fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    -- fnd_message.set_token('TABLE_NAME', l_table_name);   -- Bug 2332140
    --
    fnd_message.set_name('BEN', 'BEN_93061_ZIP_CHLD_RCD_EXISTS');
    fnd_message.set_token('TABLE_NAME',l_child_rec,TRUE );   -- Bug 2488652
    fnd_message.raise_error;
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
	(p_rec 			 in ben_rzr_shd.g_rec_type,
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
  chk_pstl_zip_rng_id
  (p_pstl_zip_rng_id          => p_rec.pstl_zip_rng_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --Check for to_value only if it is not null

  if p_rec.to_value is not null then
     chk_pstl_zip_from_to_range
     (p_from_value     => p_rec.from_value,
      p_to_value       => p_rec.to_valUE);
  end if;
 -- Check for duplicate rows
  chk_duplicate_rows
           (p_pstl_zip_rng_id => p_rec.pstl_zip_rng_id,
            p_from_value => p_rec.from_value,
            p_to_value => p_rec.to_value,
            p_business_group_id => p_rec.business_group_id,
            p_effective_date => p_effective_date,
            p_validation_start_date => p_validation_start_date,
            p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_rzr_shd.g_rec_type,
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
  chk_pstl_zip_rng_id
  (p_pstl_zip_rng_id          => p_rec.pstl_zip_rng_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --Check for to_value only if it is not null

  if p_rec.to_value is not null then
     chk_pstl_zip_from_to_range
     (p_from_value     => p_rec.from_value,
      p_to_value       => p_rec.to_value);
  end if;
  --
  chk_duplicate_rows
           (p_pstl_zip_rng_id => p_rec.pstl_zip_rng_id,
            p_from_value => p_rec.from_value,
            p_to_value => p_rec.to_value,
            p_business_group_id => p_rec.business_group_id,
            p_effective_date => p_effective_date,
            p_validation_start_date => p_validation_start_date,
            p_validation_end_date   => p_validation_end_date);
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
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
	(p_rec 			 in ben_rzr_shd.g_rec_type,
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
     p_pstl_zip_rng_id		=> p_rec.pstl_zip_rng_id);
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
  (p_pstl_zip_rng_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pstl_zip_rng_f b
    where b.pstl_zip_rng_id      = p_pstl_zip_rng_id
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
                             p_argument       => 'pstl_zip_rng_id',
                             p_argument_value => p_pstl_zip_rng_id);
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
end ben_rzr_bus;

/
