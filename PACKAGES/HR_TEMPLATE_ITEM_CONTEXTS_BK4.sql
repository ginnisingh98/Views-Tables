--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_CONTEXTS_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_CONTEXTS_BK4" AUTHID CURRENT_USER as
/* $Header: hrticapi.pkh 120.0 2005/05/31 03:08:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_template_item_context_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_item_context_b
  (p_effective_date               in date
  ,p_language_code                in varchar2
  --,p_context_type                 in varchar2
  ,p_template_item_context_id     in number
  ,p_object_version_number        in number
--  ,p_segment1                     in varchar2
--  ,p_segment2                     in varchar2
--  ,p_segment3                     in varchar2
--  ,p_segment4                     in varchar2
--  ,p_segment5                     in varchar2
--  ,p_segment6                     in varchar2
--  ,p_segment7                     in varchar2
--  ,p_segment8                     in varchar2
--  ,p_segment9                     in varchar2
--  ,p_segment10                    in varchar2
--  ,p_segment11                    in varchar2
--  ,p_segment12                    in varchar2
--  ,p_segment13                    in varchar2
--  ,p_segment14                    in varchar2
--  ,p_segment15                    in varchar2
--  ,p_segment16                    in varchar2
--  ,p_segment17                    in varchar2
--  ,p_segment18                    in varchar2
--  ,p_segment19                    in varchar2
--  ,p_segment20                    in varchar2
--  ,p_segment21                    in varchar2
--  ,p_segment22                    in varchar2
--  ,p_segment23                    in varchar2
--  ,p_segment24                    in varchar2
--  ,p_segment25                    in varchar2
--  ,p_segment26                    in varchar2
--  ,p_segment27                    in varchar2
--  ,p_segment28                    in varchar2
--  ,p_segment29                    in varchar2
--  ,p_segment30                    in varchar2
  ,p_template_tab_page_id         in number
  ,p_alignment                    in number
  ,p_bevel                        in number
  ,p_case_restriction             in number
  ,p_default_value                in varchar2
  ,p_enabled                      in number
  ,p_format_mask                  in varchar2
  ,p_height                       in number
  ,p_information_formula_id       in number
  ,p_information_param_item_id1   in number
  ,p_information_param_item_id2   in number
  ,p_information_param_item_id3   in number
  ,p_information_param_item_id4   in number
  ,p_information_param_item_id5   in number
  ,p_information_prompt           in varchar2
  ,p_insert_allowed               in number
  ,p_label                        in varchar2
  ,p_prompt_text                  in varchar2
  ,p_prompt_alignment_offset      in number
  ,p_prompt_display_style         in number
  ,p_prompt_edge                  in number
  ,p_prompt_edge_alignment        in number
  ,p_prompt_edge_offset           in number
  ,p_prompt_text_alignment        in number
  ,p_query_allowed                in number
  ,p_required                     in number
  ,p_tooltip_text                 in varchar2
  ,p_update_allowed               in number
  ,p_validation_formula_id        in number
  ,p_validation_param_item_id1    in number
  ,p_validation_param_item_id2    in number
  ,p_validation_param_item_id3    in number
  ,p_validation_param_item_id4    in number
  ,p_validation_param_item_id5    in number
  ,p_visible                      in number
  ,p_width                        in number
  ,p_x_position                   in number
  ,p_y_position                   in number
  ,p_information_category         in varchar2
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4                 in varchar2
  ,p_information5                 in varchar2
  ,p_information6                 in varchar2
  ,p_information7                 in varchar2
  ,p_information8                 in varchar2
  ,p_information9                 in varchar2
  ,p_information10                in varchar2
  ,p_information11                in varchar2
  ,p_information12                in varchar2
  ,p_information13                in varchar2
  ,p_information14                in varchar2
  ,p_information15                in varchar2
  ,p_information16                in varchar2
  ,p_information17                in varchar2
  ,p_information18                in varchar2
  ,p_information19                in varchar2
  ,p_information20                in varchar2
  ,p_information21                in varchar2
  ,p_information22                in varchar2
  ,p_information23                in varchar2
  ,p_information24                in varchar2
  ,p_information25                in varchar2
  ,p_information26                in varchar2
  ,p_information27                in varchar2
  ,p_information28                in varchar2
  ,p_information29                in varchar2
  ,p_information30                in varchar2
  ,p_next_navigation_item_id      in number
  ,p_previous_navigation_item_id  in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_template_item_context_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_item_context_a
  (p_effective_date               in date
  ,p_language_code                in varchar2
  --,p_context_type                 in varchar2
  ,p_template_item_context_id     in number
  ,p_object_version_number        in number
--  ,p_segment1                     in varchar2
--  ,p_segment2                     in varchar2
--  ,p_segment3                     in varchar2
--  ,p_segment4                     in varchar2
--  ,p_segment5                     in varchar2
--  ,p_segment6                     in varchar2
--  ,p_segment7                     in varchar2
--  ,p_segment8                     in varchar2
--  ,p_segment9                     in varchar2
--  ,p_segment10                    in varchar2
--  ,p_segment11                    in varchar2
--  ,p_segment12                    in varchar2
--  ,p_segment13                    in varchar2
--  ,p_segment14                    in varchar2
--  ,p_segment15                    in varchar2
--  ,p_segment16                    in varchar2
--  ,p_segment17                    in varchar2
--  ,p_segment18                    in varchar2
--  ,p_segment19                    in varchar2
--  ,p_segment20                    in varchar2
--  ,p_segment21                    in varchar2
--  ,p_segment22                    in varchar2
--  ,p_segment23                    in varchar2
--  ,p_segment24                    in varchar2
--  ,p_segment25                    in varchar2
--  ,p_segment26                    in varchar2
--  ,p_segment27                    in varchar2
--  ,p_segment28                    in varchar2
--  ,p_segment29                    in varchar2
--  ,p_segment30                    in varchar2
  ,p_template_tab_page_id         in number
  ,p_alignment                    in number
  ,p_bevel                        in number
  ,p_case_restriction             in number
  ,p_default_value                in varchar2
  ,p_enabled                      in number
  ,p_format_mask                  in varchar2
  ,p_height                       in number
  ,p_information_formula_id       in number
  ,p_information_param_item_id1   in number
  ,p_information_param_item_id2   in number
  ,p_information_param_item_id3   in number
  ,p_information_param_item_id4   in number
  ,p_information_param_item_id5   in number
  ,p_information_prompt           in varchar2
  ,p_insert_allowed               in number
  ,p_label                        in varchar2
  ,p_prompt_text                  in varchar2
  ,p_prompt_alignment_offset      in number
  ,p_prompt_display_style         in number
  ,p_prompt_edge                  in number
  ,p_prompt_edge_alignment        in number
  ,p_prompt_edge_offset           in number
  ,p_prompt_text_alignment        in number
  ,p_query_allowed                in number
  ,p_required                     in number
  ,p_tooltip_text                 in varchar2
  ,p_update_allowed               in number
  ,p_validation_formula_id        in number
  ,p_validation_param_item_id1    in number
  ,p_validation_param_item_id2    in number
  ,p_validation_param_item_id3    in number
  ,p_validation_param_item_id4    in number
  ,p_validation_param_item_id5    in number
  ,p_visible                      in number
  ,p_width                        in number
  ,p_x_position                   in number
  ,p_y_position                   in number
  ,p_information_category         in varchar2
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4                 in varchar2
  ,p_information5                 in varchar2
  ,p_information6                 in varchar2
  ,p_information7                 in varchar2
  ,p_information8                 in varchar2
  ,p_information9                 in varchar2
  ,p_information10                in varchar2
  ,p_information11                in varchar2
  ,p_information12                in varchar2
  ,p_information13                in varchar2
  ,p_information14                in varchar2
  ,p_information15                in varchar2
  ,p_information16                in varchar2
  ,p_information17                in varchar2
  ,p_information18                in varchar2
  ,p_information19                in varchar2
  ,p_information20                in varchar2
  ,p_information21                in varchar2
  ,p_information22                in varchar2
  ,p_information23                in varchar2
  ,p_information24                in varchar2
  ,p_information25                in varchar2
  ,p_information26                in varchar2
  ,p_information27                in varchar2
  ,p_information28                in varchar2
  ,p_information29                in varchar2
  ,p_information30                in varchar2
  ,p_next_navigation_item_id      in number
  ,p_previous_navigation_item_id  in number
  --,p_item_context_id              in number
  --,p_concatenated_segments        in varchar2
  ,p_override_value_warning       in boolean
  );
--
end hr_template_item_contexts_bk4;

 

/
