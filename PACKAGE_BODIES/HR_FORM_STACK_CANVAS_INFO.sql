--------------------------------------------------------
--  DDL for Package Body HR_FORM_STACK_CANVAS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_STACK_CANVAS_INFO" 
/* $Header: hrfscinf.pkb 120.0 2005/05/31 00:27:55 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_application_id               fnd_application.application_id%TYPE;
  g_form_id                      fnd_form.form_id%TYPE;
  g_form_stack_canvases          t_form_stack_canvases := t_form_stack_canvases();
--
-- -----------------------------------------------------------------------------
-- |--------------------------< form_stack_canvases >--------------------------|
-- -----------------------------------------------------------------------------
FUNCTION form_stack_canvases
  (p_application_id               IN     fnd_application.application_id%TYPE
  ,p_form_id                      IN     fnd_form.form_id%TYPE
  )
RETURN t_form_stack_canvases
IS
  --
  CURSOR csr_form_stack_canvases
    (p_application_id               IN     fnd_application.application_id%TYPE
    ,p_form_id                      IN     fnd_form.form_id%TYPE
    )
  IS
    SELECT fsc.form_tab_stacked_canvas_id form_stack_canvas_id
          ,fc1.canvas_name
          ,ftp.tab_page_name
          ,fc2.canvas_name stack_canvas_name
      FROM hr_form_canvases_b fc2
          ,hr_form_tab_stacked_canvases fsc
          ,hr_form_tab_pages_b ftp
          ,hr_form_canvases_b fc1
          ,hr_form_windows_b fwn
     WHERE fc2.form_canvas_id = fsc.form_canvas_id
       AND fsc.form_tab_page_id = ftp.form_tab_page_id
       AND ftp.form_canvas_id = fc1.form_canvas_id
       AND fc1.form_window_id = fwn.form_window_id
       AND fwn.application_id = p_application_id
       AND fwn.form_id = p_form_id;
  --
  l_form_stack_canvases          t_form_stack_canvases := t_form_stack_canvases();
--
BEGIN
  --
  IF (   p_application_id = nvl(g_application_id,hr_api.g_number)
     AND p_form_id = nvl(g_form_id,hr_api.g_number))
  THEN
    --
    -- The form stacked canvases have already been found with a previous call
    -- to this function. Just return the global variable.
    --
    l_form_stack_canvases := g_form_stack_canvases;
  --
  ELSE
    --
    -- The identifiers are different to the previous call to this function, or
    -- this is the first call to this function.
    --
    FOR l_form_stack_canvas IN csr_form_stack_canvases
      (p_application_id               => p_application_id
      ,p_form_id                      => p_form_id
      )
    LOOP
      l_form_stack_canvases.EXTEND;
      l_form_stack_canvases(l_form_stack_canvases.LAST) := l_form_stack_canvas;
    END LOOP;
    --
    -- Set the global variables so the values are available to the next call to
    -- the function.
    --
    g_application_id := p_application_id;
    g_form_id := p_form_id;
    g_form_stack_canvases := l_form_stack_canvases;
  --
  END IF;
  --
  RETURN(l_form_stack_canvases);
--
END form_stack_canvases;
--
END hr_form_stack_canvas_info;

/
