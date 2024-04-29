--------------------------------------------------------
--  DDL for Package Body BEN_PFF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PFF_BUS" as
/* $Header: bepffrhi.pkb 120.0 2005/05/28 10:42:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pff_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_pct_fl_tm_fctr_id >------|
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
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
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
Procedure chk_pct_fl_tm_fctr_id(p_pct_fl_tm_fctr_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pct_fl_tm_fctr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pct_fl_tm_fctr_id,hr_api.g_number)
     <>  ben_pff_shd.g_old_rec.pct_fl_tm_fctr_id) then
    --
    -- raise error as PK has changed
    --
    ben_pff_shd.constraint_error('BEN_PCT_FL_TM_FCTR_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pct_fl_tm_fctr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pff_shd.constraint_error('BEN_PCT_FL_TM_FCTR_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pct_fl_tm_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   rndg_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_rndg_rl(p_pct_fl_tm_fctr_id                in number,
                             p_business_group_id        in number,
                             p_rndg_rl              in number,
                             p_rndg_cd                in varchar2,
                             p_effective_date              in date,
                             p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
           ,per_business_groups pbg
    where  ff.formula_id = p_rndg_rl
    and    ff.formula_type_id = -169
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
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_rndg_rl,hr_api.g_number)
      <> ben_pff_shd.g_old_rec.rndg_rl
      or not l_api_updating)
      and p_rndg_rl is not null then
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
        fnd_message.set_name('BEN','BEN_91042_INVALID_RNDG_RL');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  -- Unless Rounding Code = Rule, Rounding rule must be blank.
  if  nvl(p_rndg_cd,hr_api.g_varchar2)  <> 'RL' and p_rndg_rl is not null then
        --
        fnd_message.set_name('BEN', 'BEN_91043_RNDG_RL_NOT_NULL');
        fnd_message.raise_error;
        --
  elsif  nvl(p_rndg_cd,hr_api.g_varchar2) = 'RL' and p_rndg_rl is null then
        --
        fnd_message.set_name('BEN', 'BEN_92340_RNDG_RL_NULL');
        fnd_message.raise_error;
        --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_rl;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rndg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   rndg_cd Value of lookup code.
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
Procedure chk_rndg_cd(p_pct_fl_tm_fctr_id                in number,
                            p_rndg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rndg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rndg_cd
      <> nvl(ben_pff_shd.g_old_rec.rndg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rndg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RNDG',
           p_lookup_code    => p_rndg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91040_INVALID_RNDG_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rndg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_sum_of_all_asnts_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   use_sum_of_all_asnts_flag Value of lookup code.
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
Procedure chk_use_sum_of_all_asnts_flag(p_pct_fl_tm_fctr_id                in number,
                            p_use_sum_of_all_asnts_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_sum_of_all_asnts_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_sum_of_all_asnts_flag
      <> nvl(ben_pff_shd.g_old_rec.use_sum_of_all_asnts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_sum_of_all_asnts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_sum_of_all_asnts_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91059_INVALID_SUM_ALL_ASNT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_sum_of_all_asnts_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_prmry_asnt_only_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   use_prmry_asnt_only_flag Value of lookup code.
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
Procedure chk_use_prmry_asnt_only_flag(p_pct_fl_tm_fctr_id                in number,
                            p_use_prmry_asnt_only_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_prmry_asnt_only_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_prmry_asnt_only_flag
      <> nvl(ben_pff_shd.g_old_rec.use_prmry_asnt_only_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_prmry_asnt_only_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_prmry_asnt_only_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91058_INVALID_PRMRY_ASNT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_prmry_asnt_only_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_pct_val_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   no_mx_pct_val_flag Value of lookup code.
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
Procedure chk_no_mx_pct_val_flag(p_pct_fl_tm_fctr_id                in number,
                            p_no_mx_pct_val_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_pct_val_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_pct_val_flag
      <> nvl(ben_pff_shd.g_old_rec.no_mx_pct_val_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_pct_val_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_pct_val_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91052_INVALID_MAX_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_pct_val_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_pct_val_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   no_mn_pct_val_flag Value of lookup code.
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
Procedure chk_no_mn_pct_val_flag(p_pct_fl_tm_fctr_id                in number,
                            p_no_mn_pct_val_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_pct_val_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_pct_val_flag
      <> nvl(ben_pff_shd.g_old_rec.no_mn_pct_val_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_pct_val_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_pct_val_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91051_INVALID_MIN_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_pct_val_flag;

------------------------------------------------------------------------
----
-- |------< chk_mn_mx_pct_val >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that minimum percent value is always less than
--    max percent value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   mn_pct_val Value of Minimum percentage.
--   mx_pct_val Value of Maximum percentage.
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
Procedure chk_mn_mx_pct_val(p_pct_fl_tm_fctr_id                in number,
                         p_no_mn_pct_val_flag  in varchar2,
                         p_mn_pct_val                  in number,
                         p_no_mx_pct_val_flag  in varchar2,
                         p_mx_pct_val                   in number,
                         p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_pct_val';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  if p_mn_pct_val is not null and p_mx_pct_val is not null then
      --
      -- raise error if max value not greater than min value
      --
     -- Bug Fix 1873685
     if  (p_mx_pct_val < p_mn_pct_val)  then
     -- if  (p_mx_pct_val <= p_mn_pct_val)  then
     -- End fix 1873685
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
    end if;
      --
      --
  end if;
    --
      -- If No Minimum Percent value flag set to "on" (Y),
      --    then minimum percent value must be blank.
      --
    if  nvl( p_no_mn_pct_val_flag, hr_api.g_varchar2)  = 'Y'
         and p_mn_pct_val is not null
    then
      fnd_message.set_name('BEN','BEN_91054_MIN_VAL_NOT_NULL');
      fnd_message.raise_error;
    elsif   nvl( p_no_mn_pct_val_flag, hr_api.g_varchar2)  = 'N'
         and p_mn_pct_val is null
    then
      fnd_message.set_name('BEN','BEN_91055_MIN_VAL_REQUIRED');
      fnd_message.raise_error;
    end if;
      --
      -- If No Maximum Percent value flag set to "on" (Y),
      --    then maximum percent value must be blank.
      --
    if  nvl( p_no_mx_pct_val_flag, hr_api.g_varchar2)  = 'Y'
         and p_mx_pct_val is not null
    then
      fnd_message.set_name('BEN','BEN_91056_MAX_VAL_NOT_NULL');
      fnd_message.raise_error;
    elsif   nvl( p_no_mx_pct_val_flag, hr_api.g_varchar2)  = 'N'
         and p_mx_pct_val is null
    then
      fnd_message.set_name('BEN','BEN_91057_MAX_VAL_REQUIRED');
      fnd_message.raise_error;
    end if;
   --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_pct_val;

------------------------------------------------------------------------
----
-- |------< chk_name >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Name is unique in a business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id PK of record being inserted or updated.
--   name Value of Name.
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
Procedure chk_name(p_pct_fl_tm_fctr_id                in number,
                         p_business_group_id                in number,
                         p_name                    in varchar2,
                         p_effective_date              in date,
                         p_object_version_number       in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pct_fl_tm_fctr  pff
    where  pff.business_group_id = p_business_group_id and
                 pff.name = p_name;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pff_shd.api_updating
    (p_pct_fl_tm_fctr_id                => p_pct_fl_tm_fctr_id,
     -- p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_name,hr_api.g_varchar2)
      <> ben_pff_shd.g_old_rec.name
      or not l_api_updating)
      and p_name is not null then
    --
    -- check if name already used.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the

      -- name is invalid otherwise its valid
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_name;
  --

--Bug 2978945 begin

-- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that Percent Full Time child records do
--   not exist when the user deletes the record in the
--   BEN_PCT_FL_TM_FCTR table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pct_fl_tm_fctr_id        PK of record being inserted or updated.
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
procedure chk_child_records(p_pct_fl_tm_fctr_id  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';

begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

 --Used in variable rate profiles
   If (ben_batch_utils.rows_exist
             (p_base_table_name => 'BEN_PCT_FL_TM_RT_F',
              p_base_key_column => 'pct_fl_tm_fctr_id',
              p_base_key_value  => p_pct_fl_tm_fctr_id
             )) Then
		ben_utility.child_exists_error('BEN_PCT_FL_TM_RT_F');
   End If;

  --Used in eligibility profiles
   If (ben_batch_utils.rows_exist
             (p_base_table_name => 'BEN_ELIG_PCT_FL_TM_PRTE_F',
              p_base_key_column => 'pct_fl_tm_fctr_id',
              p_base_key_value  => p_pct_fl_tm_fctr_id
             )) Then
		ben_utility.child_exists_error('BEN_ELIG_PCT_FL_TM_PRTE_F');
  End If;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --

end chk_child_records;

--Bug 2978945
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_pff_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_pct_fl_tm_fctr_id
  (p_pct_fl_tm_fctr_id     => p_rec.pct_fl_tm_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_pct_fl_tm_fctr_id     => p_rec.pct_fl_tm_fctr_id,
   p_rndg_cd               => p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_rndg_rl
  (p_pct_fl_tm_fctr_id     => p_rec.pct_fl_tm_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_rndg_rl               => p_rec.rndg_rl,
   p_rndg_cd               =>  p_rec.rndg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_sum_of_all_asnts_flag
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_use_sum_of_all_asnts_flag  => p_rec.use_sum_of_all_asnts_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_use_prmry_asnt_only_flag
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_use_prmry_asnt_only_flag   => p_rec.use_prmry_asnt_only_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mx_pct_val_flag
  (p_pct_fl_tm_fctr_id     => p_rec.pct_fl_tm_fctr_id,
   p_no_mx_pct_val_flag    => p_rec.no_mx_pct_val_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_pct_val_flag
  (p_pct_fl_tm_fctr_id     => p_rec.pct_fl_tm_fctr_id,
   p_no_mn_pct_val_flag    => p_rec.no_mn_pct_val_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mn_mx_pct_val
  (p_pct_fl_tm_fctr_id     => p_rec.pct_fl_tm_fctr_id,
   p_no_mn_pct_val_flag    => p_rec.no_mn_pct_val_flag,
   p_mn_pct_val            => p_rec.mn_pct_val,
   p_no_mx_pct_val_flag    => p_rec.no_mx_pct_val_flag,
   p_mx_pct_val            => p_rec.mx_pct_val,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_pct_fl_tm_fctr_id     => p_rec.pct_fl_tm_fctr_id,
   p_business_group_id     => p_rec.business_group_id,
   p_name                  => p_rec.name,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_pff_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_pct_fl_tm_fctr_id
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_rndg_cd
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_rndg_cd                    => p_rec.rndg_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
 --
  chk_rndg_rl
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_business_group_id          => p_rec.business_group_id,
   p_rndg_rl                   => p_rec.rndg_rl,
   p_rndg_cd                    =>  p_rec.rndg_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_use_sum_of_all_asnts_flag
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_use_sum_of_all_asnts_flag  => p_rec.use_sum_of_all_asnts_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_use_prmry_asnt_only_flag
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_use_prmry_asnt_only_flag   => p_rec.use_prmry_asnt_only_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mx_pct_val_flag
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_no_mx_pct_val_flag         => p_rec.no_mx_pct_val_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_no_mn_pct_val_flag
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_no_mn_pct_val_flag         => p_rec.no_mn_pct_val_flag,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_mn_mx_pct_val
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_no_mn_pct_val_flag         => p_rec.no_mn_pct_val_flag,
   p_mn_pct_val                 => p_rec.mn_pct_val,
   p_no_mx_pct_val_flag         => p_rec.no_mx_pct_val_flag,
   p_mx_pct_val                 => p_rec.mx_pct_val,
   p_object_version_number      => p_rec.object_version_number);
 --
  chk_name
  (p_pct_fl_tm_fctr_id          => p_rec.pct_fl_tm_fctr_id,
   p_business_group_id          => p_rec.business_group_id,
   p_name                       => p_rec.name,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_pff_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_child_records(p_pct_fl_tm_fctr_id => p_rec.pct_fl_tm_fctr_id); --Bug 2978945
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_pct_fl_tm_fctr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pct_fl_tm_fctr b
    where b.pct_fl_tm_fctr_id      = p_pct_fl_tm_fctr_id
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
                             p_argument       => 'pct_fl_tm_fctr_id',
                             p_argument_value => p_pct_fl_tm_fctr_id);
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
end ben_pff_bus;

/
