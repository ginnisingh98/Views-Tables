--------------------------------------------------------
--  DDL for Package Body PER_PEA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEA_BUS" as
/* $Header: pepearhi.pkb 120.0.12010000.1 2008/07/28 05:10:27 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
--
g_package  varchar2(33)	:= '  per_pea_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_person_id >-------------------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that PERSON_ID is not null
--
--    Validates that values enterd for this column exist in the PER_PEOPLE_F
--    table.
--
--    Validates that BUSINESS_GROUP_ID in the PER_PERSON_ANALYSES table matches
--    BUSINESS_GROUP_ID in the PER_PEOPLE_F table for the record specified by
--    PERSON_ID.
--
--  Pre-conditions:
--
--  In Arguments :
--    p_person_id
--    p_business_group_id
--    p_effective_date
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
Procedure chk_person_id
       (p_person_id             in per_person_analyses.person_id%TYPE
       ,p_business_group_id     in per_person_analyses.business_group_id%TYPE
       ,p_effective_date        in date) is
--
  l_proc                 varchar2(72) := g_package||'chk_person_id';
  l_business_group_id    per_person_analyses.business_group_id%TYPE;
--
  --
  -- Cursor to check that PERSON_ID exists, in addition obtain
  -- the BUSINESS_GROUP_ID for the other validation checks
  --
  cursor csr_valid_person_id is
    select   per.business_group_id
      from   per_people_f     per
     where   per.person_id   = p_person_id
       and   p_effective_date between per.effective_start_date
                                  and per.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Perform PERSON_ID mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
   );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc,10);
  --
  --  Check for valid PERSON_ID
  --
  open csr_valid_person_id;
  fetch csr_valid_person_id
        into l_business_group_id;
  if (csr_valid_person_id%notfound) then
    --
    close csr_valid_person_id;
    --
    hr_utility.set_message(800,'PER_52092_PEA_INV_PERSON_ID');
    hr_utility.raise_error;
  end if;
  --
  close csr_valid_person_id;
  --
  hr_utility.set_location(l_proc,15);
  --
  -- Check BUSINESS_GROUP_ID is in the same business group as the person
  --
  if (p_business_group_id <> l_business_group_id) then
    hr_utility.set_message(800,'PER_52090_PEA_INV_PERSON_COMB');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PERSON_ANALYSES.PERSON_ID'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_id_flex_num >-----------------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that ID_FLEX_NUM is not null
--
--  Pre-conditions:
--
--  In Arguments :
--
--    p_id_flex_num
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
Procedure chk_id_flex_num
       (p_id_flex_num           in per_person_analyses.id_flex_num%TYPE
       ) is
  --
  l_proc           varchar2(72) := g_package||'chk_id_flex_num';
  --
begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Perform id_flex_num mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'id_flex_num'
    ,p_argument_value => p_id_flex_num
   );
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end chk_id_flex_num;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_analysis_criteria_id >-----------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that ANALYSIS_CRITERIA_ID is not null
--
--    Validates that ID_FLEX_NUM in the PER_PERSON_ANALYSES table matches the
--    ID_FLEX_NUM in the PER_ANALYSIS_CRITERIA table for the record specified by
--    ANALYSIS_CRITERIA_ID.
--
--  Pre-conditions:
--    ID_FLEX_NUM is not null.
--
--  In Arguments :
--    p_analysis_criteria_id
--    p_id_flex_num
--    p_person_analysis_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
Procedure chk_analysis_criteria_id
     (p_analysis_criteria_id  in per_person_analyses.analysis_criteria_id%TYPE
     ,p_id_flex_num           in per_person_analyses.id_flex_num%TYPE
     ,p_person_analysis_id    in per_person_analyses.person_analysis_id%TYPE
     ,p_object_version_number in per_person_analyses.object_version_number%TYPE
     ) is
  --
  l_proc           varchar2(72) := g_package||'chk_analysis_criteria_id';
  l_id_flex_num    per_person_analyses.id_flex_num%TYPE;
  l_api_updating   boolean;
  --
  --
  -- Cursor to check that ANALYSIS_CRITERIA_ID exists, in addition obtain
  -- the ID_FLEX_NUM for the other validation checks
  --
  cursor csr_valid_analysis_criteria_id is
    select   pac.id_flex_num
    from     per_analysis_criteria     pac
    where    pac.analysis_criteria_id   = p_analysis_criteria_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Perform ANALYSIS_CRITERIA_ID mandatory check
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'analysis_criteria_id'
    ,p_argument_value => p_analysis_criteria_id
   );
  --
  hr_utility.set_location(l_proc,10);
  --
  l_api_updating := per_pea_shd.api_updating
    (p_person_analysis_id        => p_person_analysis_id
    ,p_object_version_number     => p_object_version_number);
  --
  --    Check for valid analysis criteria id
  --
  if ((l_api_updating
    and
      (per_pea_shd.g_old_rec.analysis_criteria_id <> p_analysis_criteria_id)
      or
      (per_pea_shd.g_old_rec.id_flex_num <> p_id_flex_num))
    or
      (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,15);
    --
    open  csr_valid_analysis_criteria_id;
    fetch csr_valid_analysis_criteria_id
    into l_id_flex_num;
      --
      if (csr_valid_analysis_criteria_id%notfound) then
        close csr_valid_analysis_criteria_id;
        --
        hr_utility.set_message(801,'HR_51603_PEA_INV_ANA_CRI_ID');
        hr_multi_message.add
	  (p_associated_column1  => 'PER_PERSON_ANALYSES.ANALYSIS_CRITERIA_ID'
          );
      else
        close csr_valid_analysis_criteria_id;
        --
        hr_utility.set_location(l_proc,20);
        --
        -- Check ID_FLEX_NUM is in the same ID_FLEX_NUM as the ANALYSIS_CRITERIA_ID
        --
        if (p_id_flex_num <> l_id_flex_num) then
          hr_utility.set_message(800,'PER_52093_PEA_INV_FLEX_ANA_COM');
          hr_multi_message.add
	  (p_associated_column1  => 'PER_PERSON_ANALYSES.ANALYSIS_CRITERIA_ID'
	  ,p_associated_column2  => 'PER_PERSON_ANALYSES.ID_FLEX_NUM'
          );
        end if;
        --
      end if;
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,25);
end chk_analysis_criteria_id;
--
--  ---------------------------------------------------------------------------
--  |------------------<  check_for_duplicates  >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Looks for duplicate person analyses records for the current person
--    on the same start and end dates
--
--  Pre-conditions:
--
--
--  In Arguments :
--    p_bg_id
--    p_id_flex_num
--    p_analysis_criteria_id
--    p_date_from
--    p_date_to
--    p_person_id
--    p_person_analysis_id
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
procedure check_for_duplicates
     (p_bg_id                 in per_person_analyses.business_group_id%TYPE
     ,p_id_flex_num           in per_person_analyses.id_flex_num%TYPE
     ,p_analysis_criteria_id  in per_person_analyses.analysis_criteria_id%TYPE
     ,p_date_from             in per_person_analyses.date_from%TYPE
     ,p_date_to               in per_person_analyses.date_to%TYPE
     ,p_person_id             in per_person_analyses.person_id%TYPE
     ,p_person_analysis_id    in per_person_analyses.person_analysis_id%TYPE
     ) is
--
cursor c is
select 'x'
from   per_person_analyses pa
      ,per_analysis_criteria ac
where  pa.analysis_criteria_id = p_analysis_criteria_id
and    pa.business_group_id + 0 = p_bg_id
and    pa.analysis_criteria_id = ac.analysis_criteria_id
and    ac.id_flex_num = p_id_flex_num
and    nvl(pa.date_to,hr_api.g_eot) =
       nvl(p_date_to,hr_api.g_eot)
and    pa.date_from = p_date_from
and    pa.person_id = p_person_id
and   (p_person_analysis_id is null
       or (p_person_analysis_id is not null
           and pa.person_analysis_id <> p_person_analysis_id));
--
l_exists varchar2(1);
l_proc   varchar2(72) := g_package||'check_for_duplicates';
--
begin
  hr_utility.set_location('Entering:'||l_proc,5);
--
-- Only proceed with validation when multiple message list does not already
-- contain an error associated with ANALYSIS_CRITERIA_ID,DATE_FROM, DATE_TO
-- PERSON_ID columns.
--
  if hr_multi_message.no_exclusive_error
    (p_check_column1   => 'PER_PERSON_ANALYSES.ANALYSIS_CRITERIA_ID'
    ,p_check_column2   => 'PER_PERSON_ANALYSES.DATE_FROM'
    ,p_check_column3   => 'PER_PERSON_ANALYSES.DATE_TO'
    ,p_check_column4   => 'PER_PERSON_ANALYSES.PERSON_ID'
    ,p_associated_column1 => 'PER_PERSON_ANALYSES.ANALYSIS_CRITERIA_ID'
    ,p_associated_column2 => 'PER_PERSON_ANALYSES.DATE_FROM'
    ,p_associated_column3 => 'PER_PERSON_ANALYSES.DATE_TO'
    ,p_associated_column4 => 'PER_PERSON_ANALYSES.PERSON_ID'
    ) then
  --
  -- Perform ANALYSIS_CRITERIA_ID mandatory check
  --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'analysis_criteria_id'
      ,p_argument_value => p_analysis_criteria_id
      );
  --
    hr_utility.set_location(l_proc,10);
  --
    open c;
    fetch c into l_exists;
    if c%found then
      close c;
      hr_utility.set_message(801,'HR_6012_ROW_INSERTED');
      hr_utility.raise_error;
    end if;
    close c;
  end if;
  hr_utility.set_location('Leaving '||l_proc,15);
  exception
  --
  -- When multiple error detection is enabled handle the application errors
  -- which have been raised by this procedure.
  --
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_same_associated_columns => 'Y'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end check_for_duplicates;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_date_from_to>---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--
--    Validates that DATE_FROM is less than or equal to the value for
--    DATE_TO on the same person_analysis record
--
--    Validates that if DATE_TO has values,DATE_FROM must be not null.
--
--  Pre-conditions:
--
--
--  In Arguments :
--    p_person_analysis_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_date_from_to
  (p_person_analysis_id		in	number default null
  ,p_date_from			in	date
  ,p_date_to			in	date
  ,p_object_version_number in number default null)	is
  --
  l_proc 		varchar2(72)	:= g_package||'chk_date_from_to';
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The DATE_TO value has changed
  --
  l_api_updating := per_pea_shd.api_updating
    (p_person_analysis_id    => p_person_analysis_id
    ,p_object_version_number => p_object_version_number);
  --
  if (((l_api_updating
     and
       (nvl(per_pea_shd.g_old_rec.date_from,hr_api.g_eot) <>nvl(p_date_from,hr_api.g_eot))
       or
       (nvl(per_pea_shd.g_old_rec.date_to,hr_api.g_eot) <> nvl(p_date_to,hr_api.g_eot)))
     or
       (NOT l_api_updating))) then
    --
    -- Check DATE_FROM.If the DATE_TO has value,DATE_FROM is not null.
    --
    hr_utility.set_location(l_proc,10);
    --
    if p_date_to is not null and p_date_from is null then
      --
      hr_utility.set_message(800,'PER_52095_PEA_INV_DATE_FROM');
      hr_multi_message.add
	  (p_associated_column1  => 'PER_PERSON_ANALYSES.DATE_FROM'
          ,p_associated_column2  => 'PER_PERSON_ANALYSES.DATE_TO'
          );
      --
    elsif p_date_from is not null then
      --
      --   Check that DATE_FROM <= DATE_TO
      --
      hr_utility.set_location(l_proc,15);
      --
      if p_date_from > nvl(p_date_to,hr_api.g_eot) then
        --
        hr_utility.set_message(800,'PER_52094_PEA_INV_DATE_COMB');
        hr_multi_message.add
	  (p_associated_column1  => 'PER_PERSON_ANALYSES.DATE_FROM'
          ,p_associated_column2  => 'PER_PERSON_ANALYSES.DATE_TO'
	  );
        --
      end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
  --
end chk_date_from_to;
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_non_updateable_args >-------------------------|
-- ----------------------------------------------------------------------------
Procedure check_non_updateable_args(p_rec in per_pea_shd.g_rec_type)
is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_pea_shd.api_updating
                (p_person_analysis_id      => p_rec.person_analysis_id
                ,p_object_version_number   => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,10);
  --
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
                                per_pea_shd.g_old_rec.business_group_id then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'BUSINESS_GROUP_ID'
      ,p_base_table => per_pea_shd.g_tab_nam
      );
  end if;
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
                                        per_pea_shd.g_old_rec.person_id then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => 'PERSON_ID'
      ,p_base_table => per_pea_shd.g_tab_nam
	 );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
end check_non_updateable_args;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
procedure chk_df
  (p_rec in per_pea_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.person_analysis_id is not null) and (
     nvl(per_pea_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_pea_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.person_analysis_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PERSON_ANALYSES'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			in per_pea_shd.g_rec_type,
         p_effective_date 	in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 => per_pea_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
    );  -- Validate Bus Grp
  --
  --After validating the set of important attributes,
  --if multiple message detection is enabled and atleast
  --one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  --validate dependent attributes
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Validate person id and business group id
  --
  chk_person_id
    (p_person_id             => p_rec.person_id,
     p_business_group_id     => p_rec.business_group_id,
     p_effective_date	     => p_effective_date
   );
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate id flex num
  --
  chk_id_flex_num(p_id_flex_num             => p_rec.id_flex_num);
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Validate analysis criteria id
  --
  chk_analysis_criteria_id
  (p_analysis_criteria_id    => p_rec.analysis_criteria_id,
   p_id_flex_num             => p_rec.id_flex_num,
   p_person_analysis_id	     => p_rec.person_analysis_id,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 9);
  --
  --
  -- Validate date
  --
  chk_date_from_to
  (p_person_analysis_id	     => p_rec.person_analysis_id,
   p_date_from		     => p_rec.date_from,
   p_date_to		     => p_rec.date_to,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Check For Duplicates
  --
  check_for_duplicates
     (p_bg_id                => p_rec.business_group_id
     ,p_id_flex_num          => p_rec.id_flex_num
     ,p_analysis_criteria_id => p_rec.analysis_criteria_id
     ,p_date_from            => p_rec.date_from
     ,p_date_to              => p_rec.date_to
     ,p_person_id            => p_rec.person_id
     ,p_person_analysis_id   => p_rec.person_analysis_id
     );
  --
  --
  hr_utility.set_location(l_proc, 11);
  --
  ----
  -- Validate flex fields.
  --
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location('Leaving:'||l_proc, 12);
  --

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			in per_pea_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 => per_pea_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
    );  -- Validate Bus Grp
  --
  --After validating the set of important attributes,
  --if multiple message detection is enabled and atleast
  --one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- validate dependent attributes
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Check the non-updateable arguments have in fact not been modified
  --
  per_pea_bus.check_non_updateable_args(p_rec => p_rec);
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate id flex num
  --
  chk_id_flex_num(p_id_flex_num             => p_rec.id_flex_num);
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Validate analysis criteria id
  --
  chk_analysis_criteria_id
  (p_analysis_criteria_id    => p_rec.analysis_criteria_id,
   p_id_flex_num             => p_rec.id_flex_num,
   p_person_analysis_id	     => p_rec.person_analysis_id,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  hr_utility.set_location(l_proc, 9);
  --
  --
  -- Validate date
  --
  chk_date_from_to
  (p_person_analysis_id	     => p_rec.person_analysis_id,
   p_date_from		     => p_rec.date_from,
   p_date_to		     => p_rec.date_to,
   p_object_version_number   => p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Check For Duplicates
  --
  check_for_duplicates
     (p_bg_id                => p_rec.business_group_id
     ,p_id_flex_num          => p_rec.id_flex_num
     ,p_analysis_criteria_id => p_rec.analysis_criteria_id
     ,p_date_from            => p_rec.date_from
     ,p_date_to              => p_rec.date_to
     ,p_person_id            => p_rec.person_id
     ,p_person_analysis_id   => p_rec.person_analysis_id
     );
  --
  --
  hr_utility.set_location(l_proc, 11);
  --
  ----
  -- Validate flex fields.
  --
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location('Leaving:'||l_proc, 12);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_pea_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Validate flex fields.
  --
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
  (p_person_analysis_id     in per_person_analyses.person_analysis_id%TYPE
  ) return varchar2 is
--
-- Curson to find legislation code.
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups  pbg,
                 per_person_analyses  ppa
          where  ppa.person_analysis_id = p_person_analysis_id
            and  pbg.business_group_id  = ppa.business_group_id;
--
-- Declare local variables
--
   l_proc              varchar2(72) := 'return_legislation_code';
   l_legislation_code  varchar2(150);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'person_analysis_id',
                              p_argument_value => p_person_analysis_id );
  if nvl(g_person_analysis_id, hr_api.g_number) = p_person_analysis_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
   open csr_leg_code;
   fetch csr_leg_code into l_legislation_code;
   if csr_leg_code%notfound then
     --
     -- The primary key is invalid therefore we must error
     --
     close csr_leg_code;
     --
     fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function
  --
  close csr_leg_code;
  g_person_analysis_id := p_person_analysis_id;
  g_legislation_code   := l_legislation_code;
end if;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  return l_legislation_code;
  --
end return_legislation_code;
--
end per_pea_bus;

/
