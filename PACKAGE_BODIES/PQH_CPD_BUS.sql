--------------------------------------------------------
--  DDL for Package Body PQH_CPD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CPD_BUS" as
/* $Header: pqcpdrhi.pkb 120.0 2005/05/29 01:44:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cpd_bus.';  -- Global package name
g_debug  boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_corps_definition_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_corps_definition_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_corps_definitions cpd
     where cpd.corps_definition_id = p_corps_definition_id
       and pbg.business_group_id = cpd.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72) ;
  l_legislation_code  varchar2(150);
  --
begin
  --
  if g_debug then
     l_proc := g_package||'set_security_group_id';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'corps_definition_id'
    ,p_argument_value     => p_corps_definition_id
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
        => nvl(p_associated_column1,'CORPS_DEFINITION_ID')
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
  if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_corps_definition_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pqh_corps_definitions cpd
     where cpd.corps_definition_id = p_corps_definition_id
       and pbg.business_group_id = cpd.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72);
  --
Begin
  --
  if g_debug then
     l_proc :=  g_package||'return_legislation_code';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'corps_definition_id'
    ,p_argument_value     => p_corps_definition_id
    );
  --
  if ( nvl(pqh_cpd_bus.g_corps_definition_id, hr_api.g_number)
       = p_corps_definition_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_cpd_bus.g_legislation_code;
    if g_debug then
       hr_utility.set_location(l_proc, 20);
    end if;
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
    if g_debug then
      hr_utility.set_location(l_proc,30);
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_cpd_bus.g_corps_definition_id         := p_corps_definition_id;
    pqh_cpd_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72);
--
begin
  if g_debug then
    l_proc := g_package || 'chk_df';
    hr_utility.set_location('Entering:'||l_proc,10);
  end if;
  --
  if ((p_rec.corps_definition_id is not null)  and (
    nvl(pqh_cpd_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2)  or
    nvl(pqh_cpd_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) ))
    or (p_rec.corps_definition_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQH'
      ,p_descflex_name                   => 'Additional Corps Info'
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
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,20);
  end if;
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
  ,p_rec in pqh_cpd_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_cpd_shd.api_updating
      (p_corps_definition_id               => p_rec.corps_definition_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_name >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_name
  (p_name                                 in varchar2,
   p_corps_definition_id                  in number default null,
   p_business_group_id                    in number
  ) is
  --
  -- Declare cursor
  --
  CURSOR csr_cpd_name is
    SELECT 'X'
    FROM   pqh_corps_definitions
    WHERE  name = p_name
    AND    corps_definition_id <> nvl(p_corps_definition_id,-1)
    AND    business_group_id = p_business_group_id;
  --
  -- Declare local variables
  --
  l_proc              varchar2(72) ;
  l_name              varchar2(30);
  --
begin
  --
  if g_debug then
    l_proc :=  g_package||'chk_corps_name';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'corps_name'
    ,p_argument_value     => p_name
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'business_group_id'
    ,p_argument_value     => p_business_group_id
    );
  --
  open csr_cpd_name;
  fetch csr_cpd_name into l_name;
  --
  if csr_cpd_name%found then
     close csr_cpd_name;
     fnd_message.set_name('PQH', 'PQH_DUPLICATE_CORPS_NAME');
     hr_multi_message.add(p_associated_column1 => 'NAME');
  else
    close csr_cpd_name;
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end chk_corps_name;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_type_of_ps >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_type_of_ps (p_effective_date DATE, p_type_of_ps VARCHAR2)
IS
   l_proc   VARCHAR2 (72);
   l_value varchar2(1000);
   CURSOR csr_type_of_ps
   IS
      SELECT NULL
        FROM per_shared_types_vl
       WHERE shared_type_id = TO_NUMBER (p_type_of_ps);
BEGIN
   IF g_debug
   THEN
      l_proc := g_package || 'chk_type_of_ps';
      hr_utility.set_location ('Entering: ' || l_proc, 10);
   END IF;

   hr_api.mandatory_arg_error (p_api_name            => l_proc,
                               p_argument            => 'type_of_ps',
                               p_argument_value      => p_type_of_ps
                              );

   OPEN csr_type_of_ps;

   --
   FETCH csr_type_of_ps
    INTO l_value;

   IF csr_type_of_ps%NOTFOUND
   THEN
      --
      fnd_message.set_name ('PQH', 'PQH_CORPS_INVALID_TYPE_OF_PS');
      hr_multi_message.ADD (p_associated_column1 => 'TYPE_OF_PS');
   END IF;

   CLOSE csr_type_of_ps;

   IF g_debug
   THEN
      hr_utility.set_location ('Leaving: ' || l_proc, 20);
   END IF;
END chk_type_of_ps;


--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_primary_prof_field_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_primary_prof_field_id(p_primary_prof_field_id IN NUMBER) IS

  CURSOR csr_primary_prof_field IS
    SELECT 'Y'
    FROM    per_shared_types
    WHERE   shared_type_id = p_primary_prof_field_id;
    l_proc  Varchar2(72);
    l_valid Varchar2(1) := 'N';
begin
  if g_debug then
     l_proc := g_package||'chk_primary_prof_field_id';
     hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  if p_primary_prof_field_id IS NOT NULL THEN
     OPEN csr_primary_prof_field;
     FETCH csr_primary_prof_field INTO l_valid;
     CLOSE csr_primary_prof_field;
     if l_valid = 'N' then
       fnd_message.set_name('PQH','PQH_CORPS_INVALID_PRIM_FIELD');
       hr_multi_message.add(p_associated_column1 => 'PRIMARY_PROF_FIELD_ID');
     end if;
  end if;
  if g_debug then
     hr_utility.set_location('Leaving: '||l_proc,20);
  end if;
end chk_primary_prof_field_id;

--  ---------------------------------------------------------------------------
--  |----------------------< chk_category_cd >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_category_cd(p_effective_date DATE,
                         p_category_cd    VARCHAR2) IS

  l_proc  Varchar2(72);
begin
  if g_debug then
     l_proc := g_package||'chk_category_cd';
     hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'category_cd'
    ,p_argument_value     => p_category_cd
    );
  if hr_api.not_exists_in_hr_lookups(p_effective_date,'PQH_CORPS_CATEGORY',p_category_cd) then
     fnd_message.set_name('PQH','PQH_CORPS_INVALID_CATEGORY');
     hr_multi_message.add(p_associated_column1 => 'CATEGORY_CD');
  end if;
  if g_debug then
     hr_utility.set_location('Leaving: '||l_proc,20);
  end if;
end chk_category_cd;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_type_cd >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_type_cd(p_effective_date DATE,
                            p_corps_type_cd    VARCHAR2) IS

  l_proc  Varchar2(72);
begin
  if g_debug then
     l_proc := g_package||'chk_corps_type_cd';
     hr_utility.set_location('Entering: '||l_proc,10);
  end if;
  if p_corps_type_cd IS NOT NULL AND hr_api.not_exists_in_hr_lookups(p_effective_date,'PQH_CORPS_TYPE',p_corps_type_cd) then
     fnd_message.set_name('PQH','PQH_CORPS_INVALID_TYPE_CD');
     hr_multi_message.add(p_associated_column1 => 'CORPS_TYPE_CD');
  end if;
  if g_debug then
     hr_utility.set_location('Leaving: '||l_proc,20);
  end if;
end chk_corps_type_cd;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_starting_grade_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_starting_grade_id(p_starting_grade_id NUMBER,
                                p_effective_date    DATE) IS
  CURSOR csr_valid_grade IS
     SELECT  'Y'
     FROM    per_grades
     WHERE   grade_id = p_starting_grade_id
     AND     p_effective_date BETWEEN date_from AND nvl(date_to,to_date('31/12/4712','DD/MM/RRRR'));
  l_valid  varchar2(1) := 'N';
  l_proc   varchar2(72);
begin
   if  g_debug then
     l_proc := g_package||'chk_starting_grade_id';
     hr_utility.set_location('Entering: '||l_proc,10);
   end if;
   if p_starting_grade_id IS NOT NULL THEN
     OPEN csr_valid_grade;
     FETCH csr_valid_grade INTO l_valid;
     CLOSE csr_valid_grade;
     IF l_valid = 'N' THEN
       fnd_message.set_name('PQH','PQH_CORPS_INVALID_STR_GRD');
       hr_multi_message.add(p_associated_column1 => 'STARTING_GRADE_ID');
     END IF;
   end if;
   if g_debug then
      hr_utility.set_location('Leaving: '||l_proc,20);
   end if;
end chk_starting_grade_id;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_starting_grade_step_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_starting_grade_step_id(p_starting_grade_step_id NUMBER,
                                     p_starting_grade_id NUMBER,
                                     p_effective_date    DATE) IS
  CURSOR csr_valid_step IS
     SELECT  'Y'
     FROM    per_grade_spines_f gs,
             per_spinal_point_steps_f sps
     WHERE   gs.grade_id = p_starting_grade_id
     AND     p_effective_date BETWEEN gs.effective_start_date and gs.effective_end_date
     AND     gs.grade_spine_id = sps.grade_spine_id
     AND     sps.step_id = p_starting_grade_step_id
     AND     p_effective_date BETWEEN sps.effective_start_date and sps.effective_end_date;
  l_valid  varchar2(1) := 'N';
  l_proc   varchar2(72);
begin
   if  g_debug then
     l_proc := g_package||'chk_starting_grade_id';
     hr_utility.set_location('Entering: '||l_proc,10);
   end if;
   if hr_multi_message.no_error_message
	       (p_check_message_name1 => 'PQH_CORPS_INVALID_STR_GRD') then
     if p_starting_grade_id IS NOT NULL AND p_starting_grade_step_id IS NOT NULL THEN
       OPEN csr_valid_step;
       FETCH csr_valid_step INTO l_valid;
       CLOSE csr_valid_step;
       IF l_valid = 'N' THEN
         fnd_message.set_name('PQH','PQH_CORPS_INVALID_STR_STEP');
         hr_multi_message.add(p_associated_column1 => 'STARTING_GRADE_STEP_ID');
       END IF;
     end if;
   end if;
   if g_debug then
      hr_utility.set_location('Leaving: '||l_proc,20);
   end if;
end chk_starting_grade_step_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_dates >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_dates
  (p_date_from                            in date,
   p_date_to                              in date default null,
   p_recruitment_end_date                 in date default null
  ) is
  l_proc              varchar2(72) ;
  l_date_to   date;
  l_eot date := to_date('31/12/4712','dd/mm/RRRR');
  --
begin
  --
  if g_debug then
     l_proc :=  g_package||'chk_corps_dates';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'date_from'
    ,p_argument_value     => p_date_from
    );

  if p_date_to is null then
     l_date_to := l_eot;
  else
     l_date_to := p_date_to;
  end if;
  --
  if p_date_from > l_date_to then
     fnd_message.set_name('PQH', 'PQH_CORPS_ESD_GREAT_EED');
     hr_multi_message.add(p_associated_column1=> 'DATE_FROM');
  end if;
  if nvl(p_recruitment_end_date,l_date_to) > l_date_to then
     fnd_message.set_name('PQH', 'PQH_CORPS_RED_GREAT_EED');
     hr_multi_message.add(p_associated_column1=>'RECRUITMENT_END_DATE');
  end if;
  if p_date_from > nvl(p_recruitment_end_date,p_date_from) then
     fnd_message.set_name('PQH','PQH_CORPS_ESD_GREAT_RED');
     hr_multi_message.add(p_associated_column1=>'RECRUITMENT_END_DATE');
  end if;
  if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end chk_corps_dates;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_work_hours >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_corps_work_hours (p_rec in pqh_cpd_shd.g_rec_type ) is
  l_proc              varchar2(72) ;
  --
begin
  --
  if g_debug then
     l_proc := g_package||'chk_corps_work_hours';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  if p_rec.normal_hours is not null and p_rec.normal_hours_frequency is null then
     fnd_message.set_name('PQH', 'PQH_CORPS_NOR_FRQ_MISSING');
     hr_multi_message.add(p_associated_column1 => 'NORMAL_HOURS_FREQUENCY');
  end if;
  if p_rec.minimum_hours is not null and p_rec.minimum_hours_frequency is null then
     fnd_message.set_name('PQH', 'PQH_CORPS_MIN_FRQ_MISSING');
     hr_multi_message.add(p_associated_column1 => 'MINIMUM_HOURS_FREQUENCY');
  end if;
  if nvl(p_rec.MINIMUM_HOURS,-1) > nvl(p_rec.NORMAL_HOURS,0) then
        fnd_message.set_name('PQH', 'PQH_CORPS_MIN_MORE_NOR');
        hr_multi_message.add(p_associated_column1 => 'MINIMUM_HOURS');
  end if;

  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 10);
  end if;

end chk_corps_work_hours;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_corps_other_proc_info >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_corps_other_proc_info(p_rec in pqh_cpd_shd.g_rec_type ) is
  --
  l_proc              varchar2(72);
  --
begin
  --
  if g_debug then
     l_proc  :=  g_package||'chk_corps_other_proc_info';
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  if p_rec.RETIREMENT_AGE is not null then
     if p_rec.RETIREMENT_AGE not between 40 and 80 then
        fnd_message.set_name('PQH', 'PQH_CORPS_RETIREMENT_AGE');
        hr_multi_message.add(p_associated_column1 => 'RETIREMENT_AGE');
     end if;
  end if;
  if nvl(p_rec.secondment_threshold,0) not between 0 and 100 then
     fnd_message.set_name('PQH', 'PQH_CORPS_INVALID_SECOND');
     hr_multi_message.add(p_associated_column1 => 'SECONDMENT_THRESHOLD');
  end if;
  if nvl(p_rec.probation_period,0) < 0 then
     fnd_message.set_name('PQH','PQH_PROB_PERIOD_NEGATIVE');
     hr_multi_message.add(p_associated_column1=>'PROBATION_PERIOD');
  end if;
  if p_rec.probation_period IS NOT NULL AND p_rec.probation_units IS NULL then
     fnd_message.set_name('PQH','PQH_PROB_UNITS_MISSING');
     hr_multi_message.add(p_associated_column1 => 'PROBATION_UNITS');
  end if;
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 20);
  end if;
end chk_corps_other_proc_info;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_ben_pgm_id >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_ben_pgm_id(p_ben_pgm_id NUMBER,
                         p_effective_date DATE) is
  CURSOR csr_ben_pgm_exists IS
   SELECT  'Y'
   FROM    ben_pgm_f
   WHERE   pgm_id = p_ben_pgm_id
   AND     p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_valid  varchar2(1) := 'N';
   l_proc   varchar2(72);
begin
   if g_debug then
     l_proc := g_package||'chk_ben_pgm_id';
     hr_utility.set_location('Entering: '||l_proc,10);
   end if;
   if p_ben_pgm_id IS NOT NULL then
     OPEN csr_ben_pgm_exists;
     FETCH csr_ben_pgm_exists INTO l_valid;
     CLOSE csr_ben_pgm_exists;
     if l_valid = 'N' then
       fnd_message.set_name('PQH','PQH_CORPS_INVALID_PGM');
       hr_multi_message.add(p_associated_column1=>'BEN_PGM_ID');
     end if;
   end if;
  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 20);
  end if;
end chk_ben_pgm_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=  hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'insert_validate';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_cpd_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');


  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  chk_corps_name(p_name   => p_rec.name,
                 p_corps_definition_id => p_rec.corps_definition_id,
                 p_business_group_id  => p_rec.business_group_id);

  chk_type_of_ps(p_effective_date => p_effective_date,
                 p_type_of_ps => p_rec.type_of_ps);

  chk_primary_prof_field_id(p_primary_prof_field_id => p_rec.primary_prof_field_id);

  chk_category_cd(p_effective_date  => p_effective_date,
                  p_category_cd => p_rec.category_cd);

  chk_corps_type_cd(p_effective_date => p_effective_date,
                    p_corps_type_cd  => p_rec.corps_type_cd);

  chk_starting_grade_id(p_starting_grade_id => p_rec.starting_grade_id,
                        p_effective_date => p_effective_date);

  chk_starting_grade_step_id(p_starting_grade_step_id => p_rec.starting_grade_step_id,
                             p_starting_grade_id => p_rec.starting_grade_id,
                             p_effective_date => p_effective_date);

  chk_corps_work_hours (p_rec => p_rec );
  chk_corps_other_proc_info(p_rec => p_rec);
  chk_ben_pgm_id(p_effective_date => p_effective_date,
                 p_ben_pgm_id => p_rec.ben_pgm_id);
  -- Validate Dependent Attributes
  --
   chk_corps_dates(p_date_from => p_rec.date_from,
                   p_date_to   => p_rec.date_to,
                   p_recruitment_end_date => p_rec.recruitment_end_date) ;
  -- removing the call to chk_df as at the moment the DFF is not enabled from the OA Page
  --  pqh_cpd_bus.chk_df(p_rec);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug :=  hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'update_validate';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_cpd_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  chk_corps_name(p_name   => p_rec.name,
                 p_corps_definition_id => p_rec.corps_definition_id,
                 p_business_group_id  => p_rec.business_group_id);

  chk_type_of_ps(p_effective_date => p_effective_date,
                 p_type_of_ps => p_rec.type_of_ps);

  chk_primary_prof_field_id(p_primary_prof_field_id => p_rec.primary_prof_field_id);

  chk_category_cd(p_effective_date  => p_effective_date,
                  p_category_cd => p_rec.category_cd);

  chk_corps_type_cd(p_effective_date => p_effective_date,
                    p_corps_type_cd  => p_rec.corps_type_cd);

  chk_starting_grade_id(p_starting_grade_id => p_rec.starting_grade_id,
                        p_effective_date => p_effective_date);

  chk_starting_grade_step_id(p_starting_grade_step_id => p_rec.starting_grade_step_id,
                             p_starting_grade_id => p_rec.starting_grade_id,
                             p_effective_date => p_effective_date);

  chk_corps_work_hours (p_rec => p_rec );
  chk_corps_other_proc_info(p_rec => p_rec);
  chk_ben_pgm_id(p_effective_date => p_effective_date,
                 p_ben_pgm_id => p_rec.ben_pgm_id);
  --
  -- Validate Dependent Attributes
  --
  chk_corps_dates(p_date_from => p_rec.date_from,
                  p_date_to   => p_rec.date_to,
                  p_recruitment_end_date => p_rec.recruitment_end_date) ;
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  -- removing the call to chk_df as at the moment the DFF is not enabled from the OA Page
  --  pqh_cpd_bus.chk_df(p_rec);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'delete_validate';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end pqh_cpd_bus;

/
