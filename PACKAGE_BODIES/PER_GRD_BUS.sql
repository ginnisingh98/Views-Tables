--------------------------------------------------------
--  DDL for Package Body PER_GRD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GRD_BUS" as
/* $Header: pegrdrhi.pkb 115.9 2003/08/25 11:48:08 ynegoro noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_grd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_grade_id                    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_grade_id                             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_grades grd
     where grd.grade_id = p_grade_id
       and pbg.business_group_id = grd.business_group_id;
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
    ,p_argument           => 'grade_id'
    ,p_argument_value     => p_grade_id
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
       (p_associated_column1 => nvl(p_associated_column1,'GRADE_ID')

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
  (p_grade_id                             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_grades grd
     where grd.grade_id = p_grade_id
       and pbg.business_group_id = grd.business_group_id;
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
    ,p_argument           => 'grade_id'
    ,p_argument_value     => p_grade_id
    );
  --
  if ( nvl(per_grd_bus.g_grade_id, hr_api.g_number)
       = p_grade_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_grd_bus.g_legislation_code;
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
    per_grd_bus.g_grade_id                    := p_grade_id;
    per_grd_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_delete>------------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_delete(p_grade_id                number
		    ,p_object_version_number   number
                     ) is

l_exists  varchar2(1);
--
cursor csr_assignment is
	   select 'x'
	   FROM per_all_assignments_f
	   WHERE grade_id = p_grade_id;
--
cursor csr_valid_grade is
	   select 'x'
	   FROM per_valid_grades
	   WHERE grade_id = p_grade_id;
--
cursor csr_vacancies is
	   select 'x'
	   FROM per_vacancies
	   WHERE grade_id = p_grade_id;
--
cursor csr_element is
	   select 'x'
	   FROM pay_element_links
	   WHERE grade_id = p_grade_id;
--
cursor csr_budget is
	   select 'x'
	   FROM per_budget_elements
	   WHERE grade_id = p_grade_id;
--
cursor csr_grade_spines is
	   select 'x'
	   FROM per_grade_spines
	   WHERE grade_id = p_grade_id;
--
cursor c_grade_rules is
	   select 'x'
	   FROM pay_grade_rules
	   WHERE grade_or_spinal_point_id = p_grade_id
	   AND rate_type = 'G';
--
cursor csr_salary_survey is
	   select 'x'
	   FROM per_salary_survey_mappings
	   WHERE grade_id = p_grade_id;
--
cursor csr_positions is
	   select 'x'
	   FROM hr_all_positions_f
	   WHERE entry_grade_id = p_grade_id;
--
  --
  l_proc         varchar2(72) := g_package||'chk_delete';
  l_api_updating boolean;
  l_delete_plan varchar2(20);
  l_message     varchar2(2000) := null;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --  Check there are no values in per_all_assignments_f, per_valid_grades
  --  per_vacancies, pay_element_links, per_budget_elements, per_grade_spines
  --  per_salary_survey_mappings, hr_all_positions_f, pay_grade_rules
  --
Open csr_assignment;
  --
  fetch csr_assignment into l_exists;
  --
	  If csr_assignment%found Then
	    --
	    close csr_assignment;
	    --
               fnd_message.set_name('PAY','PER_7834_DEF_GRADE_DEL_ASSIGN');
	    --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close csr_assignment;
  --

Open csr_valid_grade;
  --
  fetch csr_valid_grade into l_exists;
  --
	  If csr_valid_grade%found Then
	    --
	    close csr_valid_grade;
	    --
	      fnd_message.set_name('PAY','HR_6443_GRADE_DEL_VALID_GRADES');
	    --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close csr_valid_grade;
  --

Open csr_vacancies;
  --
  fetch csr_vacancies into l_exists;
  --
	  If csr_vacancies%found Then
	    --
	    close csr_vacancies;
	    --
               fnd_message.set_name('PAY','HR_6444_GRADE_DEL_VACANCIES');
            --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close csr_vacancies;
  --

Open csr_element;
  --
  fetch csr_element into l_exists;
  --
	  If csr_element%found Then
	    --
	    close csr_element;
	    --
              fnd_message.set_name('PAY','HR_6446_DEL_ELE_LINKS');
	    --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close csr_element;
  --

Open csr_budget;
  --
  fetch csr_budget into l_exists;
  --
	  If csr_budget%found Then
	    --
	    close csr_budget;
	    --
	      fnd_message.set_name('PAY', 'HR_6447_GRADE_DEL_BUDGET_ELE');
            --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close csr_budget;
  --

Open  csr_grade_spines;
  --
  fetch  csr_grade_spines into l_exists;
  --
	  If  csr_grade_spines%found Then
	    --
	    close  csr_grade_spines;
	    --
	     fnd_message.set_name('PAY', 'HR_6448_GRADE_DEL_GRADE_SPINES');
	    --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close  csr_grade_spines;
  --

Open c_grade_rules;
  --
  fetch c_grade_rules into l_exists;
  --
	  If c_grade_rules%found Then
	    --
	    close c_grade_rules;
	    --
	      fnd_message.set_name('PAY', 'HR_6684_GRADE_RULES');
            --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close c_grade_rules;
  --

Open csr_salary_survey;
  --
  fetch csr_salary_survey into l_exists;
  --
	  If csr_salary_survey%found Then
	    --
	    close csr_salary_survey;
	    --
	      fnd_message.set_name('PER','PER_289847_GRADE_DEL_SAL_SURV');
	    --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close csr_salary_survey;
  --

Open csr_positions;
  --
  fetch csr_positions into l_exists;
  --
	  If csr_positions%found Then
	    --
	    close csr_positions;
	    --
	      fnd_message.set_name('PER','PER_289848_GRADE_DEL_POSITIONS');
	    --
	    fnd_message.raise_error;
	    --
	  End If;
  --
Close csr_positions;
  --
  -- Call pqh_gsp_sync_compensation_obj.delete_plan_for_grade
  --
  --
  l_delete_plan := pqh_gsp_sync_compensation_obj.delete_plan_for_grade
    (p_grade_id                     => p_grade_id
    );
  --
  hr_utility.trace('pqh_gsp_sync_compensation_obj.delete_plan_for_grade return => ' || l_delete_plan);
  --
  if l_delete_plan <> 'SUCCESS' Then
    l_message := fnd_message.get;
    fnd_message.set_name('PER','HR_289563_DEL_PLAN_FOR_GRADE');
    if l_message is not null then
      hr_utility.trace('error message : ' || l_message);
      fnd_message.set_token('ERR_CODE',l_message);
    else
      fnd_message.set_token('ERR_CODE','-1');
    end if;
    --
    fnd_message.raise_error;
    --
  End if;

  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
 	--
  --
end chk_delete;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_grade_id >---------------------------------|
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
--   grade_id PK of record being inserted or updated.
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
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_grade_id(p_grade_id                     in number,
                       p_object_version_number        in number,
                       p_effective_date               in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_grade_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_grd_shd.api_updating
    (p_grade_id                     => p_grade_id,
     p_object_version_number        => p_object_version_number
   );
  --
  if (l_api_updating
     and nvl(p_grade_id,hr_api.g_number)
     <>  per_grd_shd.g_old_rec.grade_id) then
    --
    -- raise error as PK has changed
    --
    per_grd_shd.constraint_error('PER_GRADES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_grade_id is not null then
      --
      -- raise error as PK is not null
      --
      per_grd_shd.constraint_error('PER_GRADES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_grade_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_short_name >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the short_name unique within
--   a business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_short_name
--   p_business_group_id
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
Procedure chk_short_name(p_short_name               in varchar2
                        ,p_business_group_id        in number
   			,p_grade_id                 in number default null
			,p_object_version_number    in number default null
                        ) is
  --
  l_proc         varchar2(72) := g_package||'chk_short_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
--
cursor csr_unique_short_name is
  select 'x'
    from per_grades
    where p_short_name is not null
    and upper(short_name)   = upper(p_short_name)
    and business_group_id + 0 = p_business_group_id;

cursor csr_update_short_name is
  select 'x'
    from per_grades grd
    where p_short_name is not null
    and  grd.grade_id = p_grade_id
    and exists
        (select *
         from per_grades
         where business_group_id = grd.business_group_id
         and   upper(short_name)   = upper(p_short_name));

--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --    Check GSP implementation exists
  --
  -- If Grade Ladder implementation exists and short_name
  -- isn't specified, a warning message should appear.
  --
  l_api_updating := per_grd_shd.api_updating
    (p_grade_id                     => p_grade_id,
     p_object_version_number        => p_object_version_number
   );
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (l_api_updating and
      ((p_short_name is not null and per_grd_shd.g_old_rec.short_name is null)
       or (per_grd_shd.g_old_rec.short_name <> p_short_name))) then

    hr_utility.set_location(l_proc, 30);
    --
    open csr_update_short_name;
    fetch csr_update_short_name into l_exists;
    if csr_update_short_name%found then
      close csr_update_short_name;
      hr_utility.set_message(800,'HR_289555_NON_UNIQ_SHORT_NAME');
      hr_utility.raise_error;
    end if;
    close csr_update_short_name;
    --
  elsif (NOT l_api_updating) then
    --
    hr_utility.set_location(l_proc, 40);
    --
    open csr_unique_short_name;
    fetch csr_unique_short_name into l_exists;
    if csr_unique_short_name%found then
      close csr_unique_short_name;
      hr_utility.set_message(800,'HR_289555_NON_UNIQ_SHORT_NAME');
      hr_utility.raise_error;
    end if;
    close csr_unique_short_name;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 50);
  --
End chk_short_name;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_grade_definition_id  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that GRADE_DEFINITION_ID is not null
--
--    Validates that GRADE_DEFINITION_ID in the PER_GRADE_DEFINITIONS table
--    exists for the record specified by GRADE_DEFINITION_ID.
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_grade_definition_id
--    p_business_group_id
--    p_grade_id
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
procedure chk_grade_definition_id
  (p_grade_definition_id          in      number,
   p_business_group_id            in      number,
   p_grade_id                     in      number default null,
   p_object_version_number        in      number default null
  )     is
--
   l_proc       varchar2(72)    := g_package||'chk_grade_definition_id';
   l_exists             varchar2(1);
   l_api_updating  boolean;
--
cursor csr_grade_def is
  select 'x'
  from per_grade_definitions
  where grade_definition_id = p_grade_definition_id;
--
cursor csr_unique_grade_def is
  select 'x'
    from per_grades
   where grade_definition_id   = p_grade_definition_id
     and business_group_id + 0 = p_business_group_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'grade_definition_id'
    ,p_argument_value   => p_grade_definition_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  l_api_updating := per_grd_shd.api_updating
    (p_grade_id                => p_grade_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 3);
  --
  if ((l_api_updating and
       (per_grd_shd.g_old_rec.grade_definition_id <>
          p_grade_definition_id)) or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 4);
    --
    open csr_grade_def;
    fetch csr_grade_def into l_exists;
    if csr_grade_def%notfound then
      close csr_grade_def;
      per_grd_shd.constraint_error(p_constraint_name => 'PER_GRADES_FK2');
    end if;
    close csr_grade_def;
    --
    hr_utility.set_location(l_proc, 5);
    --
    open csr_unique_grade_def;
    fetch csr_unique_grade_def into l_exists;
    if csr_unique_grade_def%found then
      close csr_unique_grade_def;
      hr_utility.set_message(801,'PER_7830_DEF_GRADE_EXISTS');
      hr_utility.raise_error;
    end if;
    close csr_unique_grade_def;
    --
  end if;
  hr_utility.set_location('Leaving '||l_proc, 6);
  --
end chk_grade_definition_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_dates >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates DATE_FROM is not null
--
--    Validates that DATE_FROM is less than or equal to the value for
--    DATE_TO on the same GRADE record
--
--  Pre-conditions:
--    Format of p_date_effective must be correct
--
--  In Arguments :
--    p_grade_id
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
procedure chk_dates
  (p_grade_id                   in      number default null
  ,p_date_from                  in      date
  ,p_date_to                    in      date
  ,p_object_version_number in number default null
  )      is
--
   l_proc          varchar2(72) := g_package||'chk_dates';
   l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory parameters have been set
  --

  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'date_from'
    ,p_argument_value   => p_date_from
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_grd_shd.api_updating
    (p_grade_id                => p_grade_id
    ,p_object_version_number => p_object_version_number);
  --
  if (((l_api_updating and
       (nvl(per_grd_shd.g_old_rec.date_to,hr_api.g_eot) <>
                                               nvl(p_date_to,hr_api.g_eot)) or
       (per_grd_shd.g_old_rec.date_from <> p_date_from)) or
       (NOT l_api_updating))) then
    --
    --   Check that date_from <= date_to
    --
    hr_utility.set_location(l_proc, 3);
    --
    if p_date_from > nvl(p_date_to,hr_api.g_eot) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', '3');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_dates;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_sequence >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates SEQUENCE is not null
--
--    Validates that SEQUENCE is UNIQUE
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_sequence
--    p_business_group_id
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
                  p_sequence          IN NUMBER,
                  p_business_group_id IN NUMBER
                 ) IS
--
l_exists VARCHAR2(2);

cursor c_all_seq IS
  SELECT  'x'
    FROM  per_grades grd
      WHERE  grd.business_group_id = p_business_group_id
      AND grd.sequence = p_sequence
      ;
--
l_proc         varchar2(72) := g_package||'chk_sequence';
--
BEGIN
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
     hr_api.mandatory_arg_error
     (p_api_name       => l_proc,
      p_argument       => 'sequence',
      p_argument_value => p_sequence);
   --
   hr_utility.set_location(l_proc,10);
   --
   OPEN c_all_seq;
   --
   FETCH c_all_seq INTO l_exists;
    hr_utility.set_location(l_proc,15);
   IF c_all_seq%FOUND THEN
      fnd_message.set_name('PAY','HR_7127_GRADE_DUP_SEQ');
      CLOSE c_all_seq;
      fnd_message.raise_error;
   END IF;
   CLOSE c_all_seq;
   --
   if p_sequence < 0 then
     fnd_message.set_name('PAY','PER_7833_DEF_GRADE_SEQUENCE');
     fnd_message.raise_error;
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 20);
   --
end chk_sequence;
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
  (p_rec in per_grd_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.grade_id is not null)  and (
    nvl(per_grd_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.grade_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Grade Developer DF'
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
      );
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
  (p_rec in per_grd_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.grade_id is not null)  and (
    nvl(per_grd_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_grd_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.grade_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_GRADES'
      ,p_attribute_category              => p_rec.attribute_category
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
      );
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
  ,p_rec in per_grd_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_grd_shd.api_updating
      (p_grade_id                          => p_rec.grade_id
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
  ,p_rec                          in per_grd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_grd_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  chk_grade_id
  (p_grade_id           => p_rec.grade_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_effective_date        => p_effective_date
  );
  --
   hr_utility.set_location(l_proc, 10);
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  -- Validate date from and date_to
  --
  chk_dates
  (p_date_from             => p_rec.date_from,
   p_date_to               => p_rec.date_to
  );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate grade definition id
  --
  chk_grade_definition_id
  (p_grade_definition_id     =>   p_rec.grade_definition_id
  ,p_business_group_id       =>   p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate sequence
  --
  chk_sequence
  (p_sequence              =>   p_rec.sequence,
   p_business_group_id     =>   p_rec.business_group_id
  );
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate short_name
  --
  chk_short_name
  (p_short_name            =>   p_rec.short_name
  ,p_business_group_id     =>   p_rec.business_group_id
  );
   hr_utility.set_location(l_proc, 50);
  --
  --    Flexfield Validation
  --
  per_grd_bus.chk_ddf(p_rec);
  --
  per_grd_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_grd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
--  hr_api.validate_bus_grp_id
--    (p_business_group_id => p_rec.business_group_id
--    ,p_associated_column1 => per_grd_shd.g_tab_nam
--                              || '.BUSINESS_GROUP_ID');
  --
  chk_grade_id
  (p_grade_id           => p_rec.grade_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 10);
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
    (p_effective_date              => p_effective_date
    ,p_rec                          => p_rec
    );
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate sequence
  --
  chk_sequence
  (p_sequence              =>   p_rec.sequence,
   p_business_group_id     =>   p_rec.business_group_id
  );
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate date effective
  --
  chk_dates
  (p_grade_id                => p_rec.grade_id,
   p_date_from             => p_rec.date_from,
   p_date_to               => p_rec.date_to,
   p_object_version_number => p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate grade definition id
  --
  chk_grade_definition_id
  (p_grade_definition_id     => p_rec.grade_definition_id,
   p_business_group_id       => p_rec.business_group_id,
   p_grade_id                => p_rec.grade_id,
   p_object_version_number => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate short_name
  --
  chk_short_name
  (p_short_name            =>   p_rec.short_name
  ,p_business_group_id     =>   p_rec.business_group_id
  ,p_grade_id              =>   p_rec.grade_id
  ,p_object_version_number =>   p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 60);
  --
  --    Flexfield Validation
  --
  per_grd_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 70);
  --
  per_grd_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_grd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- CHK_DELETE
  chk_delete
  (p_grade_id       =>  p_rec.grade_id
  ,p_object_version_number => p_rec.object_version_number
   );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_grd_bus;

/
