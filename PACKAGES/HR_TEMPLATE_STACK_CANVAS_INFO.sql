--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_STACK_CANVAS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_STACK_CANVAS_INFO" 
/* $Header: hrtscinf.pkh 120.0 2005/05/31 03:31:34 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_template_stack_canvas IS RECORD
    (template_stack_canvas_id       hr_form_tab_stacked_canvases.form_tab_stacked_canvas_id%TYPE
    ,canvas_name                    hr_form_canvases_b.canvas_name%TYPE
    ,tab_page_name                  hr_form_tab_pages_b.tab_page_name%TYPE
    ,stack_canvas_name              hr_form_canvases_b.canvas_name%TYPE
    );
  TYPE t_template_stack_canvases IS TABLE OF t_template_stack_canvas;
  TYPE t_template_stack_canvases_pst IS TABLE OF t_template_stack_canvas INDEX BY BINARY_INTEGER;
--
-- -----------------------------------------------------------------------------
-- |------------------------< template_stack_canvases >------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all stacked
--   canvases for a template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A table containing the details of the template stacked canvases is
--   returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_stack_canvases
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_stack_canvases;
--
-- -----------------------------------------------------------------------------
-- |----------------------< template_stack_canvases_pst >----------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all stacked
--   canvases for a template. A PL/SQL table is returned so it may be correctly
--   retrieved by procedures within a Forms Application. Forms 6 cannot retrieve
--   nested tables from server-side packages.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A table containing the details of the template stacked canvases is
--   returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_stack_canvases_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_stack_canvases_pst;
--
END hr_template_stack_canvas_info;

 

/
