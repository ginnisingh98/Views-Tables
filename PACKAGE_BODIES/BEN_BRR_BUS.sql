--------------------------------------------------------
--  DDL for Package Body BEN_BRR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BRR_BUS" as
/* $Header: bebrrrhi.pkb 120.0.12010000.3 2008/08/25 14:16:31 ppentapa ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_brr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_bnft_vrbl_rt_rl_id >------|
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
--   bnft_vrbl_rt_rl_id PK of record being inserted or updated.
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
Procedure chk_bnft_vrbl_rt_rl_id(p_bnft_vrbl_rt_rl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bnft_vrbl_rt_rl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_brr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_vrbl_rt_rl_id                => p_bnft_vrbl_rt_rl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_bnft_vrbl_rt_rl_id,hr_api.g_number)
     <>  ben_brr_shd.g_old_rec.bnft_vrbl_rt_rl_id) then
    --
    -- raise error as PK has changed
    --
    ben_brr_shd.constraint_error('BEN_BNFT_VRBL_RT_RL_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_bnft_vrbl_rt_rl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_brr_shd.constraint_error('BEN_BNFT_VRBL_RT_RL_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_bnft_vrbl_rt_rl_id;
--
-- ---------------------------------------------------------------------------
-- |------------------< chk_ordr_to_aply_num_unique >-------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--   ensure that the Sequence Number is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_ordr_to_aply_num            Sequence Number
--     p_bnft_vrbl_rt_rl_id          Primary Key of BEN_BNFT_VRBL_RT_RL_F
--     p_cvg_amt_calc_mthd_id        Foreign Key to BEN_CVG_AMT_CALC_MTHD_F
--     p_business_group_id
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
-- ----------------------------------------------------------------------------
Procedure chk_ordr_to_aply_num_unique
          ( p_bnft_vrbl_rt_rl_id        in   number
           ,p_cvg_amt_calc_mthd_id      in   number
           ,p_ordr_to_aply_num          in   number
           ,p_business_group_id         in   number)
is
l_proc      varchar2(72) := g_package||'chk_ordr_to_aply_num_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_bnft_vrbl_rt_rl_f
             Where  bnft_vrbl_rt_rl_id <> nvl(p_bnft_vrbl_rt_rl_id,-1)
             and    cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id
             and    ordr_to_aply_num = p_ordr_to_aply_num
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
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_ordr_to_aply_num_unique;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_brr_bvr_mutexcl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the rule is mutually exclusive for
--   the cvg_amt_calc_mthd_id.  A profile cannot exist with this cvg_amt_
--   calc_mthd_id.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_vrbl_rt_rl_id       PK of record being inserted or updated.
--   cvg_amt_calc_mthd_id     cvg_amt_calc_mthd_id.
--   effective_date           Session date of record.
--   business_group_id        Business group id of record being inserted.
--   object_version_number    Object version number of record being
--                            inserted or updated.
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
------------------------------------------------------------------------------
Procedure chk_brr_bvr_mutexcl(p_bnft_vrbl_rt_rl_id         in number,
                               p_cvg_amt_calc_mthd_id      in number,
                               p_effective_date            in date,
                               p_business_group_id         in number,
                               p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_brr_bvr_mutexcl';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_bnft_vrbl_rt_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_brr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_bnft_vrbl_rt_rl_id          => p_bnft_vrbl_rt_rl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating or not l_api_updating)
     and p_cvg_amt_calc_mthd_id is not null then
    --
    -- Check if cvg_amt_calc_mthd_id is mutually exclusive.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise an error as this cvg_amt_calc_mthd_id has been
        -- assigned to profile(s).
        --
        fnd_message.set_name('BEN','BEN_91966_BRR_BVR_EXCLU');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_brr_bvr_mutexcl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_formula_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnft_vrbl_rt_rl_id PK of record being inserted or updated.
--   formula_id Value of formula rule id.
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
Procedure chk_formula_id(p_bnft_vrbl_rt_rl_id              in number,
                             p_formula_id                  in number,
                             p_business_group_id           in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_formula_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_formula_id
    and    ff.formula_type_id in (-171, -49, -507)
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
  l_api_updating := ben_brr_shd.api_updating
    (p_bnft_vrbl_rt_rl_id          => p_bnft_vrbl_rt_rl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_formula_id,hr_api.g_number)
      <> ben_brr_shd.g_old_rec.formula_id
      or not l_api_updating)
      and p_formula_id is not null then
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
        fnd_message.set_name('BEN','BEN_91007_INVALID_RULE');
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
end chk_formula_id;
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
            (p_cvg_amt_calc_mthd_id          in number default hr_api.g_number,
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
    If ((nvl(p_cvg_amt_calc_mthd_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_cvg_amt_calc_mthd_f',
             p_base_key_column => 'cvg_amt_calc_mthd_id',
             p_base_key_value  => p_cvg_amt_calc_mthd_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_cvg_amt_calc_mthd_f';
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
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
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
            (p_bnft_vrbl_rt_rl_id		in number,
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
       p_argument       => 'bnft_vrbl_rt_rl_id',
       p_argument_value => p_bnft_vrbl_rt_rl_id);
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
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_brr_shd.g_rec_type,
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
  chk_bnft_vrbl_rt_rl_id
  (p_bnft_vrbl_rt_rl_id          => p_rec.bnft_vrbl_rt_rl_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_ordr_to_aply_num_unique
  (p_bnft_vrbl_rt_rl_id        => p_rec.bnft_vrbl_rt_rl_id,
   p_cvg_amt_calc_mthd_id      => p_rec.cvg_amt_calc_mthd_id,
   p_ordr_to_aply_num          => p_rec.ordr_to_aply_num,
   p_business_group_id         => p_rec.business_group_id);
  --
  chk_brr_bvr_mutexcl
  (p_bnft_vrbl_rt_rl_id        => p_rec.bnft_vrbl_rt_rl_id,
   p_cvg_amt_calc_mthd_id      => p_rec.cvg_amt_calc_mthd_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_formula_id
  (p_bnft_vrbl_rt_rl_id      => p_rec.bnft_vrbl_rt_rl_id,
   p_formula_id              => p_rec.formula_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_brr_shd.g_rec_type,
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
  chk_bnft_vrbl_rt_rl_id
  (p_bnft_vrbl_rt_rl_id          => p_rec.bnft_vrbl_rt_rl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ordr_to_aply_num_unique
  (p_bnft_vrbl_rt_rl_id        => p_rec.bnft_vrbl_rt_rl_id,
   p_cvg_amt_calc_mthd_id      => p_rec.cvg_amt_calc_mthd_id,
   p_ordr_to_aply_num          => p_rec.ordr_to_aply_num,
   p_business_group_id         => p_rec.business_group_id);
  --
  chk_brr_bvr_mutexcl
  (p_bnft_vrbl_rt_rl_id        => p_rec.bnft_vrbl_rt_rl_id,
   p_cvg_amt_calc_mthd_id      => p_rec.cvg_amt_calc_mthd_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_formula_id
  (p_bnft_vrbl_rt_rl_id      => p_rec.bnft_vrbl_rt_rl_id,
   p_formula_id              => p_rec.formula_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_cvg_amt_calc_mthd_id          => p_rec.cvg_amt_calc_mthd_id,
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
	(p_rec 			 in ben_brr_shd.g_rec_type,
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
     p_bnft_vrbl_rt_rl_id		=> p_rec.bnft_vrbl_rt_rl_id);
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
  (p_bnft_vrbl_rt_rl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_bnft_vrbl_rt_rl_f b
    where b.bnft_vrbl_rt_rl_id      = p_bnft_vrbl_rt_rl_id
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
                             p_argument       => 'bnft_vrbl_rt_rl_id',
                             p_argument_value => p_bnft_vrbl_rt_rl_id);
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
end ben_brr_bus;

/
