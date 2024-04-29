--------------------------------------------------------
--  DDL for Package Body BEN_EPZ_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPZ_BUS" as
/* $Header: beepzrhi.pkb 120.1 2006/02/26 23:58:04 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epz_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_pstl_cd_r_rng_prte_id >------|
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
--   elig_pstl_cd_r_rng_prte_id PK of record being inserted or updated.
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
Procedure chk_elig_pstl_cd_r_rng_prte_id(p_elig_pstl_cd_r_rng_prte_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_pstl_cd_r_rng_prte_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_epz_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_pstl_cd_r_rng_prte_id                => p_elig_pstl_cd_r_rng_prte_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_pstl_cd_r_rng_prte_id,hr_api.g_number)
     <>  ben_epz_shd.g_old_rec.elig_pstl_cd_r_rng_prte_id) then
    --
    -- raise error as PK has changed
    --
    ben_epz_shd.constraint_error('BEN_ELIG_PSTL_CD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_elig_pstl_cd_r_rng_prte_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_epz_shd.constraint_error('BEN_ELIG_PSTL_CD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_pstl_cd_r_rng_prte_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pstl_zip_rng_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--   Additionally this procedure will check that pstl_zip_rng_id is unique
--   within the Eligibility profile.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_elig_pstl_cd_r_rng_prte_id PK
--   p_pstl_zip_rng_id  ID of FK column
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
Procedure chk_pstl_zip_rng_id (p_elig_pstl_cd_r_rng_prte_id      in number,
                               p_pstl_zip_rng_id                 in number,
                               p_eligy_prfl_id         in number,
                               p_validation_start_date in date,
                               p_validation_end_date   in date,
                               p_effective_date        in date,
                               p_business_group_id     in number,
                               p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pstl_zip_rng_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_exists       varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pstl_zip_rng_f a
    where  a.pstl_zip_rng_id = p_pstl_zip_rng_id
      and  a.business_group_id + 0 = p_business_group_id
      and  p_effective_date between a.effective_start_date and
                                 nvl(a.effective_end_date, p_effective_date);
  --
  cursor c3 is
     select null
       from ben_elig_pstl_cd_r_rng_prte_f
         where pstl_zip_rng_id = p_pstl_zip_rng_id
           and eligy_prfl_id = p_eligy_prfl_id
           and elig_pstl_cd_r_rng_prte_id <> nvl(p_elig_pstl_cd_r_rng_prte_id,hr_api.g_number)
           and business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date
           ;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_epz_shd.api_updating
     (p_elig_pstl_cd_r_rng_prte_id        => p_elig_pstl_cd_r_rng_prte_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pstl_zip_rng_id,hr_api.g_number)
     <> nvl(ben_epz_shd.g_old_rec.pstl_zip_rng_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if pstl_zip_rng_id value exists in ben_pstl_zip_rng_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pstl_zip_rng_f
        -- table.
        --
        ben_epz_shd.constraint_error('BEN_ELIG_PSTL_CD_FK2');
        --
      end if;
      --
    close c1;
    --
    open c3;
    fetch c3 into l_exists;
    if c3%found then
      close c3;
      --
      -- raise error as this criteria already exists for this profile
    --
     fnd_message.set_name('BEN', 'BEN_91349_DUP_ELIG_CRITERIA');
     fnd_message.raise_error;
    --
    end if;
    close c3;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pstl_zip_rng_id;
--
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
--   elig_pstl_cd_r_rng_prte_id PK of record being inserted or updated.
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
Procedure chk_excld_flag(p_elig_pstl_cd_r_rng_prte_id                in number,
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
  l_api_updating := ben_epz_shd.api_updating
    (p_elig_pstl_cd_r_rng_prte_id                => p_elig_pstl_cd_r_rng_prte_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_epz_shd.g_old_rec.excld_flag,hr_api.g_varchar2)
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
--Bug:5054189
-- ---------------------------------------------------------------------------
-- |-----------------------< chk_duplicate_ordr_num >---------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--   Ensure that the Sequence Number is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_elig_pstl_cd_r_rng_prte_id   elig_pstl_cd_r_rng_prte_id
--   p_eligy_prfl_id                eligy_prfl_id
--   p_ordr_num                     Sequence Number
--   p_business_group_id
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only
--

Procedure chk_duplicate_ordr_num
          ( p_elig_pstl_cd_r_rng_prte_id  in   number
           ,p_eligy_prfl_id               in   number
           ,p_ordr_num                    in   number
           ,p_business_group_id           in   number)
is
  l_proc     varchar2(72) := g_package||'chk_duplicate_ordr_num';
  l_dummy    char(1);
  cursor c1 is
    select null
    from   ben_elig_pstl_cd_r_rng_prte_f
    where  elig_pstl_cd_r_rng_prte_id <> nvl(p_elig_pstl_cd_r_rng_prte_id,-1)
    and    eligy_prfl_id = p_eligy_prfl_id
    and    ordr_num = p_ordr_num
    and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
    close c1;
    fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
    fnd_message.raise_error;
  end if;
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_duplicate_ordr_num;

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
             p_pstl_zip_rng_id               in number default hr_api.g_number,
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
    If ((nvl(p_pstl_zip_rng_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pstl_zip_rng_f',
             p_base_key_column => 'pstl_zip_rng_id',
             p_base_key_value  => p_pstl_zip_rng_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pstl_zip_rng_f';
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
            (p_elig_pstl_cd_r_rng_prte_id		in number,
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
       p_argument       => 'elig_pstl_cd_r_rng_prte_id',
       p_argument_value => p_elig_pstl_cd_r_rng_prte_id);
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
	(p_rec 			 in ben_epz_shd.g_rec_type,
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
  chk_elig_pstl_cd_r_rng_prte_id
  (p_elig_pstl_cd_r_rng_prte_id          => p_rec.elig_pstl_cd_r_rng_prte_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pstl_zip_rng_id (p_elig_pstl_cd_r_rng_prte_id  => p_rec.elig_pstl_cd_r_rng_prte_id,
                       p_pstl_zip_rng_id       => p_rec.pstl_zip_rng_id,
                       p_eligy_prfl_id         => p_rec.eligy_prfl_id,
                       p_validation_start_date => p_validation_start_date,
                       p_validation_end_date   => p_validation_end_date,
                       p_effective_date        => p_effective_date,
                       p_business_group_id     => p_rec.business_group_id,
                       p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_elig_pstl_cd_r_rng_prte_id          => p_rec.elig_pstl_cd_r_rng_prte_id,
   p_excld_flag         => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
chk_duplicate_ordr_num
( p_elig_pstl_cd_r_rng_prte_id   => p_rec.elig_pstl_cd_r_rng_prte_id
 ,p_eligy_prfl_id             	 => p_rec.eligy_prfl_id
 ,p_ordr_num                  	 => p_rec.ordr_num
 ,p_business_group_id         	 => p_rec.business_group_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_epz_shd.g_rec_type,
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
  chk_elig_pstl_cd_r_rng_prte_id
  (p_elig_pstl_cd_r_rng_prte_id          => p_rec.elig_pstl_cd_r_rng_prte_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_pstl_zip_rng_id (p_elig_pstl_cd_r_rng_prte_id  => p_rec.elig_pstl_cd_r_rng_prte_id,
                       p_pstl_zip_rng_id       => p_rec.pstl_zip_rng_id,
                       p_eligy_prfl_id         => p_rec.eligy_prfl_id,
                       p_validation_start_date => p_validation_start_date,
                       p_validation_end_date   => p_validation_end_date,
                       p_effective_date        => p_effective_date,
                       p_business_group_id     => p_rec.business_group_id,
                       p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_elig_pstl_cd_r_rng_prte_id          => p_rec.elig_pstl_cd_r_rng_prte_id,
   p_excld_flag         => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_eligy_prfl_id                 => p_rec.eligy_prfl_id,
             p_pstl_zip_rng_id               => p_rec.pstl_zip_rng_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
chk_duplicate_ordr_num
( p_elig_pstl_cd_r_rng_prte_id   => p_rec.elig_pstl_cd_r_rng_prte_id
 ,p_eligy_prfl_id             	 => p_rec.eligy_prfl_id
 ,p_ordr_num                  	 => p_rec.ordr_num
 ,p_business_group_id         	 => p_rec.business_group_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_epz_shd.g_rec_type,
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
     p_elig_pstl_cd_r_rng_prte_id		=> p_rec.elig_pstl_cd_r_rng_prte_id);
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
  (p_elig_pstl_cd_r_rng_prte_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_pstl_cd_r_rng_prte_f b
    where b.elig_pstl_cd_r_rng_prte_id      = p_elig_pstl_cd_r_rng_prte_id
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
                             p_argument       => 'elig_pstl_cd_r_rng_prte_id',
                             p_argument_value => p_elig_pstl_cd_r_rng_prte_id);
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
end ben_epz_bus;

/
