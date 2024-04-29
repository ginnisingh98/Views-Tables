--------------------------------------------------------
--  DDL for Package HR_FORM_STACK_CANVAS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_STACK_CANVAS_INFO" 
/* $Header: hrfscinf.pkh 120.0 2005/05/31 00:28:07 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_form_stack_canvas IS RECORD
    (form_stack_canvas_id           hr_form_tab_stacked_canvases.form_tab_stacked_canvas_id%TYPE
    ,canvas_name                    hr_form_canvases_b.canvas_name%TYPE
    ,tab_page_name                  hr_form_tab_pages_b.tab_page_name%TYPE
    ,stack_canvas_name              hr_form_canvases_b.canvas_name%TYPE
    );
  TYPE t_form_stack_canvases IS TABLE OF t_form_stack_canvas;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< form_stack_canvases >--------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all stacked
--   canvases for a form.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_application_id               Y number   Application identifier
--   p_form_id                      Y number   Form identifier
--
-- Post Success
--   A table containing the details of the form stacked canvases is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION form_stack_canvases
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_stack_canvases;
--
END hr_form_stack_canvas_info;

 

/
