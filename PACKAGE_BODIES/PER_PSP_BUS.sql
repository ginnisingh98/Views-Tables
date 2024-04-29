--------------------------------------------------------
--  DDL for Package Body PER_PSP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSP_BUS" as
/* $Header: pepsprhi.pkb 115.5 2003/11/17 13:06:07 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_psp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_spinal_point_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_spinal_point_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_spinal_points psp
     where psp.spinal_point_id = p_spinal_point_id
       and pbg.business_group_id = psp.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'spinal_point_id'
    ,p_argument_value     => p_spinal_point_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'SPINAL_POINT_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_spinal_point_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_spinal_points psp
     where psp.spinal_point_id = p_spinal_point_id
       and pbg.business_group_id = psp.business_group_id;
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
    ,p_argument           => 'spinal_point_id'
    ,p_argument_value     => p_spinal_point_id
    );
  --
  if ( nvl(per_psp_bus.g_spinal_point_id, hr_api.g_number)
       = p_spinal_point_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_psp_bus.g_legislation_code;
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
    per_psp_bus.g_spinal_point_id             := p_spinal_point_id;
    per_psp_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_spinal_point_id >------------------------|
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
--   spinal_point_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--   inserted or updated.
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_spinal_point_id
 ( p_spinal_point_id        in  per_spinal_points.spinal_point_id%TYPE
  ,p_object_version_number  in  per_spinal_points.object_version_number%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_spinal_point_id';
  l_api_updating boolean;
  --
Begin
 hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := per_psp_shd.api_updating
    (p_spinal_point_id              => p_spinal_point_id
    ,p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_spinal_point_id,hr_api.g_number)
     <>  per_psp_shd.g_old_rec.spinal_point_id) then
    --
    -- raise error as PK has changed
    --
    per_psp_shd.constraint_error('PER_SPINAL_POINTS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_spinal_point_id is not null then
      --
      -- raise error as PK is not null
      --
      per_psp_shd.constraint_error('PER_SPINAL_POINTS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_spinal_point_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_parent_spine_id >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that a parent_spine_id exists in table per_parent_spines.
--
--  Pre-conditions:
--    parent_spine_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_spinal_point_id
--    p_parent_spine_id
--    p_business_group_id
--    p_object_version_number
--
--  Post Success:
--    If a row does exist; processing continues.
--
--  Post Failure:
--    If a row does not exist in per_parent_spines for
--    a given reason id then an error will be raised and processing terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_parent_spine_id
  (p_spinal_point_id            in per_spinal_points.spinal_point_id%TYPE
  ,p_parent_spine_id            in per_spinal_points.parent_spine_id%TYPE
  ,p_business_group_id          in per_spinal_points.business_group_id%TYPE
  ,p_object_version_number      in per_spinal_points.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_parent_spine_id';
  --
  l_api_updating      boolean;
  l_business_group_id number;
  --
  cursor csr_valid_parent_spines is
     select null
     from   per_parent_spines pps
     where  pps.business_group_id = p_business_group_id
     and    pps.parent_spine_id = p_parent_spine_id;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'parent_spine_id'
    ,p_argument_value   => p_parent_spine_id
    );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for parent_spine_id has changed
  --
  l_api_updating := per_psp_shd.api_updating
         (p_spinal_point_id        => p_spinal_point_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating and nvl(per_psp_shd.g_old_rec.parent_spine_id,
     hr_api.g_number) = nvl(p_parent_spine_id, hr_api.g_number)) then
     return;
  end if;

  open csr_valid_parent_spines;
  fetch csr_valid_parent_spines into l_exists;
  if csr_valid_parent_spines%notfound then
    close csr_valid_parent_spines;
    --
    per_psp_shd.constraint_error(p_constraint_name => 'PER_SPINAL_POINTS_FK2');
    --
  end if;
  close csr_valid_parent_spines;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_parent_spine_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_sequence >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates SEQUENCE is not null
--
--    Validates that SEQUENCE is UNIQUE for each parent_spine_id
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_sequence
--    p_parent_spine_id
--    p_spinal_point
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
-- ----------------------------------------------------------------------------
procedure chk_sequence(
   p_sequence          in per_spinal_points.sequence%TYPE
  ,p_parent_spine_id   in per_spinal_points.parent_spine_id%TYPE
  ,p_spinal_point      in per_spinal_points.spinal_point%TYPE
  ,p_spinal_point_id   in per_spinal_points.spinal_point_id%TYPE
  ,p_object_version_number in per_spinal_points.object_version_number%TYPE
  ) IS
--
l_proc         varchar2(72) := g_package||'chk_sequence';
l_exists       VARCHAR2(2);
l_api_updating boolean;
--
cursor csr_unq_seq is
	select 'x'
	from per_spinal_points
	where sequence = p_sequence
        and parent_spine_id = p_parent_spine_id
        and spinal_point = p_spinal_point;
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 10);
   --
     hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'sequence',
      p_argument_value => p_sequence);
   --
   hr_utility.set_location(l_proc,20);
   --
   l_api_updating := per_psp_shd.api_updating
         (p_spinal_point_id        => p_spinal_point_id
         ,p_object_version_number  => p_object_version_number);
   --
   if (l_api_updating and nvl(per_psp_shd.g_old_rec.sequence,
     hr_api.g_number) = nvl(p_sequence, hr_api.g_number)) then
     hr_utility.set_location('Leaving:'||l_proc, 30);
     return;
   end if;

   open csr_unq_seq;
   --
   FETCH csr_unq_seq INTO l_exists;

   hr_utility.set_location(l_proc,30);

   IF csr_unq_seq%FOUND THEN
      hr_utility.set_message(801, 'PER_7925_POINT_SEQ_EXISTS');
      CLOSE csr_unq_seq;
      hr_utility.raise_error;
   END IF;

   CLOSE csr_unq_seq;
   --
   hr_utility.set_location('Leaving:'||l_proc, 40);
   --
end chk_sequence;

--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_spinal_point >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates spinal_point is not null
--
--    Validates that spinal_point is UNIQUE for each parent_spine_id
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_spinal_point
--    p_parent_spine_id
--    p_spinal_point_id
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
-- ----------------------------------------------------------------------------
procedure chk_spinal_point(
   p_spinal_point          in per_spinal_points.spinal_point%TYPE
  ,p_parent_spine_id       in per_spinal_points.parent_spine_id%TYPE
  ,p_spinal_point_id       in per_spinal_points.spinal_point_id%TYPE
  ,p_object_version_number in per_spinal_points.object_version_number%TYPE
  ) IS
--
l_proc         varchar2(72) := g_package||'chk_spinal_point';
l_exists       VARCHAR2(2);
l_api_updating boolean;
--
cursor csr_unq_spinal_point is
	select 'x'
	from per_spinal_points
	where spinal_point = p_spinal_point
        and parent_spine_id = p_parent_spine_id;
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 10);
   --
     hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'spinal_point',
      p_argument_value => p_spinal_point);
   --
   hr_utility.set_location(l_proc,20);
   --
   l_api_updating := per_psp_shd.api_updating
         (p_spinal_point_id        => p_spinal_point_id
         ,p_object_version_number  => p_object_version_number);
   --
   if (l_api_updating and nvl(per_psp_shd.g_old_rec.spinal_point,
     hr_api.g_varchar2) = nvl(p_spinal_point, hr_api.g_varchar2)) then
     hr_utility.set_location('Leaving:'||l_proc, 30);
     return;
   end if;

   hr_utility.set_location(l_proc,40);

   open csr_unq_spinal_point;
   --
   FETCH csr_unq_spinal_point INTO l_exists;

   IF csr_unq_spinal_point%FOUND THEN
      hr_utility.set_message(801, 'PER_7924_POINT_EXISTS');
      CLOSE csr_unq_spinal_point;
      fnd_message.raise_error;
   END IF;

   CLOSE csr_unq_spinal_point;
   --
   hr_utility.set_location('Leaving:'||l_proc, 50);
   --
end chk_spinal_point;

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_delete >--------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that there are no values in
--   per_grade_spines_f, per_spinal_point_steps_f and pay_grade_rules_f
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_spinal_point_id
--   p_parent_spine_id
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_delete(
   p_spinal_point_id         in per_spinal_points.spinal_point_id%TYPE
  ,p_parent_spine_id         in per_spinal_points.parent_spine_id%TYPE
 ) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete';
  l_exists       varchar2(1);
  --
cursor csr_step_grade_spine is
	select 'x'
	from  per_spinal_point_steps_f sps
             ,per_grade_spines_f       pgs
	where sps.grade_spine_id = pgs.grade_spine_id
	and   pgs.parent_spine_id = p_parent_spine_id
	and   sps.spinal_point_id = p_spinal_point_id;
--
cursor csr_grade_rule is
	select 'x'
	from pay_grade_rules_f
	where grade_or_spinal_point_id = p_spinal_point_id
	and rate_type = 'SP';

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  --  Check there are no values in per_spinal_point_steps_f and
  --  per_grade_spines_f
  --
  open csr_step_grade_spine;
  --
  fetch csr_step_grade_spine into l_exists;
  --
    If csr_step_grade_spine%found Then
    --
      close csr_step_grade_spine;
      --
      hr_utility.set_message(801, 'PER_7926_DEL_POINT_STEP');
      hr_utility.raise_error;
      --
    End If;
  --
  close csr_step_grade_spine;

  hr_utility.set_location(l_proc, 20);

  --
  --  Check there are no values in per_grade_rules_f
  --
  open csr_grade_rule;
  --
  fetch csr_grade_rule into l_exists;
  --
    If csr_grade_rule%found Then
    --
      close csr_grade_rule;
      --
      hr_utility.set_message(801, 'PER_7927_DEL_POINT_VALUE');
      hr_utility.raise_error;
      --
    End If;
  --
  close csr_grade_rule;

  hr_utility.set_location('Leaving:' || l_proc, 30);
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_ddf >----------------------------------|
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
  (p_rec in per_psp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.spinal_point_id is not null)  and (
    nvl(per_psp_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(per_psp_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2) ))
    or (p_rec.spinal_point_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_utility.set_location('Entering:'||l_proc,20);

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Further Spinal Point DF'
      ,p_attribute_category              => p_rec.INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      ,p_attribute21_name                => 'INFORMATION21'
      ,p_attribute21_value               => p_rec.information21
      ,p_attribute22_name                => 'INFORMATION22'
      ,p_attribute22_value               => p_rec.information22
      ,p_attribute23_name                => 'INFORMATION23'
      ,p_attribute23_value               => p_rec.information23
      ,p_attribute24_name                => 'INFORMATION24'
      ,p_attribute24_value               => p_rec.information24
      ,p_attribute25_name                => 'INFORMATION25'
      ,p_attribute25_value               => p_rec.information25
      ,p_attribute26_name                => 'INFORMATION26'
      ,p_attribute26_value               => p_rec.information26
      ,p_attribute27_name                => 'INFORMATION27'
      ,p_attribute27_value               => p_rec.information27
      ,p_attribute28_name                => 'INFORMATION28'
      ,p_attribute28_value               => p_rec.information28
      ,p_attribute29_name                => 'INFORMATION29'
      ,p_attribute29_value               => p_rec.information29
      ,p_attribute30_name                => 'INFORMATION30'
      ,p_attribute30_value               => p_rec.information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
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
  ,p_rec in per_psp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_psp_shd.api_updating
      (p_spinal_point_id                   => p_rec.spinal_point_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Check business_group_id is not updated
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     per_psp_shd.g_old_rec.business_group_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'BUSINESS_GROUP_ID'
    ,p_base_table => per_psp_shd.g_tab_nam
    );
  END IF;
  --
  -- Check parent_spine_id is not updated
  --
  IF nvl(p_rec.parent_spine_id, hr_api.g_number) <>
     per_psp_shd.g_old_rec.parent_spine_id then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'PARENT_SPINE_ID'
    ,p_base_table => per_psp_shd.g_tab_nam
    );
  END IF;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_psp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_psp_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- Validate spinal point id
  --
  chk_spinal_point_id
   (p_spinal_point_id       => p_rec.spinal_point_id
   ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 20);

  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Dependent Attributes
  --

  --
  -- Validate parent spine id
  --
  chk_parent_spine_id
   (p_spinal_point_id        => p_rec.spinal_point_id
   ,p_parent_spine_id        => p_rec.parent_spine_id
   ,p_business_group_id      => p_rec.business_group_id
   ,p_object_version_number  => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate sequence
  --
  chk_sequence(
   p_sequence          => p_rec.sequence
  ,p_parent_spine_id   => p_rec.parent_spine_id
  ,p_spinal_point      => p_rec.spinal_point
  ,p_spinal_point_id   => p_rec.spinal_point_id
  ,p_object_version_number  => p_rec.object_version_number
  ) ;

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate spinal point
  --
  chk_spinal_point(
   p_spinal_point          => p_rec.spinal_point
  ,p_parent_spine_id       => p_rec.parent_spine_id
  ,p_spinal_point_id       => p_rec.spinal_point_id
  ,p_object_version_number => p_rec.object_version_number
  ) ;

  hr_utility.set_location(' Leaving:'||l_proc, 50);

  --
  --    Developer Descriptive Flexfield Validation
  --
  per_psp_bus.chk_ddf(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 100);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_psp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_psp_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- Validate spinal point id
  --
  chk_spinal_point_id
   (p_spinal_point_id       => p_rec.spinal_point_id
   ,p_object_version_number => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 20);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate parent spine id
  --
  chk_parent_spine_id
   (p_spinal_point_id        => p_rec.spinal_point_id
   ,p_parent_spine_id        => p_rec.parent_spine_id
   ,p_business_group_id      => p_rec.business_group_id
   ,p_object_version_number  => p_rec.object_version_number
  );

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate sequence
  --
  chk_sequence(
   p_sequence          => p_rec.sequence
  ,p_parent_spine_id   => p_rec.parent_spine_id
  ,p_spinal_point      => p_rec.spinal_point
  ,p_spinal_point_id   => p_rec.spinal_point_id
  ,p_object_version_number  => p_rec.object_version_number
  ) ;

  hr_utility.set_location(l_proc, 50);

  --
  -- Validate spinal point
  --
  chk_spinal_point(
   p_spinal_point          => p_rec.spinal_point
  ,p_parent_spine_id       => p_rec.parent_spine_id
  ,p_spinal_point_id       => p_rec.spinal_point_id
  ,p_object_version_number => p_rec.object_version_number
  ) ;

  hr_utility.set_location(' Leaving:'||l_proc, 60);

  --
  --    Developer Descriptive Flexfield Validation
  --
  per_psp_bus.chk_ddf(p_rec);

  hr_utility.set_location(' Leaving:'||l_proc, 100);

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_psp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Call all supporting business operations
  --
  chk_delete(p_spinal_point_id  => p_rec.spinal_point_id
            ,p_parent_spine_id  => p_rec.parent_spine_id);

  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end per_psp_bus;

/
