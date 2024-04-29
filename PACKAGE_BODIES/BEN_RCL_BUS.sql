--------------------------------------------------------
--  DDL for Package Body BEN_RCL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RCL_BUS" as
/* $Header: berclrhi.pkb 115.13 2004/06/30 23:53:24 hmani ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_rcl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_rltd_per_chg_cs_ler_id >------|
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
--   rltd_per_chg_cs_ler_id PK of record being inserted or updated.
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
Procedure chk_rltd_per_chg_cs_ler_id(p_rltd_per_chg_cs_ler_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rltd_per_chg_cs_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_rcl_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_rltd_per_chg_cs_ler_id                => p_rltd_per_chg_cs_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_rltd_per_chg_cs_ler_id,hr_api.g_number)
     <>  ben_rcl_shd.g_old_rec.rltd_per_chg_cs_ler_id) then
    --
    -- raise error as PK has changed
    --
    ben_rcl_shd.constraint_error('BEN_RLTD_PER_CHG_CS_LER_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_rltd_per_chg_cs_ler_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_rcl_shd.constraint_error('BEN_RLTD_PER_CHG_CS_LER_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_rltd_per_chg_cs_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rltd_per_chg_cs_ler_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rltd_per_chg_cs_ler_id PK of record being inserted or updated.
--   rltd_per_chg_cs_ler_rl Value of formula rule id.
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
Procedure chk_rltd_per_chg_cs_ler_rl(p_rltd_per_chg_cs_ler_id                in number,
                             p_rltd_per_chg_cs_ler_rl              in number,
                             p_business_group_id        in number,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rltd_per_chg_cs_ler_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
            ,per_business_groups pbg
    where  ff.formula_id = p_rltd_per_chg_cs_ler_rl
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
  l_api_updating := ben_rcl_shd.api_updating
    (p_rltd_per_chg_cs_ler_id                => p_rltd_per_chg_cs_ler_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rltd_per_chg_cs_ler_rl,hr_api.g_number)
      <> ben_rcl_shd.g_old_rec.rltd_per_chg_cs_ler_rl
      or not l_api_updating)
      and p_rltd_per_chg_cs_ler_rl is not null then
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
end chk_rltd_per_chg_cs_ler_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_table_column_val >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the source table and source
--   column are entered and that the combo of table, column, new_value, and
--   old_value is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rltd_per_chg_cs_ler_id PK of record being inserted or updated.
--   source_table      table name selected
--   source_column     column name selected
--   new_val           New value being entered.  When this value is detected
--                     in this table.column, a database trigger should fire
--                     that checks for life events to be created for the person
--                     to which the data change is happening.
--   old_val           Old value being entered.  When this value is detected
--                     in this table.column (pre-change), a database trigger
--                     should fire
--                     that checks for life events to be created for the person
--                     to which the data change is happening.
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
Procedure chk_table_column_val(p_rltd_per_chg_cs_ler_id  in number,
                           p_source_table                in varchar2,
                           p_source_column               in varchar2,
                           p_new_val                     in varchar2,
                           p_old_val                     in varchar2,
		           P_business_group_id           in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
CURSOR c1 (p_rltd_per_chg_cs_ler_id     number
                 ,p_source_table        varchar2
                 ,p_source_column       varchar2
                 ,p_new_val           varchar2
                 ,p_old_val           varchar2
                 ,p_business_group_id   number) IS
    SELECT  'x'
    FROM    ben_rltd_per_chg_cs_ler_f
    WHERE   rltd_per_chg_cs_ler_id   <> nvl(p_rltd_per_chg_cs_ler_id,
                                            hr_api.g_number)
    AND     source_table              = p_source_table
    AND     source_column             = p_source_column
    AND     new_val                   = nvl(p_new_val, hr_api.g_varchar2)
    AND     old_val                   = nvl(p_old_val, hr_api.g_varchar2)
    AND     business_group_id + 0     = p_business_group_id
    AND     p_effective_date between effective_start_date
    AND     effective_end_date;
  --
  l_proc         varchar2(72) := g_package||'chk_table_column_val';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
     if p_source_table is null then
        fnd_message.set_name('BEN', 'BEN_91020_TABLE_REQUIRED');
        fnd_message.raise_error;
     elsif p_source_column is null then
        fnd_message.set_name('BEN', 'BEN_91021_COLUMN_REQUIRED');
        fnd_message.raise_error;
     else
          -- check if table, column, new value, old value is unique
          --
          open c1
            (p_rltd_per_chg_cs_ler_id   => p_rltd_per_chg_cs_ler_id
            ,p_source_table             => p_source_table
            ,p_source_column            => p_source_column
            ,p_new_val                  => p_new_val
            ,p_old_val                  => p_old_val
            ,p_business_group_id        => p_business_group_id) ;
        fetch c1 into l_dummy;
        if c1%found then
          close c1;
          fnd_message.set_name('BEN', 'BEN_91017_PERSON_CHANGE_UNIQUE');
          fnd_message.raise_error;
        end if;
        close c1;
     end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_table_column_val;
--
-- ----------------------------------------------------------------------------
-- |------< chk_name_unique >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the name is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   rltd_per_chg_cs_ler_id PK of record being inserted or updated.
--   old_val           Name being entered.
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
Procedure chk_name_unique(p_rltd_per_chg_cs_ler_id  in number,
                           p_name                   in varchar2,
		           P_business_group_id      in number,
                           p_effective_date         in date,
                           p_object_version_number  in number) is
  --
CURSOR c1 (p_rltd_per_chg_cs_ler_id     number
                 ,p_name                varchar2
                 ,p_business_group_id   number) IS
    SELECT  'x'
    FROM    ben_rltd_per_chg_cs_ler_f
    WHERE   rltd_per_chg_cs_ler_id   <> nvl(p_rltd_per_chg_cs_ler_id,
                                            hr_api.g_number)
    AND     name                      = nvl(p_name, hr_api.g_varchar2)
    AND     business_group_id + 0     = p_business_group_id
    AND     p_effective_date between effective_start_date
    AND     effective_end_date;
  --
  l_proc         varchar2(72) := g_package||'chk_name_unique';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
          -- check name is unique
          --
          open c1
            (p_rltd_per_chg_cs_ler_id   => p_rltd_per_chg_cs_ler_id
            ,p_name                     => p_name
            ,p_business_group_id        => p_business_group_id) ;
        fetch c1 into l_dummy;
        if c1%found then
          close c1;
          fnd_message.set_name('BEN', 'BEN_91009_NAME_NOT_UNIQUE');
          fnd_message.raise_error;
        end if;
        close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_name_unique;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_whatif_lbl_unique >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the whatif label is unique.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_rltd_per_chg_cs_ler_id PK of record being inserted or updated.
--   whatif_lbl           What If Label being entered.
--   effective_date
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
Procedure chk_whatif_lbl_unique( p_rltd_per_chg_cs_ler_id  in number,
                           p_whatif_lbl_txt                     in varchar2,
                           p_business_group_id           in number,
                           p_effective_date              in date) is
  --
CURSOR c1 (p_rltd_per_chg_cs_ler_id number
           ,p_whatif_lbl_txt      varchar2
           ,p_effective_date     date
           ,p_business_group_id   number) IS
    SELECT  'x'
    FROM    ben_rltd_per_chg_cs_ler_f
    WHERE   whatif_lbl_txt         = p_whatif_lbl_txt
    and     rltd_per_chg_cs_ler_id   <> nvl(p_rltd_per_chg_cs_ler_id,
                                            hr_api.g_number)
    AND     business_group_id + 0  = p_business_group_id
    AND     p_effective_date between effective_start_date
    AND     effective_end_date;
  --
  l_proc         varchar2(72) := g_package||'chk_whatif_lbl_unique';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
Begin
	--
	hr_utility.set_location('Entering:'||l_proc, 5);
	--
	-- check what if label is unique
	--
	if p_whatif_lbl_txt is not null then
		hr_utility.set_location(' What IF Label is not null'||l_proc, 5);
			open c1(p_rltd_per_chg_cs_ler_id  => p_rltd_per_chg_cs_ler_id
			        ,p_whatif_lbl_txt        => p_whatif_lbl_txt
				,p_effective_date           => p_effective_date
				,p_business_group_id        => p_business_group_id) ;
			fetch c1 into l_dummy;
			  if c1%found then
			    close c1;
			    fnd_message.set_name('BEN', 'BEN_94013_WHATIF_LBL_UNIQUE');
			    fnd_message.raise_error;
			   end if;
			close c1;
		--
	end if;
	hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_whatif_lbl_unique;
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
            (
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
    --
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
            (p_rltd_per_chg_cs_ler_id		in number,
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
       p_argument       => 'rltd_per_chg_cs_ler_id',
       p_argument_value => p_rltd_per_chg_cs_ler_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_rltd_per_cs_ler_f',
           p_base_key_column => 'rltd_per_chg_cs_ler_id',
           p_base_key_value  => p_rltd_per_chg_cs_ler_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_rltd_per_cs_ler_f';
      Raise l_rows_exist;
    End If;
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
	(p_rec 			 in ben_rcl_shd.g_rec_type,
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
  chk_rltd_per_chg_cs_ler_id
  (p_rltd_per_chg_cs_ler_id          => p_rec.rltd_per_chg_cs_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rltd_per_chg_cs_ler_rl
  (p_rltd_per_chg_cs_ler_id          => p_rec.rltd_per_chg_cs_ler_id,
   p_rltd_per_chg_cs_ler_rl        => p_rec.rltd_per_chg_cs_ler_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_table_column_val
  (p_rltd_per_chg_cs_ler_id      => p_rec.rltd_per_chg_cs_ler_id,
   p_source_table                => p_rec.source_table,
   p_source_column               => p_rec.source_column,
   p_new_val                     => p_rec.new_val,
   p_old_val                     => p_rec.old_val,
   p_business_group_id           => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_name_unique
  (p_rltd_per_chg_cs_ler_id      => p_rec.rltd_per_chg_cs_ler_id,
   p_name                        => p_rec.name,
   p_business_group_id           => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_whatif_lbl_unique
     (p_rltd_per_chg_cs_ler_id      => p_rec.rltd_per_chg_cs_ler_id,
      p_whatif_lbl_txt              => p_rec.whatif_lbl_txt,
      p_business_group_id           => p_rec.business_group_id,
      p_effective_date              => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_rcl_shd.g_rec_type,
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
  chk_rltd_per_chg_cs_ler_id
  (p_rltd_per_chg_cs_ler_id          => p_rec.rltd_per_chg_cs_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rltd_per_chg_cs_ler_rl
  (p_rltd_per_chg_cs_ler_id          => p_rec.rltd_per_chg_cs_ler_id,
   p_rltd_per_chg_cs_ler_rl        => p_rec.rltd_per_chg_cs_ler_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_table_column_val
  (p_rltd_per_chg_cs_ler_id      => p_rec.rltd_per_chg_cs_ler_id,
   p_source_table                => p_rec.source_table,
   p_source_column               => p_rec.source_column,
   p_new_val                     => p_rec.new_val,
   p_old_val                     => p_rec.old_val,
   p_business_group_id           => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_name_unique
  (p_rltd_per_chg_cs_ler_id      => p_rec.rltd_per_chg_cs_ler_id,
   p_name                        => p_rec.name,
   p_business_group_id           => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  --
  chk_whatif_lbl_unique
     (p_rltd_per_chg_cs_ler_id      => p_rec.rltd_per_chg_cs_ler_id,
      p_whatif_lbl_txt              => p_rec.whatif_lbl_txt,
      p_business_group_id           => p_rec.business_group_id,
      p_effective_date              => p_effective_date);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
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
	(p_rec 			 in ben_rcl_shd.g_rec_type,
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
     p_rltd_per_chg_cs_ler_id		=> p_rec.rltd_per_chg_cs_ler_id);
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
  (p_rltd_per_chg_cs_ler_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_rltd_per_chg_cs_ler_f b
    where b.rltd_per_chg_cs_ler_id      = p_rltd_per_chg_cs_ler_id
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
                             p_argument       => 'rltd_per_chg_cs_ler_id',
                             p_argument_value => p_rltd_per_chg_cs_ler_id);
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
end ben_rcl_bus;

/
