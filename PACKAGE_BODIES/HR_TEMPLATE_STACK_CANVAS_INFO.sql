--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_STACK_CANVAS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_STACK_CANVAS_INFO" 
/* $Header: hrtscinf.pkb 120.0 2005/05/31 03:31:21 appldev noship $ */
AS
-- -----------------------------------------------------------------------------
-- |------------------------< template_stack_canvases >------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_stack_canvases
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_stack_canvases
IS
  --
  l_template_stack_canvases      t_template_stack_canvases                       := t_template_stack_canvases();
  l_form_stack_canvases          hr_form_stack_canvas_info.t_form_stack_canvases := hr_form_stack_canvas_info.t_form_stack_canvases();
  l_index_number                 NUMBER;
--
BEGIN
  --
  l_form_stack_canvases := hr_form_stack_canvas_info.form_stack_canvases
    (p_application_id               => hr_form_template_info.application_id(p_form_template_id)
    ,p_form_id                      => hr_form_template_info.form_id(p_form_template_id)
    );
  --
  l_index_number := l_form_stack_canvases.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_template_stack_canvases.EXTEND;
    l_template_stack_canvases(l_template_stack_canvases.LAST).template_stack_canvas_id := l_form_stack_canvases(l_index_number).form_stack_canvas_id;
    l_template_stack_canvases(l_template_stack_canvases.LAST).canvas_name := l_form_stack_canvases(l_index_number).canvas_name;
    l_template_stack_canvases(l_template_stack_canvases.LAST).tab_page_name := l_form_stack_canvases(l_index_number).tab_page_name;
    l_template_stack_canvases(l_template_stack_canvases.LAST).stack_canvas_name := l_form_stack_canvases(l_index_number).stack_canvas_name;
    l_index_number := l_form_stack_canvases.NEXT(l_index_number);
  END LOOP;
  --
  RETURN(l_template_stack_canvases);
--
END template_stack_canvases;
--
-- -----------------------------------------------------------------------------
-- |----------------------< template_stack_canvases_pst >----------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_stack_canvases_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_stack_canvases_pst
IS
  --
  l_template_stack_canvases_pst  t_template_stack_canvases_pst;
  l_template_stack_canvases      t_template_stack_canvases     := t_template_stack_canvases();
  l_index_number                 NUMBER;
--
BEGIN
  --
  l_template_stack_canvases := template_stack_canvases
    (p_form_template_id             => p_form_template_id
    );
  --
  l_index_number := l_template_stack_canvases.FIRST;
  WHILE (l_index_number IS NOT NULL)
  LOOP
    l_template_stack_canvases_pst(l_index_number) := l_template_stack_canvases(l_index_number);
    l_index_number := l_template_stack_canvases.NEXT(l_index_number);
  END LOOP;
  --
  RETURN(l_template_stack_canvases_pst);
--
END template_stack_canvases_pst;
--
END hr_template_stack_canvas_info;

/
