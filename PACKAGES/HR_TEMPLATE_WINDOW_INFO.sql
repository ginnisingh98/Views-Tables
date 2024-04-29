--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_WINDOW_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_WINDOW_INFO" 
/* $Header: hrtwninf.pkh 120.0 2005/05/31 03:35:16 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_template_window IS RECORD
    (template_window_id             hr_template_windows_b.template_window_id%TYPE
    ,window_name                    hr_form_windows_b.window_name%TYPE
    ,height                         hr_window_properties_b.height%TYPE
    ,title                          hr_window_properties_tl.title%TYPE
    ,width                          hr_window_properties_b.width%TYPE
    ,x_position                     hr_window_properties_b.x_position%TYPE
    ,y_position                     hr_window_properties_b.y_position%TYPE
    ,information_category           hr_window_properties_b.information_category%TYPE
    ,information1                   hr_window_properties_b.information1%TYPE
    ,information2                   hr_window_properties_b.information2%TYPE
    ,information3                   hr_window_properties_b.information3%TYPE
    ,information4                   hr_window_properties_b.information4%TYPE
    ,information5                   hr_window_properties_b.information5%TYPE
    ,information6                   hr_window_properties_b.information6%TYPE
    ,information7                   hr_window_properties_b.information7%TYPE
    ,information8                   hr_window_properties_b.information8%TYPE
    ,information9                   hr_window_properties_b.information9%TYPE
    ,information10                  hr_window_properties_b.information10%TYPE
    ,information11                  hr_window_properties_b.information11%TYPE
    ,information12                  hr_window_properties_b.information12%TYPE
    ,information13                  hr_window_properties_b.information13%TYPE
    ,information14                  hr_window_properties_b.information14%TYPE
    ,information15                  hr_window_properties_b.information15%TYPE
    ,information16                  hr_window_properties_b.information16%TYPE
    ,information17                  hr_window_properties_b.information17%TYPE
    ,information18                  hr_window_properties_b.information18%TYPE
    ,information19                  hr_window_properties_b.information19%TYPE
    ,information20                  hr_window_properties_b.information20%TYPE
    ,information21                  hr_window_properties_b.information21%TYPE
    ,information22                  hr_window_properties_b.information22%TYPE
    ,information23                  hr_window_properties_b.information23%TYPE
    ,information24                  hr_window_properties_b.information24%TYPE
    ,information25                  hr_window_properties_b.information25%TYPE
    ,information26                  hr_window_properties_b.information26%TYPE
    ,information27                  hr_window_properties_b.information27%TYPE
    ,information28                  hr_window_properties_b.information28%TYPE
    ,information29                  hr_window_properties_b.information29%TYPE
    ,information30                  hr_window_properties_b.information30%TYPE
    );
  TYPE t_template_windows IS TABLE OF t_template_window;
  TYPE t_template_windows_pst IS TABLE OF t_template_window INDEX BY BINARY_INTEGER;
--
-- -----------------------------------------------------------------------------
-- |----------------------------< template_windows >---------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all windows for a
--   template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A table containing the details of the template windows is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_windows
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_windows;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< template_windows_pst >-------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all windows for a
--   template. A PL/SQL table is returned so it may be correctly retrieved by
--   procedures within a Forms Application. Forms 6 cannot retrieve nested
--   tables from server-side packages.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A table containing the details of the template windows is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_windows_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_windows_pst;
--
END hr_template_window_info;

 

/
