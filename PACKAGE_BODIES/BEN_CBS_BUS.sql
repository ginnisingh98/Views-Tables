--------------------------------------------------------
--  DDL for Package Body BEN_CBS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CBS_BUS" as
/* $Header: becbsrhi.pkb 120.1 2006/07/07 06:24:07 gsehgal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cbs_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prem_cstg_by_sgmt_id >------|
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
--   prem_cstg_by_sgmt_id PK of record being inserted or updated.
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
Procedure chk_prem_cstg_by_sgmt_id(p_prem_cstg_by_sgmt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prem_cstg_by_sgmt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cbs_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prem_cstg_by_sgmt_id                => p_prem_cstg_by_sgmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prem_cstg_by_sgmt_id,hr_api.g_number)
     <>  ben_cbs_shd.g_old_rec.prem_cstg_by_sgmt_id) then
    --
    -- raise error as PK has changed
    --
    ben_cbs_shd.constraint_error('BEN_PREM_CSTG_BY_SGMT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prem_cstg_by_sgmt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cbs_shd.constraint_error('BEN_PREM_CSTG_BY_SGMT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prem_cstg_by_sgmt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_sgmt_cstg_mthd_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prem_cstg_by_sgmt_id PK of record being inserted or updated.
--   sgmt_cstg_mthd_rl Value of formula rule id.
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
Procedure chk_sgmt_cstg_mthd_rl(p_prem_cstg_by_sgmt_id                in number,
                             p_sgmt_cstg_mthd_rl              in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sgmt_cstg_mthd_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
    where  ff.formula_id = p_sgmt_cstg_mthd_rl
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cbs_shd.api_updating
    (p_prem_cstg_by_sgmt_id                => p_prem_cstg_by_sgmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_sgmt_cstg_mthd_rl,hr_api.g_number)
      <> ben_cbs_shd.g_old_rec.sgmt_cstg_mthd_rl
      or not l_api_updating)
      and p_sgmt_cstg_mthd_rl is not null then
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
        fnd_message.set_name('PAY','FORMULA_DOES_NOT_EXIST');
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
end chk_sgmt_cstg_mthd_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_sgmt_cstg_mthd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prem_cstg_by_sgmt_id PK of record being inserted or updated.
--   sgmt_cstg_mthd_cd Value of lookup code.
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
Procedure chk_sgmt_cstg_mthd_cd(p_prem_cstg_by_sgmt_id                in number,
                            p_sgmt_cstg_mthd_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sgmt_cstg_mthd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cbs_shd.api_updating
    (p_prem_cstg_by_sgmt_id                => p_prem_cstg_by_sgmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_sgmt_cstg_mthd_cd
      <> nvl(ben_cbs_shd.g_old_rec.sgmt_cstg_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_SGMT_CSTG_MTHD',
           p_lookup_code    => p_sgmt_cstg_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_sgmt_cstg_mthd_cd');
      fnd_message.set_token('TYPE','BEN_SGMT_CSTG_MTHD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_sgmt_cstg_mthd_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_code_rule_dpnd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Rule is only allowed to
--   have a value if the value of the Code = 'Rule', and if code is
--   = RL then p_rule must have a value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   P_CODE value of code item.
--   P_RULE value of rule item
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status                                                                --   Internal table handler use only.
--
Procedure chk_code_rule_dpnd(p_code      in varchar2,
                            p_rule       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_code_rule_dpnd';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_code <> 'RL' and p_rule is not null then
      --
      fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
      fnd_message.raise_error;
      --
  elsif p_code = 'RL' and p_rule is null then
      --
      fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
      fnd_message.raise_error;
    end if;
--  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_code_rule_dpnd;
-- ---------------------------------------------------------------------------
-- |-----------------------< chk_sgmt_num_unique >---------------------------|
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
--     p_sgmt_num                Sequence Number
--     p_prem_cstg_by_sgmt_id           Primary Key
--     p_actl_prem_id            Foreign Key to BEN_ACTL_PREM_F
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
Procedure chk_sgmt_num_unique
          ( p_prem_cstg_by_sgmt_id      in number
           ,p_actl_prem_id              in   number
           ,p_sgmt_num                  in   number
           ,p_business_group_id         in   number)
is
l_proc      varchar2(72) := g_package||'chk_sgmt_num_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_prem_cstg_by_sgmt_f
             Where prem_cstg_by_sgmt_id  <> nvl(p_prem_cstg_by_sgmt_id,-1)
             and    actl_prem_id = p_actl_prem_id
             and    sgmt_num = p_sgmt_num
             and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);                                --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_sgmt_num_unique;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_sgmt_cstg_asnmt_lvl >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the actl_prem.prem_asnmt_cd = ploip
--   then the sgmt_cstg_mthd_cd can not equal 'from assignment' codes. 'VFA'
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id          actl_prem_id.
--   sgmt_cstg_mthd_cd
--   effective_date        Session date of record.
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_sgmt_cstg_asnmt_lvl(p_actl_prem_id               in number,
                                   p_sgmt_cstg_mthd_cd         in varchar2,
                                   p_effective_date            in date,
                                   p_business_group_id         in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sgmt_cstg_asnmt_lvl' ;
  l_api_updating boolean;
  l_prem_asnmt_lvl_cd hr_lookups.lookup_code%TYPE; -- UTF8varchar2(30);
  --
  cursor c1 is
    select prem_asnmt_lvl_cd  from   ben_actl_prem_f a
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
  if p_sgmt_cstg_mthd_cd = 'VFA' then
    --
    -- Check if prem_asnmt_lvl_cd  is 'PLOIPL'.
    --
    open c1;
      --
      fetch c1 into l_prem_asnmt_lvl_cd ;
      if c1%found and l_prem_asnmt_lvl_cd = 'PLOIPL' then
       --
        close c1;
        --
        -- raise an error as this p_sgmt_cstg_mthd_cd can't = 'VFA'
        --
        fnd_message.set_name('BEN','BEN_92257_SGMT_CSTG_ASNMT_LVL');
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
End chk_sgmt_cstg_asnmt_lvl;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_parent_data >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that
--   1) If parent actual premium has PREM_ASNMT_CD=PROC, then no row can be
--    inserted in the child table.
--
--   2) No row can be inserted if default costing in parent is null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actl_prem_id          actl_prem_id.
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_parent_data(p_actl_prem_id               in number,
                          p_business_group_id         in number,
			  -- bug 5376303
			  p_effective_date            in date ) is

l_proc         varchar2(72) := g_package||'chk_parent_data' ;
l_prem_asnmt_cd  hr_lookups.lookup_code%TYPE; -- UTF8   varchar2(30);
l_cost_alloc_cd  number(15);
  --
  cursor c1 is
    select a.prem_asnmt_cd,a.cost_allocation_keyflex_id from ben_actl_prem_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.actl_prem_id = p_actl_prem_id
     -- bug 5376303
     and p_effective_date between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    open c1;
    --
      fetch c1 into l_prem_asnmt_cd,l_cost_alloc_cd ;
    --
    -- Check if prem_asnmt_cd  is 'PROC'.
    --
      if c1%found and l_prem_asnmt_cd = 'PROC' then
       --
        close c1;
        --
        -- raise an error
        --
        fnd_message.set_name('BEN','BEN_92529_NO_COST');
        fnd_message.raise_error;
        --
      end if;
      --
      if c1%found and l_cost_alloc_cd is null then
       --
        close c1;
        --
        -- raise an error
        --
        fnd_message.set_name('BEN','BEN_92530_DFLT_RQD');
        fnd_message.raise_error;
        --
      end if;

    close c1;
    --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_parent_data;
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
            (p_prem_cstg_by_sgmt_id		in number,
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
       p_argument       => 'prem_cstg_by_sgmt_id',
       p_argument_value => p_prem_cstg_by_sgmt_id);
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
	(p_rec 			 in ben_cbs_shd.g_rec_type,
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
  chk_prem_cstg_by_sgmt_id
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sgmt_cstg_mthd_rl
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_sgmt_cstg_mthd_rl        => p_rec.sgmt_cstg_mthd_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sgmt_cstg_mthd_cd
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_sgmt_cstg_mthd_cd         => p_rec.sgmt_cstg_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_code_rule_dpnd
  (p_code                      => p_rec.sgmt_cstg_mthd_cd,
   p_rule                      => p_rec.sgmt_cstg_mthd_rl);
  --
  chk_sgmt_num_unique
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_actl_prem_id           => p_rec.actl_prem_id,
   p_sgmt_num               => p_rec.sgmt_num,
   p_business_group_id      => p_rec.business_group_id);
  --
  chk_sgmt_cstg_asnmt_lvl
  (p_actl_prem_id           => p_rec.actl_prem_id,
   p_sgmt_cstg_mthd_cd         => p_rec.sgmt_cstg_mthd_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id      => p_rec.business_group_id);
  --
  chk_parent_data
  (p_actl_prem_id         =>p_rec.actl_prem_id,
   p_business_group_id      => p_rec.business_group_id,
  p_effective_date        => p_effective_date );
  --

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cbs_shd.g_rec_type,
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
  chk_prem_cstg_by_sgmt_id
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sgmt_cstg_mthd_rl
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_sgmt_cstg_mthd_rl        => p_rec.sgmt_cstg_mthd_rl,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sgmt_cstg_mthd_cd
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_sgmt_cstg_mthd_cd         => p_rec.sgmt_cstg_mthd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_code_rule_dpnd
  (p_code                      => p_rec.sgmt_cstg_mthd_cd,
   p_rule                      => p_rec.sgmt_cstg_mthd_rl);
  --
  chk_sgmt_num_unique
  (p_prem_cstg_by_sgmt_id          => p_rec.prem_cstg_by_sgmt_id,
   p_actl_prem_id           => p_rec.actl_prem_id,
   p_sgmt_num               => p_rec.sgmt_num,
   p_business_group_id      => p_rec.business_group_id);
  --
  chk_sgmt_cstg_asnmt_lvl
  (p_actl_prem_id           => p_rec.actl_prem_id,
   p_sgmt_cstg_mthd_cd         => p_rec.sgmt_cstg_mthd_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id      => p_rec.business_group_id);
  --
  chk_parent_data
  (p_actl_prem_id         =>p_rec.actl_prem_id,
   p_business_group_id      => p_rec.business_group_id,
   p_effective_date        => p_effective_date);
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
	(p_rec 			 in ben_cbs_shd.g_rec_type,
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
     p_prem_cstg_by_sgmt_id		=> p_rec.prem_cstg_by_sgmt_id);
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
  (p_prem_cstg_by_sgmt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prem_cstg_by_sgmt_f b
    where b.prem_cstg_by_sgmt_id      = p_prem_cstg_by_sgmt_id
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
                             p_argument       => 'prem_cstg_by_sgmt_id',
                             p_argument_value => p_prem_cstg_by_sgmt_id);
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
end ben_cbs_bus;

/
