--------------------------------------------------------
--  DDL for Package Body BEN_ERL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ERL_BUS" as
/* $Header: beerlrhi.pkb 120.0 2005/05/28 02:52:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_erl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_eligy_prfl_rl_id >------|
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
--   eligy_prfl_rl_id PK of record being inserted or updated.
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
Procedure chk_eligy_prfl_rl_id(p_eligy_prfl_rl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_eligy_prfl_rl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_erl_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_eligy_prfl_rl_id                => p_eligy_prfl_rl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_eligy_prfl_rl_id,hr_api.g_number)
     <>  ben_erl_shd.g_old_rec.eligy_prfl_rl_id) then
    --
    -- raise error as PK has changed
    --
    ben_erl_shd.constraint_error('BEN_ELIGY_PRFL_RL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_eligy_prfl_rl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_erl_shd.constraint_error('BEN_ELIGY_PRFL_RL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_eligy_prfl_rl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_formula_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid,
--   unique and required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_rl_id PK of record being inserted or updated.
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
Procedure chk_formula_id(p_eligy_prfl_rl_id           in number,
                         p_formula_id         in number,
                         p_eligy_prfl_id      in number,
                         p_business_group_id        in number,
                         p_effective_date              in date,
                         p_validation_start_date       in date,
                         p_validation_end_date         in date,
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
    and    ff.formula_type_id = -153
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) = p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) = pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;

  cursor c3 is
    SELECT  'x'
    FROM    ben_eligy_prfl_rl_f
    WHERE   eligy_prfl_rl_id           <> nvl(p_eligy_prfl_rl_id, hr_api.g_number)
    AND     eligy_prfl_id              = p_eligy_prfl_id
    AND     formula_id    = p_formula_id
    AND     p_validation_start_date <= effective_end_date
    AND     p_validation_end_date   >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_formula_id is null then
        fnd_message.set_name('BEN','BEN_91019_RULE_REQUIRED');
        fnd_message.raise_error;
  end if;
--
  l_api_updating := ben_erl_shd.api_updating
    (p_eligy_prfl_rl_id                => p_eligy_prfl_rl_id,
     p_effective_date        => p_effective_date,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_formula_id,hr_api.g_number)
      <> ben_erl_shd.g_old_rec.formula_id
      or not l_api_updating)
      and p_formula_id is not null then
    --
    -- check if value of formula rule is valid.
    open c1;
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      fetch c1 into l_dummy;
      if c1%notfound then
        close c1;
        -- raise error
        fnd_message.set_name('BEN','BEN_91007_INVALID_RULE');
        fnd_message.raise_error;
      end if;
    close c1;
    --
    --
    -- check if value of formula rule is unique for eligy profile.
    open c3;
      fetch c3 into l_dummy;
      if c3%found then
        close c3;
        -- raise error
        fnd_message.set_name('BEN','BEN_91018_RULE_NOT_UNIQUE');
        fnd_message.raise_error;
      end if;
    close c3;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_formula_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ordr_to_aply_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Sequence Number field is unique.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_prfl_rl_id PK of record being inserted or updated.
--   ordr_to_aply_num Sequence Number (Order to Apply) of record being inserted
--                    or updated.
--   business_group_id business_group
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
Procedure chk_ordr_to_aply_num
                  (p_eligy_prfl_rl_id          in number,
                   p_eligy_prfl_id             in number,
                   p_ordr_to_aply_num      in number,
                   p_effective_date        in date,
                   p_validation_start_date in date,
                   p_validation_end_date   in date,
                   p_business_group_id     in number,
                   p_object_version_number in number) is

-- Cursor selects non-unique sequence numbers
-- Note, we are allowing records with different keys to have the same
-- sequence value as long as the two records are not 'effective' at any
-- one time.
CURSOR l_csr_rl (p_eligy_prfl_rl_id        number
                 ,p_eligy_prfl_id          number
                 ,p_ordr_to_aply_num   number
                 ,p_business_group_id  number
                 ,p_validation_start_date date
                 ,p_validation_end_date   date) IS
    SELECT  'x'
    FROM    ben_eligy_prfl_rl_f
    WHERE   eligy_prfl_rl_id           <> nvl(p_eligy_prfl_rl_id, hr_api.g_number)
    AND     eligy_prfl_id              = p_eligy_prfl_id
    AND     business_group_id + 0  = p_business_group_id
    AND     ordr_to_aply_num       = nvl(p_ordr_to_aply_num,hr_api.g_number)
    AND     p_validation_start_date <= effective_end_date
    AND     p_validation_end_date   >= effective_start_date;
  --
  l_db_rl_row   l_csr_rl%rowtype;
  l_proc         varchar2(72) := g_package||'chk_ordr_to_aply_num';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_erl_shd.api_updating
    (p_eligy_prfl_rl_id                => p_eligy_prfl_rl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);

  if (l_api_updating
     and nvl(p_ordr_to_aply_num,hr_api.g_number)
     <>  ben_erl_shd.g_old_rec.ordr_to_aply_num
     or not l_api_updating) then

     open l_csr_rl
             (p_eligy_prfl_rl_id       => p_eligy_prfl_rl_id
             ,p_eligy_prfl_id          => p_eligy_prfl_id
             ,p_ordr_to_aply_num   => p_ordr_to_aply_num
             ,p_business_group_id  => p_business_group_id
             ,p_validation_start_date     => p_validation_start_date
             ,p_validation_end_date       => p_validation_end_date) ;
     fetch l_csr_rl into l_db_rl_row;
     if l_csr_rl%found then
        close l_csr_rl;
        --
        fnd_message.set_name('BEN', 'BEN_91001_SEQ_NOT_UNIQUE');
        fnd_message.raise_error;
     end if;
    close l_csr_rl;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ordr_to_aply_num;
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
            (p_formula_id                in number default hr_api.g_number,
             p_eligy_prfl_id             in number default hr_api.g_number,
	       p_datetrack_mode		     in varchar2,
             p_validation_start_date     in date,
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
    If ((nvl(p_formula_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_formula_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
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
            (p_eligy_prfl_rl_id		in number,
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
       p_argument       => 'eligy_prfl_rl_id',
       p_argument_value => p_eligy_prfl_rl_id);
    --
  --  If (dt_api.rows_exist
  --        (p_base_table_name => 'ben_eligy_prfl_f',
  --         p_base_key_column => 'eligy_prfl_rl_id',
  --         p_base_key_value  => p_eligy_prfl_rl_id,
  --         p_from_date       => p_validation_start_date,
  --         p_to_date         => p_validation_end_date)) Then
  --    l_table_name := 'ben_eligy_prfl_f';
  --    Raise l_rows_exist;
  --  End If;
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
	(p_rec 			 in ben_erl_shd.g_rec_type,
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
  chk_eligy_prfl_rl_id
  (p_eligy_prfl_rl_id          => p_rec.eligy_prfl_rl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
--
--
  chk_formula_id
  (p_eligy_prfl_rl_id          => p_rec.eligy_prfl_rl_id,
   p_formula_id   => p_rec.formula_id,
   p_eligy_prfl_id             => p_rec.eligy_prfl_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ordr_to_aply_num
  (p_eligy_prfl_rl_id          => p_rec.eligy_prfl_rl_id,
   p_eligy_prfl_id             => p_rec.eligy_prfl_id,
   p_ordr_to_aply_num      => p_rec.ordr_to_aply_num,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_object_version_number => p_rec.object_version_number);
  --
   hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_erl_shd.g_rec_type,
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
  chk_eligy_prfl_rl_id
  (p_eligy_prfl_rl_id          => p_rec.eligy_prfl_rl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
--
--
  chk_formula_id
  (p_eligy_prfl_rl_id          => p_rec.eligy_prfl_rl_id,
   p_formula_id   => p_rec.formula_id,
   p_eligy_prfl_id             => p_rec.eligy_prfl_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ordr_to_aply_num
  (p_eligy_prfl_rl_id          => p_rec.eligy_prfl_rl_id,
   p_eligy_prfl_id             => p_rec.eligy_prfl_id,
   p_ordr_to_aply_num      => p_rec.ordr_to_aply_num,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_object_version_number => p_rec.object_version_number);
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
	(p_rec 			 in ben_erl_shd.g_rec_type,
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
     p_eligy_prfl_rl_id		=> p_rec.eligy_prfl_rl_id);
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
  (p_eligy_prfl_rl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_eligy_prfl_rl_f b
    where b.eligy_prfl_rl_id      = p_eligy_prfl_rl_id
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
                             p_argument       => 'eligy_prfl_rl_id',
                             p_argument_value => p_eligy_prfl_rl_id);
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
end ben_erl_bus;

/
