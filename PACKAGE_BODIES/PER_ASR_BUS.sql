--------------------------------------------------------
--  DDL for Package Body PER_ASR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASR_BUS" as
/* $Header: peasrrhi.pkb 115.5 99/10/05 09:44:16 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_asr_bus.';  -- Global package name
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code         varchar2(150) default null;
g_assessment_group_id      number        default null;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
--
--  In the ASSESSMENT_GROUP entity, there is only one non updatable argument :
--      business_group_id
--
Procedure chk_non_updateable_args(p_rec in per_asr_shd.g_rec_type) is
--
  l_proc        varchar2(72) := g_package||'chk_non_updateable_args';
  l_error       exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema.
  if not per_asr_shd.api_updating
  --
   (p_assessment_group_id             => p_rec.assessment_group_id
   ,p_object_version_number     => p_rec.object_version_number
   ) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location (l_proc, 6);
  --
  if p_rec.business_group_id <> per_asn_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
    --
  hr_utility.set_location(' Leaving : '|| l_proc, 10);
--
end chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_name_unique >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   This checks to make sure the name is unique within the business group.
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   p_name
--   p_assessment_group_id
--   p_business_group_id
--   p_object_version_number
--
-- POST SUCCESS
--   Processing continues
--
-- POST FAILURE
--   Processing halts and an error is displayed.
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_name_unique
  (p_name 		 in per_assessment_groups.name%TYPE
  ,p_assessment_group_id in per_assessment_groups.assessment_group_id%TYPE
  ,p_business_group_id	 in per_assessment_groups.business_group_id%TYPE
  ,p_object_version_number in per_assessment_groups.object_version_number%TYPE
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_name_unique';
--
--  Define cusror for duplicate name check
--
  cursor csr_chk_name_unique is
    select null
    from per_assessment_groups ag
    where ((p_assessment_group_id is NULL) -- if the row is being inserted
      or   (p_assessment_group_id <> ag.assessment_group_id))
    and   p_name = ag.name  -- there is a duplicate name
    and   p_business_group_id = ag.business_group_id +0 ;
--
   l_exists		varchar2(1);
   l_api_updating 	boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the business_group_id is not null.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
  -- Only proceed with validation if:
  --   a) The current g_old_rec is current and
  --   b) The value for name has changed.
  --   c) The value is being inserted.
  --
  l_api_updating := per_asr_shd.api_updating
        (p_assessment_group_id        => p_assessment_group_id
        ,p_object_version_number  => p_object_version_number
        );
  --
  hr_utility.set_location (l_proc, 2);
  --
  if (l_api_updating AND
     nvl(per_asr_shd.g_old_rec.name, hr_api.g_varchar2)
     <> nvl(p_name, hr_api.g_varchar2)
     or not l_api_updating)
  then
  --
    hr_utility.set_location (l_proc, 3);
    --
    -- Check that the name isn't NULL
    --
    if p_name is NULL then
      hr_utility.set_message(801,'HR_51595_ASR_NAME_NULL');
      hr_utility.raise_error;
    end if;
    --
    -- Check that the name is unique within the business group.
    --
    hr_utility.set_location('Cursor open;name:'||l_proc, 5);
    open csr_chk_name_unique;
    fetch csr_chk_name_unique into l_exists;
    if csr_chk_name_unique%found then
      hr_utility.set_location('name not unique:'||l_proc, 5);
      -- The name already exists in the business group
      close csr_chk_name_unique;
      per_asr_shd.constraint_error
        (p_constraint_name => 'PER_ASSESSMENT_GROUPS_NAME_UK1');
    end if;
    close csr_chk_name_unique;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
end chk_name_unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_REF_ROWS_ASN >---------------------------|
-- ----------------------------------------------------------------------------
--
-- DESCRIPTION
--   Before an assessment group can be removed, a check is carried out to make
--   sure that no rows reference it in per_assessments.
--   If they do, an error is raised.
--
-- PRE-REQUISITES
--
-- IN PARAMETERS
--   p_assessment_group_id
--
-- POST SUCCESS
--  Processing continues
-- POST FAILURE
--   Processing halts.
--
-- ACCESS STATUS
--  Internal Development Use Only
--
Procedure chk_ref_rows_asn
  (p_assessment_group_id 	in per_assessment_groups.assessment_group_id%TYPE
  ) is
--
  l_proc        varchar2(72):=g_package||'chk_ref_rows_asn';
--
  cursor csr_chk_ref_rows_asn is
    select null
    from per_assessments asn
    where p_assessment_group_id =  asn.assessment_group_id;
--
  l_exists 	varchar2(1);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check that the assessment group is not referenced by an assessment
  --
  open csr_chk_ref_rows_asn;
  fetch csr_chk_ref_rows_asn into l_exists;
  --
  if csr_chk_ref_rows_asn%found then
    close csr_chk_ref_rows_asn;
    --
    hr_utility.set_location(l_proc,5);
    hr_utility.set_message (801, 'HR_51597_ASR_REF_BY_ASS');
    hr_utility.raise_error;
    --
  end if;
  close csr_chk_ref_rows_asn;
  --
end chk_ref_rows_asn;
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
  (p_rec in per_asr_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.assessment_group_id is not null) and (
    nvl(per_asr_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_asr_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.assessment_group_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_ASSESSMENT_GROUPS'
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
--
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec in per_asr_shd.g_rec_type
  ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- VALIDATE CHK_NAME_UNIQUE
  --   Business Rule Mapping
  --   ---------------------
  --   Rule CHK_NAME_UNIQUE a. b.
  --
  per_asr_bus.chk_name_unique
    (p_name    		    => p_rec.name
    ,p_assessment_group_id  => p_rec.assessment_group_id
    ,p_business_group_id    => p_rec.business_group_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- Call descriptive flexfield validation routines
  --
  per_asr_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec in per_asr_shd.g_rec_type
  ,p_effective_date  in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping is provided
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- VALIDATE CHK_NON_UPDATABLE_ARGS
  --     Check those columns which cannot be updated have not changed.
  --   Business Rule Mapping
  --   =====================
  --   Rule CHK_BUSINESS_GROUP_ID a
  --
  per_asr_bus.chk_non_updateable_args
    (p_rec      =>  p_rec);
  --
  -- VALIDATE CHK_NAME_UNIQUE
  --   Business Rule Mapping
  --   ---------------------
  --   Rule CHK_NAME_UNIQUE a. b.
  --
  per_asr_bus.chk_name_unique
    (p_name    		    => p_rec.name
    ,p_assessment_group_id  => p_rec.assessment_group_id
    ,p_business_group_id    => p_rec.business_group_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  -- Call descriptive flexfield validation routines
  --
  per_asr_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_asr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  per_asr_bus.chk_ref_rows_asn
   (p_assessment_group_id   => p_rec.assessment_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_assessment_group_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups    pbg,
                 per_assessment_groups  pag
          where  pag.assessment_group_id  = p_assessment_group_id
            and  pbg.business_group_id    = pag.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'assessment_group_id',
                              p_argument_value => p_assessment_group_id );
    if nvl(g_assessment_group_id, hr_api.g_number) = p_assessment_group_id then
       --
       -- The legislation code has already been found with a previous
       -- call to this function. Just return the value in the global
       -- variable.
       --
       l_legislation_code := g_legislation_code;
       hr_utility.set_location(l_proc, 10);
    else
       --
       -- The ID is different to the last call to this function
       -- or this is the first call to this function.
     --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  --
    g_assessment_group_id:= p_assessment_group_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
  --
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
End return_legislation_code;
--
--
end per_asr_bus;

/
