--------------------------------------------------------
--  DDL for Package Body BEN_PET_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PET_BUS" as
/* $Header: bepetrhi.pkb 120.1 2006/03/07 23:43:30 abparekh noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pet_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_popl_enrt_typ_cycl_id >------|
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
--   popl_enrt_typ_cycl_id PK of record being inserted or updated.
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
Procedure chk_popl_enrt_typ_cycl_id(p_popl_enrt_typ_cycl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_popl_enrt_typ_cycl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pet_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_popl_enrt_typ_cycl_id                => p_popl_enrt_typ_cycl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_popl_enrt_typ_cycl_id,hr_api.g_number)
     <>  ben_pet_shd.g_old_rec.popl_enrt_typ_cycl_id) then
    --
    -- raise error as PK has changed
    --
    ben_pet_shd.constraint_error('BEN_POPL_ENRT_TYP_CYCL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_popl_enrt_typ_cycl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pet_shd.constraint_error('BEN_POPL_ENRT_TYP_CYCL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_popl_enrt_typ_cycl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_typ_cycl_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid it alse
--   ensures that the value is unique within pgm/pl and within bus grp.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   popl_enrt_typ_cycl_id PK of record being inserted or updated.
--   enrt_typ_cycl_cd Value of lookup code.
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
Procedure chk_enrt_typ_cycl_cd(p_popl_enrt_typ_cycl_id    in number,
                            p_enrt_typ_cycl_cd            in varchar2,
                            p_pgm_id                      in number,
                            p_pl_id                       in number,
                            p_effective_date              in date,
				    p_validation_start_date         in date,
                            p_validation_end_date           in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is


 --
  l_proc         varchar2(72) := g_package||'chk_enrt_typ_cycl_cd';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor chk_unique is
     select null
        from ben_popl_enrt_typ_cycl_f
        where enrt_typ_cycl_cd = p_enrt_typ_cycl_cd
          and popl_enrt_typ_cycl_id <> nvl(p_popl_enrt_typ_cycl_id, hr_api.g_number)
          and (pgm_id = p_pgm_id or pl_id = p_pl_id)
          and business_group_id + 0 = p_business_group_id
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pet_shd.api_updating
    (p_popl_enrt_typ_cycl_id                => p_popl_enrt_typ_cycl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_typ_cycl_cd
      <> nvl(ben_pet_shd.g_old_rec.enrt_typ_cycl_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_TYP_CYCL',
           p_lookup_code    => p_enrt_typ_cycl_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      -- Bug 5076148 - Changed the message name
      --
      fnd_message.set_name('BEN','BEN_93236_ENRT_TYP_CYL_CD_NULL');
      fnd_message.raise_error;
      --
    end if;
    --
    --
    -- this value must be unique
    --
    open chk_unique;
    fetch chk_unique into l_exists;
    if chk_unique%found then
      close chk_unique;
      --
      -- raise error as UK1 is violated
      --
      fnd_message.set_name('PAY','VALUE IS NOT UNIQUE');
      fnd_message.raise_error;
      --
    end if;
    --
    close chk_unique;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_enrt_typ_cycl_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< enp_rows_exists >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a any child rows exists for table with
--   short name enp. This will prevent deletes when enrt_perds exist.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_regy_bod_id PK
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
Function enp_rows_exists (p_popl_enrt_typ_cycl_id in number ) Return Boolean  is
  --
  l_proc         varchar2(72) := g_package||'enp_rows_exists';
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_enrt_perd enp
    where  enp.popl_enrt_typ_cycl_id = p_popl_enrt_typ_cycl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --
  -- check if child rows exists in ben_enrt_perd.
  --
  open c1;
  --
  fetch c1 into l_dummy;
  if c1%found then
        --
        close c1;
        --
        -- raise error as child rows exists.
        --
        Return(true);
        --
  Else
        --
        close c1;
        --
        Return(false);
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End enp_rows_exists;

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
            (p_pl_id                         in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
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
            (p_popl_enrt_typ_cycl_id		in number,
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
       p_argument       => 'popl_enrt_typ_cycl_id',
       p_argument_value => p_popl_enrt_typ_cycl_id);
    --
    If (enp_rows_exists(p_popl_enrt_typ_cycl_id => p_popl_enrt_typ_cycl_id)) then
       l_table_name := 'ben_enrt_perd';
       Raise l_rows_exist;
    End If;
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_lee_rsn_f',
           p_base_key_column => 'popl_enrt_typ_cycl_id',
           p_base_key_value  => p_popl_enrt_typ_cycl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_lee_rsn_f';
      Raise l_rows_exist;
    End If;
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
	(p_rec 			 in ben_pet_shd.g_rec_type,
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
  chk_popl_enrt_typ_cycl_id
  (p_popl_enrt_typ_cycl_id          => p_rec.popl_enrt_typ_cycl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_typ_cycl_cd
  (p_popl_enrt_typ_cycl_id          => p_rec.popl_enrt_typ_cycl_id,
   p_enrt_typ_cycl_cd         => p_rec.enrt_typ_cycl_cd,
   p_pgm_id                   => p_rec.pgm_id,
   p_pl_id                  => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
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
	(p_rec 			 in ben_pet_shd.g_rec_type,
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
  chk_popl_enrt_typ_cycl_id
  (p_popl_enrt_typ_cycl_id          => p_rec.popl_enrt_typ_cycl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_typ_cycl_cd
  (p_popl_enrt_typ_cycl_id          => p_rec.popl_enrt_typ_cycl_id,
   p_enrt_typ_cycl_cd         => p_rec.enrt_typ_cycl_cd,
   p_pgm_id                   => p_rec.pgm_id,
   p_pl_id                  => p_rec.pl_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date  =>    p_validation_start_date,
   p_validation_end_date      =>  p_validation_end_date,
   p_business_group_id        =>  p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (        p_pl_id                         => p_rec.pl_id,
             p_pgm_id                        => p_rec.pgm_id,
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
	(p_rec 			 in ben_pet_shd.g_rec_type,
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
     p_popl_enrt_typ_cycl_id		=> p_rec.popl_enrt_typ_cycl_id);
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
  (p_popl_enrt_typ_cycl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_popl_enrt_typ_cycl_f b
    where b.popl_enrt_typ_cycl_id      = p_popl_enrt_typ_cycl_id
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
                             p_argument       => 'popl_enrt_typ_cycl_id',
                             p_argument_value => p_popl_enrt_typ_cycl_id);
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
end ben_pet_bus;

/
