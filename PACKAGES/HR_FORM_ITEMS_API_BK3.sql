--------------------------------------------------------
--  DDL for Package HR_FORM_ITEMS_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_ITEMS_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrfimapi.pkh 120.0 2005/05/31 00:20:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_form_item_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_item_b
  (p_effective_date              in date
  ,p_language_code               in varchar2
  ,p_form_item_id                in  number
  ,p_object_version_number       in number
  ,p_full_item_name              in varchar2
  --,p_item_type                   in varchar2
  ,p_user_item_name              in varchar2
  ,p_description                 in varchar2
  ,p_radio_button_name           in varchar2
  ,p_required_override           in number
  ,p_form_tab_page_id_override   in number
  ,p_visible_override            in number
  ,p_alignment                   in number
  ,p_bevel                       in number
  ,p_case_restriction            in number
  ,p_default_value               in varchar2
  ,p_enabled                     in number
  ,p_format_mask                 in varchar2
  ,p_height                      in number
  ,p_information_formula_id      in number
  ,p_information_param_item_id1  in number
  ,p_information_param_item_id2  in number
  ,p_information_param_item_id3  in number
  ,p_information_param_item_id4  in number
  ,p_information_param_item_id5  in number
  ,p_information_prompt          in varchar2
  ,p_insert_allowed              in number
  ,p_label                       in varchar2
  ,p_prompt_text                 in varchar2
  ,p_prompt_alignment_offset     in number
  ,p_prompt_display_style        in number
  ,p_prompt_edge                 in number
  ,p_prompt_edge_alignment       in number
  ,p_prompt_edge_offset          in number
  ,p_prompt_text_alignment       in number
  ,p_query_allowed               in number
  ,p_required                    in number
  ,p_tooltip_text                in varchar2
  ,p_update_allowed              in number
  ,p_validation_formula_id       in number
  ,p_validation_param_item_id1   in number
  ,p_validation_param_item_id2   in number
  ,p_validation_param_item_id3   in number
  ,p_validation_param_item_id4   in number
  ,p_validation_param_item_id5   in number
  ,p_visible                     in number
  ,p_width                       in number
  ,p_x_position                  in number
  ,p_y_position                  in number
  ,p_information_category        in varchar2
  ,p_information1                in varchar2
  ,p_information2                in varchar2
  ,p_information3                in varchar2
  ,p_information4                in varchar2
  ,p_information5                in varchar2
  ,p_information6                in varchar2
  ,p_information7                in varchar2
  ,p_information8                in varchar2
  ,p_information9                in varchar2
  ,p_information10               in varchar2
  ,p_information11               in varchar2
  ,p_information12               in varchar2
  ,p_information13               in varchar2
  ,p_information14               in varchar2
  ,p_information15               in varchar2
  ,p_information16               in varchar2
  ,p_information17               in varchar2
  ,p_information18               in varchar2
  ,p_information19               in varchar2
  ,p_information20               in varchar2
  ,p_information21               in varchar2
  ,p_information22               in varchar2
  ,p_information23               in varchar2
  ,p_information24               in varchar2
  ,p_information25               in varchar2
  ,p_information26               in varchar2
  ,p_information27               in varchar2
  ,p_information28               in varchar2
  ,p_information29               in varchar2
  ,p_information30               in varchar2
  ,p_next_navigation_item_id     in number
  ,p_previous_navigation_item_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_form_item_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_item_a
  (p_effective_date              in date
  ,p_language_code               in varchar2
  ,p_form_item_id                in number
  ,p_object_version_number       in number
  ,p_full_item_name              in varchar2
  --,p_item_type                   in varchar2
  ,p_user_item_name              in varchar2
  ,p_description                 in varchar2
  ,p_radio_button_name           in varchar2
  ,p_required_override           in number
  ,p_form_tab_page_id_override   in number
  ,p_visible_override            in number
  ,p_alignment                   in number
  ,p_bevel                       in number
  ,p_case_restriction            in number
  ,p_default_value               in varchar2
  ,p_enabled                     in number
  ,p_format_mask                 in varchar2
  ,p_height                      in number
  ,p_information_formula_id      in number
  ,p_information_param_item_id1  in number
  ,p_information_param_item_id2  in number
  ,p_information_param_item_id3  in number
  ,p_information_param_item_id4  in number
  ,p_information_param_item_id5  in number
  ,p_information_prompt          in varchar2
  ,p_insert_allowed              in number
  ,p_label                       in varchar2
  ,p_prompt_text                 in varchar2
  ,p_prompt_alignment_offset     in number
  ,p_prompt_display_style        in number
  ,p_prompt_edge                 in number
  ,p_prompt_edge_alignment       in number
  ,p_prompt_edge_offset          in number
  ,p_prompt_text_alignment       in number
  ,p_query_allowed               in number
  ,p_required                    in number
  ,p_tooltip_text                in varchar2
  ,p_update_allowed              in number
  ,p_validation_formula_id       in number
  ,p_validation_param_item_id1   in number
  ,p_validation_param_item_id2   in number
  ,p_validation_param_item_id3   in number
  ,p_validation_param_item_id4   in number
  ,p_validation_param_item_id5   in number
  ,p_visible                     in number
  ,p_width                       in number
  ,p_x_position                  in number
  ,p_y_position                  in number
  ,p_information_category        in varchar2
  ,p_information1                in varchar2
  ,p_information2                in varchar2
  ,p_information3                in varchar2
  ,p_information4                in varchar2
  ,p_information5                in varchar2
  ,p_information6                in varchar2
  ,p_information7                in varchar2
  ,p_information8                in varchar2
  ,p_information9                in varchar2
  ,p_information10               in varchar2
  ,p_information11               in varchar2
  ,p_information12               in varchar2
  ,p_information13               in varchar2
  ,p_information14               in varchar2
  ,p_information15               in varchar2
  ,p_information16               in varchar2
  ,p_information17               in varchar2
  ,p_information18               in varchar2
  ,p_information19               in varchar2
  ,p_information20               in varchar2
  ,p_information21               in varchar2
  ,p_information22               in varchar2
  ,p_information23               in varchar2
  ,p_information24               in varchar2
  ,p_information25               in varchar2
  ,p_information26               in varchar2
  ,p_information27               in varchar2
  ,p_information28               in varchar2
  ,p_information29               in varchar2
  ,p_information30               in varchar2
  ,p_next_navigation_item_id     in number
  ,p_previous_navigation_item_id in number
  ,p_override_value_warning      in boolean
  );
--
end hr_form_items_api_bk3;

 

/
