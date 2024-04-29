--------------------------------------------------------
--  DDL for Package Body PER_RSC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RSC_BUS" as
/* $Header: perscrhi.pkb 120.0 2005/05/31 19:45:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_rsc_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_rating_scale_id number default null;
g_legislation_code varchar2(150) default null;
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_non_updateable_args(p_rec in per_rsc_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_rsc_shd.api_updating
                (p_rating_scale_id          => p_rec.rating_scale_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_rsc_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  if p_rec.rating_scale_id <> per_rsc_shd.g_old_rec.rating_scale_id then
     l_argument := 'rating_scale_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 9);
  --
if p_rec.type <> per_rsc_shd.g_old_rec.type then
     l_argument := 'type';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 10);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end check_non_updateable_args;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------<not_used_chk_name>-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description
--  - Validates that NAME exists
--  - Validates that NAME is UNIQUE for the BUSINESS_GROUP
--
-- Pre-conditions
--  - A valid BUSINESS_GROUP_ID
--
--
-- In Arguments:
--   p_rating_scale_id
--   p_business_group_id
--   p_name
--   p_object_version_number
--
-- Post Success:
--   Process continues if:
--   All the in parameters are valid.
--
-- Post Failure:
--   An application error is raised and processing is terminated if any of
--   the folowing cases are found:
--     - The NAME does not exist.
--     - The NAME is not UNIQUE for the BUSINESS_GROUP
--
-- Access Status
--   Internal Table Handler Use Only.
--
--

procedure not_used_chk_name
   (p_rating_scale_id        in   per_rating_scales.rating_scale_id%TYPE
   ,p_business_group_id      in   per_rating_scales.business_group_id%TYPE
   ,p_name                   in   per_rating_scales.name%TYPE
   ,p_object_version_number  in   per_rating_scales.object_version_number%TYPE
   )
   is
--
   l_exists             per_rating_scales.business_group_id%TYPE;
   l_api_updating       boolean;
   l_proc               varchar2(72) := g_package||'not_used_chk_name';
   l_business_group_id  number(15);
--
--
-- Cursor to check name is unique within business group
-- ngundura changes done for pa requirements.
cursor csr_name_exists is
  select business_group_id
  from per_rating_scales
  where (   (p_rating_scale_id is null)
           or(rating_scale_id <> p_rating_scale_id)
         )
  and name = p_name
  and p_business_group_id is null
  UNION
  select business_group_id
  from   per_rating_scales
  where	 (  (p_rating_scale_id is null)
	  or(rating_scale_id <> p_rating_scale_id)
         )
  and    name = p_name
  and    (business_group_id = p_business_group_id or
	  business_group_id is null)
  and    p_business_group_id is not null;
--  ngundura end of changes
--
begin
  hr_utility.set_location ('Entering:'|| l_proc, 1);
  --
  --
  if p_name is null then
     hr_utility.set_message(801, 'HR_51571_RSC_NAME_MANDATORY');
     hr_utility.raise_error;
  end if;
  --
  -- ngundura changes as per the pa requirements.
/*  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'business_group_id'
     ,p_argument_value => p_business_group_id
     );
*/
  -- ngundura end of changes.
  --
  -- Only proceed with validation if:
  -- a) The current g_old_rec is current and
  -- b) The value for name has changed.
  --
  l_api_updating := per_rsc_shd.api_updating
        (p_rating_scale_id        => p_rating_scale_id
        ,p_object_version_number  => p_object_version_number
        );
  --
  hr_utility.set_location (l_proc, 3);
  --
  if (l_api_updating AND
     nvl(per_rsc_shd.g_old_rec.name, hr_api.g_varchar2)
     <> nvl(p_name, hr_api.g_varchar2)
  or not l_api_updating)
  then
  --
  hr_utility.set_location (l_proc, 4);
  --
  -- Check that NAME is UNIQUE
  --
  open csr_name_exists;
  hr_utility.set_location (l_proc, 100);
  fetch csr_name_exists into l_exists;
  if csr_name_exists%found then
     hr_utility.set_location(l_proc, 10);
     close csr_name_exists;
     hr_utility.set_location(to_char(l_exists), 99);
     if l_exists is null then
	fnd_message.set_name('PER', 'HR_52696_RSC_NAME_IN_GLOB');
	fnd_message.raise_error;
     else
        fnd_message.set_name('PER', 'HR_52697_RSC_NAME_IN_BUSGRP');
        fnd_message.raise_error;
     end if;
  end if;
  close csr_name_exists;
  end if;
  --
  hr_utility.set_location ('Leaving '||l_proc, 20);
end not_used_chk_name;
--
--
-------------------------------------------------------------------------------
-------------------------check_type--------------------------------------------
-------------------------------------------------------------------------------
--
-- Description
-- This function validates that:
-- if type is not null, it must have a value of 'PROFIECIENCY', 'WEIGHTING' or
-- 'PERFORMANCE'.
--
-- In Arguments
--  p_rating_level_id
--  p_type
--  p_effective_date
--  p_object_version_number
--
-- Post Success
--  Process continues if:
--  The value of type is 'PROFIECIENCY', 'WEIGHTING' or 'PERFORMANCE'
--
-- Post Failure
--  An application error is raised and processing is terminated if any of
--  the following cases are found:
--  - Type does not have a value of 'PROFIECIENCY', 'WEIGHTING' or 'PERFORMANCE'
--
-- Access status
--  Internal Table Handler Use Only
--
procedure chk_type
  (p_rating_scale_id       in per_rating_scales.rating_scale_id%TYPE
  ,p_type                  in per_rating_scales.type%TYPE
  ,p_effective_date        in date
  ,p_object_version_number in per_rating_scales.object_version_number%TYPE
  ) is
--
  l_proc          varchar2(72) := g_package||'chk_not_applicable_flag';
  l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  -- Check mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => p_effective_date
     );
  --
  -- Only proceed with the validation if:
  -- a) The current g_old_rec is current
  -- b) The not_applicable value has changed.
  -- c) A record is being inserted.
  --
  l_api_updating := per_rsc_shd.api_updating
     (p_rating_scale_id             => p_rating_scale_id
     ,p_object_version_number       => p_object_version_number
     );
  --
  if ((l_api_updating and nvl(per_rsc_shd.g_old_rec.type,
                              hr_api.g_varchar2)
    <> nvl(p_type, hr_api.g_varchar2)) or
    (NOT l_api_updating)) then
  --
  hr_utility.set_location(l_proc, 2);
  --
  -- If type is not null then
  -- Check if the type value exists in hr_lookups
  -- where lookup_type is 'RATING_SCALE_TYPE'
  --
    if p_type is not null then
       if hr_api.not_exists_in_hr_lookups
         (p_effective_date      => p_effective_date
         ,p_lookup_type         => 'RATING_SCALE_TYPE'
         ,p_lookup_code         => p_type
         ) then
        hr_utility.set_message(801,'HR_51444_RSC_INVALID_TYPE');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 3);
    end if;
  end if;
  hr_utility.set_location('Leaving '||l_proc, 4);
end chk_type;
--
--
--
-------------------------------------------------------------------------------
-------------------------check_default_flag------------------------------------
-------------------------------------------------------------------------------
--
-- Description
-- This function validates that:
-- if default_flag is not null, it must have a value of 'Y' or 'N'
-- There is at most only one Default Flag value of 'Y' for each Type within
-- a business group.
--
-- In Arguments
--  p_rating_level_id
--  p_default_flag
--  p_effective_date
--  p_object_version_number
--
-- Post Success
--  Process continues if:
--  The value of default_flag is 'Y' or 'N'
--  There is at most only one Default Flag value of 'Y' for each Type within
--  a Business Group
--
-- Post Failure
--  An application error is raised and processing is terminated if any of
--  the following cases are found:
--  - default_flag does not have a value of 'Y' or 'N'
--  - there is more then one Default Flag value of 'Y' for a Type within
--    a Business Group.
--
-- Access status
--  Internal Table Handler Use Only
--
procedure chk_default_flag
  (p_rating_scale_id       in per_rating_scales.rating_scale_id%TYPE
  ,p_business_group_id     in per_rating_scales.business_group_id%TYPE default null
  ,p_type                  in per_rating_scales.type%TYPE
  ,p_default_flag          in per_rating_scales.default_flag%TYPE
  ,p_effective_date        in date
  ,p_object_version_number in per_rating_scales.object_version_number%TYPE
  ) is
--
  l_proc          varchar2(72) := g_package||'chk_default_flag';
  l_api_updating  boolean;
  l_exists        varchar2(1);
--
-- Define a cursor to get a default flag with a value of 'Y' for a specific
-- Business Group
-- ngundura changes done for pa requirements..
  cursor csr_get_default_flag is
  select null
  from per_rating_scales
  where (   (p_rating_scale_id is null)
          or(rating_scale_id <> p_rating_scale_id)
         )
  and default_flag = 'Y'
  and type = p_type
  and business_group_id is null
  and p_business_group_id is null
  UNION
  select null
  from   per_rating_scales
  where  (  (p_rating_scale_id is null)
	  or(rating_scale_id <> p_rating_scale_id)
         )
  and    business_group_id = p_business_group_id
  and    default_flag = 'Y'
  and    type = p_type
  and    p_business_group_id is not null;
--  ngundura end of changes
begin
  hr_utility.set_location('Entering: '||l_proc, 1);
  --
  -- Check mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'effective_date'
     ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with the validation if:
  -- a) The current g_old_rec is current
  -- b) The default flag has changed.
  -- c) A record is being inserted.
  --
  l_api_updating := per_rsc_shd.api_updating
     (p_rating_scale_id             => p_rating_scale_id
     ,p_object_version_number       => p_object_version_number
     );
  --
  if ((l_api_updating and nvl(per_rsc_shd.g_old_rec.default_flag,
                              hr_api.g_varchar2)
                       <> nvl(p_default_flag, hr_api.g_varchar2))
  or
     (NOT l_api_updating)) then
  --
  hr_utility.set_location(l_proc, 2);
  --
  --
  -- If default_flag is not null then
  -- Check if the default_flag value exists in hr_lookups
  -- where lookup_type is 'YES_NO'
  --
  if p_default_flag is not null then
    if hr_api.not_exists_in_hr_lookups
         (p_effective_date      => p_effective_date
         ,p_lookup_type         => 'YES_NO'
         ,p_lookup_code         => p_default_flag
         )
    then hr_utility.set_message(801,'HR_51450_RSC_INV_DEF_FLAG');
         hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 3);
  end if;
  end if;
  --
  hr_utility.set_location (l_proc, 4);
  --
  if   p_default_flag = 'Y' then
 	open csr_get_default_flag;
        fetch csr_get_default_flag into l_exists;
        if    csr_get_default_flag%found then
          close csr_get_default_flag;
          hr_utility.set_location (l_proc, 5);
          hr_utility.set_message (801, 'HR_51451_RSC_DEFAULT_EXISTS');
          hr_utility.raise_error;
        end if;
        close csr_get_default_flag;
  end if;
--
  hr_utility.set_location('Leaving '||l_proc, 6);
end chk_default_flag;
--
--
--
-------------------------------------------------------------------------------
-- --------------------------chk_rating_scale_delete---------------------------
-------------------------------------------------------------------------------
--
--
-- Description
--   - Checks the rating scale is not referenced by an assessment type as a
--     rating scale id.
--   - Checks the rating scale is not referenced by an assessment type as a
--     wighting scale id.
--   - Checks the rating scale is not referenced by a performance rating.
--   - Checks the rating scale is not referenced by a rating level
--     which is referenced by a competence element as a rating level id.
--   - Checks the rating scale is not referenced by a rating level
--     which is referenced by a competence element as a weighting level id
--
-- Pre-conditions:
--
--
-- In Arguments:
--   p_rating_scale_id
--   p_object_version_number
--
-- Post Success:
--   Process continues if:
--   The rating scale is not referenced anywhere.
--
-- Post Failure:
--    An Application error is raised and processing is terminated if any of
--    the following cases are found:
--      - The rating scale is referenced by an assessment,
--                                           a performance rating,
--                                           a rating scale step which is
--                                           referenced by a competence element
--
--
procedure chk_rating_scale_delete
   (p_rating_scale_id         in   per_rating_scales.rating_scale_id%TYPE
   ,p_object_version_number   in   per_rating_scales.object_version_number%TYPE
   ) is
--
   l_proc                varchar2(72) := g_package||' chk_rating_scale_delete';
   l_exists              varchar2(1);
--
-- Define a cursor to check if rating scale  is referenced in
-- assessment types
--
   cursor csr_get_rs_assessment_type is
   select null
   from   per_assessment_types
   where  (  (rating_scale_id    = p_rating_scale_id)
	   or(weighting_scale_id = p_rating_scale_id)
          );
--
/* **** Not implemented yet ******
--
-- Define a cursor to get a performance rating which references a rating scale.
--
   cursor csr_get_performance_rating is
   select null
   from   per_performance_ratings
   where  rating_scale_id = p_rating_scale_id;
   ******************************* */
--
-- Define a cursor to get a competence which is referenced by a rating_scale.
--
   cursor csr_get_competence_rating is
   select null
   from   per_competences
   where  rating_scale_id = p_rating_scale_id;
--
-- Define a cursor to to check id rating scales has any levels that
-- are referenced in competence element
--
   cursor csr_get_rl_rating_level is   --Bug fix 3732129
   select null   from   per_rating_levels rle
   where  rle.rating_scale_id = p_rating_scale_id and
   exists (select /*+ INDEX(pce)*/ null
         from per_competence_elements pce
        where   (rle.rating_level_id= pce.rating_level_id)
         or (rle.rating_level_id = pce.weighting_level_id)  );
--
begin
  hr_utility.set_location('Entering '||l_proc, 1);
  --
  -- Check a rating scale is not referenced by an assessment type
  --
     open csr_get_rs_assessment_type;
     fetch csr_get_rs_assessment_type into l_exists;
     if    csr_get_rs_assessment_type%found
     then  close csr_get_rs_assessment_type;
           hr_utility.set_location (l_proc, 2);
           hr_utility.set_message (801, 'HR_51573_RSC_RSC_IN_AST');
           hr_utility.raise_error;
     end if;
     close csr_get_rs_assessment_type;
  --
 /*  *** Not impelemented yet **************
  --
  -- Check a rating scale is not referenced by a performance rating.
  --
     open csr_get_performance_rating;
     fetch csr_get_performance_rating into l_exists;
     if    csr_get_performance_rating%found
     then  close csr_get_performance_rating;
           hr_utility.set_location (l_proc, 3);
           hr_utility.set_message (801, 'HR_<<create new message>>');
           hr_utility.raise_error;
     end if;
     close csr_get_performance_rating;
  **************************************** */
  --
  -- Check a rating scale is not referenced by a competence.
  --
     open csr_get_competence_rating;
     fetch csr_get_competence_rating into l_exists;
     if    csr_get_competence_rating%found
     then  close csr_get_competence_rating;
           hr_utility.set_location (l_proc, 4);
           hr_utility.set_message (801, 'HR_51572_RSC_RSC_IN_CPN');
           hr_utility.raise_error;
     end if;
     close csr_get_competence_rating;
  --
  -- Check a rating scale is not referenced by a rating LEVEL which is
  -- referenced by a competence element.
  --
     open csr_get_rl_rating_level;
     fetch csr_get_rl_rating_level into l_exists;
     if    csr_get_rl_rating_level%found
     then  close csr_get_rl_rating_level;
           hr_utility.set_location (l_proc, 4);
           hr_utility.set_message (801, 'HR_51574_RSC_IN_RTL_IN_ELE');
           hr_utility.raise_error;
     end if;
     close csr_get_rl_rating_level;
  --
  hr_utility.set_location ('Leaving '||l_proc, 5);
  --
end chk_rating_scale_delete;
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
  (p_rec in per_rsc_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if (((p_rec.rating_scale_id is not null) and (
    nvl(per_rsc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_rsc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.rating_scale_id is null))
    and hr_rating_scales_api.g_ignore_df <> 'Y' then    -- BUG3621261
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_RATING_SCALES'
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
Procedure insert_validate(p_rec in per_rsc_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in perrsc.bru is provided.
  --
  -- Validate business_group_id
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_BUSINESS_GROUP_ID a
  -- ngundura changes done for pa requirements
  if p_rec.business_group_id is not null then
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  -- ngundura end of changes
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  --
  -- Validate name
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_NAME a,b
  --
  -- pmfletch. Now moved to TL row handler
  --
  -- per_rsc_bus.chk_name
  --   (p_rating_scale_id             => p_rec.rating_scale_id
  --   ,p_business_group_id           => p_rec.business_group_id
  --   ,p_name                        => p_rec.name
  --   ,p_object_version_number       => p_rec.object_version_number
  --   );
  --
  hr_utility.set_location (l_proc, 15);
  --
  -- Validate type
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_TYPE a
  --
  per_rsc_bus.chk_type
    (p_rating_scale_id             => p_rec.rating_scale_id
    ,p_type                        => p_rec.type
    ,p_effective_date              => p_effective_date
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  hr_utility.set_location (l_proc, 20);
  --
  -- Validate default flag
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_DEFAULT_FLAG
  --
  per_rsc_bus.chk_default_flag
    (p_rating_scale_id             => p_rec.rating_scale_id
    ,p_business_group_id           => p_rec.business_group_id
    ,p_type                        => p_rec.type
    ,p_default_flag                => p_rec.default_flag
    ,p_effective_date              => p_effective_date
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- call descriptive flexfield validation routines
  --
  per_rsc_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location (l_proc, 25);
  --
  hr_utility.set_location ('Leaving '||l_proc, 30);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_rsc_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations. Mapping to the
  -- appropriate Business Rules in perrsc.bru is provided.
  --
  --
  -- Check those columns which cannot be updated have not changed.
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_BUSINESS_GROUP_ID b
  -- ngundura changes as per pa changes
  if p_rec.business_group_id is not null then
       hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  -- CHK_TYPE b
  --
  per_rsc_bus.check_non_updateable_args
    (p_rec          => p_rec);
  --
  hr_utility.set_location (l_proc, 10);
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_NAME a,b
  --
  -- pmfletch. Now moved to TL row handler
  --
  -- per_rsc_bus.chk_name
  --   (p_rating_scale_id             => p_rec.rating_scale_id
  --   ,p_business_group_id           => p_rec.business_group_id
  --   ,p_name                        => p_rec.name
  --   ,p_object_version_number       => p_rec.object_version_number
  --   );
  --
 -- Validate default flag
  --
  -- Business Rule Mapping
  -- =====================
  -- Rule CHK_DEFAULT_FLAG
  --
  per_rsc_bus.chk_default_flag
    (p_rating_scale_id             => p_rec.rating_scale_id
    ,p_business_group_id           => p_rec.business_group_id
    ,p_type                        => p_rec.type
    ,p_default_flag                => p_rec.default_flag
    ,p_effective_date              => p_effective_date
    ,p_object_version_number       => p_rec.object_version_number
    );
  --
  -- call descriptive flexfield validation routines
  --
  -- call descriptive flexfield validation routines
  --
  per_rsc_bus.chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location (l_proc, 15);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_rsc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate delete
  --
  -- Business Rule Mapping
  -- =====================
  --
  -- Rule CHK_RATING_SCALE_DELETE a,b,c
  --
  per_rsc_bus.chk_rating_scale_delete
     (p_rating_scale_id              => p_rec.rating_scale_id
     ,p_object_version_number        => p_rec.object_version_number
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code
         (  p_rating_scale_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups pbg,
                 per_rating_scales   prs
          where  prs.rating_scale_id   = p_rating_scale_id
            and  pbg.business_group_id = prs.business_group_id;

   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
   l_business_group_flag varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'rating_scale_id',
                              p_argument_value => p_rating_scale_id );
  -- ngundura changes done for pa requirements...
    select 'Y' into l_business_group_flag
    from per_rating_scales
    where rating_scale_id = p_rating_scale_id
    and   business_group_id is null;
    if l_business_group_flag = 'Y' then
        return null;
    end if;
 -- ngundura end of changes
    if nvl(g_rating_scale_id, hr_api.g_number) = p_rating_scale_id then
    --
    -- The legislation has already been found with a previous
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
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
    g_rating_scale_id:= p_rating_scale_id;
    g_legislation_code := l_legislation_code;
  end if;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;
--
--
end per_rsc_bus;

/
