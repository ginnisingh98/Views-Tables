--------------------------------------------------------
--  DDL for Package Body BEN_EGL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGL_BUS" as

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_egl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_eligy_criteria_id >------|
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
--   eligy_criteria_id PK of record being inserted or updated.
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
Procedure chk_eligy_criteria_id(p_eligy_criteria_id           in number,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_eligy_criteria_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_egl_shd.api_updating
    (p_eligy_criteria_id                => p_eligy_criteria_id,
     p_object_version_number            => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_eligy_criteria_id,hr_api.g_number)
     <>  ben_egl_shd.g_old_rec.eligy_criteria_id) then
    --
    -- raise error as PK has changed
    --
    ben_egl_shd.constraint_error('BEN_eligy_criteria_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_eligy_criteria_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_egl_shd.constraint_error('BEN_eligy_criteria_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_eligy_criteria_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the  Name is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name eligibility criteria name
--     p_eligy_criteria_id is eligy_criteria_id
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
---- ----------------------------------------------------------------------------
Procedure chk_name_unique
          ( p_eligy_criteria_id    in   number
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number)
is
l_proc      varchar2(72) := g_package||'chk_name_unique';
l_dummy     char(1);

cursor c1 is select null
             from   ben_eligy_criteria
             Where  eligy_criteria_id <> nvl(p_eligy_criteria_id,-1)
             and    name = p_name
             and    business_group_id = p_business_group_id;

--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
--
End chk_name_unique;

/* Bug 5338058 - Commenting this check as short_code need not to be unique
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_short_code_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the short code is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is
--     p_eligy_criteria_id is eligy_criteria_id
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
---- ----------------------------------------------------------------------------
Procedure chk_short_code_unique
          ( p_eligy_criteria_id    in   number
           ,p_short_code           in   varchar2
           ,p_business_group_id    in   number)
is
l_proc      varchar2(72) := g_package||'chk_short_code_unique';
l_dummy     char(1);

cursor c1 is select null
             from   ben_eligy_criteria
             Where  eligy_criteria_id <> nvl(p_eligy_criteria_id,-1)
             and    short_code = p_short_code
             and    business_group_id = p_business_group_id;

--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_94151_NOT_UNIQUE');
      fnd_message.set_token('FIELD','Short Code');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);

End chk_short_code_unique;
--
 */

--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_all_lookups >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup codes are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_eligy_criteria_id          PK of record being inserted or updated.
--   p_criteria_type              value of lookup code
--   p_crit_col1_val_type_cd      value of lookup code
--   p_crit_col1_datatype         value of lookup code
--
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_all_lookups(p_eligy_criteria_id            in number,
                          p_criteria_type                in varchar2,
                          p_crit_col1_val_type_cd        in varchar2,
                          p_crit_col1_datatype           in varchar2,
			  p_crit_col2_val_type_cd        in varchar2,
                          p_crit_col2_datatype           in varchar2,
			  p_allow_range_validation_flg	 in varchar2,
			  p_allow_range_validation_flag2 in varchar2,
			  p_user_defined_flag		 in varchar2,
                          p_effective_date               in date,
                          p_object_version_number        in number) is
  --
  --
  --

  l_proc         varchar2(72) := g_package||'chk_all_lookups';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_egl_shd.api_updating
    (p_eligy_criteria_id           => p_eligy_criteria_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_criteria_type
      <> nvl(ben_egl_shd.g_old_rec.criteria_type,hr_api.g_varchar2)
      or not l_api_updating)
      and p_criteria_type is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CRITERIA_TYPE',
           p_lookup_code    => p_criteria_type,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
            fnd_message.set_token('FIELD', 'TYPE');
            fnd_message.set_token('TYPE','BEN_CRITERIA_TYPE');
            fnd_message.set_token('VALUE',p_criteria_type);
            fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
        and p_crit_col1_val_type_cd
        <> nvl(ben_egl_shd.g_old_rec.crit_col1_val_type_cd,hr_api.g_varchar2)
        or not l_api_updating)
        and p_crit_col1_val_type_cd is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'CRIT_COL1_VAL_TYPE_CD',
             p_lookup_code    => p_crit_col1_val_type_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'Crit Col1 Val Type Cd');
        fnd_message.set_token('TYPE', 'CRIT_COL1_VAL_TYPE_CD');
	fnd_message.set_token('VALUE',p_crit_col1_val_type_cd);
        fnd_message.raise_error;
        --
      end if;
      --
  end if;
  --
    if (l_api_updating
        and p_crit_col1_datatype
        <> nvl(ben_egl_shd.g_old_rec.crit_col1_datatype,hr_api.g_varchar2)
        or not l_api_updating)
        and p_crit_col1_datatype is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'CRIT_COL1_DATATYPE',
             p_lookup_code    => p_crit_col1_datatype,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'Datatype');
        fnd_message.set_token('TYPE', 'CRIT_COL1_DATATYPE');
	fnd_message.set_token('VALUE', p_crit_col1_datatype);
        fnd_message.raise_error;
        --
      end if;
      --
    end if;
  --
  if (l_api_updating
        and p_crit_col2_val_type_cd
        <> nvl(ben_egl_shd.g_old_rec.crit_col2_val_type_cd,hr_api.g_varchar2)
        or not l_api_updating)
        and p_crit_col2_val_type_cd is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'CRIT_COL1_VAL_TYPE_CD',
             p_lookup_code    => p_crit_col2_val_type_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', p_crit_col2_val_type_cd);
        fnd_message.set_token('TYPE', 'CRIT_COL1_VAL_TYPE_CD');
	fnd_message.set_token('VALUE', p_crit_col2_val_type_cd);
        fnd_message.raise_error;
        --
      end if;
      --
  end if;
  --
   if (l_api_updating
        and p_allow_range_validation_flg
        <> nvl(ben_egl_shd.g_old_rec.allow_range_validation_flg,hr_api.g_varchar2)
        or not l_api_updating)
        and p_allow_range_validation_flg is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_allow_range_validation_flg,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'Allow Range Validation');
        fnd_message.set_token('TYPE', 'YES_NO');
	fnd_message.set_token('VALUE', p_allow_range_validation_flg);
        fnd_message.raise_error;
        --
      end if;
      --
    end if;
  --
  --  Added by rbingi for allow_range_validation_flag2 exixts check in Lookup
   if (l_api_updating
        and p_allow_range_validation_flag2
        <> nvl(ben_egl_shd.g_old_rec.allow_range_validation_flag2,hr_api.g_varchar2)
        or not l_api_updating)
        and p_allow_range_validation_flag2 is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_allow_range_validation_flag2,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'Allow Range Validation');
        fnd_message.set_token('TYPE', 'YES_NO');
	fnd_message.set_token('VALUE', p_allow_range_validation_flag2);
        fnd_message.raise_error;
        --
      end if;
      --
    end if;
  --

  if (l_api_updating
        and p_user_defined_flag
        <> nvl(ben_egl_shd.g_old_rec.user_defined_flag,hr_api.g_varchar2)
        or not l_api_updating)
        and p_user_defined_flag is not null then
      --
      -- check if value of lookup falls within lookup type.
      --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_user_defined_flag,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'User Defined Flag');
        fnd_message.set_token('TYPE', 'YES_NO');
	fnd_message.set_token('VALUE', p_user_defined_flag);
        fnd_message.raise_error;
        --
      end if;
      --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
    --
end chk_all_lookups;

--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_col_lookup_type >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- To check if look-up type is valid one
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_eligy_criteria_id      in number,
--     p_col1_lookup_type       in varchar2,
--     p_effective_date         in date,
--     p_object_version_number  in number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.

Procedure  chk_col_lookup_type( p_eligy_criteria_id      in number,
                                p_col1_lookup_type       in varchar2,
				p_col2_lookup_type       in varchar2,
                                p_effective_date         in date,
                                p_object_version_number  in number,
                                p_business_group_id      in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_col_lookup_type';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  --
  /*
    cursor c1(p_col_lookup_type varchar2) is
      select  null
        from  hr_lookups
	where lookup_type  = p_col_lookup_type
         and  p_effective_date between
              nvl(start_date_active, p_effective_date)
         and  nvl(end_date_active, p_effective_date);
   */
   CURSOR c1 (
      cv_lookup_type                  varchar2,
      cv_business_group_id            number
   )
   IS
      SELECT NULL
        FROM fnd_lookup_types_vl flv
       WHERE lookup_type = cv_lookup_type
         AND (   customization_level IN ('E', 'S')
              OR (    customization_level = 'U'
                  AND (   security_group_id = 0
                       OR security_group_id IN (
                             SELECT security_group_id
                               FROM fnd_security_groups
                              WHERE security_group_key =
                                               TO_CHAR (cv_business_group_id))
                      )
                 )
             );
  --
  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    --
      l_api_updating := ben_egl_shd.api_updating
        (p_eligy_criteria_id           => p_eligy_criteria_id,
         p_object_version_number       => p_object_version_number);
      --
      if (l_api_updating
          and p_col1_lookup_type
          <> nvl(ben_egl_shd.g_old_rec.col1_lookup_type,hr_api.g_varchar2)
          or not l_api_updating)
          and p_col1_lookup_type is not null then
    	 --
    	 open c1(p_col1_lookup_type, p_business_group_id);
    	 fetch c1 into l_dummy;
    	 if c1%notfound then
    	     close c1;
    	     fnd_message.set_name('PER','HR_6091_DEF_MISSING_LOOKUPS');
	     fnd_message.set_token('LOOKUP_TYPE', p_col1_lookup_type);
    	     fnd_message.raise_error;
    	 end if;
	 close c1;
    	 --
      end if;
      --

      if (l_api_updating
          and p_col2_lookup_type
          <> nvl(ben_egl_shd.g_old_rec.col2_lookup_type,hr_api.g_varchar2)
          or not l_api_updating)
          and p_col2_lookup_type is not null then
    	 --
    	 open c1(p_col2_lookup_type, p_business_group_id);
    	 fetch c1 into l_dummy;
    	 if c1%notfound then
    	     close c1;
    	     fnd_message.set_name('PER','HR_6091_DEF_MISSING_LOOKUPS');
	     fnd_message.set_token('LOOKUP_TYPE', p_col2_lookup_type);
    	     fnd_message.raise_error;
    	 end if;
	 close c1;
    	 --
      end if;
      --
    hr_utility.set_location('Leaving:'||l_proc, 15);

end chk_col_lookup_type;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_access_calc_rule >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that Access calc rule is valid
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_eligy_criteria_id      in number,
--     p_access_calc_rule       in varchar2,
--     p_business_group_id      in number,
--     p_effective_date         in date,
--     p_object_version_number  in number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.

Procedure chk_access_calc_rule (p_eligy_criteria_id      in number,
                                p_access_calc_rule       in number,
                                p_business_group_id      in number,
                                p_effective_date         in date,
                                p_object_version_number  in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_access_calc_rule';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  CURSOR c_formula
  IS
     SELECT NULL
       FROM ff_formulas_f
      WHERE formula_id = p_access_calc_rule
        AND formula_type_id = -552
        AND nvl(business_group_id, p_business_group_id) = p_business_group_id;
  --
  Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    --
      l_api_updating := ben_egl_shd.api_updating
        (p_eligy_criteria_id           => p_eligy_criteria_id,
         p_object_version_number       => p_object_version_number);
      --
      if (l_api_updating
          and p_access_calc_rule
          <> nvl(ben_egl_shd.g_old_rec.access_calc_rule,hr_api.g_number)
          or not l_api_updating)
          and p_access_calc_rule is not null
      then
    	 --
         -- Bug 4303085 : Do not validate the formula id against effective date since
         --               BEN_ELIGY_CRITERIA is not a datetracked table
         --
         open c_formula;
           --
           fetch c_formula into l_dummy;
           --
           if c_formula%notfound
           then
             --
             close c_formula;
             --
             /*
      	     if not benutils.formula_exists
      	        (p_formula_id        => p_access_calc_rule,
      	         p_formula_type_id   => -552,
      	         p_business_group_id => p_business_group_id,
      	         p_effective_date    => p_effective_date) then
             */
      	     --
      	     -- raise error
      	     --
      	     fnd_message.set_name('BEN','BEN_91741_FORMULA_NOT_FOUND');
      	     fnd_message.set_token('ID',p_access_calc_rule);
      	     fnd_message.set_token('TYPE_ID',-552);
      	     fnd_message.raise_error;
      	     --
           end if;
           --
         close c_formula;
    	 --
      end if;
      --
    hr_utility.set_location('Leaving:'||l_proc, 15);

end chk_access_calc_rule;

--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_col_value_set_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description

-- Pre Conditions
--   None.
--
-- In Parameters
--     p_eligy_criteria_id      in number,
--     p_col1_value_set_id       in varchar2,
--     p_object_version_number  in number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.

Procedure chk_col_value_set_id (p_eligy_criteria_id      in number,
                                p_col1_value_set_id      in number,
				p_col2_value_set_id      in number,
                                p_object_version_number  in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_col_value_set_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  --
    cursor c1(p_col_value_set_id number) is
      select null
        from fnd_flex_value_sets
        where flex_value_set_id  = p_col_value_set_id;

  --
  --
  Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    --
      l_api_updating := ben_egl_shd.api_updating
        (p_eligy_criteria_id           => p_eligy_criteria_id,
         p_object_version_number       => p_object_version_number);
      --
      if (l_api_updating
          and p_col1_value_set_id
          <> nvl(ben_egl_shd.g_old_rec.col1_value_set_id,hr_api.g_number)
          or not l_api_updating)
          and p_col1_value_set_id is not null then
    	 --
    	 open c1(p_col1_value_set_id);
    	 fetch c1 into l_dummy;
    	 if c1%notfound then
    	     close c1;
    	     fnd_message.set_name('BEN','BEN_94132_INVALID_VALUE_SET_ID');
	     fnd_message.set_token('VALUESET',p_col1_value_set_id);
    	     fnd_message.raise_error;
    	 end if;
	 close c1;
    	 --
      end if;


      if (l_api_updating
          and p_col2_value_set_id
          <> nvl(ben_egl_shd.g_old_rec.col2_value_set_id,hr_api.g_number)
          or not l_api_updating)
          and p_col2_value_set_id is not null then
    	 --
    	 open c1(p_col2_value_set_id);
    	 fetch c1 into l_dummy;
    	 if c1%notfound then
    	     close c1;
    	     fnd_message.set_name('BEN','BEN_94132_INVALID_VALUE_SET_ID');
	     fnd_message.set_token('VALUESET',p_col2_value_set_id);
    	     fnd_message.raise_error;
    	 end if;
	 close c1;
    	 --
      end if;
      --
    hr_utility.set_location('Leaving:'||l_proc, 15);

end chk_col_value_set_id;

--
-- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that eligy criteria do not exist in the
--   ben_eligy_crit_values_f table when the user deletes the record in the ben_
--   eligy_criteria table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   eligy_criteria_id      PK of record being inserted or updated.
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
procedure chk_child_records(p_eligy_criteria_id  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';
  v_dummy        varchar2(1);
  --
   cursor chk_eligy_criteria is
     select null
     from   ben_eligy_crit_values_f ecv
     where  ecv.eligy_criteria_id = p_eligy_criteria_id;
begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- check if eligy criteria exists in the eligy_crit_values_f table
    --
   open chk_eligy_criteria;
     --
     -- fetch value from cursor if it returns a record then the
     -- the user cannot delete the eligy criteria
     --
   fetch chk_eligy_criteria into v_dummy;
   if chk_eligy_criteria%found then
        close chk_eligy_criteria;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_94133_EGL_CHLD_RCD_EXISTS');
        fnd_message.raise_error;
   end if;
   --
   close chk_eligy_criteria;
   --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_records;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_access_exclusive >---------------------------|
-- -- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that
-- 1. p_acess_calc_rule is mutually exclusive to .p_access_table_name1  AND p_access_column_name1
--

-- Pre Conditions
--   None.
--
-- In Parameters
--   p_eligy_criteria_id               PK of record being inserted or updated.
--   p_acess_calc_rule
--   p_access_table_name1
--   p_access_column_name1
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_access_exclusive(p_access_calc_rule         in number,
                               p_access_table_name1	  in varchar2,
                               p_access_column_name1	  in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_access_exclusive';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_access_calc_rule is not null  and
      (p_access_table_name1 is not null
           or p_access_column_name1 is not null ) )

    then
      --
      fnd_message.set_name('BEN','BEN_94134_ACCESS_RL_TAB_COL');
      fnd_message.raise_error;
      --
    end if;

  hr_utility.set_location('Leaving:'||l_proc, 10);

end chk_access_exclusive;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_table_column >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- Table and column names to be valid .
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_eligy_criteria_id      in number,
--     p_access_table_name1       in varchar2,
--     p_access_column_name1    in  varchar2,
--     p_access_table_name2     in  varchar2,
--     p_access_column_name2    in  varchar2,
--     p_object_version_number  in number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.

Procedure chk_table_column (p_eligy_criteria_id      in  number,
                            p_access_table_name1     in  varchar2,
	                    p_access_column_name1    in  varchar2,
			    p_access_table_name2     in  varchar2,
	                    p_access_column_name2    in  varchar2,
                            p_object_version_number  in  number) is

  --
  l_proc         varchar2(72) := g_package||'chk_table_column';
  l_table_id        number(15);
  l_dummy           varchar2(1);
  --
  --
    cursor c1(p_access_table_name varchar2) is
      select  table_id
        from  fnd_tables
        where table_name  = p_access_table_name;
  --
    cursor c2(p_access_column_name varchar2) is
      select  null
        from  fnd_columns
        where table_id     = l_table_id
	and   column_name  = p_access_column_name;
  --
  --
  Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --

      if  p_access_table_name1 is not null then
    	 --
    	 open c1(p_access_table_name1);
    	 fetch c1 into l_table_id;
	 --
    	 if c1%notfound then
    	     close c1;
    	     fnd_message.set_name('BEN','BEN_91039_INVALID_TABLE');
	     fnd_message.set_token('PROCNAME',l_proc);
    	     fnd_message.raise_error;
            --
         else
	 --
	   if p_access_table_name1 not in ('PER_ALL_ASSIGNMENTS_F','PER_ALL_PEOPLE_F')then
	     fnd_message.set_name ('BEN','BEN_91039_INVALID_TABLE');
             fnd_message.set_token('TABLENAME','p_access_table_name1');
	     fnd_message.set_token('PROCNAME',l_proc);
    	     fnd_message.raise_error;
	   end if;
	 --
	 end if;
	 --
	 close c1;
    	 --
      end if;
      --
      --
      if (p_access_table_name1 is not null and p_access_column_name1 is null) then
	  fnd_message.set_name('BEN','BEN_94433_COLUMN_REQUIRED');
	  fnd_message.raise_error;
      end if;
      --

      if  p_access_column_name1 is not null then
        --
	  if p_access_table_name1 is null then
	     fnd_message.set_name('BEN','BEN_94432_TABLE_REQUIRED');
	     fnd_message.raise_error;
            --
	     else
              open  c2(p_access_column_name1);
	      fetch c2 into l_dummy;
	       if c2%notfound then
    	         close c2;
    	         fnd_message.set_name('BEN','BEN_91039_INVALID_COLUMN');
		 fnd_message.set_token('COLUMNNAME',p_access_column_name1);
	         fnd_message.set_token('PROCNAME',l_proc);
    	         fnd_message.raise_error;
               end if;
    	      --
	      close c2;
	  --
	    end if;

      end if;
      --

      --
       if  p_access_table_name2 is not null then
    	 --
    	 open c1(p_access_table_name2);
    	 fetch c1 into l_table_id;
	 --
    	 if c1%notfound then
    	     close c1;
	     fnd_message.set_name('BEN','BEN_91039_INVALID_TABLE');
             fnd_message.set_token('TABLENAME',p_access_table_name2);
	     fnd_message.set_token('PROCNAME',l_proc);
         end if;
	 --
	 close c1;
    	 --
      end if;
      --
      --
      if (p_access_table_name2 is not null and p_access_column_name2 is null) then
  	  fnd_message.set_name('BEN','BEN_94484_COLUMN_REQUIRED');
	  fnd_message.raise_error;
      end if;
      --

      if  p_access_column_name2 is not null then
        --
	  if p_access_table_name2 is null then
	     fnd_message.set_name('BEN','BEN_94485_TABLE_REQUIRED');
	     fnd_message.raise_error;
	     --
	     else
              open c2(p_access_column_name2);
	      fetch c2 into l_dummy;
	        --
	        if c2%notfound then
    	         close c2;
		   fnd_message.set_name('BEN','BEN_91039_INVALID_COLUMN');
		   fnd_message.set_token('COLUMNNAME',p_access_column_name1);
	           fnd_message.set_token('PROCNAME',l_proc);
    	           fnd_message.raise_error;
                end if;
    	        --
	      close c2;
	      --
	    end if;
          --
      end if;
      --
    hr_utility.set_location('Leaving:'||l_proc, 15);

end chk_table_column;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_col_val_type_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- validating crit_col_val_type_cd value for both set1 and set2
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_eligy_criteria_id      in number,
--     p_col1_value_set_id       in varchar2,
--     p_object_version_number  in number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.

Procedure chk_col_val_type_cd (p_crit_col_val_type_cd      in varchar2,
				p_col_lookup_type           in varchar2,
				p_access_calc_rule           in number,
                                p_col_value_set_id          in number,
				p_access_table_name	     in varchar2,
                                p_access_column_name	     in varchar2,
				p_allow_range_validation_flg in varchar2,
				p_set			     in number
                                ) is
--Bug 4729818 Added new parameter p_set
  --
  l_proc         varchar2(72) := g_package||'chk_col_val_type_cd';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --

  --
  Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
    if p_crit_col_val_type_cd is not null
    then
      --
      if p_crit_col_val_type_cd = 'LOOKUP' --lookup
      then
        --
        if (p_col_lookup_type is null or p_col_value_set_id is not null)
	then
	  --
	  fnd_message.set_name('BEN','BEN_94137_VALID_CRIT_BASIS');
    	  fnd_message.raise_error;
	  --
        end if;
	--
      else
        --
        if p_crit_col_val_type_cd = 'VAL_SET'
	then
	  --
	  if (p_col_lookup_type is not null or p_col_value_set_id is  null)
	  then
	    --
	    fnd_message.set_name('BEN','BEN_94137_VALID_CRIT_BASIS');
    	    fnd_message.raise_error;
	    --
	  end if;
	  --
	else
	  --
	  if p_crit_col_val_type_cd in ('ORG_HIER','POS_HIER')
	  then
	    --
	    if (p_col_lookup_type is not null or p_col_value_set_id is not null or p_access_calc_rule is not null)
	    then
	      --
	      fnd_message.set_name('BEN','BEN_94137_VALID_CRIT_BASIS');
    	      fnd_message.raise_error;
	      --
            else
	      --
	      if(p_allow_range_validation_flg = 'Y')
	      then
	        --
                fnd_message.set_name('BEN','BEN_94137_VALID_CRIT_BASIS');
    	        fnd_message.raise_error;
		--
              else
	        --
	        if p_crit_col_val_type_cd ='ORG_HIER'
		then
		  --
		  if (p_access_table_name <> 'PER_ALL_ASSIGNMENTS_F' or p_access_column_name <> 'ORGANIZATION_ID')
		  then
		    --
		    fnd_message.set_name('BEN','BEN_94137_VALID_CRIT_BASIS');
    	            fnd_message.raise_error;
		    --
		  end if;
		  --
	        else
		  --
		  if p_crit_col_val_type_cd ='POS_HIER'
		  then
		    --
	            if (p_access_table_name <> 'PER_ALL_ASSIGNMENTS_F' or p_access_column_name <> 'POSITION_ID')
		    then
		      --
		      fnd_message.set_name('BEN','BEN_94137_VALID_CRIT_BASIS');
    	              fnd_message.raise_error;
		      --
		    end if;
		    --
	          end if;
		  --
	        end if;
		--
	      end if;
	      --
	    end if;
	    --
	  end if;--hier
	  --
	end if;--val
	--
      end if;--look
      --
    else
      --
      if p_crit_col_val_type_cd is null
      then
        --
--	Bug 4729818 Display Appropriate error messages for two Sets
	if (p_set = 1) then --signifies set 1 is being checked
        fnd_message.set_name('BEN','BEN_94152_VAL_TYP_CD_NULL');
    	fnd_message.raise_error;
	end if;

	if (p_set = 2) then -- signifies set 2 is being checked
	--RKG Set 2 Error Message for Bug 4729818
	fnd_message.set_name('BEN','BEN_94483_VAL_TYP_CD_NULL');
	fnd_message.raise_error;
	end if;
	--
      end if;
      --
    end if;-- upd
    --
    hr_utility.set_location('Leaving:'||l_proc, 15);
    --
end chk_col_val_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_col_val_type_cd_upd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
-- validating crit_col_val_type_cd value for both set1 and set2
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_eligy_criteria_id      in number,
--     p_col1_value_set_id       in varchar2,
--     p_object_version_number  in number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.

Procedure chk_col_val_type_cd_upd(p_eligy_criteria_id          in number,
                                   p_crit_col_val_type_cd      in varchar2,
				   p_col_lookup_type           in varchar2,
				   p_access_calc_rule           in number,
                                   p_col_value_set_id          in number,
				   p_access_table_name	        in varchar2,
                                   p_access_column_name	        in varchar2,
                                   p_object_version_number      in number,
				   p_allow_range_validation_flg in varchar2,
				   p_set                        in number) is

--Bug 4729818  Added additional parameter p_set
  --
  l_proc         varchar2(72) := g_package||'chk_col_val_type_cd_upd';
  l_dummy        varchar2(1);
  l_api_updating boolean;
  --
  cursor chk_eligy_criteria is
   select null
      from   ben_eligy_crit_values_f ecv
      where  ecv.eligy_criteria_id = p_eligy_criteria_id;
  --
  Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
      --
      l_api_updating := ben_egl_shd.api_updating
        (p_eligy_criteria_id           => p_eligy_criteria_id,
         p_object_version_number       => p_object_version_number);
      --
       --
       if p_crit_col_val_type_cd is null
         then
            --
--Bug 4729818 Display appropriate error messages
        if (p_set = 1) then --signifies set 1 is being checked
            fnd_message.set_name('BEN','BEN_94152_VAL_TYP_CD_NULL');
            fnd_message.raise_error;
	end if;

	if (p_set = 2) then -- signifies set 2 is being checked
	--RKG Set 2 Error Message for Bug 4729818
              fnd_message.set_name('BEN','BEN_94483_VAL_TYP_CD_NULL');
              fnd_message.raise_error;
	end if;
	    --

       else
         if (
           (l_api_updating
            and p_crit_col_val_type_cd
            <> nvl(ben_egl_shd.g_old_rec.crit_col1_val_type_cd,hr_api.g_number)
	    )
          or not l_api_updating
	  )
	  and p_crit_col_val_type_cd is not null then
           --
             open chk_eligy_criteria;

             fetch chk_eligy_criteria into l_dummy;
	     --
             if chk_eligy_criteria%found then
               close chk_eligy_criteria;
               --
                fnd_message.set_name('BEN','BEN_94133_EGL_CHLD_RCD_EXISTS');
                fnd_message.raise_error;
               --
	     --
	     else
                chk_col_val_type_cd(p_crit_col_val_type_cd      => p_crit_col_val_type_cd,
		                  p_col_lookup_type           => p_col_lookup_type,
		                  p_access_calc_rule           => p_access_calc_rule,
                                  p_col_value_set_id          => p_col_value_set_id,
		                  p_access_table_name         => p_access_table_name,
                                  p_access_column_name        => p_access_column_name,
		                  p_allow_range_validation_flg => p_allow_range_validation_flg,
				  p_set                        => p_set);
-- Bug 4729818 Changed the above call according to the signature of chk_col_val_type_cd
             end if;
             --
            close chk_eligy_criteria;
         --
          end if;-- upd
       --
       end if;--if null
    hr_utility.set_location('Leaving:'||l_proc, 15);

end chk_col_val_type_cd_upd;

-- ----------------------------------------------------------------------------
-- |---------------------< chk_tab_col_rl_null >---------------------------|
-- -- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that
-- 1. p_acess_calc_rule is mutually exclusive to .p_access_table_name1  AND p_access_column_name1
--

-- Pre Conditions
--   None.
--
-- In Parameters
--   p_eligy_criteria_id               PK of record being inserted or updated.
--   p_acess_calc_rule
--   p_access_table_name1
--   p_access_column_name1
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_tab_col_rl_null(p_access_calc_rule          in number,
                              p_access_table_name1	  in varchar2,
                              p_access_column_name1	  in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_tab_col_rl_null';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_access_calc_rule is  null  and
      (p_access_table_name1 is  null
           and p_access_column_name1 is  null ) )

    then
      --
      fnd_message.set_name('BEN','BEN_94149_TAB_COL_RL_NULL');
      fnd_message.raise_error;
      --
   end if;
 --
  hr_utility.set_location('Leaving:'||l_proc, 10);

end chk_tab_col_rl_null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_tab_col_rl_upd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  Check for child records while updating table,column or access rule
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_eligy_criteria_id      in number,
--     p_access_calc_rule       in number
--     p_access_table_name1	in varchar2,
--     p_access_column_name1    in varchar2
--     p_object_version_number  in number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.

Procedure chk_tab_col_rl_upd(      p_eligy_criteria_id      in number,
                                   p_access_calc_rule       in number,
                                   p_access_table_name1	    in varchar2,
                                   p_access_column_name1    in varchar2,
                                   p_object_version_number  in number) is

  --
  l_proc         varchar2(72) := g_package||'chk_tab_col_rl_upd';
  l_api_updating boolean;
   --

  Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
    --
    --
      l_api_updating := ben_egl_shd.api_updating
        (p_eligy_criteria_id           => p_eligy_criteria_id,
         p_object_version_number       => p_object_version_number);
      --

      if (l_api_updating
          and p_access_calc_rule
          <> nvl(ben_egl_shd.g_old_rec.access_calc_rule,hr_api.g_number)
          or not l_api_updating)
          and p_access_calc_rule is not null then
        --
         chk_child_records(p_eligy_criteria_id   => p_eligy_criteria_id);
        --
      end if;
      --
      if (l_api_updating
          and p_access_table_name1
          <> nvl(ben_egl_shd.g_old_rec.access_table_name1,hr_api.g_number)
          or not l_api_updating)
          and p_access_table_name1 is not null then
        --
         chk_child_records(p_eligy_criteria_id   => p_eligy_criteria_id);
        --
      end if;
      --
      if (l_api_updating
          and p_access_column_name1
          <> nvl(ben_egl_shd.g_old_rec.access_column_name1,hr_api.g_number)
          or not l_api_updating)
          and p_access_column_name1 is not null then
        --
         chk_child_records(p_eligy_criteria_id   => p_eligy_criteria_id);
        --
      end if;
      --

    hr_utility.set_location('Leaving:'||l_proc, 15);

   end chk_tab_col_rl_upd;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_allw_range_vld_flag_upd >-----------------------|
-- ----------------------------------------------------------------------------
-- Created in Bug 4584283 fix. To error when allow_range_validation_flag is
-- updated when child records exists.
procedure chk_allw_range_vld_flag_upd(
                           p_eligy_criteria_id           in number,
			   p_allow_range_validation_flg  in varchar2,
			   p_allow_range_validation_flg2 in varchar2,
                           p_object_version_number       in number) is
  l_api_updating boolean;
  --
Begin
  --
  --
  l_api_updating := ben_egl_shd.api_updating
    (p_eligy_criteria_id                => p_eligy_criteria_id,
     p_object_version_number            => p_object_version_number);
      --
      if  -- Flag 1 is changed
         (((l_api_updating
          and p_allow_range_validation_flg
          <> nvl(ben_egl_shd.g_old_rec.allow_range_validation_flg,hr_api.g_varchar2)
          or not l_api_updating) and p_allow_range_validation_flg is not null)
       or -- Flag 2 is changed
          ((l_api_updating
          and p_allow_range_validation_flg2
          <> nvl(ben_egl_shd.g_old_rec.allow_range_validation_flag2,hr_api.g_varchar2)
          or not l_api_updating) and p_allow_range_validation_flg2 is not null)
	 ) then
	--
         chk_child_records(p_eligy_criteria_id   => p_eligy_criteria_id);
        --
      end if;
      --
      --
End chk_allw_range_vld_flag_upd;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_egl_shd.g_rec_type
         		,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_set2_empty varchar2(1) := 'Y';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_eligy_criteria_id(p_eligy_criteria_id          => p_rec.eligy_criteria_id,
                        p_object_version_number      => p_rec.object_version_number);
  --
  chk_name_unique( p_eligy_criteria_id               => p_rec.eligy_criteria_id
                  ,p_name                            => p_rec.name
                  ,p_business_group_id               => p_rec.business_group_id);
  --
  /* Bug 5338058 - Commenting this check as short_code need not to be unique
  chk_short_code_unique( p_eligy_criteria_id          => p_rec.eligy_criteria_id
                        ,p_short_code                 => p_rec.short_code
                        ,p_business_group_id          => p_rec.business_group_id); */
  --
  chk_all_lookups (    p_eligy_criteria_id            => p_rec.eligy_criteria_id ,
                       p_criteria_type                => p_rec.criteria_type,
                       p_crit_col1_val_type_cd        => p_rec.crit_col1_val_type_cd,
                       p_crit_col1_datatype           => p_rec.crit_col1_datatype,
	               p_crit_col2_val_type_cd        => p_rec.crit_col2_val_type_cd,
                       p_crit_col2_datatype           => p_rec.crit_col2_datatype,
	               p_allow_range_validation_flg   => p_rec.allow_range_validation_flg,
		       p_allow_range_validation_flag2 => p_rec.allow_range_validation_flag2, -- added paramter by rbingi
		       p_user_defined_flag	      => p_rec.user_defined_flag,
                       p_effective_date               => p_effective_date,
                       p_object_version_number        => p_rec.object_version_number) ;
  --
  chk_col_lookup_type (p_eligy_criteria_id           => p_rec.eligy_criteria_id,
                       p_col1_lookup_type            => p_rec.col1_lookup_type,
		       p_col2_lookup_type            => p_rec.col2_lookup_type,
                       p_effective_date              => p_effective_date,
                       p_object_version_number       => p_rec.object_version_number,
                       p_business_group_id           => p_rec.business_group_id);
  --
  chk_col_value_set_id(p_eligy_criteria_id           => p_rec.eligy_criteria_id,
                       p_col1_value_set_id           => p_rec.col1_value_set_id,
		       p_col2_value_set_id           => p_rec.col2_value_set_id,
                       p_object_version_number       => p_rec.object_version_number);
  --
  chk_access_calc_rule(p_eligy_criteria_id           => p_rec.eligy_criteria_id,
                       p_access_calc_rule            => p_rec.access_calc_rule,
                       p_business_group_id           => p_rec.business_group_id,
                       p_effective_date              => p_effective_date,
                       p_object_version_number       => p_rec.object_version_number);
  chk_access_exclusive(p_access_calc_rule            => p_rec.access_calc_rule,
                       p_access_table_name1	     => p_rec.access_table_name1,
                       p_access_column_name1	     => p_rec.access_column_name1);
  chk_table_column (  p_eligy_criteria_id           => p_rec.eligy_criteria_id,
                      p_access_table_name1          => p_rec.access_table_name1,
	              p_access_column_name1         => p_rec.access_column_name1,
		      p_access_table_name2          => p_rec.access_table_name2,
	              p_access_column_name2         => p_rec.access_column_name2,
                      p_object_version_number       => p_rec.object_version_number);
  --
  chk_col_val_type_cd(p_crit_col_val_type_cd      => p_rec.crit_col1_val_type_cd,
		       p_col_lookup_type           => p_rec.col1_lookup_type,
		       p_access_calc_rule           => p_rec.access_calc_rule,
                       p_col_value_set_id          => p_rec.col1_value_set_id,
		       p_access_table_name         => p_rec.access_table_name1,
                       p_access_column_name        => p_rec.access_column_name1,
		       p_allow_range_validation_flg =>p_rec.allow_range_validation_flg,
		       p_set                        => 1);
--Bug 4729818 Make the call according to the signature
  --
  if p_rec.criteria_type = 'USER'
  then
  chk_tab_col_rl_null(p_access_calc_rule           => p_rec.access_calc_rule,
                      p_access_table_name1	   => p_rec.access_table_name1,
                      p_access_column_name1	   => p_rec.access_column_name1);
  end if;

  --
  if(p_rec.crit_col2_val_type_cd is not null) then
        l_set2_empty:='N';
  end if;
  --
  if(p_rec.col2_lookup_type is not null) then
        l_set2_empty:='N';
  end if;
  --
  if(p_rec.col2_value_set_id is not null) then
	l_set2_empty:='N';
  end if;
  --
  if(p_rec.access_table_name2 is not null) then
	l_set2_empty:='N';
  end if;
  --
  if(p_rec.access_column_name2 is not null) then
	l_set2_empty:='N';
  end if;
  --
  if(p_rec.access_calc_rule2 is not null) then
	l_set2_empty:='N';
  end if;
  --
  if(p_rec.time_access_calc_rule2 is not null) then
        l_set2_empty:='N';
  end if;
   --  Check for Hierarchy Criteria type, There shd not be Sub-Criteria(Set2) defined
   if p_rec.crit_col1_val_type_cd like '%HIER' and
       l_set2_empty = 'N' then
     --
      fnd_message.set_name('BEN','BEN_94271_EGL_HIER_NO_SET2');
      fnd_message.raise_error;
     --
   end if;
   --
   if(l_set2_empty = 'N') then
     --
	 chk_access_calc_rule(p_eligy_criteria_id           => p_rec.eligy_criteria_id,
                       p_access_calc_rule            => p_rec.access_calc_rule2,
                       p_business_group_id           => p_rec.business_group_id,
                       p_effective_date              => p_effective_date,
                       p_object_version_number       => p_rec.object_version_number);
     --
     --
	  chk_access_exclusive(p_access_calc_rule            => p_rec.access_calc_rule2,
                       p_access_table_name1	     => p_rec.access_table_name2,
                       p_access_column_name1	     => p_rec.access_column_name2);
     --
     --
	chk_col_val_type_cd(p_crit_col_val_type_cd      => p_rec.crit_col2_val_type_cd,
		       p_col_lookup_type           => p_rec.col2_lookup_type,
		       p_access_calc_rule           => p_rec.access_calc_rule2,
                       p_col_value_set_id          => p_rec.col2_value_set_id,
		       p_access_table_name         => p_rec.access_table_name2,
                       p_access_column_name        => p_rec.access_column_name2,
		       p_allow_range_validation_flg =>p_rec.allow_range_validation_flag2,
		       p_set                        => 2);
-- Bug 4729818 Make the call according to the signature


     --
   if p_rec.criteria_type = 'USER'
   then
	chk_tab_col_rl_null(p_access_calc_rule => p_rec.access_calc_rule2,
                      p_access_table_name1	   => p_rec.access_table_name2,
                      p_access_column_name1	   => p_rec.access_column_name2);
   end if;
 end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_egl_shd.g_rec_type
			,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_set2_empty varchar2(1) := 'Y';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_eligy_criteria_id( p_eligy_criteria_id          => p_rec.eligy_criteria_id,
                         p_object_version_number      => p_rec.object_version_number);
  --
  chk_name_unique( p_eligy_criteria_id            => p_rec.eligy_criteria_id
                  ,p_name                         => p_rec.name
                  ,p_business_group_id            => p_rec.business_group_id);
  --
  /* Bug 5338058 - Commenting this check as short_code need not to be unique
  chk_short_code_unique( p_eligy_criteria_id       => p_rec.eligy_criteria_id
                        ,p_short_code              => p_rec.short_code
                        ,p_business_group_id       => p_rec.business_group_id); */
  --
  chk_all_lookups (    p_eligy_criteria_id          => p_rec.eligy_criteria_id ,
                       p_criteria_type              => p_rec.criteria_type,
                       p_crit_col1_val_type_cd      => p_rec.crit_col1_val_type_cd,
                       p_crit_col1_datatype         => p_rec.crit_col1_datatype,
		       p_crit_col2_val_type_cd      => p_rec.crit_col2_val_type_cd,
                       p_crit_col2_datatype         => p_rec.crit_col2_datatype,
		       p_allow_range_validation_flg => p_rec.allow_range_validation_flg,
		       p_allow_range_validation_flag2 => p_rec.allow_range_validation_flag2, -- added paramter by rbingi
		       p_user_defined_flag	    => p_rec.user_defined_flag,
                       p_effective_date             => p_effective_date,
                       p_object_version_number      =>  p_rec.object_version_number) ;
  --
  chk_col_lookup_type ( p_eligy_criteria_id      => p_rec.eligy_criteria_id,
                        p_col1_lookup_type       => p_rec.col1_lookup_type,
		        p_col2_lookup_type       => p_rec.col2_lookup_type,
                        p_effective_date         => p_effective_date,
                        p_object_version_number  => p_rec.object_version_number,
                        p_business_group_id      => p_rec.business_group_id);
  --
  chk_col_value_set_id( p_eligy_criteria_id       => p_rec.eligy_criteria_id,
                        p_col1_value_set_id       => p_rec.col1_value_set_id,
		        p_col2_value_set_id       => p_rec.col2_value_set_id,
                        p_object_version_number   => p_rec.object_version_number);
  --
  chk_tab_col_rl_upd(   p_eligy_criteria_id      => p_rec.eligy_criteria_id,
                        p_access_calc_rule       => p_rec.access_calc_rule,
                        p_access_table_name1	 => p_rec.access_table_name1,
                        p_access_column_name1    => p_rec.access_column_name1,
                        p_object_version_number  => p_rec.object_version_number);
  --
  chk_access_calc_rule(p_eligy_criteria_id        => p_rec.eligy_criteria_id,
                       p_access_calc_rule         => p_rec.access_calc_rule,
                       p_business_group_id        => p_rec.business_group_id,
                       p_effective_date           => p_effective_date,
                       p_object_version_number    => p_rec.object_version_number);
  chk_access_exclusive(p_access_calc_rule          => p_rec.access_calc_rule,
                       p_access_table_name1	   => p_rec.access_table_name1,
                       p_access_column_name1	   => p_rec.access_column_name1);
  chk_table_column (   p_eligy_criteria_id          => p_rec.eligy_criteria_id,
                       p_access_table_name1         => p_rec.access_table_name1,
	               p_access_column_name1        => p_rec.access_column_name1,
		       p_access_table_name2         => p_rec.access_table_name2,
	               p_access_column_name2        => p_rec.access_column_name2,
                       p_object_version_number      => p_rec.object_version_number);
 --
 chk_col_val_type_cd_upd (p_eligy_criteria_id      => p_rec.eligy_criteria_id,
                       p_crit_col_val_type_cd      => p_rec.crit_col1_val_type_cd,
		       p_col_lookup_type           => p_rec.col1_lookup_type,
		       p_access_calc_rule           => p_rec.access_calc_rule,
                       p_col_value_set_id          => p_rec.col1_value_set_id,
		       p_access_table_name         => p_rec.access_table_name1,
                       p_access_column_name        => p_rec.access_column_name1,
                       p_object_version_number      => p_rec.object_version_number,
		       p_allow_range_validation_flg =>p_rec.allow_range_validation_flg,
		       p_set                        => 1);
-- Bug 4729818 Make the call according to the signature
 -- Bug 4584283, Added call to chk_allw_range_vld_flag_upd.
 chk_allw_range_vld_flag_upd( p_eligy_criteria_id    => p_rec.eligy_criteria_id,
		       p_allow_range_validation_flg  => p_rec.allow_range_validation_flg,
		       p_allow_range_validation_flg2 => p_rec.allow_range_validation_flag2,
                       p_object_version_number       => p_rec.object_version_number);
--
 if p_rec.criteria_type = 'USER'
 then
 chk_tab_col_rl_null( p_access_calc_rule            => p_rec.access_calc_rule,
                      p_access_table_name1	    => p_rec.access_table_name1,
                      p_access_column_name1	    => p_rec.access_column_name1);
  end if;
  --
  if(p_rec.crit_col2_val_type_cd is not null) then
        l_set2_empty:='N';
  end if;
  --
  if(p_rec.col2_lookup_type is not null) then
 	l_set2_empty:='N';
  end if;
  --
  if(p_rec.col2_value_set_id is not null) then
	l_set2_empty:='N';
   end if;
  --
  if(p_rec.access_table_name2 is not null) then
	l_set2_empty:='N';
   end if;
  --
  if(p_rec.access_column_name2 is not null) then
	l_set2_empty:='N';
   end if;
  --
  if(p_rec.access_calc_rule2 is not null) then
	l_set2_empty:='N';
   end if;
  --
   if(p_rec.time_access_calc_rule2 is not null) then
	l_set2_empty:='N';
   end if;
   --
   --  Check for Hierarchy Criteria type, There shd not be any Sub-Criteria defined
   if p_rec.crit_col1_val_type_cd like '%HIER' and
       l_set2_empty = 'N' then
     --
      fnd_message.set_name('BEN','BEN_94271_EGL_HIER_NO_SET2');
      fnd_message.raise_error;
     --
   end if;
   --
   if(l_set2_empty = 'N') then

   -- Following call added by rbingi

--Bug 4726244 added checks chk_tab_col_rl_upd , chk_col_val_type_cd_upd

	chk_tab_col_rl_upd(   p_eligy_criteria_id      => p_rec.eligy_criteria_id,
                        p_access_calc_rule       => p_rec.access_calc_rule2,
                        p_access_table_name1	 => p_rec.access_table_name2,
                        p_access_column_name1    => p_rec.access_column_name2,
                        p_object_version_number  => p_rec.object_version_number);

	 chk_access_calc_rule(p_eligy_criteria_id           => p_rec.eligy_criteria_id,
                       p_access_calc_rule            => p_rec.access_calc_rule2,
                       p_business_group_id           => p_rec.business_group_id,
                       p_effective_date              => p_effective_date,
                       p_object_version_number       => p_rec.object_version_number);
   --
	  chk_access_exclusive(p_access_calc_rule            => p_rec.access_calc_rule2,
                       p_access_table_name1	     => p_rec.access_table_name2,
                       p_access_column_name1	     => p_rec.access_column_name2);
   --
	chk_col_val_type_cd(p_crit_col_val_type_cd      => p_rec.crit_col2_val_type_cd,
		       p_col_lookup_type           => p_rec.col2_lookup_type,
		       p_access_calc_rule           => p_rec.access_calc_rule2,
                       p_col_value_set_id          => p_rec.col2_value_set_id,
		       p_access_table_name         => p_rec.access_table_name2,
                       p_access_column_name        => p_rec.access_column_name2,
		       p_allow_range_validation_flg =>p_rec.allow_range_validation_flag2,
		       p_set                        => 2);
-- Bug 4729818 Make the call according to the signature

	 chk_col_val_type_cd_upd (p_eligy_criteria_id      => p_rec.eligy_criteria_id,
                       p_crit_col_val_type_cd      => p_rec.crit_col2_val_type_cd,
		       p_col_lookup_type           => p_rec.col2_lookup_type,
		       p_access_calc_rule           => p_rec.access_calc_rule2,
                       p_col_value_set_id          => p_rec.col2_value_set_id,
		       p_access_table_name         => p_rec.access_table_name2,
                       p_access_column_name        => p_rec.access_column_name2,
                       p_object_version_number      => p_rec.object_version_number,
		       p_allow_range_validation_flg =>p_rec.allow_range_validation_flag2,
		       p_set                       => 2);
-- Bug 4729818 Make the call according to the signature

   --
      if p_rec.criteria_type = 'USER'
      then
	  chk_tab_col_rl_null(p_access_calc_rule  => p_rec.access_calc_rule2,
                      p_access_table_name1	   => p_rec.access_table_name2,
                      p_access_column_name1	   => p_rec.access_column_name2);
      end if;
   end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_egl_shd.g_rec_type
			,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
chk_child_records
  (p_eligy_criteria_id           => p_rec.eligy_criteria_id);
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
  (p_eligy_criteria_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select  a.legislation_code
     from   per_business_groups a,
            ben_eligy_criteria b
     where  b.eligy_criteria_id     = p_eligy_criteria_id
     and     a.business_group_id    = b.business_group_id;
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
                             p_argument       => 'eligy_criteria_id',
                             p_argument_value => p_eligy_criteria_id);
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
end ben_egl_bus;

/
