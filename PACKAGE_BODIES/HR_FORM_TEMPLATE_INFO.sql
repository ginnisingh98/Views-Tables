--------------------------------------------------------
--  DDL for Package Body HR_FORM_TEMPLATE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_TEMPLATE_INFO" 
/* $Header: hrtmpinf.pkb 120.0 2005/05/31 03:21:18 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_form_template_id             hr_form_templates_b.form_template_id%TYPE;
  g_form_template                t_form_template;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_template >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_template
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_form_template
IS
  --
  CURSOR csr_form_templates
    (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
    )
  IS
    SELECT tmp.form_template_id
          ,tmp.application_id
          ,tmp.form_id
          ,tmp.template_name
          ,tmp.legislation_code
          ,tmp.enabled_flag
          ,tmp.help_target
          ,tmp.information_category
          ,tmp.information1
          ,tmp.information2
          ,tmp.information3
          ,tmp.information4
          ,tmp.information5
          ,tmp.information6
          ,tmp.information7
          ,tmp.information8
          ,tmp.information9
          ,tmp.information10
          ,tmp.information11
          ,tmp.information12
          ,tmp.information13
          ,tmp.information14
          ,tmp.information15
          ,tmp.information16
          ,tmp.information17
          ,tmp.information18
          ,tmp.information19
          ,tmp.information20
          ,tmp.information21
          ,tmp.information22
          ,tmp.information23
          ,tmp.information24
          ,tmp.information25
          ,tmp.information26
          ,tmp.information27
          ,tmp.information28
          ,tmp.information29
          ,tmp.information30
      FROM hr_form_templates tmp
     WHERE tmp.form_template_id = p_form_template_id;
  --
  l_proc                         VARCHAR2(61) := 'form_template (1)';
  l_form_template                t_form_template;
--
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc||': '||TO_CHAR(p_form_template_id),10);
  --
  IF (p_form_template_id = nvl(g_form_template_id,hr_api.g_number))
  THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    -- The form template has already been found with a previous call to this
    -- function. Just return the global variable.
    --
    l_form_template := g_form_template;
  --
  ELSE
    --
    hr_utility.set_location(l_proc,30);
    --
    -- The identifier is different to the previous call to this function, or
    -- this is the first call to this function.
    --
    OPEN csr_form_templates
      (p_form_template_id             => p_form_template_id
      );
    FETCH csr_form_templates INTO l_form_template;
    IF (csr_form_templates%NOTFOUND)
    THEN
      hr_utility.set_location(l_proc,40);
    END IF;
    CLOSE csr_form_templates;
    --
    hr_utility.set_location(l_proc,50);
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_form_template_id := p_form_template_id;
    g_form_template := l_form_template;
  --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc,60);
  --
  RETURN(l_form_template);
--
END form_template;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_template >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_template
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  ,p_template_name                IN     hr_form_templates_b.template_name%TYPE
  ,p_legislation_code             IN     hr_form_templates_b.legislation_code%TYPE
  )
RETURN t_form_template
IS
  --
  CURSOR csr_form_templates
    (p_application_id               IN     hr_form_templates_b.application_id%TYPE
    ,p_form_id                      IN     hr_form_templates_b.form_id%TYPE
    ,p_template_name                IN     hr_form_templates_b.template_name%TYPE
    ,p_legislation_code             IN     hr_form_templates_b.legislation_code%TYPE
    )
  IS
    SELECT tmp.form_template_id
      FROM hr_form_templates_b tmp
     WHERE tmp.application_id = p_application_id
       AND tmp.form_id = p_form_id
       AND tmp.template_name = p_template_name
       AND (  tmp.legislation_code = p_legislation_code
           OR (   tmp.legislation_code IS NULL
              AND p_legislation_code IS NULL));
  CURSOR csr_form_templates2
    (p_application_id              IN     hr_form_templates_b.application_id%TYPE
    ,p_form_id                     IN     hr_form_templates_b.form_id%TYPE
    ,p_template_name               IN     hr_form_templates_b.template_name%TYPE
    )
  IS
    SELECT tmp.form_template_id
      FROM hr_form_templates_b tmp
     WHERE tmp.application_id = p_application_id
       AND tmp.form_id = p_form_id
       AND tmp.template_name = p_template_name
       AND tmp.legislation_code IS NULL;
  l_form_template_internal       csr_form_templates%ROWTYPE;
  --
  l_proc                         VARCHAR2(61)    := 'form_template (2)';
  l_form_template                t_form_template;
  l_form_template_found          BOOLEAN         := FALSE;
--
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc||': '||TO_CHAR(p_application_id)||', '||TO_CHAR(p_form_id)||', '||p_template_name||', '||p_legislation_code,10);
  --
  -- Search for a template within the specified legislation
  --
  IF (p_legislation_code IS NOT NULL)
  THEN
    hr_utility.set_location(l_proc,20);
    OPEN csr_form_templates
      (p_application_id               => p_application_id
      ,p_form_id                      => p_form_id
      ,p_template_name                => p_template_name
      ,p_legislation_code             => p_legislation_code
      );
    FETCH csr_form_templates INTO l_form_template_internal;
    l_form_template_found := csr_form_templates%FOUND;
    CLOSE csr_form_templates;
  END IF;
  --
  hr_utility.set_location(l_proc,30);
  --
  -- Search for a template which is not specific to any legislation, if one has
  -- not been found already
  --
  IF (NOT l_form_template_found)
  THEN
    hr_utility.set_location(l_proc||': '||TO_CHAR(p_application_id)||', '||TO_CHAR(p_form_id)||', '||p_template_name,40);
    OPEN csr_form_templates2
      (p_application_id               => p_application_id
      ,p_form_id                      => p_form_id
      ,p_template_name                => p_template_name
      );
    FETCH csr_form_templates2 INTO l_form_template_internal;
    l_form_template_found := csr_form_templates2%FOUND;
    CLOSE csr_form_templates2;
  END IF;
  --
  hr_utility.set_location(l_proc,50);
  --
  IF (l_form_template_found)
  THEN
    hr_utility.set_location(l_proc,60);
    l_form_template := form_template
      (p_form_template_id             => l_form_template_internal.form_template_id
      );
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc,70);
  --
  RETURN(l_form_template);
--
END form_template;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_template >-----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_template
  (p_function_name                IN     fnd_form_functions.function_name%TYPE
  ,p_template_name                IN     hr_form_templates_b.template_name%TYPE
  ,p_legislation_code             IN     hr_form_templates_b.legislation_code%TYPE
  )
RETURN t_form_template
IS
  --
  CURSOR csr_form_functions
    (p_function_name                IN     fnd_form_functions.function_name%TYPE
    )
  IS
    SELECT fnc.application_id
          ,fnc.form_id
      FROM fnd_form_functions fnc
     WHERE fnc.function_name = p_function_name;
  l_form_function                csr_form_functions%ROWTYPE;
  --
  l_proc                         VARCHAR2(61)    := 'form_template (3)';
  l_form_template                t_form_template;
--
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc||': '||p_function_name||', '||p_template_name||', '||p_legislation_code,10);
  --
  OPEN csr_form_functions
    (p_function_name                => p_function_name
    );
  FETCH csr_form_functions INTO l_form_function;
  IF (csr_form_functions%FOUND)
  THEN
    hr_utility.set_location(l_proc,20);
    l_form_template := form_template
      (p_application_id               => l_form_function.application_id
      ,p_form_id                      => l_form_function.form_id
      ,p_template_name                => p_template_name
      ,p_legislation_code             => p_legislation_code
      );
  END IF;
  CLOSE csr_form_functions;
  --
  hr_utility.set_location('Leaving '||l_proc,30);
  --
  RETURN(l_form_template);
--
END form_template;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< application_id >----------------------------|
-- -----------------------------------------------------------------------------
FUNCTION application_id
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN hr_form_templates_b.application_id%TYPE
IS
  --
  l_form_template                t_form_template;
--
BEGIN
  --
  l_form_template := form_template
    (p_form_template_id             => p_form_template_id
    );
  --
  RETURN(l_form_template.application_id);
--
END application_id;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< form_id >--------------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_id
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN hr_form_templates_b.form_id%TYPE
IS
  --
  l_form_template                t_form_template;
--
BEGIN
  --
  l_form_template := form_template
    (p_form_template_id             => p_form_template_id
    );
  --
  RETURN(l_form_template.form_id);
--
END form_id;
--
FUNCTION date_format_mask
RETURN VARCHAR2
IS
BEGIN
  RETURN(fnd_date.output_mask);
END date_format_mask;
--
FUNCTION datetime_format_mask
RETURN VARCHAR2
IS
BEGIN
  RETURN(fnd_date.outputdt_mask);
END datetime_format_mask;
--
END hr_form_template_info;

/
