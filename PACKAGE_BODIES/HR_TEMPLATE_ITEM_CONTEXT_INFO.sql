--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_ITEM_CONTEXT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_ITEM_CONTEXT_INFO" 
/* $Header: hrticinf.pkb 120.0 2005/05/31 03:09:37 appldev noship $ */
AS
  --
  -- Global variables
  --
  g_form_template_id             hr_form_templates_b.form_template_id%TYPE;
  g_template_item_contexts       t_template_item_contexts := t_template_item_contexts();
  --
  g_form_template_id_pst         hr_form_templates_b.form_template_id%TYPE;
  g_template_item_contexts_pst   t_template_item_contexts_pst;
  g_index_number_pst             NUMBER;
  g_null_template_item_contexts  t_template_item_contexts_pst;
  --
  -- Global cursors
  --
  CURSOR csr_template_item_contexts
    (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
    )
  IS
    SELECT tic.template_item_context_id
          ,tic.template_item_id
          ,fim.full_item_name
          ,fim.item_type
          ,fwn.window_name
          ,fcn.canvas_name
          ,ftp.tab_page_name
          ,fim.radio_button_name
          ,tic.context_type
          ,icx.segment1
          ,icx.segment2
          ,icx.segment3
          ,icx.segment4
          ,icx.segment5
          ,icx.segment6
          ,icx.segment7
          ,icx.segment8
          ,icx.segment9
          ,icx.segment10
          ,icx.segment11
          ,icx.segment12
          ,icx.segment13
          ,icx.segment14
          ,icx.segment15
          ,icx.segment16
          ,icx.segment17
          ,icx.segment18
          ,icx.segment19
          ,icx.segment20
          ,icx.segment21
          ,icx.segment22
          ,icx.segment23
          ,icx.segment24
          ,icx.segment25
          ,icx.segment26
          ,icx.segment27
          ,icx.segment28
          ,icx.segment29
          ,icx.segment30
          ,itp.alignment
          ,itp.bevel
          ,itp.case_restriction
          ,ipt.default_value
          ,itp.enabled
          ,itp.format_mask
          ,itp.height
          ,itp.information_formula_id
          ,hr_form_item_info.full_item_name(itp.information_parameter_item_id1) information_parameter_item1
          ,hr_form_item_info.full_item_name(itp.information_parameter_item_id2) information_parameter_item2
          ,hr_form_item_info.full_item_name(itp.information_parameter_item_id3) information_parameter_item3
          ,hr_form_item_info.full_item_name(itp.information_parameter_item_id4) information_parameter_item4
          ,hr_form_item_info.full_item_name(itp.information_parameter_item_id5) information_parameter_item5
          ,ipt.information_prompt
          ,itp.insert_allowed
          ,ipt.label
          ,hr_form_item_info.full_item_name(itp.next_navigation_item_id) next_navigation_item
          ,hr_form_item_info.full_item_name(itp.previous_navigation_item_id) previous_navigation_item
          ,itp.prompt_alignment_offset
          ,itp.prompt_display_style
          ,itp.prompt_edge
          ,itp.prompt_edge_alignment
          ,itp.prompt_edge_offset
          ,ipt.prompt_text
          ,itp.prompt_text_alignment
          ,itp.query_allowed
          ,itp.required
          ,ipt.tooltip_text
          ,itp.update_allowed
          ,itp.validation_formula_id
          ,hr_form_item_info.full_item_name(itp.validation_parameter_item_id1) validation_parameter_item1
          ,hr_form_item_info.full_item_name(itp.validation_parameter_item_id2) validation_parameter_item2
          ,hr_form_item_info.full_item_name(itp.validation_parameter_item_id3) validation_parameter_item3
          ,hr_form_item_info.full_item_name(itp.validation_parameter_item_id4) validation_parameter_item4
          ,hr_form_item_info.full_item_name(itp.validation_parameter_item_id5) validation_parameter_item5
          ,itp.visible
          ,itp.width
          ,itp.x_position
          ,itp.y_position
          ,itp.information_category
          ,itp.information1
          ,itp.information2
          ,itp.information3
          ,itp.information4
          ,itp.information5
          ,itp.information6
          ,itp.information7
          ,itp.information8
          ,itp.information9
          ,itp.information10
          ,itp.information11
          ,itp.information12
          ,itp.information13
          ,itp.information14
          ,itp.information15
          ,itp.information16
          ,itp.information17
          ,itp.information18
          ,itp.information19
          ,itp.information20
          ,itp.information21
          ,itp.information22
          ,itp.information23
          ,itp.information24
          ,itp.information25
          ,itp.information26
          ,itp.information27
          ,itp.information28
          ,itp.information29
          ,itp.information30
          ,fim.full_item_name AS deleted -- 'N'
      FROM hr_form_tab_pages_b ftp
          ,hr_template_tab_pages_b ttp
          ,hr_template_item_context_pages tcp
          ,hr_form_windows_b fwn
          ,hr_form_canvases_b fcn
          ,hr_form_items_b fim
          ,hr_item_contexts icx
          ,hr_item_properties_tl ipt
          ,hr_item_properties_b itp
          ,hr_template_item_contexts_b tic
          ,hr_template_items_b tim
     WHERE ftp.form_tab_page_id (+) = ttp.form_tab_page_id
       AND ttp.template_tab_page_id (+) = tcp.template_tab_page_id
       AND tcp.template_item_context_id (+) = tic.template_item_context_id
       AND fwn.form_window_id = fcn.form_window_id
       AND fcn.form_canvas_id = fim.form_canvas_id
       AND fim.form_item_id = tim.form_item_id
       AND icx.item_context_id = tic.item_context_id
       AND ipt.language = userenv('LANG')
       AND ipt.item_property_id = itp.item_property_id
       AND itp.template_item_context_id = tic.template_item_context_id
       AND tic.template_item_id = tim.template_item_id
       AND tim.form_template_id = p_form_template_id;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< template_item_contexts >------------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_item_contexts
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_item_contexts
IS
  --
  l_template_item_contexts       t_template_item_contexts := t_template_item_contexts();
--
BEGIN
  --
  FOR l_template_item_context IN csr_template_item_contexts
    (p_form_template_id             => p_form_template_id
    )
  LOOP
    IF (l_template_item_context.template_item_context_id IS NULL)
    THEN
      l_template_item_context.visible := 5;
    END IF;
    l_template_item_contexts.EXTEND;
    l_template_item_contexts(l_template_item_contexts.LAST) := l_template_item_context;
  END LOOP;
  --
  RETURN(l_template_item_contexts);
--
END template_item_contexts;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< template_item_contexts_pst >----------------------|
-- -----------------------------------------------------------------------------
FUNCTION template_item_contexts_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_item_contexts_pst
IS
  --
  l_template_item_contexts_pst   t_template_item_contexts_pst;
  l_index_number                 NUMBER;
--
BEGIN
  --
  IF (p_form_template_id = g_form_template_id_pst)
  THEN
    --
    NULL;
  --
  ELSE
    --
    g_template_item_contexts_pst := g_null_template_item_contexts;
    l_index_number := 1;
    FOR l_template_item_context IN csr_template_item_contexts
      (p_form_template_id             => p_form_template_id
      )
    LOOP
      IF (l_template_item_context.template_item_context_id IS NULL)
      THEN
        l_template_item_context.visible := 5;
      END IF;
      g_template_item_contexts_pst(l_index_number) := l_template_item_context;
      l_index_number := l_index_number + 1;
    END LOOP;
    --
    g_form_template_id_pst := p_form_template_id;
    g_index_number_pst := g_template_item_contexts_pst.FIRST;
  --
  END IF;
  --
  l_index_number := g_index_number_pst;
  WHILE (   (l_index_number IS NOT NULL)
        AND (l_index_number < g_index_number_pst + 50) )
  LOOP
    l_template_item_contexts_pst(l_index_number) := g_template_item_contexts_pst(l_index_number);
    l_index_number := g_template_item_contexts_pst.NEXT(l_index_number);
  END LOOP;
  g_index_number_pst := l_index_number;
  IF (l_template_item_contexts_pst.COUNT = 0)
  THEN
    g_form_template_id_pst := NULL;
  END IF;
  --
  RETURN(l_template_item_contexts_pst);
--
END template_item_contexts_pst;
--
END hr_template_item_context_info;

/
