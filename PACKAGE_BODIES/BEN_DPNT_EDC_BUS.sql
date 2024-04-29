--------------------------------------------------------
--  DDL for Package Body BEN_DPNT_EDC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DPNT_EDC_BUS" as
/* $Header: beedvrhi.pkb 120.0.12010000.2 2010/04/16 06:19:30 pvelvano noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_dpnt_edc_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_eligy_crit_values_id >------|
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
--   dpnt_eligy_crit_values_id PK of record being inserted or updated.
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
procedure chk_dpnt_eligy_crit_values_id (
                                    p_dpnt_eligy_crit_values_id      In   Number,
                                    p_effective_date            In   Date,
                                    p_object_version_number     In   Number
									) is
       --
       l_proc varchar2(72) := g_package||'chk_dpnt_eligy_crit_values_id';
       l_api_updating boolean;
       --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_dpnt_edc_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_dpnt_eligy_crit_values_id        => p_dpnt_eligy_crit_values_id,
	 p_object_version_number       => p_object_version_number
	 );
  --
  if (l_api_updating
      and nvl(p_dpnt_eligy_crit_values_id,hr_api.g_number)
	      <> ben_dpnt_edc_shd.g_old_rec.dpnt_eligy_crit_values_id) then
    --
    -- raise error as PK has changed
    --
    ben_dpnt_edc_shd.constraint_error('ben_dpnt_eligy_crit_values_f_PK');
    --
    elsif not l_api_updating then
    --
    --check if PK is NULL
    --
    if p_dpnt_eligy_crit_values_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_dpnt_edc_shd.constraint_error('ben_dpnt_eligy_crit_values_f_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dpnt_eligy_crit_values_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_eligy_criteria_dpnt_id >----------------------------|
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
--   p_dpnt_eligy_crit_values_id PK
--   p_eligy_criteria_dpnt_id ID of FK column
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
procedure chk_eligy_criteria_dpnt_id(
                                p_dpnt_eligy_crit_values_id  In Number,
                                p_eligy_criteria_dpnt_id     In Number,
                                p_effective_date        In Date,
                                p_object_version_number In Number
                                ) is
      --
      l_proc varchar2(72) := g_package||'chk_eligy_criteria_dpnt_id';
      l_api_updating boolean;
      l_dummy varchar2(1);
      --
      Cursor csr_eligy_criteria_dpnt_id is
         select NULL
         from ben_eligy_criteria_dpnt
         where eligy_criteria_dpnt_id = p_eligy_criteria_dpnt_id;
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_dpnt_edc_shd.api_updating(
        p_dpnt_eligy_crit_values_id  => p_dpnt_eligy_crit_values_id,
        p_effective_date        => p_effective_date,
        p_object_version_number => p_object_version_number
        );
  --
  if (l_api_updating
      and nvl(p_eligy_criteria_dpnt_id,hr_api.g_number)
          <>  ben_dpnt_edc_shd.g_old_rec.eligy_criteria_dpnt_id
		   or  not l_api_updating) then
     --
     open csr_eligy_criteria_dpnt_id;
     --
     fetch csr_eligy_criteria_dpnt_id into l_dummy;
     --
     if csr_eligy_criteria_dpnt_id%notfound then
        --
        close csr_eligy_criteria_dpnt_id;
        --
        --Raise an error
        --
       ben_dpnt_edc_shd.constraint_error('ben_dpnt_eligy_crit_values_fK1');
      --
     end if;
     --
     close csr_eligy_criteria_dpnt_id;
     --
   end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end chk_eligy_criteria_dpnt_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_eligy_prfl_id >----------------------------|
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
--   p_dpnt_eligy_crit_values_id PK
--   p_eligy_prfl_id ID of FK column
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
procedure chk_eligy_prfl_id(
                            p_dpnt_eligy_crit_values_id  In Number,
                            p_dpnt_cvg_eligy_prfl_id     In Number,
                            p_effective_date        In Date,
                            p_object_version_number In Number
                            ) is
      --
      l_proc varchar2(72) := g_package||'chk_eligy_prfl_id';
      l_api_updating boolean;
      l_dummy varchar2(1);
      --
      Cursor csr_eligy_prfl_id is
         select NULL
         from ben_dpnt_cvg_eligy_prfl_f
         where dpnt_cvg_eligy_prfl_id = p_dpnt_cvg_eligy_prfl_id;
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_dpnt_edc_shd.api_updating(
        p_dpnt_eligy_crit_values_id  => p_dpnt_eligy_crit_values_id,
        p_effective_date        => p_effective_date,
        p_object_version_number => p_object_version_number
        );
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_eligy_prfl_id,hr_api.g_number)
          <>  ben_dpnt_edc_shd.g_old_rec.dpnt_cvg_eligy_prfl_id
		  or  not l_api_updating) then
     --
     open csr_eligy_prfl_id;
     --
     fetch csr_eligy_prfl_id into l_dummy;
     --
     if csr_eligy_prfl_id%notfound then
        --
        close csr_eligy_prfl_id;
        --Raise an error
        --
       ben_dpnt_edc_shd.constraint_error('ben_dpnt_eligy_crit_values_fK1');
      --
     end if;
     --
     close csr_eligy_prfl_id;
   end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end chk_eligy_prfl_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_duplicate_eligy_criteria >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--   This procedure checks that an eligibility criteria is not attached more
--   than once to the eligiblity profile
-- ---------------------------------------------------------------------------
procedure chk_duplicate_eligy_criteria
          (p_dpnt_eligy_crit_values_id       in number,
           p_dpnt_cvg_eligy_prfl_id              in number,
           p_eligy_criteria_dpnt_id          in number,
	   p_number_value1              in number,
           p_char_value1                in varchar2,
           p_date_value1                in date,
           p_number_value2              in number,
           p_char_value2                in varchar2,
           p_date_value2                in date,
	   p_number_value3              in number,
           p_char_value3                in varchar2,
           p_date_value3                in date,
           p_number_value4              in number,
           p_char_value4                in varchar2,
           p_date_value4                in date,
           p_validation_start_date      in date,
           p_validation_end_date        in date,
           p_business_group_id          in number
          ) is
  --
  l_proc    varchar2(72)    :=   g_package||'.chk_duplicate_eligy_criteria';
  l_dummy   varchar2(1);
  --
  cursor c_eligy_prfl is
     select null
       from ben_dpnt_eligy_crit_values_f edc
      where edc.dpnt_cvg_eligy_prfl_id = p_dpnt_cvg_eligy_prfl_id
        and edc.eligy_criteria_dpnt_id = p_eligy_criteria_dpnt_id
        and edc.dpnt_eligy_crit_values_id <> nvl ( p_dpnt_eligy_crit_values_id, -1)
	and nvl(edc.number_value1,hr_api.g_number) = nvl(p_number_value1,hr_api.g_number)
	and nvl(edc.number_value2,hr_api.g_number) = nvl(p_number_value2,hr_api.g_number)
	and nvl(edc.char_value1,hr_api.g_varchar2) = nvl(p_char_value1,hr_api.g_varchar2)
	and nvl(edc.char_value2,hr_api.g_varchar2) = nvl(p_char_value2,hr_api.g_varchar2)
	and nvl(edc.date_value1,hr_api.g_date) = nvl (p_date_value1,hr_api.g_date)
	and nvl(edc.date_value2,hr_api.g_date) = nvl (p_date_value2,hr_api.g_date)
	and nvl(edc.number_value3,hr_api.g_number) = nvl(p_number_value3,hr_api.g_number)
	and nvl(edc.number_value4,hr_api.g_number) = nvl(p_number_value4,hr_api.g_number)
	and nvl(edc.char_value3,hr_api.g_varchar2) = nvl(p_char_value3,hr_api.g_varchar2)
	and nvl(edc.char_value4,hr_api.g_varchar2) = nvl(p_char_value4,hr_api.g_varchar2)
	and nvl(edc.date_value3,hr_api.g_date) = nvl (p_date_value3,hr_api.g_date)
	and nvl(edc.date_value4,hr_api.g_date) = nvl (p_date_value4,hr_api.g_date)
	and edc.effective_start_date <= p_validation_end_date
        and edc.effective_end_date >= p_validation_start_date
        and edc.business_group_id = p_business_group_id;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  open c_eligy_prfl;
    --
    fetch c_eligy_prfl into l_dummy;
    --
    if c_eligy_prfl%found
    then
      --
      close c_eligy_prfl;
      fnd_message.set_name('BEN', 'BEN_94139_DUP_ELIGY_CRIT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  close c_eligy_prfl;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end chk_duplicate_eligy_criteria;
--
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
--   p_dpnt_eligy_crit_values_id dpnt_eligy_crit_values_id
--   p_dpnt_cvg_eligy_prfl_id            dpnt_cvg_eligy_prfl_id
--   p_ordr_num                 Sequence Number
--   p_business_group_id        Business Group ID
--   p_validation_start_date    Start date of the record
--   p_validation_end_date      End date of the record
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
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_ordr_num
          ( p_dpnt_eligy_crit_values_id  in   number,
            p_dpnt_cvg_eligy_prfl_id         in   number,
            p_ordr_num              in   number,
            p_validation_start_date in   date,
            p_validation_end_date   in   date,
            p_business_group_id     in   number
           ) is
  --
  l_proc     varchar2(72) := g_package||'.chk_duplicate_ordr_num';
  l_dummy    char(1);
  --
  cursor c1 is
     select null
       from ben_dpnt_eligy_crit_values_f
      where dpnt_eligy_crit_values_id <> nvl( p_dpnt_eligy_crit_values_id, -1 )
        and dpnt_cvg_eligy_prfl_id = p_dpnt_cvg_eligy_prfl_id
        and ordr_num = p_ordr_num
        and business_group_id = p_business_group_id
        and effective_start_date <= p_validation_end_date
        and effective_end_date   >= p_validation_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    --
    if c1%found
    then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_91001_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
    --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
  --
End chk_duplicate_ordr_num;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_required_fields >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--   This procedure checks
--      (1) Based on selected eligibility criteria, all relevant fields are not null
--      (2) Validates the Lookup Type (if required)
--      (3) Validates if Organization Hierarchy exists and is active on p_effective_date
--      (4) Validates if Start Organization falls under Organization Hierarchy
--      (5) Validates if Position Hierarchy exists and is active on p_effective_date
--      (6) Validates if Start Position falls under Position Hierarchy
-- ---------------------------------------------------------------------------
procedure chk_required_fields
          (p_dpnt_eligy_crit_values_id       in number,
           p_eligy_criteria_dpnt_id          in number,
           p_number_value1              in number,
           p_char_value1                in varchar2,
           p_date_Value1                in date,
           p_number_value2              in number,
           p_char_value2                in varchar2,
           p_date_Value2                in date,
           p_number_value3              in number,
           p_char_value3                in varchar2,
           p_date_Value3                in date,
           p_number_value4              in number,
           p_char_value4                in varchar2,
           p_date_Value4                in date,
	   p_business_group_id          in number,
           p_effective_date             in date
          ) is
  --
  l_proc                        varchar2(72)    :=   g_package||'.chk_required_fields';
  l_dummy                       varchar2(1);
  l_crit_col1_val_type_cd       varchar2(30);
  l_crit_col1_datatype          varchar2(30);
  l_col1_lookup_type            varchar2(30);
  l_lookup_code                 varchar2(30);
  l_allow_range_validation_flag varchar2(30);
  --
  l_crit_col2_val_type_cd        varchar2(30);
  l_crit_col2_datatype           varchar2(30);
  l_col2_lookup_type             varchar2(30);
  l_allow_range_validation_flag2 varchar2(30);
  --
  cursor c_eligy_criteria is
     select crit_col1_val_type_cd, crit_col1_datatype, col1_lookup_type, allow_range_validation_flag,
            crit_col2_val_type_cd, crit_col2_datatype, col2_lookup_type, allow_range_validation_flag2
       from ben_eligy_criteria_dpnt egl
      where egl.eligy_criteria_dpnt_id = p_eligy_criteria_dpnt_id
        and egl.business_group_id = p_business_group_id;
  -- Cursors for Set 1
  cursor c_org_stru_ver is
     select null
       from per_org_structure_versions osv
      where osv.business_group_id = p_business_group_id
        and osv.org_structure_version_id = p_number_value1
        and p_effective_date between osv.date_from
                                 and nvl (osv.date_to, p_effective_date );
  --
  cursor c_start_org is
     select null
       from per_org_structure_elements ose
      where ose.org_structure_version_id = p_number_value1
        and ( ose.organization_id_parent = p_number_value2 or
              ose.organization_id_child = p_number_value2
             );
  --
  cursor c_pos_stru_ver is
     select null
       from per_pos_structure_versions psv
      where psv.business_group_id = p_business_group_id
        and psv.pos_structure_version_id = p_number_value1
        and p_effective_date between psv.date_from
                                 and nvl (psv.date_to, p_effective_date );
  --
  cursor c_start_pos is
     select null
       from per_pos_structure_elements pse
      where pse.pos_structure_version_id = p_number_value1
        and ( pse.parent_position_id = p_number_value2 or
              pse.subordinate_position_id = p_number_value2
             );
  --
  -- Cursors for Set 2
  cursor c_org_stru_ver2 is
     select null
       from per_org_structure_versions osv
      where osv.business_group_id = p_business_group_id
        and osv.org_structure_version_id = p_number_value3
        and p_effective_date between osv.date_from
                                 and nvl (osv.date_to, p_effective_date );
  --
  cursor c_start_org2 is
     select null
       from per_org_structure_elements ose
      where ose.org_structure_version_id = p_number_value3
        and ( ose.organization_id_parent = p_number_value4 or
              ose.organization_id_child = p_number_value4
             );
  --
  cursor c_pos_stru_ver2 is
     select null
       from per_pos_structure_versions psv
      where psv.business_group_id = p_business_group_id
        and psv.pos_structure_version_id = p_number_value3
        and p_effective_date between psv.date_from
                                 and nvl (psv.date_to, p_effective_date );
  --
  cursor c_start_pos2 is
     select null
       from per_pos_structure_elements pse
      where pse.pos_structure_version_id = p_number_value3
        and ( pse.parent_position_id = p_number_value4 or
              pse.subordinate_position_id = p_number_value4
             );
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_eligy_criteria;
    --
    fetch c_eligy_criteria into l_crit_col1_val_type_cd,
                                l_crit_col1_datatype,
                                l_col1_lookup_type,
                                l_allow_range_validation_flag,
				l_crit_col2_val_type_cd,
                                l_crit_col2_datatype,
                                l_col2_lookup_type,
                                l_allow_range_validation_flag2;
    --
    if c_eligy_criteria%found
    then
      --
      -- LOOKUP VALUES
      --
      if l_crit_col1_val_type_cd = 'LOOKUP'
      then
        --
        if ( l_crit_col1_datatype = 'N' and p_number_value1 is null ) OR
           ( l_crit_col1_datatype = 'N' and l_allow_range_validation_flag = 'Y' and p_number_value2 is null ) OR
           ( l_crit_col1_datatype = 'D' and p_date_value1 is null ) OR
           ( l_crit_col1_datatype = 'D' and l_allow_range_validation_flag = 'Y' and p_date_value2 is null ) OR
           ( l_crit_col1_datatype = 'C' and p_char_value1 is null ) OR
           ( l_crit_col1_datatype = 'C' and l_allow_range_validation_flag = 'Y' and p_char_value2 is null )
        then
          --
          fnd_message.set_name('BEN', 'BEN_94140_LOOKUP_VALUE_NULL');
          fnd_message.raise_error;
          --
        else
          --
          if l_crit_col1_datatype = 'N'
          then
            l_lookup_code := p_number_value1;
          elsif l_crit_col1_datatype = 'C'
          then
            l_lookup_code := p_char_value1;
          elsif l_crit_col1_datatype = 'D'
          then
            l_lookup_code := p_date_value1;
          end if;
          --
          if hr_api.not_exists_in_hr_lookups
                (p_lookup_type    => l_col1_lookup_type,
                 p_lookup_code    => l_lookup_code,
                 p_effective_date => p_effective_date) then
            --
            -- raise error as code does not exist as lookup
            --
            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
            fnd_message.set_token('FIELD', 'Lookup Value');
            fnd_message.set_token('TYPE',l_col1_lookup_type);
            fnd_message.set_token('VALUE',l_lookup_code);
            fnd_message.raise_error;
            --
          end if;
          --
        end if;
        --
      --
      -- Value Set
      --
      elsif l_crit_col1_val_type_cd = 'VAL_SET'
      then
        --
        if ( l_crit_col1_datatype = 'N' and p_number_value1 is null ) OR
           ( l_crit_col1_datatype = 'N' and l_allow_range_validation_flag = 'Y' and p_number_value2 is null ) OR
           ( l_crit_col1_datatype = 'D' and p_date_value1 is null ) OR
           ( l_crit_col1_datatype = 'D' and l_allow_range_validation_flag = 'Y' and p_date_value2 is null ) OR
           ( l_crit_col1_datatype = 'C' and p_char_value1 is null ) OR
           ( l_crit_col1_datatype = 'C' and l_allow_range_validation_flag = 'Y' and p_char_value2 is null )
        then
          --
          fnd_message.set_name('BEN', 'BEN_94141_VSET_VALUE_NULL');
          fnd_message.raise_error;
          --
        end if;
        --
        --
      end if;
      --
      -- Set 2 validations added rbingi
      if l_crit_col2_val_type_cd = 'LOOKUP'
      then
        --
        if ( l_crit_col2_datatype = 'N' and p_number_value3 is null ) OR
           ( l_crit_col2_datatype = 'N' and l_allow_range_validation_flag2 = 'Y' and p_number_value4 is null ) OR
           ( l_crit_col2_datatype = 'D' and p_date_value3 is null ) OR
           ( l_crit_col2_datatype = 'D' and l_allow_range_validation_flag2 = 'Y' and p_date_value4 is null ) OR
           ( l_crit_col2_datatype = 'C' and p_char_value3 is null ) OR
           ( l_crit_col2_datatype = 'C' and l_allow_range_validation_flag2 = 'Y' and p_char_value4 is null )
        then
          --
          fnd_message.set_name('BEN', 'BEN_94140_LOOKUP_VALUE_NULL');
          fnd_message.raise_error;
          --
        else
          --
          if l_crit_col2_datatype = 'N'
          then
            l_lookup_code := p_number_value3;
          elsif l_crit_col2_datatype = 'C'
          then
            l_lookup_code := p_char_value3;
          elsif l_crit_col2_datatype = 'D'
          then
            l_lookup_code := p_date_value3;
          end if;
          --
          if hr_api.not_exists_in_hr_lookups
                (p_lookup_type    => l_col2_lookup_type,
                 p_lookup_code    => l_lookup_code,
                 p_effective_date => p_effective_date) then
            --
            -- raise error as code does not exist as lookup
            --
            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
            fnd_message.set_token('FIELD', 'Lookup Value');
            fnd_message.set_token('TYPE',l_col2_lookup_type);
            fnd_message.set_token('VALUE',l_lookup_code);
            fnd_message.raise_error;
            --
          end if;
          --
        end if;
        --
      --
      -- Value Set
      --
      elsif l_crit_col2_val_type_cd = 'VAL_SET'
      then
        --
        if ( l_crit_col2_datatype = 'N' and p_number_value3 is null ) OR
           ( l_crit_col2_datatype = 'N' and l_allow_range_validation_flag2 = 'Y' and p_number_value4 is null ) OR
           ( l_crit_col2_datatype = 'D' and p_date_value3 is null ) OR
           ( l_crit_col2_datatype = 'D' and l_allow_range_validation_flag2 = 'Y' and p_date_value4 is null ) OR
           ( l_crit_col2_datatype = 'C' and p_char_value3 is null ) OR
           ( l_crit_col2_datatype = 'C' and l_allow_range_validation_flag2 = 'Y' and p_char_value4 is null )
        then
          --
          fnd_message.set_name('BEN', 'BEN_94141_VSET_VALUE_NULL');
          fnd_message.raise_error;
          --
        end if;
        --
      end if;
      --
    end if;
    --
  close c_eligy_criteria;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
end chk_required_fields;
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
procedure dt_update_validate
          (p_eligy_criteria_dpnt_id       In number default hr_api.g_number,
           p_dpnt_cvg_eligy_prfl_id           In number default hr_api.g_number,
           p_datetrack_mode          In Varchar2,
           p_validation_start_date   In Date,
           p_validation_end_date     In Date
           ) Is
  --
  l_proc    varchar2(72)    :=   g_package||'dt_update_validate';
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
  /*  If ((nvl(p_eligy_criteria_dpnt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_eligy_criteria',
             p_base_key_column => 'eligy_criteria_dpnt_id',
             p_base_key_value  => p_eligy_criteria_dpnt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_eligy_criteria';
      Raise l_integrity_error;
    End If;*/
    --
    If ((nvl(p_dpnt_cvg_eligy_prfl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_dpnt_cvg_eligy_prfl_f',
             p_base_key_column => 'dpnt_cvg_eligy_prfl_id',
             p_base_key_value  => p_dpnt_cvg_eligy_prfl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_eligy_prfl_f';
      Raise l_integrity_error;
    End If;
    --
  end if;
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
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
end dt_update_validate;
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
            (p_dpnt_eligy_crit_values_id	   	in number,
             p_datetrack_mode	    	in varchar2,
	         p_validation_start_date	in date,
	         p_validation_end_date	    in date) Is
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
       p_argument       => 'dpnt_eligy_crit_values_id',
       p_argument_value => p_dpnt_eligy_crit_values_id);
    --
  end if;
--
end dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_dpnt_edc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if p_rec.business_group_id is not null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_dpnt_eligy_crit_values_id( p_dpnt_eligy_crit_values_id         =>  p_rec.dpnt_eligy_crit_values_id,
                            p_effective_date               =>  p_effective_date,
                            p_object_version_number        =>  p_rec.object_version_number );
  --
  chk_eligy_criteria_dpnt_id( p_dpnt_eligy_crit_values_id         =>  p_rec.dpnt_eligy_crit_values_id,
                         p_eligy_criteria_dpnt_id            =>  p_rec.eligy_criteria_dpnt_id,
                         p_effective_date               =>  p_effective_date,
                         p_object_version_number        =>  p_rec.object_version_number );
  --
  chk_eligy_prfl_id( p_dpnt_eligy_crit_values_id         =>  p_rec.dpnt_eligy_crit_values_id,
                     p_dpnt_cvg_eligy_prfl_id                =>  p_rec.dpnt_cvg_eligy_prfl_id,
                     p_effective_date               =>  p_effective_date,
                     p_object_version_number        =>  p_rec.object_version_number );
  --
  chk_duplicate_eligy_criteria (p_dpnt_eligy_crit_values_id       => p_rec.dpnt_eligy_crit_values_id,
                                p_dpnt_cvg_eligy_prfl_id              => p_rec.dpnt_cvg_eligy_prfl_id,
                                p_eligy_criteria_dpnt_id          => p_rec.eligy_criteria_dpnt_id,
				p_number_value1              => p_rec.number_value1,
                                p_char_value1                => p_rec.char_value1,
                                p_date_value1                => p_rec.date_value1,
                                p_number_value2              => p_rec.number_value2,
                                p_char_value2                => p_rec.char_value2,
                                p_date_value2                => p_rec.date_value2,
				p_number_value3              => p_rec.number_value3,
                                p_char_value3                => p_rec.char_value3,
                                p_date_value3                => p_rec.date_value3,
                                p_number_value4              => p_rec.number_value4,
                                p_char_value4                => p_rec.char_value4,
                                p_date_value4                => p_rec.date_value4,
				p_validation_start_date      => p_validation_start_date,
                                p_validation_end_date        => p_validation_end_date,
                                p_business_group_id          => p_rec.business_group_id );

  --
  chk_duplicate_ordr_num ( p_dpnt_eligy_crit_values_id       => p_rec.dpnt_eligy_crit_values_id,
                           p_dpnt_cvg_eligy_prfl_id              => p_rec.dpnt_cvg_eligy_prfl_id,
                           p_ordr_num                   => p_rec.ordr_num,
                           p_validation_start_date      => p_validation_start_date,
                           p_validation_end_date        => p_validation_end_date,
                           p_business_group_id          => p_rec.business_group_id );
  --
  chk_required_fields ( p_dpnt_eligy_crit_values_id       => p_rec.dpnt_eligy_crit_values_id,
                        p_eligy_criteria_dpnt_id          => p_rec.eligy_criteria_dpnt_id,
                        p_number_value1              => p_rec.number_value1,
                        p_char_value1                => p_rec.char_value1,
                        p_date_Value1                => p_rec.date_Value1,
                        p_number_value2              => p_rec.number_value2,
                        p_char_value2                => p_rec.char_value2,
                        p_date_Value2                => p_rec.date_Value2,
                        p_number_value3              => p_rec.number_value3,
                        p_char_value3                => p_rec.char_value3,
                        p_date_Value3                => p_rec.date_Value3,
                        p_number_value4              => p_rec.number_value4,
                        p_char_value4                => p_rec.char_value4,
                        p_date_Value4                => p_rec.date_Value4,
			p_business_group_id          => p_rec.business_group_id,
			p_effective_date             => p_effective_date) ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_dpnt_edc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
  --
  l_proc varchar2(72)   :=   g_package||'update_validate';
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if p_rec.business_group_id is not null
  then
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
    --
  end if;
  --
  chk_dpnt_eligy_crit_values_id( p_dpnt_eligy_crit_values_id         =>  p_rec.dpnt_eligy_crit_values_id,
                            p_effective_date               =>  p_effective_date,
                            p_object_version_number        =>  p_rec.object_version_number );
  --
  chk_eligy_criteria_dpnt_id( p_dpnt_eligy_crit_values_id         =>  p_rec.dpnt_eligy_crit_values_id,
                         p_eligy_criteria_dpnt_id            =>  p_rec.eligy_criteria_dpnt_id,
                         p_effective_date               =>  p_effective_date,
                         p_object_version_number        =>  p_rec.object_version_number );
  --
  chk_eligy_prfl_id( p_dpnt_eligy_crit_values_id         =>  p_rec.dpnt_eligy_crit_values_id,
                     p_dpnt_cvg_eligy_prfl_id                =>  p_rec.dpnt_cvg_eligy_prfl_id,
                     p_effective_date               =>  p_effective_date,
                     p_object_version_number        =>  p_rec.object_version_number );
  --
  chk_duplicate_eligy_criteria (p_dpnt_eligy_crit_values_id       => p_rec.dpnt_eligy_crit_values_id,
                                p_dpnt_cvg_eligy_prfl_id              => p_rec.dpnt_cvg_eligy_prfl_id,
                                p_eligy_criteria_dpnt_id          => p_rec.eligy_criteria_dpnt_id,
				p_number_value1              => p_rec.number_value1,
                                p_char_value1                => p_rec.char_value1,
                                p_date_value1                => p_rec.date_value1,
                                p_number_value2              => p_rec.number_value2,
                                p_char_value2                => p_rec.char_value2,
                                p_date_value2                => p_rec.date_value2,
				p_number_value3              => p_rec.number_value3,
                                p_char_value3                => p_rec.char_value3,
                                p_date_value3                => p_rec.date_value3,
                                p_number_value4              => p_rec.number_value4,
                                p_char_value4                => p_rec.char_value4,
                                p_date_value4                => p_rec.date_value4,
                                p_validation_start_date      => p_validation_start_date,
                                p_validation_end_date        => p_validation_end_date,
                                p_business_group_id          => p_rec.business_group_id );
  --
  chk_duplicate_ordr_num ( p_dpnt_eligy_crit_values_id       => p_rec.dpnt_eligy_crit_values_id,
                           p_dpnt_cvg_eligy_prfl_id              => p_rec.dpnt_cvg_eligy_prfl_id,
                           p_ordr_num                   => p_rec.ordr_num,
                           p_validation_start_date      => p_validation_start_date,
                           p_validation_end_date        => p_validation_end_date,
                           p_business_group_id          => p_rec.business_group_id );
  --
  chk_required_fields ( p_dpnt_eligy_crit_values_id       => p_rec.dpnt_eligy_crit_values_id,
                        p_eligy_criteria_dpnt_id          => p_rec.eligy_criteria_dpnt_id,
                        p_number_value1              => p_rec.number_value1,
                        p_char_value1                => p_rec.char_value1,
                        p_date_Value1                => p_rec.date_Value1,
                        p_number_value2              => p_rec.number_value2,
                        p_char_value2                => p_rec.char_value2,
                        p_date_Value2                => p_rec.date_Value2,
                        p_number_value3              => p_rec.number_value3,
                        p_char_value3                => p_rec.char_value3,
                        p_date_Value3                => p_rec.date_Value3,
                        p_number_value4              => p_rec.number_value4,
                        p_char_value4                => p_rec.char_value4,
                        p_date_Value4                => p_rec.date_Value4,
                        p_business_group_id          => p_rec.business_group_id,
                        p_effective_date             => p_effective_date) ;
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate( p_eligy_criteria_dpnt_id            => p_rec.eligy_criteria_dpnt_id,
                      p_dpnt_cvg_eligy_prfl_id                => p_rec.dpnt_cvg_eligy_prfl_id,
                      p_datetrack_mode               => p_datetrack_mode,
                      p_validation_start_date        => p_validation_start_date,
                      p_validation_end_date          => p_validation_end_date );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_dpnt_edc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
  --
  l_proc   varchar2(72)   :=   g_package||'delete_validate';
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_dpnt_eligy_crit_values_id
                          (
                          p_dpnt_eligy_crit_values_id         =>  p_rec.dpnt_eligy_crit_values_id,
                          p_effective_date               =>  p_effective_date,
                          p_object_version_number        =>  p_rec.object_version_number
                          );
  --
 dt_delete_validate
                  (
				  p_dpnt_eligy_crit_values_id	   	=> p_rec.dpnt_eligy_crit_values_id,
                  p_datetrack_mode	            => p_datetrack_mode,
	              p_validation_start_date	    => p_validation_start_date,
	              p_validation_end_date	        => p_validation_end_date
			 );
end delete_validate;
--
/*
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
function return_legislation_code
  (p_dpnt_eligy_crit_values_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_dpnt_eligy_crit_values_f b
    where b.dpnt_eligy_crit_values_id      = p_dpnt_eligy_crit_values_id
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
                             p_argument       => 'dpnt_eligy_crit_values_id',
                             p_argument_value => p_dpnt_eligy_crit_values_id);
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
end return_legislation_code;*/
--
end ben_dpnt_edc_bus;
--

/
