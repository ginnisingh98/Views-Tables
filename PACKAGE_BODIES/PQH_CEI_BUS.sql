--------------------------------------------------------
--  DDL for Package Body PQH_CEI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CEI_BUS" as
/* $Header: pqceirhi.pkb 115.6 2002/12/05 19:31:08 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cei_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_corps_extra_info_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_grades_dup >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_grades_dup
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
  --
  -- Declare cursor
  --
  cursor csr_cpd_grade is
    select 'X'
      from pqh_corps_extra_info
     where information_type ='GRADE'
     and corps_definition_id = p_rec.corps_definition_id
     and information3 = p_rec.information3;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'chk_corps_grades_dup';
  l_grade             varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  --
  open csr_cpd_grade;
  fetch csr_cpd_grade into l_grade;
  --
  if csr_cpd_grade%found then
     close csr_cpd_grade;
     hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_GRADE');
     hr_utility.raise_error;
  else
    close csr_cpd_grade;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_corps_grades_dup;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_org >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_org
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
  --
  -- Declare cursor
  --
  cursor csr_cpd_org is
    select 'X'
      from pqh_corps_extra_info
     where information_type ='ORGANIZATION'
     and corps_definition_id = p_rec.corps_definition_id
     and information3 = p_rec.information3;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'chk_corps_org';
  l_org               varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  --
  open csr_cpd_org;
  fetch csr_cpd_org into l_org;
  --
  if csr_cpd_org%found then
     close csr_cpd_org;
     hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_ORG');
     hr_utility.raise_error;
  else
    close csr_cpd_org;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_corps_org;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_grades >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_grades
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
  l_proc              varchar2(72)  :=  g_package||'chk_corps_grades';
  l_sum_quota         number;
  l_grade_quota       number;
  l_information4      number;
  l_information5      number;
  l_information6      number;
  l_information7      number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_rec.information_type ='GRADE' then
     --
     l_information4 := to_number(p_rec.information4);
     l_information5 := to_number(p_rec.information5);
     l_information6 := to_number(p_rec.information6);
     l_information7 := to_number(p_rec.information7);
     --
     if l_information4 not between 0 and 100 then
        hr_utility.set_message(8302, 'PQH_CORPS_GRADE_QUOTA');
        hr_utility.raise_error;
     end if;
     if l_information5 not between 0 and 100 then
        hr_utility.set_message(8302, 'PQH_CORPS_MIN_QUOTA');
        hr_utility.raise_error;
     end if;
     if l_information6 not between 0 and 100 then
        hr_utility.set_message(8302, 'PQH_CORPS_AVG_QUOTA');
        hr_utility.raise_error;
     end if;
     if l_information7 not between 0 and 100 then
        hr_utility.set_message(8302, 'PQH_CORPS_MAX_QUOTA');
        hr_utility.raise_error;
     end if;
     l_sum_quota := nvl(l_information5,0)+nvl(l_information6,0)+nvl(l_information7,0);
     if l_sum_quota > 100 then
        hr_utility.set_message(8302, 'PQH_CORPS_TOTAL_QUOTA');
        hr_utility.raise_error;
     end if;
     select sum(information4)
     into l_grade_quota
     from pqh_corps_extra_info
     where corps_definition_id = p_rec.corps_definition_id
     and information_type ='GRADE'
     and corps_extra_info_id <> nvl(p_rec.corps_extra_info_id,corps_extra_info_id);
     if l_grade_quota + l_information4 > 100 then
        hr_utility.set_message(8302, 'PQH_CORPS_OCCU_QUOTA');
        hr_utility.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_corps_grades;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_training >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_training
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
  --
  -- Declare cursor
  --
  cursor csr_cpd_training is
    select 'X'
      from pqh_corps_extra_info
     where information_type ='TRAINING'
     and corps_definition_id = p_rec.corps_definition_id
     and corps_extra_info_id <> nvl(p_rec.corps_extra_info_id,-1)
     and information3 = p_rec.information3
     and information4 = p_rec.information4
     and information5 = p_rec.information5
     and information6 = p_rec.information6
     and information7 = p_rec.information7;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'chk_corps_training';
  l_training             varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  --
  open csr_cpd_training;
  fetch csr_cpd_training into l_training;
  --
  if csr_cpd_training%found then
     close csr_cpd_training;
     hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_TRAINING');
     hr_utility.raise_error;
  else
    close csr_cpd_training;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_corps_training;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_exam >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_exam
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
  --
  -- Declare cursor
  --
  cursor csr_cpd_exam is
    select 'X'
      from pqh_corps_extra_info
     where information_type ='EXAM'
     and corps_definition_id = p_rec.corps_definition_id
     and corps_extra_info_id <> nvl(p_rec.corps_extra_info_id,-1)
     and information3 = p_rec.information3
     and information4 = p_rec.information4
     and information5 = p_rec.information5
     and information6 = p_rec.information6;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'chk_corps_exam';
  l_exam              varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  --
  open csr_cpd_exam;
  fetch csr_cpd_exam into l_exam;
  --
  if csr_cpd_exam%found then
     close csr_cpd_exam;
     hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_EXAM');
     hr_utility.raise_error;
  else
    close csr_cpd_exam;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_corps_exam;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_rules >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_rules
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
  --
  -- Declare cursor
  --
  cursor csr_cpd_rules is
    select 'X'
      from pqh_corps_extra_info
     where information_type ='RULES'
     and corps_definition_id = p_rec.corps_definition_id
     and corps_extra_info_id <> nvl(p_rec.corps_extra_info_id,-1)
     and information3 = p_rec.information3
     and information4 = p_rec.information4
     and information5 = p_rec.information5
     and information6 = p_rec.information6
     and information7 = p_rec.information7;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'chk_corps_rules';
  l_rules              varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  --
  open csr_cpd_rules;
  fetch csr_cpd_rules into l_rules;
  --
  if csr_cpd_rules%found then
     close csr_cpd_rules;
     hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_RULES');
     hr_utility.raise_error;
  else
    close csr_cpd_rules;
  end if;
  if p_rec.information_type ='RULES' then
     if p_rec.information4 ='DIPLOMA' then
        null;
     elsif p_rec.information4 ='MAX_AGE' then
        if p_rec.information5 is null then
           hr_utility.set_message(8302, 'PQH_CORPS_MAX_AGE_NULL');
           hr_utility.raise_error;
        end if;
        if p_rec.information5 not between 0 and 80 then
           hr_utility.set_message(8302, 'PQH_CORPS_JOINING_MAX_AGE');
           hr_utility.raise_error;
        end if;
        if nvl(p_rec.information6,'Y') <> 'Y' then
           hr_utility.set_message(8302, 'PQH_CORPS_MAX_AGE_YEARS');
           hr_utility.raise_error;
        end if;
     elsif p_rec.information4 ='MIN_AGE' then
        if p_rec.information5 is null then
           hr_utility.set_message(8302, 'PQH_CORPS_MIN_AGE_NULL');
           hr_utility.raise_error;
        end if;
        if p_rec.information5 not between 0 and 80 then
           hr_utility.set_message(8302, 'PQH_CORPS_JOINING_MIN_AGE');
           hr_utility.raise_error;
        end if;
        if nvl(p_rec.information6,'Y') <> 'Y' then
           hr_utility.set_message(8302, 'PQH_CORPS_MIN_AGE_YEARS');
           hr_utility.raise_error;
        end if;
     elsif p_rec.information4 ='NATIONAL' then
        null;
     elsif p_rec.information4 ='PROB_PERIOD' then
        if p_rec.information6 is null then
           hr_utility.set_message(8302, 'PQH_CORPS_PROB_PRD_UOM_NULL');
           hr_utility.raise_error;
        end if;
     elsif p_rec.information4 ='SERVICE_LEN' then
        null;
     elsif p_rec.information4 ='START_STEP' then
        null;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_corps_rules;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_doc >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_doc
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
  --
  -- Declare cursor
  --
  cursor csr_cpd_doc is
    select 'X'
      from pqh_corps_extra_info
     where information_type ='DOCUMENT'
     and corps_definition_id = p_rec.corps_definition_id
     and corps_extra_info_id <> nvl(p_rec.corps_extra_info_id, -1)
     and information3 = p_rec.information3
     and information4 = p_rec.information4
     and information5 = p_rec.information5
     and information6 = p_rec.information6;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72)  :=  g_package||'chk_corps_doc';
  l_doc              varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  --
  open csr_cpd_doc;
  fetch csr_cpd_doc into l_doc;
  --
  if csr_cpd_doc%found then
     close csr_cpd_doc;
     hr_utility.set_message(8302, 'PQH_DUPLICATE_CORPS_DOC');
     hr_utility.raise_error;
  else
    close csr_cpd_doc;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end chk_corps_doc;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_corps_extra_info_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_corps_extra_info and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_corps_extra_info cei
      --   , EDIT_HERE table_name(s) 333
     where cei.corps_extra_info_id = p_corps_extra_info_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'corps_extra_info_id'
    ,p_argument_value     => p_corps_extra_info_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'CORPS_EXTRA_INFO_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_corps_extra_info_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- pqh_corps_extra_info and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pqh_corps_extra_info cei
      --   , EDIT_HERE table_name(s) 333
     where cei.corps_extra_info_id = p_corps_extra_info_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'corps_extra_info_id'
    ,p_argument_value     => p_corps_extra_info_id
    );
  --
  if ( nvl(pqh_cei_bus.g_corps_extra_info_id, hr_api.g_number)
       = p_corps_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_cei_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_cei_bus.g_corps_extra_info_id         := p_corps_extra_info_id;
    pqh_cei_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.corps_extra_info_id is not null)  and (
    nvl(pqh_cei_shd.g_old_rec.information_type, hr_api.g_varchar2) <>
    nvl(p_rec.information_type, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2) ))
    or (p_rec.corps_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
/*
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQH'
      ,p_descflex_name                   => 'Further Corps Extra Information'
      ,p_attribute1_name                 => 'INFORMATION_TYPE'
      ,p_attribute1_value                => p_rec.information_type
      ,p_attribute2_name                 => 'INFORMATION1'
      ,p_attribute2_value                => p_rec.information1
      ,p_attribute3_name                 => 'INFORMATION2'
      ,p_attribute3_value                => p_rec.information2
      ,p_attribute4_name                 => 'INFORMATION3'
      ,p_attribute4_value                => p_rec.information3
      ,p_attribute5_name                 => 'INFORMATION4'
      ,p_attribute5_value                => p_rec.information4
      ,p_attribute6_name                 => 'INFORMATION5'
      ,p_attribute6_value                => p_rec.information5
      ,p_attribute7_name                 => 'INFORMATION6'
      ,p_attribute7_value                => p_rec.information6
      ,p_attribute8_name                 => 'INFORMATION7'
      ,p_attribute8_value                => p_rec.information7
      ,p_attribute9_name                 => 'INFORMATION8'
      ,p_attribute9_value                => p_rec.information8
      ,p_attribute10_name                => 'INFORMATION9'
      ,p_attribute10_value               => p_rec.information9
      ,p_attribute11_name                => 'INFORMATION10'
      ,p_attribute11_value               => p_rec.information10
      ,p_attribute12_name                => 'INFORMATION11'
      ,p_attribute12_value               => p_rec.information11
      ,p_attribute13_name                => 'INFORMATION12'
      ,p_attribute13_value               => p_rec.information12
      ,p_attribute14_name                => 'INFORMATION13'
      ,p_attribute14_value               => p_rec.information13
      ,p_attribute15_name                => 'INFORMATION14'
      ,p_attribute15_value               => p_rec.information14
      ,p_attribute16_name                => 'INFORMATION15'
      ,p_attribute16_value               => p_rec.information15
      ,p_attribute17_name                => 'INFORMATION16'
      ,p_attribute17_value               => p_rec.information16
      ,p_attribute18_name                => 'INFORMATION17'
      ,p_attribute18_value               => p_rec.information17
      ,p_attribute19_name                => 'INFORMATION18'
      ,p_attribute19_value               => p_rec.information18
      ,p_attribute20_name                => 'INFORMATION19'
      ,p_attribute20_value               => p_rec.information19
      ,p_attribute21_name                => 'INFORMATION20'
      ,p_attribute21_value               => p_rec.information20
      ,p_attribute22_name                => 'INFORMATION21'
      ,p_attribute22_value               => p_rec.information21
      ,p_attribute23_name                => 'INFORMATION22'
      ,p_attribute23_value               => p_rec.information22
      ,p_attribute24_name                => 'INFORMATION23'
      ,p_attribute24_value               => p_rec.information23
      ,p_attribute25_name                => 'INFORMATION24'
      ,p_attribute25_value               => p_rec.information24
      ,p_attribute26_name                => 'INFORMATION25'
      ,p_attribute26_value               => p_rec.information25
      ,p_attribute27_name                => 'INFORMATION26'
      ,p_attribute27_value               => p_rec.information26
      ,p_attribute28_name                => 'INFORMATION27'
      ,p_attribute28_value               => p_rec.information27
      ,p_attribute29_name                => 'INFORMATION28'
      ,p_attribute29_value               => p_rec.information28
      ,p_attribute30_name                => 'INFORMATION29'
      ,p_attribute30_value               => p_rec.information29
      ,p_attribute31_name                => 'INFORMATION30'
      ,p_attribute31_value               => p_rec.information30
      ,p_attribute_category              => 'INFORMATION_CATEGORY'
      );
*/
null;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
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
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in pqh_cei_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.corps_extra_info_id is not null)  and (
    nvl(pqh_cei_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2)  or
    nvl(pqh_cei_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) ))
    or (p_rec.corps_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
/*
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQH'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
      ,p_attribute_category              => 'ATTRIBUTE_CATEGORY'
      );
*/
null;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in pqh_cei_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_cei_shd.api_updating
      (p_corps_extra_info_id               => p_rec.corps_extra_info_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  chk_corps_org(p_rec) ;
  --
  chk_corps_grades_dup(p_rec) ;
  --
  chk_corps_grades(p_rec) ;
  --
  chk_corps_rules(p_rec) ;
  --
  chk_corps_training(p_rec) ;
  --
  chk_corps_exam(p_rec) ;
  --
  chk_corps_doc(p_rec) ;
  --
  -- pqh_cei_bus.chk_ddf(p_rec);
  --
  -- pqh_cei_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  chk_corps_org (p_rec) ;
  --
  chk_corps_grades (p_rec) ;
  --
  chk_corps_rules(p_rec) ;
  --
  chk_corps_training(p_rec) ;
  --
  chk_corps_exam(p_rec) ;
  --
  chk_corps_doc(p_rec) ;
  --
  -- pqh_cei_bus.chk_ddf(p_rec);
  --
  -- pqh_cei_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_cei_bus;

/
