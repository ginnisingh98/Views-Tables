--------------------------------------------------------
--  DDL for Package Body BEN_AVA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AVA_BUS" as
/* $Header: beavarhi.pkb 120.0.12010000.1 2008/08/18 07:00:07 dpatange noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ava_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_actl_prem_vrbl_rt_rl_id >------|
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
--   actl_prem_vrbl_rt_rl_id PK of record being inserted or updated.
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
Procedure chk_actl_prem_vrbl_rt_rl_id(p_actl_prem_vrbl_rt_rl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_actl_prem_vrbl_rt_rl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ava_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_actl_prem_vrbl_rt_rl_id                => p_actl_prem_vrbl_rt_rl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_actl_prem_vrbl_rt_rl_id,hr_api.g_number)
     <>  ben_ava_shd.g_old_rec.actl_prem_vrbl_rt_rl_id) then
    --
    -- raise error as PK has changed
    --
    ben_ava_shd.constraint_error('BEN_ACTL_PREM_VRBL_RT_RL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_actl_prem_vrbl_rt_rl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ava_shd.constraint_error('BEN_ACTL_PREM_VRBL_RT_RL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_actl_prem_vrbl_rt_rl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rt_trtmt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_vrbl_rt_rl_id PK of record being inserted or updated.
--   rt_trtmt_cd Value of lookup code.
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
Procedure chk_rt_trtmt_cd(p_actl_prem_vrbl_rt_rl_id                in number,
                            p_rt_trtmt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rt_trtmt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ava_shd.api_updating
    (p_actl_prem_vrbl_rt_rl_id                => p_actl_prem_vrbl_rt_rl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rt_trtmt_cd
      <> nvl(ben_ava_shd.g_old_rec.rt_trtmt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_trtmt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_TRTMT',
           p_lookup_code    => p_rt_trtmt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91609_INVALID_RT_TRMT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rt_trtmt_cd;
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
--   actl_prem_vrbl_rt_rl_id PK of record being inserted or updated.
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
Procedure chk_formula_id(p_actl_prem_vrbl_rt_rl_id         in number,
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
    and    ff.formula_type_id = -507
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
  l_api_updating := ben_ava_shd.api_updating
    (p_actl_prem_vrbl_rt_rl_id   => p_actl_prem_vrbl_rt_rl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_formula_id,hr_api.g_number)
      <> ben_ava_shd.g_old_rec.formula_id
      or not l_api_updating)
      and p_formula_id is not null then
    --
    -- check if value of formula rule is valid.
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
        fnd_message.set_token('ID',p_formula_id);
        fnd_message.set_token('TYPE_ID',-507);
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
-- |------------------------< chk_vrr_vrp_mutexcl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the rule is mutually exclusive for the
--   actl_prem_id. A profile cannot exist with this actl_prem_id due to the ARC
--   relationship on ben_actl_prem_f.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_vrbl_rt_rl_id  PK of record being inserted or updated.
--   actl_prem_id             actl_prem_id.
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
Procedure chk_vrr_vrp_mutexcl(p_actl_prem_vrbl_rt_rl_id   in number,
                               p_actl_prem_id               in number,
                               p_effective_date            in date,
                               p_business_group_id         in number,
                               p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrr_vrp_mutexcl';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_actl_prem_vrbl_rt_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.actl_prem_id = p_actl_prem_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ava_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_actl_prem_vrbl_rt_rl_id     => p_actl_prem_vrbl_rt_rl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating or not l_api_updating)
     and p_actl_prem_id is not null then
    --
    -- Check if actl_prem_id is mutually exclusive.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise an error as this actl_prem_id has been assigned to profile(s).
        --
        fnd_message.set_name('BEN','BEN_91612_VRR_VRP_EXCL1');
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
End chk_vrr_vrp_mutexcl;
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
--     p_actl_prem_vrbl_rt_rl_id     Primary Key of BEN_ACTL_PREM_VRBL_RT_RL_F
--     p_actl_prem_id                Foreign Key to BEN_ACTL_PREM_F
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
          ( p_actl_prem_vrbl_rt_rl_id   in   number
           ,p_actl_prem_id              in   number
           ,p_ordr_to_aply_num          in   number
           ,p_business_group_id         in   number)
is
l_proc      varchar2(72) := g_package||'chk_ordr_to_aply_num_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_actl_prem_vrbl_rt_rl_f
             Where  actl_prem_vrbl_rt_rl_id <> nvl(p_actl_prem_vrbl_rt_rl_id,-1)
             and    actl_prem_id = p_actl_prem_id
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
            (p_actl_prem_id                  in number default hr_api.g_number,
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
    If ((nvl(p_actl_prem_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_actl_prem_f',
             p_base_key_column => 'actl_prem_id',
             p_base_key_value  => p_actl_prem_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_actl_prem_f';
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
            (p_actl_prem_vrbl_rt_rl_id		in number,
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
       p_argument       => 'actl_prem_vrbl_rt_rl_id',
       p_argument_value => p_actl_prem_vrbl_rt_rl_id);
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
	(p_rec 			 in ben_ava_shd.g_rec_type,
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
  chk_actl_prem_vrbl_rt_rl_id
  (p_actl_prem_vrbl_rt_rl_id          => p_rec.actl_prem_vrbl_rt_rl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_trtmt_cd
  (p_actl_prem_vrbl_rt_rl_id          => p_rec.actl_prem_vrbl_rt_rl_id,
   p_rt_trtmt_cd         => p_rec.rt_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_formula_id
  (p_actl_prem_vrbl_rt_rl_id => p_rec.actl_prem_vrbl_rt_rl_id,
   p_formula_id              => p_rec.formula_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_vrr_vrp_mutexcl
  (p_actl_prem_vrbl_rt_rl_id   => p_rec.actl_prem_vrbl_rt_rl_id,
   p_actl_prem_id              => p_rec.actl_prem_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_ordr_to_aply_num_unique
  (p_actl_prem_vrbl_rt_rl_id   => p_rec.actl_prem_vrbl_rt_rl_id,
   p_actl_prem_id              => p_rec.actl_prem_id,
   p_ordr_to_aply_num          => p_rec.ordr_to_aply_num,
   p_business_group_id         => p_rec.business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ava_shd.g_rec_type,
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
  chk_actl_prem_vrbl_rt_rl_id
  (p_actl_prem_vrbl_rt_rl_id          => p_rec.actl_prem_vrbl_rt_rl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rt_trtmt_cd
  (p_actl_prem_vrbl_rt_rl_id          => p_rec.actl_prem_vrbl_rt_rl_id,
   p_rt_trtmt_cd         => p_rec.rt_trtmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_formula_id
  (p_actl_prem_vrbl_rt_rl_id => p_rec.actl_prem_vrbl_rt_rl_id,
   p_formula_id              => p_rec.formula_id,
   p_business_group_id       => p_rec.business_group_id,
   p_effective_date          => p_effective_date,
   p_object_version_number   => p_rec.object_version_number);
  --
  chk_vrr_vrp_mutexcl
  (p_actl_prem_vrbl_rt_rl_id   => p_rec.actl_prem_vrbl_rt_rl_id,
   p_actl_prem_id              => p_rec.actl_prem_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_ordr_to_aply_num_unique
  (p_actl_prem_vrbl_rt_rl_id   => p_rec.actl_prem_vrbl_rt_rl_id,
   p_actl_prem_id              => p_rec.actl_prem_id,
   p_ordr_to_aply_num          => p_rec.ordr_to_aply_num,
   p_business_group_id         => p_rec.business_group_id);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_actl_prem_id                  => p_rec.actl_prem_id,
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
	(p_rec 			 in ben_ava_shd.g_rec_type,
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
     p_actl_prem_vrbl_rt_rl_id		=> p_rec.actl_prem_vrbl_rt_rl_id);
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
  (p_actl_prem_vrbl_rt_rl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_actl_prem_vrbl_rt_rl_f b
    where b.actl_prem_vrbl_rt_rl_id      = p_actl_prem_vrbl_rt_rl_id
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
                             p_argument       => 'actl_prem_vrbl_rt_rl_id',
                             p_argument_value => p_actl_prem_vrbl_rt_rl_id);
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
end ben_ava_bus;

/
