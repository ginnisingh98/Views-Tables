--------------------------------------------------------
--  DDL for Package Body PSP_PEE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PEE_BUS" as
/* $Header: PSPEERHB.pls 120.3 2006/02/08 05:35 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_pee_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_external_effort_line_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_external_effort_line_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , psp_external_effort_lines pee
     where pee.external_effort_line_id = p_external_effort_line_id
       and pbg.business_group_id = pee.business_group_id;
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
    ,p_argument           => 'external_effort_line_id'
    ,p_argument_value     => p_external_effort_line_id
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
        => nvl(p_associated_column1,'EXTERNAL_EFFORT_LINE_ID')
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
  (p_external_effort_line_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , psp_external_effort_lines pee
     where pee.external_effort_line_id = p_external_effort_line_id
       and pbg.business_group_id = pee.business_group_id;
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
    ,p_argument           => 'external_effort_line_id'
    ,p_argument_value     => p_external_effort_line_id
    );
  --
  if ( nvl(psp_pee_bus.g_external_effort_line_id, hr_api.g_number)
       = p_external_effort_line_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := psp_pee_bus.g_legislation_code;
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
    psp_pee_bus.g_external_effort_line_id     := p_external_effort_line_id;
    psp_pee_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
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
  (p_rec in psp_pee_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.external_effort_line_id is not null)  and (
    nvl(psp_pee_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(psp_pee_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) ))
    or (p_rec.external_effort_line_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PSP'
      ,p_descflex_name                   => 'External Effort Lines DF'
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
  (p_rec in psp_pee_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT psp_pee_shd.api_updating
      (p_external_effort_line_id           => p_rec.external_effort_line_id
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
-- |---------------------------< chk_business_group_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_business_group_id
( p_business_group_id    IN NUMBER
, p_distribution_date    IN DATE
)
IS
  l_proc             VARCHAR2(72)  :=  g_package||'chk_business_group_id';
  l_business_group_id NUMBER;
  --
  CURSOR business_group_csr IS
  SELECT business_group_id
  FROM   per_business_groups
  where  business_group_id = p_business_group_id
  AND    p_distribution_date between DATE_FROM and nvl(DATE_TO,to_date('31/12/4712','DD/MM/RRRR'));
  --
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'business group id'
  ,p_argument_value => p_business_group_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN business_group_csr;
  FETCH business_group_csr INTO l_business_group_id;
  IF business_group_csr%NOTFOUND THEN
    CLOSE business_group_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_BUSINESS_GROUP');
    hr_utility.raise_error;
  END IF;
  CLOSE business_group_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.BUSINESS_GROUP_ID') THEN
    RAISE;
  END IF;
END chk_business_group_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_set_of_books_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_set_of_books_id
(p_set_of_books_id IN NUMBER
)
IS
  l_proc             VARCHAR2(72)  :=  g_package||'chk_set_of_books_id';
  l_set_of_books_id  NUMBER;
  --
  CURSOR set_of_books_id_csr IS
  SELECT set_of_books_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = p_set_of_books_id;
  --
BEGIN
   --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'set of books id'
  ,p_argument_value => p_set_of_books_id
  );

 OPEN set_of_books_id_csr;
  FETCH set_of_books_id_csr INTO l_set_of_books_id;
  if set_of_books_id_csr%notfound then
    CLOSE set_of_books_id_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_SET_OF_BOOKS');
    fnd_message.set_token('SET_OF_BOOKS_ID',l_set_of_books_id);
    hr_utility.raise_error;
  END IF;
  CLOSE set_of_books_id_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.SET_OF_BOOKS_ID') THEN
    RAISE;
  END IF;
END chk_set_of_books_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_person_id
( p_person_id         IN NUMBER
, p_business_group_id IN NUMBER
, p_distribution_date IN DATE
)
IS
  --
  l_proc             VARCHAR2(72)  :=  g_package||'chk_person_id';
  l_person_id        NUMBER;
  --
  CURSOR person_id_csr IS
  SELECT person_id
  FROM   per_all_people_f
  WHERE  person_id = p_person_id
  AND    current_employee_flag = 'Y'
  AND    business_group_id = p_business_group_id
  AND    p_distribution_date between effective_start_date and effective_end_date;
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'person id'
  ,p_argument_value => p_person_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'business group id'
  ,p_argument_value => p_business_group_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN person_id_csr;
  FETCH person_id_csr INTO l_person_id;
  if person_id_csr%notfound then
    CLOSE person_id_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_PERSON');
    fnd_message.set_token('PERSON_ID',l_person_id);
    hr_utility.raise_error;
  END IF;
  CLOSE person_id_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.PERSON_ID') THEN
    RAISE;
  END IF;
END chk_person_id;




--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_assignment_id
( p_assignment_id     IN NUMBER
, p_person_id         IN NUMBER
, p_business_group_id IN NUMBER
, p_distribution_date IN DATE
)
IS
  --
  l_proc             VARCHAR2(72)  :=  g_package||'chk_person_id';
  l_assignment_id        NUMBER;
  --
  CURSOR assignment_id_csr IS
  SELECT assignment_id
  FROM   per_all_assignments_f paaf,
         pay_all_payrolls_f papf
  WHERE  paaf.payroll_id = papf.payroll_id
  AND    paaf.assignment_id = p_assignment_id
  AND    paaf.person_id = p_person_id
  AND    paaf.business_group_id = p_business_group_id
  AND    p_distribution_date between paaf.effective_start_date and paaf.effective_end_date
  AND    p_distribution_date between papf.effective_start_date and papf.effective_end_date;
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'assignment id'
  ,p_argument_value => p_assignment_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'person id'
  ,p_argument_value => p_person_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'business group id'
  ,p_argument_value => p_business_group_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN assignment_id_csr;
  FETCH assignment_id_csr INTO l_assignment_id;
  if assignment_id_csr%notfound then
    CLOSE assignment_id_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_ASSIGNMENT');
    fnd_message.set_token('ASSIGNMENT_ID',l_assignment_id);
    hr_utility.raise_error;
  END IF;
  CLOSE assignment_id_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.ASSIGNMENT_ID') THEN
    RAISE;
  END IF;
END chk_assignment_id;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_currency >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_currency
( p_currency_code IN VARCHAR2
, p_distribution_date IN DATE
)
IS
  --
  l_proc             VARCHAR2(72)  :=  g_package||'chk_currency';
  l_currency_code    VARCHAR2(15);
  --
  CURSOR currency_csr (p_currency_code IN VARCHAR2, p_distribution_date IN DATE )IS
  SELECT fc.currency_code
  FROM   fnd_currencies fc,
         per_business_groups pbg
  WHERE  fc.currency_code =pbg.currency_code
  AND    fc.enabled_flag = 'Y'
  AND    fc.currency_flag = 'Y'
  AND    fc.currency_code = p_currency_code
  AND    p_distribution_date between nvl(fc.start_date_active,p_distribution_date) and nvl(fc.end_date_active ,to_date('31/12/4712','DD/MM/RRRR'))
  AND    p_distribution_date between date_from and nvl(pbg.DATE_TO,to_date('31/12/4712','DD/MM/RRRR'));
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'currency code'
  ,p_argument_value => p_currency_code
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN currency_csr(p_currency_code, p_distribution_date);
  FETCH currency_csr INTO l_currency_code;
  if currency_csr%notfound then
    CLOSE currency_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_CURRENCY');
    fnd_message.set_token('CURRENCY_CODE',l_currency_code);
    hr_utility.raise_error;
  END IF;
  CLOSE currency_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.CURRENCY_CODE') THEN
    RAISE;
  END IF;
END chk_currency;



--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ptaoe_gl_combination >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_ptaoe_gl_combination
(p_rec                          IN psp_pee_shd.g_rec_type
) IS
BEGIN
  IF p_rec.project_id IS NULL AND p_rec.gl_code_combination_id IS NULL THEN
    hr_utility.set_message(8403, 'PSP_POETA_GL');
    hr_utility.raise_error;
  END IF;

  IF p_rec.gl_code_combination_id IS NOT NULL
     AND (p_rec.project_id IS NOT NULL
          OR p_rec.task_id IS NOT NULL
          OR p_rec.award_id IS NOT NULL
          OR p_rec.expenditure_organization_id IS NOT NULL
          OR p_rec.expenditure_type IS NOT NULL
	  )
  THEN
    hr_utility.set_message(8403, 'PSP_ER_EXTRA_CI');
    hr_utility.raise_error;
  END IF;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add() THEN
    RAISE;
  END IF;
END chk_ptaoe_gl_combination;



--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_gl_code_combination >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_gl_code_combination
( p_gl_code_combination_id IN NUMBER
)
IS
  --
  l_proc             VARCHAR2(72)  :=  g_package||'chk_gl_code_combination';
  l_gl_code_combination_id NUMBER;
  --
 CURSOR gl_code_combination_csr  (p_gl_code_combination_id IN NUMBER) IS
  SELECT code_combination_id
  FROM   gl_code_combinations
  WHERE  code_combination_id = p_gl_code_combination_id
  AND    enabled_flag ='Y';
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'gl code combination id'
  ,p_argument_value => p_gl_code_combination_id
  );

    OPEN gl_code_combination_csr(p_gl_code_combination_id);
    FETCH gl_code_combination_csr INTO l_gl_code_combination_id;
    IF gl_code_combination_csr%notfound then
      CLOSE gl_code_combination_csr;
      hr_utility.set_message(8403, 'PSP_ER_INVALID_GLCC');
      fnd_message.set_token('GL_CODE_COMBINATION_ID',l_gl_code_combination_id);
      hr_utility.raise_error;
    END IF;
    CLOSE gl_code_combination_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.GL_CODE_COMBINATION') THEN
    RAISE;
  END IF;
END chk_gl_code_combination;



--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_project_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_project_id
( p_project_id IN NUMBER
, p_distribution_date IN DATE)
IS
  --
  l_proc             VARCHAR2(72)  :=  g_package||'chk_project_id';
  l_project_id       NUMBER;
  --
  CURSOR project_id_csr(p_project_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT project_id
  FROM   pa_projects_all
  WHERE  project_id = p_project_id
  AND    p_distribution_date between nvl(start_date,trunc(p_distribution_date)) and nvl(completion_date,to_date('31/12/4712','DD/MM/RRRR'));
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'project id'
  ,p_argument_value => p_project_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN project_id_csr(p_project_id, p_distribution_date);
  FETCH project_id_csr INTO l_project_id;
  if project_id_csr%notfound then
    CLOSE project_id_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_PROJECT_ID');
    fnd_message.set_token('PROJECT_ID',l_project_id);
    hr_utility.raise_error;
  END IF;
  CLOSE project_id_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.PROJECT_ID') THEN
    RAISE;
  END IF;
END chk_project_id;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_task_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_task_id
( p_task_id IN NUMBER
, p_distribution_date IN DATE)
IS
  --
  l_proc             VARCHAR2(72)  :=  g_package||'chk_task_id';
  l_task_id          NUMBER;
  --
  CURSOR task_id_csr(p_task_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT task_id
  FROM   pa_tasks
  WHERE  task_id = p_task_id
  AND    p_distribution_date between nvl(start_date,trunc(p_distribution_date)) and nvl(completion_date,to_date('31/12/4712','DD/MM/RRRR'));
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'task id'
  ,p_argument_value => p_task_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN task_id_csr(p_task_id, p_distribution_date);
  FETCH task_id_csr INTO l_task_id;
  if task_id_csr%notfound then
    CLOSE task_id_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_TASK_ID');
    fnd_message.set_token('TASK_ID',l_task_id);
    hr_utility.raise_error;
  END IF;
  CLOSE task_id_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.TASK_ID') THEN
    RAISE;
  END IF;
END chk_task_id;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_award_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_award_id
( p_award_id IN NUMBER
, p_distribution_date IN DATE)
IS
  --
  l_proc             VARCHAR2(72)  :=  g_package||'chk_award_id';
  l_award_id         NUMBER;
  --
  CURSOR award_id_csr(p_award_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT award_id
  FROM   gms_awards_all
  WHERE  award_id = p_award_id
  AND    p_distribution_date between nvl(start_date_active,trunc(p_distribution_date)) and nvl(end_date_active,to_date('31/12/4712','DD/MM/RRRR'));
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'award id'
  ,p_argument_value => p_award_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN award_id_csr(p_award_id, p_distribution_date);
  FETCH award_id_csr INTO l_award_id;
  if award_id_csr%notfound then
    CLOSE award_id_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_AWARD_ID');
    fnd_message.set_token('AWARD_ID',l_award_id);
    hr_utility.raise_error;
  END IF;
  CLOSE award_id_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.AWARD_ID') THEN
    RAISE;
  END IF;
END chk_award_id;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_exp_org_id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_exp_org_id
( p_expenditure_organization_id IN NUMBER
, p_distribution_date IN DATE)
IS
  --
  l_proc                                VARCHAR2(72)  :=  g_package||'chk_exp_org_id';
  l_expenditure_organization_id         NUMBER;

  --
  CURSOR expenditure_organization_csr(p_expenditure_organization_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT organization_id
  FROM   psp_organizations_expend_v
  WHERE  organization_id = p_expenditure_organization_id
  AND    trunc(p_distribution_date) between date_from and nvl(date_to,trunc(p_distribution_date));
BEGIN
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'expenditure organization id'
  ,p_argument_value => p_expenditure_organization_id
  );

  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'distribution date'
  ,p_argument_value => p_distribution_date
  );

  OPEN expenditure_organization_csr(p_expenditure_organization_id, p_distribution_date);
  FETCH expenditure_organization_csr INTO l_expenditure_organization_id;
  if expenditure_organization_csr%notfound then
    CLOSE expenditure_organization_csr;
    hr_utility.set_message(8403, 'PSP_ER_INVALID_EXP_ORG_ID');
    fnd_message.set_token('EXP_ORG_ID',l_expenditure_organization_id);
    hr_utility.raise_error;
  END IF;
  CLOSE expenditure_organization_csr;
EXCEPTION
  WHEN app_exception.application_exception THEN
  IF hr_multi_message.exception_add(p_associated_column1 => 'PSP_EFFORT_INTERFACE.expenditure_organization_id') THEN
    RAISE;
  END IF;
END chk_exp_org_id;







--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_existing_eff_report >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_existing_eff_report
( p_person_id         IN NUMBER
, p_assignment_id     IN NUMBER
, p_distribution_date IN DATE
)
IS
  CURSOR person_effort_report_csr(p_person_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT per.effort_report_id, prth.selection_match_level
  FROM   psp_eff_reports per,
         psp_report_templates_h prth
  WHERE  per.request_id = prth.request_id
  AND    per.PERSON_ID = p_person_id
  AND    p_distribution_date between per.start_date and per.end_date
  AND    per.STATUS_CODE IN ('N','A');

  CURSOR assignment_effort_report_csr (p_effort_report_id IN NUMBER, p_assignment_id IN NUMBER) IS
  SELECT assignment_id
  FROM   psp_eff_report_details perd
  WHERE  effort_report_id = p_effort_report_id
  AND    ASSIGNMENT_ID = p_assignment_id;
  --
  l_effort_report_id NUMBER;
  l_selection_match_level VARCHAR2(30);
  l_assignment_id NUMBER;
  --
  person_effort_report_exist EXCEPTION;
  assignment_effort_report_exist EXCEPTION;

BEGIN
  -- If an Effort Report already exists for the person and overlapping date range
  OPEN person_effort_report_csr(p_person_id, p_distribution_date);
  FETCH person_effort_report_csr INTO l_effort_report_id, l_selection_match_level;
  CLOSE person_effort_report_csr;

  IF l_effort_report_id IS NOT NULL THEN
    IF l_selection_match_level = 'EMP' THEN
      RAISE person_effort_report_exist;
    ELSIF l_selection_match_level = 'ASG' THEN
      OPEN assignment_effort_report_csr(l_effort_report_id, p_assignment_id);
      FETCH assignment_effort_report_csr INTO l_assignment_id;
      CLOSE assignment_effort_report_csr;
      IF l_assignment_id IS NOT NULL THEN
        RAISE assignment_effort_report_exist;
      END IF;
    END IF;
  END IF;
EXCEPTION
  WHEN person_effort_report_exist THEN
    fnd_message.set_name('PSP', 'PSP_ER_PERSON_EFF_REPORT_EXIST');
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('DISTRIBUTION_DATE',p_distribution_date);
    fnd_message.raise_error;
  WHEN assignment_effort_report_exist THEN
    fnd_message.set_name('PSP', 'PSP_ER_ASSGN_EFF_REPORT_EXIST');
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('ASSIGNMENT_ID',p_assignment_id);
    fnd_message.set_token('DISTRIBUTION_DATE',p_distribution_date);
    fnd_message.raise_error;
END chk_existing_eff_report;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_record_validity >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_record_validity
  (p_rec                          IN psp_pee_shd.g_rec_type
  ) IS
  --
/*
  CURSOR person_effort_report_csr(p_person_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT per.effort_report_id, prth.selection_match_level
  FROM   psp_eff_reports per,
         psp_report_templates_h prth
  WHERE  per.request_id = prth.request_id
  AND    per.PERSON_ID = p_person_id
  AND    p_distribution_date between per.start_date and per.end_date
  AND    per.STATUS_CODE IN ('N','A');

  CURSOR assignment_effort_report_csr (p_effort_report_id IN NUMBER, p_assignment_id IN NUMBER) IS
  SELECT assignment_id
  FROM   psp_eff_report_details perd
  WHERE  effort_report_id = p_effort_report_id
  AND    ASSIGNMENT_ID = p_assignment_id;
*/
  CURSOR business_group_csr(p_business_group_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT business_group_id
  FROM   per_business_groups
  where  business_group_id = p_business_group_id
  AND    p_distribution_date between DATE_FROM and nvl(DATE_TO,to_date('31/12/4712','DD/MM/RRRR'));

  CURSOR set_of_books_csr(p_set_of_books_id IN NUMBER) IS
  SELECT set_of_books_id
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = p_set_of_books_id;

  CURSOR person_csr(p_person_id IN NUMBER, p_business_group_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT person_id
  FROM   per_all_people_f
  WHERE  person_id = p_person_id
  AND    current_employee_flag = 'Y'
  AND    business_group_id = p_business_group_id
  AND    p_distribution_date between effective_start_date and effective_end_date;

  CURSOR assignment_csr(p_assignment_id IN NUMBER, p_person_id IN NUMBER,  p_business_group_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT assignment_id
  FROM   per_all_assignments_f paaf,
         pay_all_payrolls_f papf
  WHERE  paaf.payroll_id = papf.payroll_id
  AND    paaf.assignment_id = p_assignment_id
  AND    paaf.person_id = p_person_id
  AND    paaf.business_group_id = p_business_group_id
  AND    p_distribution_date between paaf.effective_start_date and paaf.effective_end_date
  AND    p_distribution_date between papf.effective_start_date and papf.effective_end_date;

  CURSOR currency_csr (p_currency_code IN VARCHAR2, p_distribution_date IN DATE )IS
  SELECT fc.currency_code
  FROM   fnd_currencies fc,
         per_business_groups pbg
  WHERE  fc.currency_code =pbg.currency_code
  AND    fc.enabled_flag = 'Y'
  AND    fc.currency_flag = 'Y'
  AND    fc.currency_code = p_currency_code
  AND    p_distribution_date between nvl(fc.start_date_active,p_distribution_date) and nvl(fc.end_date_active ,to_date('31/12/4712','DD/MM/RRRR'))
  AND    p_distribution_date between date_from and nvl(pbg.DATE_TO,to_date('31/12/4712','DD/MM/RRRR'));

  CURSOR gl_code_combination_csr  (p_gl_code_combination_id IN NUMBER) IS
  SELECT code_combination_id
  FROM   gl_code_combinations
  WHERE  code_combination_id = p_gl_code_combination_id
  AND    enabled_flag ='Y';

  CURSOR project_csr(p_project_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT project_id
  FROM   pa_projects_all
  WHERE  project_id = p_project_id
  AND    p_distribution_date between nvl(start_date,trunc(p_distribution_date)) and nvl(completion_date,to_date('31/12/4712','DD/MM/RRRR'));

  CURSOR task_csr(p_task_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT task_id
  FROM   pa_tasks
  WHERE  task_id = p_task_id
  AND    p_distribution_date between nvl(start_date,trunc(p_distribution_date)) and nvl(completion_date,to_date('31/12/4712','DD/MM/RRRR'));

  CURSOR award_csr(p_award_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT award_id
  FROM   gms_awards_all
  WHERE  award_id = p_award_id
  AND    p_distribution_date between nvl(start_date_active,trunc(p_distribution_date)) and nvl(end_date_active,to_date('31/12/4712','DD/MM/RRRR'));

  CURSOR expenditure_organization_csr(p_expenditure_organization_id IN NUMBER, p_distribution_date IN DATE) IS
  SELECT organization_id
  FROM   psp_organizations_expend_v
  WHERE  organization_id = p_expenditure_organization_id
  AND    trunc(p_distribution_date) between date_from and nvl(date_to,trunc(p_distribution_date));

  --
  l_effort_report_id NUMBER;
  l_selection_match_level VARCHAR2(30);
  l_assignment_id_temp NUMBER;
  l_business_group_id NUMBER;
  l_set_of_books_id NUMBER;
  l_person_id NUMBER;
  l_assignment_id NUMBER;
  l_currency_code VARCHAR2(15);
  l_project_id NUMBER;
  l_task_id NUMBER;
  l_award_id NUMBER;
  l_expenditure_organization_id NUMBER;
  l_gl_code_combination_id NUMBER;
  --
/*
  person_effort_report_exist EXCEPTION;
  assignment_effort_report_exist EXCEPTION;
*/
  invalid_business_group EXCEPTION;
  invalid_set_of_books EXCEPTION;
  invalid_person EXCEPTION;
  invalid_assignment EXCEPTION;
  invalid_currency EXCEPTION;
  invalid_gl_code_combination EXCEPTION;
  invalid_project EXCEPTION;
  invalid_task EXCEPTION;
  invalid_award EXCEPTION;
  invalid_exp_org EXCEPTION;
  no_charging_instruction EXCEPTION;
  extra_charging_instruction  EXCEPTION;

  --
BEGIN
/*
-- If an Effort Report already exists for the person and overlapping date range
  OPEN person_effort_report_csr(p_rec.person_id, p_rec.distribution_date);
  FETCH person_effort_report_csr INTO l_effort_report_id, l_selection_match_level;
  CLOSE person_effort_report_csr;

  IF l_effort_report_id IS NOT NULL THEN
    IF l_selection_match_level = 'EMP' THEN
      RAISE person_effort_report_exist;
    ELSIF l_selection_match_level = 'ASG' THEN
      OPEN assignment_effort_report_csr(l_effort_report_id, p_rec.assignment_id);
      FETCH assignment_effort_report_csr INTO l_assignment_id_temp;
      CLOSE assignment_effort_report_csr;
      IF l_assignment_id IS NOT NULL THEN
        RAISE assignment_effort_report_exist;
      END IF;
    END IF;
  END IF;
*/

chk_existing_eff_report(p_rec.person_id, p_rec.assignment_id, p_rec.distribution_date);
-- If Business_group is invalid
  OPEN business_group_csr (p_rec.business_group_id,  p_rec.distribution_date);
  FETCH business_group_csr INTO l_business_group_id;
  CLOSE business_group_csr;
  IF l_business_group_id IS NULL THEN
    RAISE invalid_business_group;
  END IF;

-- If set of books is invalid
  OPEN set_of_books_csr(p_rec.set_of_books_id);
  FETCH set_of_books_csr INTO l_set_of_books_id;
  CLOSE set_of_books_csr;
  IF l_set_of_books_id IS NULL THEN
    RAISE invalid_set_of_books;
  END IF;

-- If person is invalid
  OPEN person_csr(p_rec.person_id, p_rec.business_group_id, p_rec.distribution_date);
  FETCH person_csr INTO l_person_id;
  CLOSE person_csr;
  IF l_person_id IS NULL THEN
    RAISE invalid_person;
  END IF;

-- If assignment is invalid
  OPEN assignment_csr (p_rec.assignment_id, p_rec.person_id, p_rec.business_group_id, p_rec.distribution_date);
  FETCH assignment_csr INTO l_assignment_id;
  CLOSE assignment_csr;
  IF l_assignment_id IS NULL THEN
    RAISE invalid_assignment;
  END IF;

-- If currency  is invalid
  OPEN currency_csr(p_rec.currency_code, p_rec.distribution_date);
  FETCH currency_csr INTO l_currency_code;
  CLOSE currency_csr;
  IF l_currency_code IS NULL THEN
    RAISE invalid_currency;
  END IF;


  -- Check PTAOE or GL
  IF p_rec.project_id IS NULL AND p_rec.gl_code_combination_id IS NULL THEN
    RAISE no_charging_instruction;
  END IF;

  IF p_rec.gl_code_combination_id IS NOT NULL
     AND (p_rec.project_id IS NOT NULL
          OR p_rec.task_id IS NOT NULL
          OR p_rec.award_id IS NOT NULL
          OR p_rec.expenditure_organization_id IS NOT NULL
          OR p_rec.expenditure_type IS NOT NULL
	  )
  THEN
    RAISE extra_charging_instruction;
  END IF;

  IF p_rec.gl_code_combination_id IS NOT NULL THEN
    -- If glccid is invalid
    OPEN gl_code_combination_csr(p_rec.gl_code_combination_id);
    FETCH gl_code_combination_csr INTO l_gl_code_combination_id;
    CLOSE gl_code_combination_csr;
    IF l_gl_code_combination_id IS NULL THEN
      RAISE invalid_gl_code_combination;
    END IF;
  ELSIF p_rec.project_id IS NOT NULL THEN
    -- If Project is invalid
    OPEN project_csr(p_rec.project_id, p_rec.distribution_date);
    FETCH project_csr into l_project_id;
    CLOSE project_csr;
    IF l_project_id IS NULL THEN
      RAISE invalid_project;
    END IF;

    -- If task is invalid
    IF p_rec.task_id IS NOT NULL THEN
      OPEN task_csr(p_rec.task_id, p_rec.distribution_date);
      FETCH task_csr into l_task_id;
      CLOSE task_csr;
      IF l_task_id IS NULL THEN
        RAISE invalid_task;
      END IF;
    END IF;

    -- If award is invalid
    IF p_rec.award_id IS NOT NULL THEN
      OPEN award_csr(p_rec.award_id, p_rec.distribution_date);
      FETCH award_csr into l_award_id;
      CLOSE award_csr;
      IF l_award_id IS NULL THEN
        RAISE invalid_award;
      END IF;
    END IF;

    -- If expenditure_organization is invalid
    IF p_rec.expenditure_organization_id IS NOT NULL THEN
      OPEN expenditure_organization_csr(p_rec.expenditure_organization_id, p_rec.distribution_date);
      FETCH expenditure_organization_csr into l_expenditure_organization_id;
      CLOSE expenditure_organization_csr;
      IF l_expenditure_organization_id IS NULL THEN
        RAISE invalid_exp_org;
      END IF;
    END IF;

  END IF;


EXCEPTION
/*
  WHEN person_effort_report_exist THEN
    fnd_message.set_name('PSP', 'PSP_ER_PERSON_EFF_REPORT_EXIST');
    fnd_message.set_token('PERSON_ID',p_rec.person_id);
    fnd_message.set_token('DISTRIBUTION_DATE',p_rec.distribution_date);
    fnd_message.raise_error;
  WHEN assignment_effort_report_exist THEN
    fnd_message.set_name('PSP', 'PSP_ER_ASSGN_EFF_REPORT_EXIST');
    fnd_message.set_token('PERSON_ID',p_rec.person_id);
    fnd_message.set_token('ASSIGNMENt_ID',p_rec.assignment_id);
    fnd_message.set_token('DISTRIBUTION_DATE',p_rec.distribution_date);
    fnd_message.raise_error;
*/
  WHEN invalid_business_group THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_BUSINESS_GROUP');
    fnd_message.set_token('BUSINESS_GROUP_ID',p_rec.business_group_id);
    fnd_message.raise_error;
  WHEN invalid_set_of_books THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_SET_OF_BOOKS');
    fnd_message.set_token('SET_OF_BOOKS_ID',p_rec.set_of_books_id);
    fnd_message.raise_error;
  WHEN invalid_person THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_PERSON');
    fnd_message.set_token('PERSON_ID',p_rec.person_id);
    fnd_message.raise_error;
  WHEN invalid_assignment THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_ASSIGNMENT');
    fnd_message.set_token('ASSIGNMENT_ID',p_rec.assignment_id);
    fnd_message.raise_error;
  WHEN invalid_currency THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_CURRENCY');
    fnd_message.set_token('CURRENCY_CODE',p_rec.currency_code);
    fnd_message.raise_error;
  WHEN invalid_project THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_PROJECT');
    fnd_message.set_token('PROJECT_ID',p_rec.project_id);
    fnd_message.raise_error;
  WHEN invalid_task THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_TASK');
    fnd_message.set_token('TASK_ID',p_rec.task_id);
    fnd_message.raise_error;
  WHEN invalid_award THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_AWARD');
    fnd_message.set_token('AWARD_ID',p_rec.award_id);
    fnd_message.raise_error;
  WHEN invalid_exp_org THEN
    fnd_message.set_name('PSP', 'PSP_ER_INVALID_EXP_ORG');
    fnd_message.set_token('EXPENDITURE_ORGANIZATION_ID',p_rec.expenditure_organization_id);
    fnd_message.raise_error;
  WHEN extra_charging_instruction THEN
    fnd_message.set_name('PSP', 'PSP_ER_EXTRA_CI');
    fnd_message.set_token('EXPENDITURE_ORGANIZATION_ID',p_rec.expenditure_organization_id);
    fnd_message.raise_error;
  WHEN no_charging_instruction THEN
    fnd_message.set_name('PSP', 'PSP_POETA_GL');
    fnd_message.raise_error;
END chk_record_validity;



--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in psp_pee_shd.g_rec_type
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
    ,p_associated_column1 => psp_pee_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  chk_set_of_books_id (p_set_of_books_id  => p_rec.set_of_books_id );

  chk_person_id
  ( p_person_id         => p_rec.person_id
  , p_business_group_id => p_rec.business_group_id
  , p_distribution_date => p_rec.distribution_date );


  chk_assignment_id
  ( p_assignment_id     => p_rec.assignment_id
  , p_person_id         => p_rec.person_id
  , p_business_group_id => p_rec.business_group_id
  , p_distribution_date => p_rec.distribution_date );


  chk_existing_eff_report
  ( p_person_id         => p_rec.person_id
  , p_assignment_id     => p_rec.assignment_id
  , p_distribution_date => p_rec.distribution_date );


  chk_currency
  ( p_currency_code     => p_rec.currency_code
  , p_distribution_date => p_rec.distribution_date );

  chk_ptaoe_gl_combination(p_rec);

  IF p_rec.gl_code_combination_id IS NOT NULL THEN
    chk_gl_code_combination ( p_gl_code_combination_id   => p_rec.gl_code_combination_id );
  END IF;

  IF p_rec.project_id IS NOT NULL THEN
    chk_project_id
    ( p_project_id	      => p_rec.project_id
    , p_distribution_date     => p_rec.distribution_date );
  END IF;

  IF p_rec.task_id  IS NOT NULL THEN
    chk_task_id
    ( p_task_id	          => p_rec.task_id
    , p_distribution_date => p_rec.distribution_date );
  END IF;

  IF p_rec.award_id  IS NOT NULL THEN
    chk_award_id
    ( p_award_id	  => p_rec.award_id
    , p_distribution_date => p_rec.distribution_date );
  END IF;


  IF p_rec.expenditure_organization_id IS NOT NULL THEN
    chk_exp_org_id
    ( p_expenditure_organization_id => p_rec.expenditure_organization_id
    , p_distribution_date           => p_rec.distribution_date );
  END IF;

  psp_pee_bus.chk_df(p_rec);
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in psp_pee_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => psp_pee_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  chk_set_of_books_id (p_set_of_books_id  => p_rec.set_of_books_id );

  chk_person_id
  ( p_person_id         => p_rec.person_id
  , p_business_group_id => p_rec.business_group_id
  , p_distribution_date => p_rec.distribution_date );


  chk_assignment_id
  ( p_assignment_id     => p_rec.assignment_id
  , p_person_id         => p_rec.person_id
  , p_business_group_id => p_rec.business_group_id
  , p_distribution_date => p_rec.distribution_date );


  chk_existing_eff_report
  ( p_person_id         => p_rec.person_id
  , p_assignment_id     => p_rec.assignment_id
  , p_distribution_date => p_rec.distribution_date );


  chk_currency
  ( p_currency_code     => p_rec.currency_code
  , p_distribution_date => p_rec.distribution_date );

  chk_ptaoe_gl_combination(p_rec);

  IF p_rec.gl_code_combination_id IS NOT NULL THEN
    chk_gl_code_combination ( p_gl_code_combination_id   => p_rec.gl_code_combination_id );
  END IF;

  IF p_rec.project_id IS NOT NULL THEN
    chk_project_id
    ( p_project_id	      => p_rec.project_id
    , p_distribution_date     => p_rec.distribution_date );
  END IF;

  IF p_rec.task_id  IS NOT NULL THEN
    chk_task_id
    ( p_task_id	          => p_rec.task_id
    , p_distribution_date => p_rec.distribution_date );
  END IF;

  IF p_rec.award_id  IS NOT NULL THEN
    chk_award_id
    ( p_award_id	  => p_rec.award_id
    , p_distribution_date => p_rec.distribution_date );
  END IF;


  IF p_rec.expenditure_organization_id IS NOT NULL THEN
    chk_exp_org_id
    ( p_expenditure_organization_id => p_rec.expenditure_organization_id
    , p_distribution_date           => p_rec.distribution_date );
  END IF;

  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  psp_pee_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in psp_pee_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_existing_eff_report(p_rec.person_id, p_rec.assignment_id, p_rec.distribution_date);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end psp_pee_bus;

/
