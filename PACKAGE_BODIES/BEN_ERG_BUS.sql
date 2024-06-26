--------------------------------------------------------
--  DDL for Package Body BEN_ERG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ERG_BUS" as
/* $Header: beergrhi.pkb 120.1 2006/02/27 01:55:45 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_erg_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ELIG_PERF_RTNG_PRTE_id >------|
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
--   ELIG_PERF_RTNG_PRTE_id PK of record being inserted or updated.
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
Procedure chk_ELIG_PERF_RTNG_PRTE_id
            (p_ELIG_PERF_RTNG_PRTE_id  in number,
             p_effective_date              in date,
             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ELIG_PERF_RTNG_PRTE_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_erg_shd.api_updating
    (p_effective_date        => p_effective_date,
     p_ELIG_PERF_RTNG_PRTE_id => p_ELIG_PERF_RTNG_PRTE_id,
     p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ELIG_PERF_RTNG_PRTE_id,hr_api.g_number)
     <>  ben_erg_shd.g_old_rec.ELIG_PERF_RTNG_PRTE_id) then
    --
    -- raise error as PK has changed
    --
    ben_erg_shd.constraint_error('BEN_ELIG_PERF_RTNG_PRTE_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ELIG_PERF_RTNG_PRTE_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_erg_shd.constraint_error('BEN_ELIG_PERF_RTNG_PRTE_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ELIG_PERF_RTNG_PRTE_id;
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
--   ELIG_PERF_RTNG_PRTE_id PK of record being inserted or updated.
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
Procedure chk_excld_flag(p_ELIG_PERF_RTNG_PRTE_id  in number,
                         p_excld_flag               in varchar2,
                         p_effective_date           in date,
                         p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_excld_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_erg_shd.api_updating
    (p_ELIG_PERF_RTNG_PRTE_id  => p_ELIG_PERF_RTNG_PRTE_id,
     p_effective_date         => p_effective_date,
     p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_erg_shd.g_old_rec.excld_flag,hr_api.g_varchar2)
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
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('VALUE',p_excld_flag);
      fnd_message.set_token('FIELD','EXCLD_FLAG');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
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
-- |------< chk_event_type>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ELIG_PERF_RTNG_PRTE_id PK
--   p_event_type of FK column
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
Procedure chk_event_type (p_ELIG_PERF_RTNG_PRTE_id  	in number,
                        p_event_type 		in varchar2,
                        p_object_version_number in number,
                        p_effective_date        in date,
                        p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_event_type';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_erg_shd.api_updating
     (p_ELIG_PERF_RTNG_PRTE_id => p_ELIG_PERF_RTNG_PRTE_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_event_type,hr_api.g_varchar2)
     <> nvl(ben_erg_shd.g_old_rec.event_type,hr_api.g_varchar2)
     or not l_api_updating)
     and p_event_type is not null
     and p_event_type <> '-1'        /* Bug 4031314 : Enter Event Type as -1, when user does not select it */
  then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'EMP_INTERVIEW_TYPE',
           p_lookup_code    => p_event_type,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('VALUE',p_event_type);
      fnd_message.set_token('FIELD','EVENT_TYPE');
      fnd_message.set_token('TYPE','EMP_INTERVIEW_TYPE');
      fnd_message.raise_error;
      --
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_event_type;
--

--
-- ----------------------------------------------------------------------------
-- |------< chk_perf_rtng_cd>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ELIG_PERF_RTNG_PRTE_id PK
--   p_perf_rtng_cd of FK column
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
Procedure chk_perf_rtng_cd (p_ELIG_PERF_RTNG_PRTE_id  in number,
                        p_perf_rtng_cd in  varchar2,
                        p_object_version_number in number,
                        p_effective_date        in date,
                        p_business_group_id     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_perf_rtng_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_erg_shd.api_updating
     (p_ELIG_PERF_RTNG_PRTE_id => p_ELIG_PERF_RTNG_PRTE_id,
      p_effective_date        => p_effective_date,
      p_object_version_number => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_perf_rtng_cd,hr_api.g_varchar2)
     <> nvl(ben_erg_shd.g_old_rec.perf_rtng_cd,hr_api.g_varchar2)
     or not l_api_updating)
     and p_perf_rtng_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'PERFORMANCE_RATING',
           p_lookup_code    => p_perf_rtng_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('VALUE',p_perf_rtng_cd);
      fnd_message.set_token('FIELD','PERF_RTNG_CD');
      fnd_message.set_token('TYPE','PERFORMANCE_RATING');
      fnd_message.raise_error;
      --
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_perf_rtng_cd;
--

-- ----------------------------------------------------------------------------
-- |------< chk_dup_perf_rtng_cd_criteria>------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks for a duplicate leave of absence criteria.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ELIG_PERF_RTNG_PRTE_id
--   p_ELIGY_PRFL_id
--   p_event_type
--   p_perf_rtng_cd
--   p_validation_start_date
--   p_validation_end_date
--   p_business_group_id
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
Procedure chk_dup_perf_rtng_cd_criteria (p_ELIG_PERF_RTNG_PRTE_id    in number,
                            p_event_type       		  in varchar2,
                            p_perf_rtng_cd                in varchar2,
                            p_ELIGY_PRFL_id             in number,
                            p_business_group_id           in number
                            ) is
  --
  l_proc         varchar2(72) := g_package||'chk_dup_perf_rtng_cd_criteria';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
     select null
       from ben_ELIG_PERF_RTNG_PRTE_f erg
       where nvl(erg.event_type,'xxxx') = nvl(p_event_type,'xxxx')
       and   nvl(erg.perf_rtng_cd,'xxxx') = nvl(p_perf_rtng_cd,'xxxx')
       and erg.ELIGY_PRFL_id = p_ELIGY_PRFL_id
       and erg.ELIG_PERF_RTNG_PRTE_id <> nvl(p_ELIG_PERF_RTNG_PRTE_id,hr_api.g_number)
       and erg.business_group_id = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open c1;
      --
    fetch c1 into l_dummy;
    if c1%found then
        --
      close c1;
      --
      -- raise error as duplicate criteria has been entered
      --
      fnd_message.set_name('BEN','BEN_91349_DUP_ELIG_CRITERIA');
      fnd_message.raise_error;
      --
    end if;
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dup_perf_rtng_cd_criteria;
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
--   p_ELIG_PERF_RTNG_PRTE_id    ELIG_PERF_RTNG_PRTE_id
--   p_eligy_prfl_id             eligy_prfl_id
--   p_ordr_num                  Sequence Number
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
          ( p_ELIG_PERF_RTNG_PRTE_id      in   number
           ,p_eligy_prfl_id               in   number
           ,p_ordr_num                    in   number
           ,p_business_group_id           in   number)
is
  l_proc     varchar2(72) := g_package||'chk_duplicate_ordr_num';
  l_dummy    char(1);
  cursor c1 is
    select null
    from   ben_ELIG_PERF_RTNG_PRTE_f
    where  ELIG_PERF_RTNG_PRTE_id <> nvl(p_ELIG_PERF_RTNG_PRTE_id,-1)
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
            (p_ELIGY_PRFL_id               in number default hr_api.g_number,
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
    If ((nvl(p_ELIGY_PRFL_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ELIGY_PRFL_f',
             p_base_key_column => 'ELIGY_PRFL_id',
             p_base_key_value  => p_ELIGY_PRFL_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ELIGY_PRFL_f';
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
            (p_ELIG_PERF_RTNG_PRTE_id in number,
             p_datetrack_mode        in varchar2,
	     p_validation_start_date in date,
	     p_validation_end_date   in date) Is
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
       p_argument       => 'ELIG_PERF_RTNG_PRTE_id',
       p_argument_value => p_ELIG_PERF_RTNG_PRTE_id);
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
	(p_rec 			 in ben_erg_shd.g_rec_type,
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
  chk_ELIG_PERF_RTNG_PRTE_id
  (p_ELIG_PERF_RTNG_PRTE_id => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_ELIG_PERF_RTNG_PRTE_id 	   => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_excld_flag            => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_event_type
  (p_ELIG_PERF_RTNG_PRTE_id 	   => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_event_type 	   => p_rec.event_type,
   p_object_version_number => p_rec.object_version_number,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_perf_rtng_cd
  (p_ELIG_PERF_RTNG_PRTE_id       => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_perf_rtng_cd          => p_rec.perf_rtng_cd,
   p_object_version_number => p_rec.object_version_number,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dup_perf_rtng_cd_criteria
  (p_ELIG_PERF_RTNG_PRTE_id 	   => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_event_type 	   => p_rec.event_type,
   p_perf_rtng_cd          => p_rec.perf_rtng_cd,
   p_ELIGY_PRFL_id       => p_rec.ELIGY_PRFL_id,
   p_business_group_id     => p_rec.business_group_id);
  --
 chk_duplicate_ordr_num
( p_ELIG_PERF_RTNG_PRTE_id       => p_rec.ELIG_PERF_RTNG_PRTE_id
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
	(p_rec 			 in ben_erg_shd.g_rec_type,
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
  chk_ELIG_PERF_RTNG_PRTE_id
  (p_ELIG_PERF_RTNG_PRTE_id 	   => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_excld_flag
  (p_ELIG_PERF_RTNG_PRTE_id  	   => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_excld_flag            => p_rec.excld_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_event_type
  (p_ELIG_PERF_RTNG_PRTE_id       => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_event_type   	   => p_rec.event_type,
   p_object_version_number => p_rec.object_version_number,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_perf_rtng_cd
  (p_ELIG_PERF_RTNG_PRTE_id       => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_perf_rtng_cd          => p_rec.perf_rtng_cd,
   p_object_version_number => p_rec.object_version_number,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
  --
  chk_dup_perf_rtng_cd_criteria
  (p_ELIG_PERF_RTNG_PRTE_id       => p_rec.ELIG_PERF_RTNG_PRTE_id,
   p_event_type 		   => p_rec.event_type,
   p_perf_rtng_cd          => p_rec.perf_rtng_cd,
   p_ELIGY_PRFL_id       => p_rec.ELIGY_PRFL_id,
   p_business_group_id     => p_rec.business_group_id);
  --
 chk_duplicate_ordr_num
( p_ELIG_PERF_RTNG_PRTE_id       => p_rec.ELIG_PERF_RTNG_PRTE_id
 ,p_eligy_prfl_id             	 => p_rec.eligy_prfl_id
 ,p_ordr_num                  	 => p_rec.ordr_num
 ,p_business_group_id         	 => p_rec.business_group_id);
 --
 -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ELIGY_PRFL_id               => p_rec.ELIGY_PRFL_id,
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
	(p_rec 			 in ben_erg_shd.g_rec_type,
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
     p_ELIG_PERF_RTNG_PRTE_id => p_rec.ELIG_PERF_RTNG_PRTE_id);
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
  (p_ELIG_PERF_RTNG_PRTE_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ELIG_PERF_RTNG_PRTE_f b
    where b.ELIG_PERF_RTNG_PRTE_id      = p_ELIG_PERF_RTNG_PRTE_id
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
                             p_argument       => 'ELIG_PERF_RTNG_PRTE_id',
                             p_argument_value => p_ELIG_PERF_RTNG_PRTE_id);
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
end ben_erg_bus;

/
