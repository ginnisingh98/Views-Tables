--------------------------------------------------------
--  DDL for Package Body BEN_LPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LPL_BUS" as
/* $Header: belplrhi.pkb 120.0 2005/05/28 03:31:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lpl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_per_info_cs_ler_id >------|
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
--   ler_per_info_cs_ler_id PK of record being inserted or updated.
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
Procedure chk_ler_per_info_cs_ler_id(p_ler_per_info_cs_ler_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_per_info_cs_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lpl_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_ler_per_info_cs_ler_id                => p_ler_per_info_cs_ler_id,
     p_object_version_number       => p_object_version_number);
  --

  if (l_api_updating
     and nvl(p_ler_per_info_cs_ler_id,hr_api.g_number)
     <>  ben_lpl_shd.g_old_rec.ler_per_info_cs_ler_id) then
    --
    -- raise error as PK has changed
    --
    ben_lpl_shd.constraint_error('BEN_LER_PER_INFO_CS_LER_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ler_per_info_cs_ler_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_lpl_shd.constraint_error('BEN_LER_PER_INFO_CS_LER_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler_per_info_cs_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_per_info_chg_cs_ler_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table, the key is required and is unique for this
--   life event.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ler_per_info_cs_ler_id PK
--   p_per_info_chg_cs_ler_id ID of FK column
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
Procedure chk_per_info_chg_cs_ler_id
                           (p_ler_per_info_cs_ler_id          in number,
                            p_per_info_chg_cs_ler_id          in number,
                            p_ler_id                          in number,
                            p_validation_start_date in date,
                            p_validation_end_date   in date,
                            p_effective_date        in date,
                            p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_per_info_chg_cs_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_per_info_chg_cs_ler_f a
    where  a.per_info_chg_cs_ler_id = p_per_info_chg_cs_ler_id
    and    p_effective_date between effective_start_date
    and    effective_end_date;

  CURSOR c2 (p_ler_per_info_cs_ler_id number
                 ,p_ler_id              number
                 ,p_per_info_chg_cs_ler_id    number
                 ,p_business_group_id   number
                 ,p_validation_start_date date
                 ,p_validation_end_date   date) IS
    SELECT  'x'
    FROM    ben_ler_per_info_cs_ler_f
    WHERE   ler_per_info_cs_ler_id    <> nvl(p_ler_per_info_cs_ler_id, hr_api.g_number)
    AND     per_info_chg_cs_ler_id    = p_per_info_chg_cs_ler_id
    AND     ler_id                    = p_ler_id
    AND     business_group_id + 0     = p_business_group_id
    AND     p_validation_start_date <= effective_end_date
    AND     p_validation_end_date   >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if p_per_info_chg_cs_ler_id is null then
     fnd_message.set_name('BEN', 'BEN_91016_PERSON_CHANGE_REQ');
     fnd_message.raise_error;
  end if;

  l_api_updating := ben_lpl_shd.api_updating
     (p_ler_per_info_cs_ler_id            => p_ler_per_info_cs_ler_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);

  --
  if (l_api_updating
     and nvl(p_per_info_chg_cs_ler_id,hr_api.g_number)
     <> nvl(ben_lpl_shd.g_old_rec.per_info_chg_cs_ler_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if per_info_chg_cs_ler_id value exists in
    -- ben_per_info_chg_cs_ler_f table
    open c1;
      fetch c1 into l_dummy;
      if c1%notfound then
        close c1;
        -- raise error as FK does not relate to PK in ben_per_info_chg_cs_ler
        -- table.
        ben_lpl_shd.constraint_error('BEN_LER_PER_INFO_CS_LER_FK2');
      end if;
    close c1;
    --
    -- check if per_info_chg_cs_ler_id is unique for this ler.
    open c2
            (p_ler_per_info_cs_ler_id     => p_ler_per_info_cs_ler_id
             ,p_ler_id                    => p_ler_id
             ,p_per_info_chg_cs_ler_id    => p_per_info_chg_cs_ler_id
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
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_per_info_chg_cs_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_per_info_cs_ler_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_per_info_cs_ler_id PK of record being inserted or updated.
--   ler_per_info_cs_ler_rl Value of formula rule id.
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
Procedure chk_ler_per_info_cs_ler_rl(p_ler_per_info_cs_ler_id                in number,
                             p_ler_per_info_cs_ler_rl              in number,
                             p_business_group_id        in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_per_info_cs_ler_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
            ,per_business_groups pbg
    where  ff.formula_id = p_ler_per_info_cs_ler_rl
    and    ff.formula_type_id = -46   -- Person Information Causes Life Event
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
  l_api_updating := ben_lpl_shd.api_updating
    (p_ler_per_info_cs_ler_id                => p_ler_per_info_cs_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_ler_per_info_cs_ler_rl,hr_api.g_number)
      <> ben_lpl_shd.g_old_rec.ler_per_info_cs_ler_rl
      or not l_api_updating)
      and p_ler_per_info_cs_ler_rl is not null then
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
end chk_ler_per_info_cs_ler_rl;
-- ----------------------------------------------------------------------------
-- |------< chk_ler_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the ler for which this child record is being
--   created is not of certain delivered types.
--
--   This procedure is called from other APIs, so do not add additional logic
--   here unless it's needed by other modules too.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ler_id
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
--   Internal table handler use only - but called from other table handlers.
--
Procedure chk_ler_id
                           (p_ler_id                in number,
                            p_effective_date        in date,
                            p_validation_start_date in date,
                            p_validation_end_date   in date,
                            p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select 'x'
    from   ben_ler_f a
    where  a.ler_id = p_ler_id
    AND    a.business_group_id + 0  = p_business_group_id
    AND    p_validation_start_date <= a.effective_end_date
    AND    p_validation_end_date   >= a.effective_start_date
    and    a.typ_cd in ('DRVDAGE', 'DRVDLOS', 'DRVDCAL',
           'DRVDHRW', 'DRVDCMP', 'DRVDTPF', 'SCHEDDO','SCHEDDA','SCHEDDU');
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

    --
    -- check if the parent ler is of certain types

    open c1;
      fetch c1 into l_dummy;
      if c1%found then
        close c1;
        fnd_message.set_name('BEN','BEN_91425_DELIVERED_TYPE_CHILD');
        fnd_message.raise_error;
      end if;
    close c1;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks the ler for which this child record is being
--   created is of type ABS for OSB customers.
--
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_ler_id
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
--   Internal table handler use only - but called from other table handlers.
--
Procedure chk_ler_typ_cd
                           (p_ler_id                in number,
                            p_effective_date        in date,
                            p_validation_start_date in date,
                            p_validation_end_date   in date,
                            p_business_group_id     in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_typ_cd';
  l_api_updating boolean;
  l_status       varchar2(1);
  l_dummy        ben_ler_f.typ_cd%type ; -- varchar2(1); bug 3067285
  l_exist        varchar2(1);
  --
  cursor c1 is
    select status
      from fnd_product_installations
     where application_id = 805;
  --
  cursor c2 is
    select typ_cd
    from   ben_ler_f a
    where  a.ler_id = p_ler_id
    AND    a.typ_cd = 'ABS'
    AND    a.business_group_id   = p_business_group_id
    AND    p_validation_start_date <= a.effective_end_date
    AND    p_validation_end_date   >= a.effective_start_date;
  --
  --iRec
    cursor c3 is
    select null
    from   ben_ler_f ler
    where  ler.ler_id = p_ler_id
    and    p_validation_start_date <= ler.effective_end_date
    and    p_validation_end_date   >= ler.effective_start_date
    and    typ_cd = 'IREC';
  --iRec
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --iRec
  open c3;
  fetch c3 into l_dummy;
  if c3%found then
    --
    close c3;
    --
    --Raise error : Life events with type = iRecruitment cannot have person changes
    --associated.
    --
    fnd_message.set_name('BEN','BEN_93927_NOASSC_LPL_IREC_LER');
    fnd_message.raise_error;
    --
  end if;
  --
  close c3;
  --
  --iRec

    -- check if oab/osb customer
    open c1;
    fetch c1 into l_status;
    close c1;

    -- For osb customers, allow child record only if ler typ is ABS
    if (nvl(l_status,'N') <> 'I')
    then
       -- check if the ler is of type ABS
       open c2;
       fetch c2 into l_dummy;
       if (c2%notfound)
       then
          close c2;
          fnd_message.set_name('BEN','BEN_91425_CHILD_NOT_ALLOWED');
          fnd_message.raise_error;
       end if;
       close c2;
    end if;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ler_typ_cd;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_not_multiple_tables >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the attached per_info_chg_cs_ler_id
--   does not conflict with any other table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler_per_info_cs_ler_id PK of record being inserted or updated.
--   per_info_chg_cs_ler_id Value of linked record.
--   ler_id                 Value of life event being linked.
--   effective_date         effective date
--   object_version_number  Object version number of record being
--                          inserted or updated.
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
Procedure chk_not_multiple_tables
  (p_ler_per_info_cs_ler_id   in number,
   p_per_info_chg_cs_ler_id   in number,
   p_ler_id                   in number,
   p_effective_date           in date,
   p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_not_multiple_tables';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c_source_table is
    select psl.source_table
    from   ben_per_info_chg_cs_ler_f psl
    where  psl.per_info_chg_cs_ler_id = p_per_info_chg_cs_ler_id
    and    p_effective_date
           between psl.effective_start_date
           and     psl.effective_end_date;
  --
  l_source_table varchar2(30);
  --
  cursor c_check_multiple(p_source_table varchar2) is
    select null
    from   ben_ler_per_info_cs_ler_f lpl,
           ben_per_info_chg_cs_ler_f psl
    where  lpl.ler_per_info_cs_ler_id <> nvl(p_ler_per_info_cs_ler_id,-1)
    and    lpl.ler_id = p_ler_id
    and    p_effective_date
           between lpl.effective_start_date
           and     lpl.effective_end_date
    and    lpl.per_info_chg_cs_ler_id = psl.per_info_chg_cs_ler_id
    and    p_effective_date
           between psl.effective_start_date
           and     psl.effective_end_date
    and    psl.source_table <> p_source_table;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_lpl_shd.api_updating
    (p_ler_per_info_cs_ler_id      => p_ler_per_info_cs_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_per_info_chg_cs_ler_id,hr_api.g_number)
      <> ben_lpl_shd.g_old_rec.per_info_chg_cs_ler_id
      or not l_api_updating)
      and p_per_info_chg_cs_ler_id is not null then
    --
    open c_source_table;
      --
      fetch c_source_table into l_source_table;
      --
    close c_source_table;
    --
    -- check if the triggering logic uses multiple tables.
    --
    open c_check_multiple(l_source_table);
      --
      fetch c_check_multiple into l_dummy;
      if c_check_multiple%found then
        --
        close c_check_multiple;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_92559_MULTIPLE_TABLES');
        fnd_message.raise_error;
        --
      end if;
      --
    close c_check_multiple;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_not_multiple_tables;
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
            (p_ler_per_info_cs_ler_id		in number,
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
       p_argument       => 'ler_per_info_cs_ler_id',
       p_argument_value => p_ler_per_info_cs_ler_id);
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
	(p_rec 			 in ben_lpl_shd.g_rec_type,
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
  chk_ler_per_info_cs_ler_id
  (p_ler_per_info_cs_ler_id          => p_rec.ler_per_info_cs_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_per_info_chg_cs_ler_id
  (p_ler_per_info_cs_ler_id          => p_rec.ler_per_info_cs_ler_id,
   p_per_info_chg_cs_ler_id          => p_rec.per_info_chg_cs_ler_id,
   p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_typ_cd
  (p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_per_info_cs_ler_rl
  (p_ler_per_info_cs_ler_id          => p_rec.ler_per_info_cs_ler_id,
   p_ler_per_info_cs_ler_rl        => p_rec.ler_per_info_cs_ler_rl,
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
	(p_rec 			 in ben_lpl_shd.g_rec_type,
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
  chk_ler_per_info_cs_ler_id
  (p_ler_per_info_cs_ler_id          => p_rec.ler_per_info_cs_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_per_info_chg_cs_ler_id
  (p_ler_per_info_cs_ler_id          => p_rec.ler_per_info_cs_ler_id,
   p_per_info_chg_cs_ler_id          => p_rec.per_info_chg_cs_ler_id,
   p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_id
  (p_ler_id                => p_rec.ler_id,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);

  --
  chk_ler_per_info_cs_ler_rl
  (p_ler_per_info_cs_ler_id          => p_rec.ler_per_info_cs_ler_id,
   p_ler_per_info_cs_ler_rl        => p_rec.ler_per_info_cs_ler_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_formula_id           => p_rec.ler_per_info_cs_ler_rl,
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
	(p_rec 			 in ben_lpl_shd.g_rec_type,
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
     p_ler_per_info_cs_ler_id		=> p_rec.ler_per_info_cs_ler_id);
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
  (p_ler_per_info_cs_ler_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ler_per_info_cs_ler_f b
    where b.ler_per_info_cs_ler_id      = p_ler_per_info_cs_ler_id
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
                             p_argument       => 'ler_per_info_cs_ler_id',
                             p_argument_value => p_ler_per_info_cs_ler_id);
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
end ben_lpl_bus;

/
