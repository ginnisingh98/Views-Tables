--------------------------------------------------------
--  DDL for Package HR_FORM_TEMPLATE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_TEMPLATE_INFO" 
/* $Header: hrtmpinf.pkh 120.0 2005/05/31 03:21:30 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_form_template IS RECORD
    (form_template_id               hr_form_templates_b.form_template_id%TYPE
    ,application_id                 hr_form_templates_b.application_id%TYPE
    ,form_id                        hr_form_templates_b.form_id%TYPE
    ,template_name                  hr_form_templates_b.template_name%TYPE
    ,legislation_code               hr_form_templates_b.legislation_code%TYPE
    ,enabled_flag                   hr_form_templates_b.enabled_flag%TYPE
    ,help_target                    hr_form_properties.help_target%TYPE
    ,information_category           hr_form_properties.information_category%TYPE
    ,information1                   hr_form_properties.information1%TYPE
    ,information2                   hr_form_properties.information2%TYPE
    ,information3                   hr_form_properties.information3%TYPE
    ,information4                   hr_form_properties.information4%TYPE
    ,information5                   hr_form_properties.information5%TYPE
    ,information6                   hr_form_properties.information6%TYPE
    ,information7                   hr_form_properties.information7%TYPE
    ,information8                   hr_form_properties.information8%TYPE
    ,information9                   hr_form_properties.information9%TYPE
    ,information10                  hr_form_properties.information10%TYPE
    ,information11                  hr_form_properties.information11%TYPE
    ,information12                  hr_form_properties.information12%TYPE
    ,information13                  hr_form_properties.information13%TYPE
    ,information14                  hr_form_properties.information14%TYPE
    ,information15                  hr_form_properties.information15%TYPE
    ,information16                  hr_form_properties.information16%TYPE
    ,information17                  hr_form_properties.information17%TYPE
    ,information18                  hr_form_properties.information18%TYPE
    ,information19                  hr_form_properties.information19%TYPE
    ,information20                  hr_form_properties.information20%TYPE
    ,information21                  hr_form_properties.information21%TYPE
    ,information22                  hr_form_properties.information22%TYPE
    ,information23                  hr_form_properties.information23%TYPE
    ,information24                  hr_form_properties.information24%TYPE
    ,information25                  hr_form_properties.information25%TYPE
    ,information26                  hr_form_properties.information26%TYPE
    ,information27                  hr_form_properties.information27%TYPE
    ,information28                  hr_form_properties.information28%TYPE
    ,information29                  hr_form_properties.information29%TYPE
    ,information30                  hr_form_properties.information30%TYPE
    );
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_template >-----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a record containing the details of the form template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A record containing the details of the form template is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION form_template
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_form_template;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_template >-----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a record containing the details of the form template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_application_id               Y number   Application identifier
--   p_form_id                      Y number   Form identifier
--   p_template_name                Y varchar2 Template name
--   p_legislation_code             Y varchar2 Legislation code
--
-- Post Success
--   A record containing the details of the form template is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION form_template
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  ,p_template_name                IN     hr_form_templates_b.template_name%TYPE
  ,p_legislation_code             IN     hr_form_templates_b.legislation_code%TYPE
  )
RETURN t_form_template;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< form_template >-----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a record containing the details of the form template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_function_name                Y varchar2 Form function name
--   p_template_name                Y varchar2 Template name
--   p_legislation_code             Y varchar2 Legislation code
--
-- Post Success
--   A record containing the details of the form template is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION form_template
  (p_function_name                IN     fnd_form_functions.function_name%TYPE
  ,p_template_name                IN     hr_form_templates_b.template_name%TYPE
  ,p_legislation_code             IN     hr_form_templates_b.legislation_code%TYPE
  )
RETURN t_form_template;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< application_id >----------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the application identifier for a form template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   The application identifier associated with the form template is returned.
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION application_id
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN hr_form_templates_b.application_id%TYPE;
--
-- -----------------------------------------------------------------------------
-- |--------------------------------< form_id >--------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns the form identifier for a form template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   The form identifier associated with the form template is returned.
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION form_id
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN hr_form_templates_b.form_id%TYPE;
--
FUNCTION date_format_mask
RETURN VARCHAR2;
--
FUNCTION datetime_format_mask
RETURN VARCHAR2;
--
END hr_form_template_info;

 

/
