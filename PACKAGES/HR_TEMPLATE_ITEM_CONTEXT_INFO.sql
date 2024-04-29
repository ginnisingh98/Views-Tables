--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_CONTEXT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_CONTEXT_INFO" 
/* $Header: hrticinf.pkh 120.0 2005/05/31 03:10:04 appldev noship $ */
AUTHID CURRENT_USER AS
  --
  -- Global types
  --
  TYPE t_template_item_context IS RECORD
    (template_item_context_id       hr_template_item_contexts_b.template_item_context_id%TYPE
    ,template_item_id               hr_template_items_b.template_item_id%TYPE
    ,full_item_name                 hr_form_items_b.full_item_name%TYPE
    ,item_type                      hr_form_items_b.item_type%TYPE
    ,window_name                    hr_form_windows_b.window_name%TYPE
    ,canvas_name                    hr_form_canvases_b.canvas_name%TYPE
    ,tab_page_name                  hr_form_tab_pages_b.tab_page_name%TYPE
    ,radio_button_name              hr_form_items_b.radio_button_name%TYPE
    ,context_type                   hr_template_item_contexts_b.context_type%TYPE
    ,segment1                       hr_item_contexts.segment1%TYPE
    ,segment2                       hr_item_contexts.segment2%TYPE
    ,segment3                       hr_item_contexts.segment3%TYPE
    ,segment4                       hr_item_contexts.segment4%TYPE
    ,segment5                       hr_item_contexts.segment5%TYPE
    ,segment6                       hr_item_contexts.segment6%TYPE
    ,segment7                       hr_item_contexts.segment7%TYPE
    ,segment8                       hr_item_contexts.segment8%TYPE
    ,segment9                       hr_item_contexts.segment9%TYPE
    ,segment10                      hr_item_contexts.segment10%TYPE
    ,segment11                      hr_item_contexts.segment11%TYPE
    ,segment12                      hr_item_contexts.segment12%TYPE
    ,segment13                      hr_item_contexts.segment13%TYPE
    ,segment14                      hr_item_contexts.segment14%TYPE
    ,segment15                      hr_item_contexts.segment15%TYPE
    ,segment16                      hr_item_contexts.segment16%TYPE
    ,segment17                      hr_item_contexts.segment17%TYPE
    ,segment18                      hr_item_contexts.segment18%TYPE
    ,segment19                      hr_item_contexts.segment19%TYPE
    ,segment20                      hr_item_contexts.segment20%TYPE
    ,segment21                      hr_item_contexts.segment21%TYPE
    ,segment22                      hr_item_contexts.segment22%TYPE
    ,segment23                      hr_item_contexts.segment23%TYPE
    ,segment24                      hr_item_contexts.segment24%TYPE
    ,segment25                      hr_item_contexts.segment25%TYPE
    ,segment26                      hr_item_contexts.segment26%TYPE
    ,segment27                      hr_item_contexts.segment27%TYPE
    ,segment28                      hr_item_contexts.segment28%TYPE
    ,segment29                      hr_item_contexts.segment29%TYPE
    ,segment30                      hr_item_contexts.segment30%TYPE
    ,alignment                      hr_item_properties_b.alignment%TYPE
    ,bevel                          hr_item_properties_b.bevel%TYPE
    ,case_restriction               hr_item_properties_b.case_restriction%TYPE
    ,default_value                  hr_item_properties_tl.default_value%TYPE
    ,enabled                        hr_item_properties_b.enabled%TYPE
    ,format_mask                    hr_item_properties_b.format_mask%TYPE
    ,height                         hr_item_properties_b.height%TYPE
    ,information_formula_id         hr_item_properties_b.information_formula_id%TYPE
    ,information_parameter_item1    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item2    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item3    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item4    hr_form_items_b.full_item_name%TYPE
    ,information_parameter_item5    hr_form_items_b.full_item_name%TYPE
    ,information_prompt             hr_item_properties_tl.information_prompt%TYPE
    ,insert_allowed                 hr_item_properties_b.insert_allowed%TYPE
    ,label                          hr_item_properties_tl.label%TYPE
    ,next_navigation_item           hr_form_items_b.full_item_name%TYPE
    ,previous_navigation_item       hr_form_items_b.full_item_name%TYPE
    ,prompt_alignment_offset        hr_item_properties_b.prompt_alignment_offset%TYPE
    ,prompt_display_style           hr_item_properties_b.prompt_display_style%TYPE
    ,prompt_edge                    hr_item_properties_b.prompt_edge%TYPE
    ,prompt_edge_alignment          hr_item_properties_b.prompt_edge_alignment%TYPE
    ,prompt_edge_offset             hr_item_properties_b.prompt_edge_offset%TYPE
    ,prompt_text                    hr_item_properties_tl.prompt_text%TYPE
    ,prompt_text_alignment          hr_item_properties_b.prompt_text_alignment%TYPE
    ,query_allowed                  hr_item_properties_b.query_allowed%TYPE
    ,required                       hr_item_properties_b.required%TYPE
    ,tooltip_text                   hr_item_properties_tl.tooltip_text%TYPE
    ,update_allowed                 hr_item_properties_b.update_allowed%TYPE
    ,validation_formula_id          hr_item_properties_b.validation_formula_id%TYPE
    ,validation_parameter_item1     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item2     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item3     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item4     hr_form_items_b.full_item_name%TYPE
    ,validation_parameter_item5     hr_form_items_b.full_item_name%TYPE
    ,visible                        hr_item_properties_b.visible%TYPE
    ,width                          hr_item_properties_b.width%TYPE
    ,x_position                     hr_item_properties_b.x_position%TYPE
    ,y_position                     hr_item_properties_b.y_position%TYPE
    ,information_category           hr_item_properties_b.information_category%TYPE
    ,information1                   hr_item_properties_b.information1%TYPE
    ,information2                   hr_item_properties_b.information2%TYPE
    ,information3                   hr_item_properties_b.information3%TYPE
    ,information4                   hr_item_properties_b.information4%TYPE
    ,information5                   hr_item_properties_b.information5%TYPE
    ,information6                   hr_item_properties_b.information6%TYPE
    ,information7                   hr_item_properties_b.information7%TYPE
    ,information8                   hr_item_properties_b.information8%TYPE
    ,information9                   hr_item_properties_b.information9%TYPE
    ,information10                  hr_item_properties_b.information10%TYPE
    ,information11                  hr_item_properties_b.information11%TYPE
    ,information12                  hr_item_properties_b.information12%TYPE
    ,information13                  hr_item_properties_b.information13%TYPE
    ,information14                  hr_item_properties_b.information14%TYPE
    ,information15                  hr_item_properties_b.information15%TYPE
    ,information16                  hr_item_properties_b.information16%TYPE
    ,information17                  hr_item_properties_b.information17%TYPE
    ,information18                  hr_item_properties_b.information18%TYPE
    ,information19                  hr_item_properties_b.information19%TYPE
    ,information20                  hr_item_properties_b.information20%TYPE
    ,information21                  hr_item_properties_b.information21%TYPE
    ,information22                  hr_item_properties_b.information22%TYPE
    ,information23                  hr_item_properties_b.information23%TYPE
    ,information24                  hr_item_properties_b.information24%TYPE
    ,information25                  hr_item_properties_b.information25%TYPE
    ,information26                  hr_item_properties_b.information26%TYPE
    ,information27                  hr_item_properties_b.information27%TYPE
    ,information28                  hr_item_properties_b.information28%TYPE
    ,information29                  hr_item_properties_b.information29%TYPE
    ,information30                  hr_item_properties_b.information30%TYPE
    ,deleted                        hr_form_items_b.full_item_name%TYPE
    );
  TYPE t_template_item_contexts IS TABLE OF t_template_item_context;
  TYPE t_template_item_contexts_pst IS TABLE OF t_template_item_context INDEX BY BINARY_INTEGER;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< template_item_contexts >------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all item contexts
--   for a template.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A table containing the details of the template item contexts is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_item_contexts
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_item_contexts;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< template_item_contexts_pst >----------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description
--   This function returns a table containing the details of all item contexts
--   for a template. A PL/SQL table is returned so it may be correctly retrieved
--   by procedures within a Forms Application. Forms 6 cannot retrieve nested
--   tables from server-side packages.
--
-- Prerequisites
--   None.
--
-- In Parameters
--   p_form_template_id             Y number   Form template identifier
--
-- Post Success
--   A table containing the details of the template item contexts is returned
--
-- Post Failure
--   An error is raised
--
-- Access Status
--   Internal Development Use Only
--
-- {End of Comments}
-- -----------------------------------------------------------------------------
FUNCTION template_item_contexts_pst
  (p_form_template_id             IN     hr_form_templates_b.form_template_id%TYPE
  )
RETURN t_template_item_contexts_pst;
--
END hr_template_item_context_info;

 

/
