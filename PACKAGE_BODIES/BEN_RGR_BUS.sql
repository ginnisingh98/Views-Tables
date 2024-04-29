--------------------------------------------------------
--  DDL for Package Body BEN_RGR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RGR_BUS" as
/* $Header: bergrrhi.pkb 120.0.12010000.3 2008/08/05 15:26:29 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_rgr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_popl_rptg_grp_id >------|
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
--   popl_rptg_grp_id PK of record being inserted or updated.
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
Procedure chk_popl_rptg_grp_id(p_popl_rptg_grp_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_popl_rptg_grp_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_rgr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_popl_rptg_grp_id                => p_popl_rptg_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_popl_rptg_grp_id,hr_api.g_number)
     <>  ben_rgr_shd.g_old_rec.popl_rptg_grp_id) then
    --
    -- raise error as PK has changed
    --
    ben_rgr_shd.constraint_error('BEN_POPL_RPTG_GRP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_popl_rptg_grp_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_rgr_shd.constraint_error('BEN_POPL_RPTG_GRP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_popl_rptg_grp_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_parent_rec_exists >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a parent rec exists in different business group
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_rptg_grp_id ID of FK column
--   p_business_group_id
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
Procedure chk_parent_rec_exists
                          (p_rptg_grp_id           in number,
                           p_business_group_id     in number,
                           p_effective_date        in date,
                           p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_parent_rec_exists';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  -- This should return if there is a parent in different business group
  -- If there is no parent business group id this should not return any rows
  cursor c1 is
    select null
    from   ben_rptg_grp bnr
    where  bnr.rptg_grp_id = p_rptg_grp_id
     and   nvl(bnr.business_group_id,p_business_group_id) <> p_business_group_id ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
    -- check if rptg_grp_id value exists in ben_rptg_grp table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        fnd_message.set_name('BEN','BEN_92776_PARENT_REC_EXISTS');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_parent_rec_exists;
--

-- ----------------------------------------------------------------------------
-- |------< chk_rptg_grp_id >------|
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
--   p_popl_rptg_grp_id PK
--   p_rptg_grp_id ID of FK column
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
Procedure chk_rptg_grp_id (p_popl_rptg_grp_id          in number,
                            p_rptg_grp_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rptg_grp_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_rptg_grp a
    where  a.rptg_grp_id = p_rptg_grp_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_rgr_shd.api_updating
     (p_popl_rptg_grp_id            => p_popl_rptg_grp_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_rptg_grp_id,hr_api.g_number)
     <> nvl(ben_rgr_shd.g_old_rec.rptg_grp_id,hr_api.g_number)
     or not l_api_updating)
     -- and p_rptg_grp_id is not null  /* Moved the check condition below  bug 2690186 */
     then
    --
    -- check if rptg_grp_id value exists in ben_rptg_grp table
    --
    if p_rptg_grp_id is null then

        fnd_message.set_name('BEN','BEN_93266_RPTG_GRP_NAME_NULL');
        fnd_message.raise_error;

    else

	    open c1;
	      --
	      fetch c1 into l_dummy;
	      if c1%notfound then
		--
		close c1;
		--
		-- raise error as FK does not relate to PK in ben_rptg_grp
		-- table.
		--
		ben_rgr_shd.constraint_error('BEN_POPL_RPTG_GRP_FK1');
		--
	      end if;
	      --
	    close c1;

    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_rptg_grp_id;

-- --------------------------------------------------------------------------
--
-- |------< chk_pl_id >------|
-- --------------------------------------------------------------------------
--
--
-- Description
--   This procedure checks that a referenced foreign key is already used
--   in the popl reporting table for a reporting group.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_popl_rptg_grp_id ID of FK column
--   p_pl_id FK
--   p_rptg_grp_id ID of FK column
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
----------------------------------------------------------------------------
Procedure chk_pl_id(p_popl_rptg_grp_id     in number,
                   p_rptg_grp_id           in number,
                   p_pl_id                       in varchar2,
                   p_effective_date              in date,
                   p_validate_start_date         in date,
                   p_validate_end_date           in date,
                   p_business_group_id           in number,
                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  l_dummy        varchar2(1);
  l_rptg_prps_cd varchar2(30);
  --
  --
  cursor crs_pl_id is
     select null
        from ben_popl_rptg_grp_f
        where pl_id = p_pl_id
          and rptg_grp_id = nvl(p_rptg_grp_id, hr_api.g_number)
          and business_group_id + 0 = p_business_group_id
          and p_validate_start_date <= effective_end_date
          and p_validate_end_date >= effective_start_date;
  --iRec
  cursor crs_rptg_prps is
     select rptg_prps_cd
        from ben_rptg_grp
	where rptg_grp_id = p_rptg_grp_id;
  --
  cursor crs_irec_pln is
     select null
	from ben_pl_f pln, ben_pl_typ_f ptp
	where pln.pl_id = p_pl_id
	and p_validate_start_date <= pln.effective_end_date
	and p_validate_end_date >= pln.effective_start_date
	and pln.pl_typ_id = ptp.pl_typ_id
	and ptp.opt_typ_cd <> 'COMP'
	and ptp.business_group_id = p_business_group_id
	and greatest(p_validate_start_date, pln.effective_start_date) <= ptp.effective_end_date
	and least(p_validate_end_date, pln.effective_end_date) >= ptp.effective_start_date;
  --iRec
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_rgr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_popl_rptg_grp_id            => p_popl_rptg_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pl_id <> ben_rgr_shd.g_old_rec.pl_id) or
      not l_api_updating then
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- check if this name already exist
    --
    open crs_pl_id;
    fetch crs_pl_id into l_exists;
    if crs_pl_id%found then
      --
      close crs_pl_id;
      --
      -- raise error as UK1 is violated
      --
      -- ben_rgr_shd.constraint_error('BEN_REGN_UK1');
      fnd_message.set_name('BEN','BEN_91313_DUP_RPTG_GRP_PL_ID');
      fnd_message.raise_error;
      --
    end if;
    --
    close crs_pl_id;
    --
    --iRec
    --Get the purpose of the reporting group to which the popl_rptg_grp record belongs to
    --
    open crs_rptg_prps;
    fetch crs_rptg_prps into l_rptg_prps_cd;
    if crs_rptg_prps%found and l_rptg_prps_cd = 'IREC'
    then
      --
      open crs_irec_pln;
      fetch crs_irec_pln into l_dummy;
      if crs_irec_pln%found
      then
        --
	close crs_rptg_prps;
        close crs_irec_pln;
        --
        --Raise error : plan being added or modified has Plan Type other than Individual Compensation Distribution
        --at some point of time later than p_validation_start_date
	--
        fnd_message.set_name('BEN','BEN_93920_RPTG_IREC_NONICD_PLN'); --Bug#5204203
        fnd_message.raise_error;
        --
      end if;
      --
      close crs_irec_pln;
      --
    end if;
    close crs_rptg_prps;
    --iRec
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_pl_id;
--
-- --------------------------------------------------------------------------
--
-- |------< chk_pgm_id >------|
-- --------------------------------------------------------------------------
--
--
-- Description
--   This procedure checks that a referenced foreign key is already used
--   in the popl reporting table for a reporting group.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_popl_rptg_grp_id ID of FK column
--   p_pgm_id FK
--   p_rptg_grp_id ID of FK column
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
----------------------------------------------------------------------------
Procedure chk_pgm_id(p_popl_rptg_grp_id               in number,
	           p_rptg_grp_id               in number,
                   p_pgm_id                      in varchar2,
                   p_effective_date              in date,
                   p_validate_start_date         in date,
                   p_validate_end_date           in date,
                   p_business_group_id           in number,
                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor csr_pgm_id is
     select null
        from ben_popl_rptg_grp_f
        where pgm_id = p_pgm_id
          and rptg_grp_id = nvl(p_rptg_grp_id, hr_api.g_number)
          and business_group_id + 0 = p_business_group_id
          and p_validate_start_date <= effective_end_date
          and p_validate_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_rgr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_popl_rptg_grp_id            => p_popl_rptg_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pgm_id <> ben_rgr_shd.g_old_rec.pgm_id) or
      not l_api_updating then
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- check if this name already exist
    --
    open csr_pgm_id;
     fetch csr_pgm_id into l_exists;
    if csr_pgm_id%found then
      close csr_pgm_id;
      --
      -- raise error as UK1 is violated
      --
      -- ben_rgr_shd.constraint_error('BEN_REGN_UK1');
      fnd_message.set_name('BEN','BEN_91314_DUP_RPTG_GRP_PGM_ID');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_pgm_id;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_pgm_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pgm_pl_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that only one of the program or plan id is
--   referenced in a record.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pgm_id ID of FK column
--   p_pl_id ID of FK column
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
Procedure chk_pgm_pl_id (p_pgm_id          in number,
                         p_pl_id        in number ) is
  --
  l_proc         varchar2(72) := g_package||'chk_pgm_pl_id';
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  If p_pgm_id is null and p_pl_id is null then
     --
     -- raise error as both pl_id and pgm_id can't be null
     --
     fnd_message.set_name('BEN','BEN_91111_WO_PGM_OR_PL_ID');
     fnd_message.raise_error;
     --
  elsif p_pgm_id is not null and p_pl_id is not null then
     --
     -- raise error as both pl_id and pgm_id can't be not null
     --
     fnd_message.set_name('BEN','BEN_91110_EITHER_PGM_OR_PL_ID');
     fnd_message.raise_error;
     --
     --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_pgm_pl_id;
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
            (p_pgm_id                        in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
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
    -- fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    -- fnd_message.set_token('TABLE_NAME', l_table_name);
    -- fnd_message.raise_error;
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
            (p_popl_rptg_grp_id		in number,
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
       p_argument       => 'popl_rptg_grp_id',
       p_argument_value => p_popl_rptg_grp_id);
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
    -- fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    -- fnd_message.set_token('TABLE_NAME', l_table_name);
    -- fnd_message.raise_error;
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
	(p_rec 			 in ben_rgr_shd.g_rec_type,
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
  -- CWB Changes
  if p_rec.business_group_id is not null then
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  end if;
  --
  chk_popl_rptg_grp_id
  (p_popl_rptg_grp_id          => p_rec.popl_rptg_grp_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rptg_grp_id
  (p_popl_rptg_grp_id          => p_rec.popl_rptg_grp_id,
   p_rptg_grp_id          => p_rec.rptg_grp_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_pl_id (p_pgm_id  => p_rec.pgm_id,
                 p_pl_id   => p_rec.pl_id );
  --
  chk_pgm_id(p_popl_rptg_grp_id      =>       p_rec.popl_rptg_grp_id,
             p_rptg_grp_id      =>       p_rec.rptg_grp_id,
                   p_pgm_id     =>               p_rec.pgm_id,
                   p_effective_date        =>    p_effective_date,
                   p_validate_start_date   =>    p_validation_start_date,
                   p_validate_end_date     =>    p_validation_end_date,
                   p_business_group_id     =>    p_rec.business_group_id,
                   p_object_version_number =>    p_rec.object_version_number);
  --
  --
  chk_pl_id( p_popl_rptg_grp_id      =>       p_rec.popl_rptg_grp_id,
                   p_rptg_grp_id         =>    p_rec.rptg_grp_id,
                   p_pl_id         =>           p_rec.pl_id,
                   p_effective_date =>           p_effective_date,
                   p_validate_start_date   =>    p_validation_start_date,
                   p_validate_end_date     =>    p_validation_end_date,
                   p_business_group_id     =>    p_rec.business_group_id,
                   p_object_version_number =>    p_rec.object_version_number)
;
  --
  chk_parent_rec_exists
  (p_rptg_grp_id           => p_rec.rptg_grp_id,
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
	(p_rec 			 in ben_rgr_shd.g_rec_type,
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
  -- CWB Changes
  if p_rec.business_group_id is not null then
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  end if;
  --
  chk_popl_rptg_grp_id
  (p_popl_rptg_grp_id          => p_rec.popl_rptg_grp_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rptg_grp_id
  (p_popl_rptg_grp_id          => p_rec.popl_rptg_grp_id,
   p_rptg_grp_id          => p_rec.rptg_grp_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pgm_pl_id (p_pgm_id  => p_rec.pgm_id,
                 p_pl_id   => p_rec.pl_id );
  --
  --
  chk_pgm_id(p_popl_rptg_grp_id            => p_rec.popl_rptg_grp_id,
                   p_rptg_grp_id        =>     p_rec.rptg_grp_id,
                   p_pgm_id                =>    p_rec.pgm_id,
                   p_effective_date        =>    p_effective_date,
                   p_validate_start_date   =>    p_validation_start_date,
                   p_validate_end_date     =>    p_validation_end_date,
                   p_business_group_id     =>    p_rec.business_group_id,
                   p_object_version_number =>    p_rec.object_version_number)
;
  --
  --
  chk_pl_id(p_popl_rptg_grp_id            => p_rec.popl_rptg_grp_id,
                   p_rptg_grp_id            => p_rec.rptg_grp_id,
                   p_pl_id             =>       p_rec.pl_id,
                   p_effective_date    =>        p_effective_date,
                   p_validate_start_date  =>     p_validation_start_date,
                   p_validate_end_date    =>     p_validation_end_date,
                   p_business_group_id    =>     p_rec.business_group_id,
                   p_object_version_number =>    p_rec.object_version_number)
;
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_pgm_id                        => p_rec.pgm_id,
     p_pl_id                         => p_rec.pl_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  chk_parent_rec_exists
  (p_rptg_grp_id           => p_rec.rptg_grp_id,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_rgr_shd.g_rec_type,
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
     p_popl_rptg_grp_id		=> p_rec.popl_rptg_grp_id);
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
  (p_popl_rptg_grp_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_popl_rptg_grp_f b
    where b.popl_rptg_grp_id      = p_popl_rptg_grp_id
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
                             p_argument       => 'popl_rptg_grp_id',
                             p_argument_value => p_popl_rptg_grp_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
/** CWB Changes
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
*/
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_rgr_bus;

/
