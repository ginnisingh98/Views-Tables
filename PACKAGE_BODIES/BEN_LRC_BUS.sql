--------------------------------------------------------
--  DDL for Package Body BEN_LRC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LRC_BUS" as
/* $Header: belrcrhi.pkb 115.9 2004/01/25 00:24:37 hmani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lrc_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_rltd_per_cs_ler_id >------|
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
--   ler_rltd_per_cs_ler_id PK of record being inserted or updated.
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
Procedure chk_ler_rltd_per_cs_ler_id(p_ler_rltd_per_cs_ler_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_rltd_per_cs_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lrc_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_rltd_per_cs_ler_id      => p_ler_rltd_per_cs_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_rltd_per_cs_ler_id,hr_api.g_number)
     <>  ben_lrc_shd.g_old_rec.ler_rltd_per_cs_ler_id) then
    --
    -- raise error as PK has changed
    --
    ben_lrc_shd.constraint_error('BEN_LER_RTLD_PER_CS_LER_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_rltd_per_cs_ler_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_lrc_shd.constraint_error('BEN_LER_RTLD_PER_CS_LER_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_rltd_per_cs_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rltd_per_chg_cs_ler_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table and that the key is entered.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ler_rltd_per_cs_ler_id PK
--   p_rltd_per_chg_cs_ler_id ID of FK column
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
Procedure chk_rltd_per_chg_cs_ler_id (p_ler_rltd_per_cs_ler_id          in number,
                            p_rltd_per_chg_cs_ler_id          in number,
                            p_ler_id                          in number,
                            p_validation_start_date in date,
                            p_validation_end_date   in date,
                            p_effective_date        in date,
                            p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rltd_per_chg_cs_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_rltd_per_chg_cs_ler_f a
    where  a.rltd_per_chg_cs_ler_id = p_rltd_per_chg_cs_ler_id
    and    p_effective_date between effective_start_date
    and    effective_end_date;
  --
  CURSOR c2 (p_ler_rltd_per_cs_ler_id number
                 ,p_ler_id              number
                 ,p_rltd_per_chg_cs_ler_id    number
                 ,p_business_group_id   number
                 ,p_validation_start_date date
                 ,p_validation_end_date   date) IS
    SELECT  'x'
    FROM    ben_ler_rltd_per_cs_ler_f
    WHERE   ler_rltd_per_cs_ler_id    <> nvl(p_ler_rltd_per_cs_ler_id, hr_api.g_number)
    AND     rltd_per_chg_cs_ler_id    = p_rltd_per_chg_cs_ler_id
    AND     ler_id                    = p_ler_id
    AND     business_group_id + 0     = p_business_group_id
    AND     p_validation_start_date <= effective_end_date
    AND     p_validation_end_date   >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);

  if p_rltd_per_chg_cs_ler_id is null then
     fnd_message.set_name('BEN', 'BEN_91016_PERSON_CHANGE_REQ');
     fnd_message.raise_error;
  end if;
  --
  l_api_updating := ben_lrc_shd.api_updating
     (p_ler_rltd_per_cs_ler_id            => p_ler_rltd_per_cs_ler_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);

  --
  if (l_api_updating
     and nvl(p_rltd_per_chg_cs_ler_id,hr_api.g_number)
     <> nvl(ben_lrc_shd.g_old_rec.rltd_per_chg_cs_ler_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if rltd_per_chg_cs_ler_id value exists in
    -- ben_rltd_per_chg_cs_ler_f table
    --
    open c1;
      fetch c1 into l_dummy;
      if c1%notfound then
        close c1;
        -- raise error as FK does not relate to PK in ben_rltd_per_chg_cs_ler_f
        -- table.
        ben_lrc_shd.constraint_error('BEN_LER_RLTD_PER_CS_LER_F_FK2');
      end if;
    close c1;
    -- check if the foreign key is unique for this ler.
    open c2
            (p_ler_rltd_per_cs_ler_id     => p_ler_rltd_per_cs_ler_id
             ,p_ler_id                    => p_ler_id
             ,p_rltd_per_chg_cs_ler_id    => p_rltd_per_chg_cs_ler_id
             ,p_business_group_id         => p_business_group_id
             ,p_validation_start_date     => p_validation_start_date
             ,p_validation_end_date       => p_validation_end_date) ;

      fetch c2 into l_dummy;
      if c2%found then
        close c2;
        fnd_message.set_name('BEN', 'BEN_91017_PERSON_CHANGE_UNIQUE');
        fnd_message.raise_error;
      end if;
    close c2;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_rltd_per_chg_cs_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_rltd_per_cs_chg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_rltd_per_cs_ler_id PK of record being inserted or updated.
--   ler_rltd_per_cs_chg_rl Value of formula rule id.
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
Procedure chk_ler_rltd_per_cs_chg_rl(p_ler_rltd_per_cs_ler_id     in number,
                             p_ler_rltd_per_cs_chg_rl   in number,
                             p_business_group_id     in number,
                             p_effective_date        in date,
                             p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_rltd_per_cs_chg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
            ,per_business_groups pbg
    where  ff.formula_id = p_ler_rltd_per_cs_chg_rl
    and    ff.formula_type_id = -168   -- Person Information Causes Life Event
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id, p_business_group_id) = p_business_group_id
    and    nvl(ff.legislation_code, pbg.legislation_code) = pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lrc_shd.api_updating
    (p_ler_rltd_per_cs_ler_id                => p_ler_rltd_per_cs_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_ler_rltd_per_cs_chg_rl,hr_api.g_number)
      <> ben_lrc_shd.g_old_rec.ler_rltd_per_cs_chg_rl
      or not l_api_updating)
      and p_ler_rltd_per_cs_chg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound or c1%notfound is null then
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
end chk_ler_rltd_per_cs_chg_rl;
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
            (p_formula_id           in number default hr_api.g_number,
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
            (p_ler_rltd_per_cs_ler_id		in number,
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
       p_argument       => 'ler_rltd_per_cs_ler_id',
       p_argument_value => p_ler_rltd_per_cs_ler_id);
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
	(p_rec 			 in ben_lrc_shd.g_rec_type,
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
  chk_ler_rltd_per_cs_ler_id
  (p_ler_rltd_per_cs_ler_id          => p_rec.ler_rltd_per_cs_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rltd_per_chg_cs_ler_id
  (p_ler_rltd_per_cs_ler_id          => p_rec.ler_rltd_per_cs_ler_id,
   p_rltd_per_chg_cs_ler_id          => p_rec.rltd_per_chg_cs_ler_id,
   p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  -- Ensure that child records are not created for certain delivered ler types.
  --
  ben_lpl_bus.chk_ler_id
  (p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  ben_lpl_bus.chk_ler_typ_cd
  (p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_rltd_per_cs_chg_rl
  (p_ler_rltd_per_cs_ler_id          => p_rec.ler_rltd_per_cs_ler_id,
   p_ler_rltd_per_cs_chg_rl        => p_rec.ler_rltd_per_cs_chg_rl,
   p_business_group_id     => p_rec.business_group_id,
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
	(p_rec 			 in ben_lrc_shd.g_rec_type,
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
  chk_ler_rltd_per_cs_ler_id
  (p_ler_rltd_per_cs_ler_id          => p_rec.ler_rltd_per_cs_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rltd_per_chg_cs_ler_id
  (p_ler_rltd_per_cs_ler_id          => p_rec.ler_rltd_per_cs_ler_id,
   p_rltd_per_chg_cs_ler_id          => p_rec.rltd_per_chg_cs_ler_id,
   p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  -- Ensure that child records are not created for certain delivered ler types.
  --
  ben_lpl_bus.chk_ler_id
  (p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_rltd_per_cs_chg_rl
  (p_ler_rltd_per_cs_ler_id        => p_rec.ler_rltd_per_cs_ler_id,
   p_ler_rltd_per_cs_chg_rl        => p_rec.ler_rltd_per_cs_chg_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_formula_id           => p_rec.ler_rltd_per_cs_chg_rl,
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
	(p_rec 			 in ben_lrc_shd.g_rec_type,
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
     p_ler_rltd_per_cs_ler_id		=> p_rec.ler_rltd_per_cs_ler_id);
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
  (p_ler_rltd_per_cs_ler_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_rltd_per_cs_ler_f b
    where b.ler_rltd_per_cs_ler_id      = p_ler_rltd_per_cs_ler_id
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
                             p_argument       => 'ler_rltd_per_cs_ler_id',
                             p_argument_value => p_ler_rltd_per_cs_ler_id);
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
end ben_lrc_bus;

/
