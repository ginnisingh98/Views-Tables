--------------------------------------------------------
--  DDL for Package Body BEN_CLR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLR_BUS" as
/* $Header: beclrrhi.pkb 115.8 2002/12/31 23:56:57 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_clr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_lvl_rt_id >------|
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
--   comp_lvl_rt_id PK of record being inserted or updated.
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
Procedure chk_comp_lvl_rt_id(p_comp_lvl_rt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_comp_lvl_rt_id                => p_comp_lvl_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_comp_lvl_rt_id,hr_api.g_number)
     <>  ben_clr_shd.g_old_rec.comp_lvl_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_clr_shd.constraint_error('BEN_COMP_LVL_RT_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_comp_lvl_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_clr_shd.constraint_error('BEN_COMP_LVL_RT_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_comp_lvl_rt_id;
--
-- |--------------------< chk_duplicate_ordr_num >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--    p_vrbl_rt_prfl_id
--    p_ordr_num
--    p_effective_date
--    p_business_group_id
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
procedure chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id in number
           ,p_ordr_num in number
           ,p_effective_date in date
           ,p_business_group_id in number
           ,p_comp_lvl_rt_id in number)
is
   l_proc   varchar2(72) := g_package||' chk_duplicate_ordr_num ';
   l_dummy    char(1);
   cursor c1 is select null
                  from ben_comp_lvl_rt_f
                 where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
                   and comp_lvl_rt_id <> nvl(p_comp_lvl_rt_id,-1)
                   and p_effective_date between effective_start_date
                                            and effective_end_date
                   and business_group_id + 0 = p_business_group_id
                   and ordr_num = p_ordr_num;
--
Begin
   hr_utility.set_location('Entering:'||l_proc, 5);

   --
   open c1;
   fetch c1 into l_dummy;
   --
   if c1%found then
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
   end if;
   close c1;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_duplicate_ordr_num;

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
--   comp_lvl_rt_id PK of record being inserted or updated.
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
Procedure chk_excld_flag(p_comp_lvl_rt_id                in number,
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
  l_api_updating := ben_clr_shd.api_updating
    (p_comp_lvl_rt_id                => p_comp_lvl_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_clr_shd.g_old_rec.excld_flag,hr_api.g_varchar2)
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
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
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
-- |-----------------------< chk_comp_lvl_fctr_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the foreign key for the table
--   is created properly. a corresponding record should exist in the
--   BEN_COMP_LVL_FCTR table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   comp_lvl_fctr_id FK of pointing to BEN_COMP_LVL_FCTR tables.
--   business_group_id or record being inserted or updated
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
Procedure chk_comp_lvl_fctr_id(p_comp_lvl_fctr_id      in number,
                              p_business_group_id    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_lvl_fctr_id';
  l_dummy        varchar2(1);
  cursor c1 is select  null
               from    BEN_COMP_LVL_FCTR
               where   comp_lvl_fctr_id = p_comp_lvl_fctr_id
               and     business_group_id = p_business_group_id;
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_comp_lvl_fctr_id is not null then
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        hr_utility.set_message(801,'Comp_Lvl_Fctr_NotExist');
        hr_utility.raise_error;
     end if;
     close c1;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_comp_lvl_fctr_id;

-- ----------------------------------------------------------------------------
-- |------< chk_dup_record >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there is no duplicate record
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_comp_lvl_rt_id        PK of record being inserted or updated.
--   p_comp_lvl_fctr_id      Value of FK
--   p_vrbl_rt_prfl_id	     FK of the record
--   p_effective_date 	     effective date
--   p_object_version_number Object version number of record being
--                           inserted or updated.
--   p_business_group_id     business_group_id of the record
--   p_validation_start_date validation_start_date of record
--   p_validation_end_date   validation_end_date of record
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
Procedure chk_dup_record
		     (p_comp_lvl_rt_id        in number,
		      p_comp_lvl_fctr_id      in number,
		      p_vrbl_rt_prfl_id	      in number,
		      p_effective_date        in date,
		      p_object_version_number in number,
		      p_business_group_id     in number,
		      p_validation_start_date in date,
		      p_validation_end_date   in date )
is
--
l_proc         varchar2(72) := g_package||'chk_dup_record';
l_api_updating boolean;
l_exists       varchar2(1);
--
cursor c_dup is
select null
from ben_comp_lvl_rt_f
where comp_lvl_fctr_id = p_comp_lvl_fctr_id
and vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
and comp_lvl_rt_id <> nvl(p_comp_lvl_rt_id,hr_api.g_number)
and business_group_id + 0 = p_business_group_id
and p_validation_start_date <= effective_end_date
and p_validation_end_date >= effective_start_date;
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clr_shd.api_updating
    (p_comp_lvl_rt_id              => p_comp_lvl_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_lvl_fctr_id <> nvl(ben_clr_shd.g_old_rec.comp_lvl_fctr_id,hr_api.g_number)
      or not l_api_updating) then

	open c_dup;
	fetch c_dup into l_exists;
	if c_dup%found then
		close c_dup;
		--
		-- raise error as this Compensation Level already exists for this profile
		--
		fnd_message.set_name('BEN', 'BEN_92992_DUPS_ROW');
		fnd_message.set_token('VAR1','Compensation Level criteria',TRUE);
		fnd_message.set_token('VAR2','Variable Rate Profile',TRUE);
		fnd_message.raise_error;
		--
	end if;
	close c_dup;
	--
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
END chk_dup_record;


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
            (p_vrbl_rt_prfl_id               in number default hr_api.g_number,
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
    If ((nvl(p_vrbl_rt_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_vrbl_rt_prfl_f',
             p_base_key_column => 'vrbl_rt_prfl_id',
             p_base_key_value  => p_vrbl_rt_prfl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_vrbl_rt_prfl_f';
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
            (p_comp_lvl_rt_id		in number,
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
       p_argument       => 'comp_lvl_rt_id',
       p_argument_value => p_comp_lvl_rt_id);
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
    --
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
	(p_rec 			 in ben_clr_shd.g_rec_type,
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
  chk_comp_lvl_rt_id
  (p_comp_lvl_rt_id          => p_rec.comp_lvl_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_comp_lvl_rt_id          => p_rec.comp_lvl_rt_id,
   p_excld_flag         => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_fctr_id(p_comp_lvl_fctr_id  => p_rec.comp_lvl_fctr_id,
                       p_business_group_id => p_rec.business_group_id);
  --
  chk_dup_record
  (p_comp_lvl_rt_id    	   => p_rec.comp_lvl_rt_id,
   p_comp_lvl_fctr_id      => p_rec.comp_lvl_fctr_id,
   p_vrbl_rt_prfl_id	   => p_rec.vrbl_rt_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date);
  --
chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_effective_date      => p_effective_date
           ,p_business_group_id   => p_rec.business_group_id
           ,p_comp_lvl_rt_id 	  => p_rec.comp_lvl_rt_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_clr_shd.g_rec_type,
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
  chk_comp_lvl_rt_id
  (p_comp_lvl_rt_id          => p_rec.comp_lvl_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_comp_lvl_rt_id          => p_rec.comp_lvl_rt_id,
   p_excld_flag         => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_lvl_fctr_id(p_comp_lvl_fctr_id  => p_rec.comp_lvl_fctr_id,
                       p_business_group_id => p_rec.business_group_id);
  --
  chk_dup_record
  (p_comp_lvl_rt_id    	   => p_rec.comp_lvl_rt_id,
   p_comp_lvl_fctr_id      => p_rec.comp_lvl_fctr_id,
   p_vrbl_rt_prfl_id	   => p_rec.vrbl_rt_prfl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number,
   p_business_group_id     => p_rec.business_group_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_effective_date      => p_effective_date
           ,p_business_group_id   => p_rec.business_group_id
           ,p_comp_lvl_rt_id	  => p_rec.comp_lvl_rt_id);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_clr_shd.g_rec_type,
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
     p_comp_lvl_rt_id		=> p_rec.comp_lvl_rt_id);
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
  (p_comp_lvl_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_comp_lvl_rt_f b
    where b.comp_lvl_rt_id      = p_comp_lvl_rt_id
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
                             p_argument       => 'comp_lvl_rt_id',
                             p_argument_value => p_comp_lvl_rt_id);
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
end ben_clr_bus;

/
