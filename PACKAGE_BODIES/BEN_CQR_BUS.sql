--------------------------------------------------------
--  DDL for Package Body BEN_CQR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CQR_BUS" as
/* $Header: becqrrhi.pkb 120.2 2006/03/30 23:57:08 gsehgal noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cqr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_cbr_quald_bnf_rt_id >------|
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
--   cbr_quald_bnf_rt_id PK of record being inserted or updated.
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
Procedure chk_cbr_quald_bnf_rt_id(p_cbr_quald_bnf_rt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cbr_quald_bnf_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cqr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_cbr_quald_bnf_rt_id                => p_cbr_quald_bnf_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cbr_quald_bnf_rt_id,hr_api.g_number)
     <>  ben_cqr_shd.g_old_rec.cbr_quald_bnf_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_cqr_shd.constraint_error('BEN_CBR_QUALD_BNF_RT_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cbr_quald_bnf_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cqr_shd.constraint_error('BEN_CBR_QUALD_BNF_RT_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cbr_quald_bnf_rt_id;

--
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
--   <>  		     PK of record being inserted or updated.
--   <>  		     Value of lookup code.
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
		     (p_cbr_quald_bnf_rt_id     in number,
		      p_ptip_id                 in number,
		      p_pgm_id                  in number,
                      p_quald_bnf_flag          in varchar2,
		      p_vrbl_rt_prfl_id	        in number,
                      p_effective_date          in date,
                      p_object_version_number   in number,
                      p_business_group_id       in number,
		      p_validation_start_date   in date,
		      p_validation_end_date     in date )
is
--
l_proc         varchar2(72) := g_package||'chk_dup_record';
l_api_updating boolean;
l_exists       varchar2(1);
--
cursor c_dup is
select null
from ben_cbr_quald_bnf_rt_f
where quald_bnf_flag = p_quald_bnf_flag
and (pgm_id = nvl(p_pgm_id,hr_api.g_number)
     or
     ptip_id = nvl(p_ptip_id,hr_api.g_number)
    )
and vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
and cbr_quald_bnf_rt_id <> nvl(p_cbr_quald_bnf_rt_id,hr_api.g_number)
and business_group_id + 0 = p_business_group_id
and p_validation_start_date <= effective_end_date
and p_validation_end_date >= effective_start_date;
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cqr_shd.api_updating
    (p_cbr_quald_bnf_rt_id         => p_cbr_quald_bnf_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and
      (p_quald_bnf_flag <> nvl(ben_cqr_shd.g_old_rec.quald_bnf_flag,hr_api.g_varchar2) or
       (nvl(p_pgm_id,hr_api.g_number) <>  nvl(ben_cqr_shd.g_old_rec.pgm_id,hr_api.g_number)
        or
        nvl(p_ptip_id,hr_api.g_number) <> nvl(ben_cqr_shd.g_old_rec.ptip_id,hr_api.g_number)
       )
      )
      or not l_api_updating) then

      	open c_dup;
 	fetch c_dup into l_exists;
	if c_dup%found then
    		close c_dup;
   		--
   		-- raise error as this < > criteria already exists for this profile
   		--
   		fnd_message.set_name('BEN', 'BEN_92992_DUPS_ROW');
   		fnd_message.set_token('VAR1','Cobra qualified beneficiary criteria',TRUE);
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
-- |---------------------< chk_pgm_id >--------------------------------|
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
--   p_cbr_quald_bnf_rt_id PK
--   p_pgm_id ID of FK column
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
Procedure chk_pgm_id (p_cbr_quald_bnf_rt_id    in number,
                      p_pgm_id                   in number,
                      p_effective_date           in date,
                      p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pgm_f a
    where  a.pgm_id = p_pgm_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cqr_shd.api_updating
     (p_effective_date          => p_effective_date,
      p_cbr_quald_bnf_rt_id   => p_cbr_quald_bnf_rt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pgm_id,hr_api.g_number)
     <> nvl(ben_cqr_shd.g_old_rec.pgm_id,hr_api.g_number)
     or not l_api_updating) and p_pgm_id is not null then
    --
    -- check if pgm_id value exists in ben_pgm_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_pgm_f
        -- table.
        --
        ben_cqr_shd.constraint_error('BEN_CBR_QUALD_BNF_RT_F_DT3');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pgm_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_ptip_id >--------------------------------|
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
--   p_cbr_quald_bnf_rt_id PK
--   p_ptip_id ID of FK column
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
Procedure chk_ptip_id(p_cbr_quald_bnf_rt_id    in number,
                      p_ptip_id                  in number,
                      p_effective_date           in date,
                      p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ptip_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ptip_f a
    where  a.ptip_id = p_ptip_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cqr_shd.api_updating
     (p_effective_date          => p_effective_date,
      p_cbr_quald_bnf_rt_id   => p_cbr_quald_bnf_rt_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ptip_id,hr_api.g_number)
     <> nvl(ben_cqr_shd.g_old_rec.ptip_id,hr_api.g_number)
     or not l_api_updating) and p_ptip_id is not null then
    --
    -- check if ptip_id value exists in ben_ptip_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ptip_f
        -- table.
        --
        ben_cqr_shd.constraint_error('BEN_CBR_QUALD_BNF_RT_F_DT2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ptip_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_quald_bnf_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cbr_quald_bnf_rt_id PK of record being inserted or updated.
--   quald_bnf_flag Value of lookup code.
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
Procedure chk_quald_bnf_flag(p_cbr_quald_bnf_rt_id      in number,
                             p_quald_bnf_flag             in varchar2,
                             p_effective_date             in date,
                             p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_quald_bnf_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cqr_shd.api_updating
    (p_cbr_quald_bnf_rt_id       => p_cbr_quald_bnf_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_quald_bnf_flag
      <> nvl(ben_cqr_shd.g_old_rec.quald_bnf_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_quald_bnf_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_quald_bnf_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_quald_bnf_flag;
--
-- added for Bug 5078478 .. add this procedure to check the duplicate seq no
-- |--------------------< chk_duplicate_ordr_num >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--
-- Pre Conditions
--   None.
--
-- In Parameters
--    p_cbr_quald_bnf_rt_id
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
           ,p_cbr_quald_bnf_rt_id  in number
           ,p_ordr_num in number
           ,p_validation_start_date in date
	   ,p_validation_end_date in date
           ,p_business_group_id in number)
is
l_proc   varchar2(72) := g_package||' chk_duplicate_ordr_num ';
   l_dummy    char(1);
   cursor c1 is select null
                  from ben_cbr_quald_bnf_rt_f
                 where vrbl_rt_prfl_id = p_vrbl_rt_prfl_id
                   and cbr_quald_bnf_rt_id   <> nvl(p_cbr_quald_bnf_rt_id  ,-1)
                   --and p_effective_date between effective_start_date
                   --                         and effective_end_date
		   and p_validation_start_date <= effective_end_date
		   and p_validation_end_date >= effective_start_date
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
            (p_vrbl_rt_prfl_id                 in number default hr_api.g_number,
             p_pgm_id                        in number default hr_api.g_number,
             p_ptip_id                       in number default hr_api.g_number,
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
    If ((nvl(p_ptip_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ptip_f',
             p_base_key_column => 'ptip_id',
             p_base_key_value  => p_ptip_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ptip_f';
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
            (p_cbr_quald_bnf_rt_id		in number,
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
       p_argument       => 'cbr_quald_bnf_rt_id',
       p_argument_value => p_cbr_quald_bnf_rt_id);
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
	(p_rec 			 in ben_cqr_shd.g_rec_type,
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
  chk_cbr_quald_bnf_rt_id
  (p_cbr_quald_bnf_rt_id          => p_rec.cbr_quald_bnf_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_id
  (p_cbr_quald_bnf_rt_id  => p_rec.cbr_quald_bnf_rt_id,
   p_pgm_id                 => p_rec.pgm_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_ptip_id
  (p_cbr_quald_bnf_rt_id  => p_rec.cbr_quald_bnf_rt_id,
   p_ptip_id                => p_rec.ptip_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_quald_bnf_flag
  (p_cbr_quald_bnf_rt_id          => p_rec.cbr_quald_bnf_rt_id,
   p_quald_bnf_flag         => p_rec.quald_bnf_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_dup_record
  (p_cbr_quald_bnf_rt_id       => p_rec.cbr_quald_bnf_rt_id,
   p_quald_bnf_flag            => p_rec.quald_bnf_flag,
   p_ptip_id                   => p_rec.ptip_id,
   p_pgm_id                    => p_rec.pgm_id,
   p_vrbl_rt_prfl_id	       => p_rec.vrbl_rt_prfl_id,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number,
   p_business_group_id         => p_rec.business_group_id,
   p_validation_start_date     => p_validation_start_date,
   p_validation_end_date       => p_validation_end_date);
   --
   -- added for Bug 5078478 .. add this procedure to check the duplicate seq no
   chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_cbr_quald_bnf_rt_id	  => p_rec.cbr_quald_bnf_rt_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_validation_start_date => p_validation_start_date
	   ,p_validation_end_date => p_validation_end_date
           ,p_business_group_id   => p_rec.business_group_id);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_cqr_shd.g_rec_type,
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
  chk_cbr_quald_bnf_rt_id
  (p_cbr_quald_bnf_rt_id          => p_rec.cbr_quald_bnf_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_id
  (p_cbr_quald_bnf_rt_id  => p_rec.cbr_quald_bnf_rt_id,
   p_pgm_id                 => p_rec.pgm_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_ptip_id
  (p_cbr_quald_bnf_rt_id  => p_rec.cbr_quald_bnf_rt_id,
   p_ptip_id                => p_rec.ptip_id,
   p_effective_date         => p_effective_date,
   p_object_version_number  => p_rec.object_version_number);
  --
  chk_quald_bnf_flag
  (p_cbr_quald_bnf_rt_id          => p_rec.cbr_quald_bnf_rt_id,
   p_quald_bnf_flag         => p_rec.quald_bnf_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_dup_record
  (p_cbr_quald_bnf_rt_id       => p_rec.cbr_quald_bnf_rt_id,
   p_quald_bnf_flag            => p_rec.quald_bnf_flag,
   p_ptip_id                   => p_rec.ptip_id,
   p_pgm_id                    => p_rec.pgm_id,
   p_vrbl_rt_prfl_id	       => p_rec.vrbl_rt_prfl_id,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number,
   p_business_group_id         => p_rec.business_group_id,
   p_validation_start_date     => p_validation_start_date,
   p_validation_end_date       => p_validation_end_date);
  --
  -- added for Bug 5078478 .. add this procedure to check the duplicate seq no
   chk_duplicate_ordr_num
          (p_vrbl_rt_prfl_id      => p_rec.vrbl_rt_prfl_id
           ,p_cbr_quald_bnf_rt_id	  => p_rec.cbr_quald_bnf_rt_id
           ,p_ordr_num            => p_rec.ordr_num
           ,p_validation_start_date => p_validation_start_date
	   ,p_validation_end_date => p_validation_end_date
           ,p_business_group_id   => p_rec.business_group_id);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_vrbl_rt_prfl_id                 => p_rec.vrbl_rt_prfl_id,
     p_pgm_id                        => p_rec.pgm_id,
     p_ptip_id                       => p_rec.ptip_id,
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
	(p_rec 			 in ben_cqr_shd.g_rec_type,
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
     p_cbr_quald_bnf_rt_id		=> p_rec.cbr_quald_bnf_rt_id);
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
  (p_cbr_quald_bnf_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cbr_quald_bnf_rt_f b
    where b.cbr_quald_bnf_rt_id      = p_cbr_quald_bnf_rt_id
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
                             p_argument       => 'cbr_quald_bnf_rt_id',
                             p_argument_value => p_cbr_quald_bnf_rt_id);
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
end ben_cqr_bus;

/