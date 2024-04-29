--------------------------------------------------------
--  DDL for Package Body BEN_CER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CER_BUS" as
/* $Header: becerrhi.pkb 120.0 2005/05/28 01:00:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cer_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtn_eligy_rl_id >------|
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
--   prtn_eligy_rl_id PK of record being inserted or updated.
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
Procedure chk_prtn_eligy_rl_id(p_prtn_eligy_rl_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtn_eligy_rl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cer_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prtn_eligy_rl_id                => p_prtn_eligy_rl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtn_eligy_rl_id,hr_api.g_number)
     <>  ben_cer_shd.g_old_rec.prtn_eligy_rl_id) then
    --
    -- raise error as PK has changed
    --
    ben_cer_shd.constraint_error('BEN_ELIGY_RL_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prtn_eligy_rl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cer_shd.constraint_error('BEN_ELIGY_RL_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prtn_eligy_rl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mndtry_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_eligy_rl_id PK of record being inserted or updated.
--   mndtry_flag Value of lookup code.
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
Procedure chk_mndtry_flag(p_prtn_eligy_rl_id                in number,
                            p_mndtry_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mndtry_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cer_shd.api_updating
    (p_prtn_eligy_rl_id                => p_prtn_eligy_rl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_mndtry_flag
      <> nvl(ben_cer_shd.g_old_rec.mndtry_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_mndtry_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_mndtry_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mndtry_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_drvbl_fctr_apls_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_eligy_rl_id PK of record being inserted or updated.
--   drvbl_fctr_apls_flag Value of lookup code.
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
Procedure chk_drvbl_fctr_apls_flag(p_prtn_eligy_rl_id                in number,
                            p_drvbl_fctr_apls_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_drvbl_fctr_apls_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cer_shd.api_updating
    (p_prtn_eligy_rl_id                => p_prtn_eligy_rl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_drvbl_fctr_apls_flag
      <> nvl(ben_cer_shd.g_old_rec.drvbl_fctr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_apls_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_drvbl_fctr_apls_flag');
      fnd_message.set_token('TYPE', 'YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_drvbl_fctr_apls_flag;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_formula_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtn_eligy_rl_id      PK of record being inserted or updated.
--   formula_id            Value of formula rule id.
--   effective_date        effective date
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
Procedure chk_formula_id(p_prtn_eligy_rl_id         in number,
                         p_business_group_id        in number,
                         p_formula_id               in number,
                         p_effective_date           in date,
                         p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_formula_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_formula_id
    and    ff.formula_type_id = -153 -- BEN_ELIGY
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id,p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code,pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cer_shd.api_updating
    (p_prtn_eligy_rl_id         => p_prtn_eligy_rl_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_formula_id,hr_api.g_number)
      <> ben_cer_shd.g_old_rec.formula_id
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
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_formula_id);
        fnd_message.set_token('TYPE_ID',-153);
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
-- |--------------------<chk_duplicate_ordr_num >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--     make sure ordr_to_aply_num is unique within prtn_elig_prfl
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_prtn_eligy_prfl_rl_id
--     p_prtn_elig_prfl_id
--     p_ordr_to_aply_num
--     p_business_group_id
--     p_effective_date
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
Procedure chk_duplicate_ordr_num
          ( p_prtn_eligy_rl_id in number
           ,p_prtn_elig_id in number
           ,p_ordr_to_aply_num in number
           ,p_business_group_id in number
           ,p_effective_date in date )
is
   l_proc  varchar2(72) := g_package||' chk_duplicate_ordr_num ';
   l_dummy char(1);
   cursor c1 is select null
                  from ben_prtn_eligy_rl_f
                 where prtn_eligy_rl_id <> nvl(p_prtn_eligy_rl_id, -1 )
                   and prtn_elig_id = p_prtn_elig_id
                   and ordr_to_aply_num = p_ordr_to_aply_num
                   and business_group_id + 0 = p_business_group_id
                   and p_effective_date between effective_start_date
                                            and effective_end_date;
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   open c1;
   fetch c1 into l_dummy;
   if c1%found then
       close c1;
       hr_utility.set_message(801,'Duplicate sequence#');
       hr_utility.raise_error;
   end if;
   close c1;
   --
   hr_utility.set_location('Leaving:'||l_proc, 15);
   --
End chk_duplicate_ordr_num;
--
-- bug 3876692
--
-- ----------------------------------------------------------------------------
-- |------< chk_flx_impt_extnce >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks if plan type is flex or imputed shell or not.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtn_elig_id of FK column
--   p_effective_date session date
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
Procedure chk_flx_impt_extnce(
                      p_prtn_elig_id         in number,
                      p_effective_date        in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_flx_impt_extnce';
  l_exists       varchar2(1);
  --
  cursor c1 is
     select null
       from ben_prtn_elig_f prtn, ben_pl_f p
         where prtn.prtn_elig_id = p_prtn_elig_id
		   and prtn.pl_id = p.pl_id
		   and (p.invk_flx_cr_pl_flag = 'Y'
		       or
			   p.imptd_incm_calc_cd is not null)
		   and p_effective_date between prtn.effective_start_date
		       and prtn.effective_end_date
		   and p_effective_date between p.effective_start_date
		       and p.effective_end_date;
  --
  cursor c2 is
     select null
       from ben_prtn_elig_f epa, ben_pl_f pln, ben_plip_f plip
         where epa.prtn_elig_id = p_prtn_elig_id
		   and epa.plip_id = plip.plip_id
		   and plip.pl_id = pln.pl_id
		   and (pln.invk_flx_cr_pl_flag = 'Y'
		       or
			   pln.imptd_incm_calc_cd is not null)
		   and p_effective_date between epa.effective_start_date
		       and epa.effective_end_date
		   and p_effective_date between pln.effective_start_date
		       and pln.effective_end_date
           and p_effective_date between plip.effective_start_date
		       and plip.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
    open c1;
    fetch c1 into l_exists;
    if c1%found then
      close c1;
      --
      -- raise error as insert or update is not allowed when plan
	  -- is flex or imputed shell type
      --
      fnd_message.set_name('BEN','BEN_94046_PLN_INS_VAL');
      fnd_message.raise_error;
    --
    else
      --
      close c1;
      open c2;
	  fetch c2 into l_exists;
	  if c2%found then
	    close c2;
        --
        -- raise error as insert or update is not allowed when plan
	    -- is flex or imputed shell type
        --
        fnd_message.set_name('BEN','BEN_94046_PLN_INS_VAL');
        fnd_message.raise_error;
        --
      end if;
      close c2;
      --
    end if;
    --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_flx_impt_extnce;
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
            (p_prtn_elig_id                  in number default hr_api.g_number,
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
    If ((nvl(p_prtn_elig_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_prtn_elig_f',
             p_base_key_column => 'prtn_elig_id',
             p_base_key_value  => p_prtn_elig_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_prtn_elig_f';
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
            (p_prtn_eligy_rl_id		in number,
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
       p_argument       => 'prtn_eligy_rl_id',
       p_argument_value => p_prtn_eligy_rl_id);
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
	(p_rec 			 in ben_cer_shd.g_rec_type,
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
  chk_prtn_eligy_rl_id
  (p_prtn_eligy_rl_id          => p_rec.prtn_eligy_rl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mndtry_flag
  (p_prtn_eligy_rl_id          => p_rec.prtn_eligy_rl_id,
   p_mndtry_flag         => p_rec.mndtry_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_flag
  (p_prtn_eligy_rl_id          => p_rec.prtn_eligy_rl_id,
   p_drvbl_fctr_apls_flag         => p_rec.drvbl_fctr_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_ordr_num
  (p_rec.prtn_eligy_rl_id
  ,p_rec.prtn_elig_id
  ,p_rec.ordr_to_aply_num
  ,p_rec.business_group_id
  ,p_effective_date);
  --
  chk_formula_id
  (p_prtn_eligy_rl_id      => p_rec.prtn_eligy_rl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_formula_id            => p_rec.formula_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- bug 3876692
  --
  chk_flx_impt_extnce(p_prtn_elig_id          => p_rec.prtn_elig_id,
                      p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cer_shd.g_rec_type,
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
  chk_prtn_eligy_rl_id
  (p_prtn_eligy_rl_id          => p_rec.prtn_eligy_rl_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mndtry_flag
  (p_prtn_eligy_rl_id          => p_rec.prtn_eligy_rl_id,
   p_mndtry_flag         => p_rec.mndtry_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_drvbl_fctr_apls_flag
  (p_prtn_eligy_rl_id          => p_rec.prtn_eligy_rl_id,
   p_drvbl_fctr_apls_flag         => p_rec.drvbl_fctr_apls_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_duplicate_ordr_num
  (p_rec.prtn_eligy_rl_id
  ,p_rec.prtn_elig_id
  ,p_rec.ordr_to_aply_num
  ,p_rec.business_group_id
  ,p_effective_date);
  --
  chk_formula_id
  (p_prtn_eligy_rl_id      => p_rec.prtn_eligy_rl_id,
   p_business_group_id     => p_rec.business_group_id,
   p_formula_id            => p_rec.formula_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_prtn_elig_id                  => p_rec.prtn_elig_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	         => p_validation_end_date);
  --
  -- bug 3876692
  --
  chk_flx_impt_extnce(p_prtn_elig_id          => p_rec.prtn_elig_id,
                      p_effective_date        => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_cer_shd.g_rec_type,
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
     p_prtn_eligy_rl_id		=> p_rec.prtn_eligy_rl_id);
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
  (p_prtn_eligy_rl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prtn_eligy_rl_f b
    where b.prtn_eligy_rl_id      = p_prtn_eligy_rl_id
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
                             p_argument       => 'prtn_eligy_rl_id',
                             p_argument_value => p_prtn_eligy_rl_id);
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
end ben_cer_bus;

/
