--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_CANVAS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_CANVAS_INFO" 
/* $Header: hrtcninf.pkh 120.0 2005/05/31 02:58:16 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_template_canvas IS RECORD
    (template_canvas_id             hr_template_canvases_b.template_canvas_id%TYPE
    ,canvas_name                    hr_form_canvases_b.canvas_name%TYPE
    ,canvas_type                    hr_form_canvases_b.canvas_type%TYPE
    ,window_name                    hr_form_windows_b.window_name%TYPE
    ,height                         hr_canvas_properties.height%TYPE
    ,visible                        hr_canvas_properties.visible%TYPE
    ,width                          hr_canvas_properties.width%TYPE
    ,x_position                     hr_canvas_properties.x_position%TYPE
    ,y_position                     hr_canvas_properties.y_position%TYPE
    ,information_category           hr_canvas_properties.information_category%TYPE
    ,information1                   hr_canvas_properties.information1%TYPE
    ,information2                   hr_canvas_properties.information2%TYPE
    ,information3                   hr_canvas_properties.information3%TYPE
    ,information4                   hr_canvas_properties.information4%TYPE
    ,information5                   hr_canvas_properties.information5%TYPE
    ,information6                   hr_canvas_properties.information6%TYPE
    ,information7                   hr_canvas_properties.information7%TYPE
    ,information8                   hr_canvas_properties.information8%TYPE
    ,information9                   hr_canvas_properties.information9%TYPE
    ,information10                  hr_canvas_properties.information10%TYPE
    ,information11                  hr_canvas_properties.information11%TYPE
    ,information12                  hr_canvas_properties.information12%TYPE
    ,information13                  hr_canvas_properties.information13%TYPE
    ,information14                  hr_canvas_properties.information14%TYPE
    ,information15                  hr_canvas_properties.information15%TYPE
    ,information16                  hr_canvas_properties.information16%TYPE
    ,information17                  hr_canvas_properties.information17%TYPE
    ,information18                  hr_canvas_properties.information18%TYPE
    ,information19                  hr_canvas_properties.information19%TYPE
    ,information20                  hr_canvas_properties.information20%TYPE
    ,information21                  hr_canvas_properties.information21%TYPE
    ,information22                  hr_canvas_properties.information22%TYPE
    ,information23                  hr_canvas_properties.information23%TYPE
    ,information24                  hr_canvas_properties.information24%TYPE
    ,information25                  hr_canvas_properties.information25%TYPE
    ,information26                  hr_canvas_properties.information26%TYPE
    ,information27                  hr_canvas_properties.information27%TYPE
    ,information28                  hr_canvas_properties.information28%TYPE
    ,information29                  hr_canvas_properties.information29%TYPE
    ,information30                  hr_canvas_properties.information30%TYPE
    );
  TYPE t_template_canvases IS TABLE OF t_template_canvas;
  TYPE t_template_canvases_pst IS TABLE OF t_template_canvas INDEX BY BINARY_INTEGER;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< template_canvases >---------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all canvases for a
--   template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A table containing the details of the template canvases is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_canvases
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_canvases;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< template_canvases_pst >-------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all canvases for a
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
--   A table containing the details of the template canvases is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_canvases_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_canvases_pst;
--
END hr_template_canvas_info;

 

/
