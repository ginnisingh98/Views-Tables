--------------------------------------------------------
--  DDL for Package HR_ITP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITP_RKU" AUTHID CURRENT_USER as
/* $Header: hritprhi.pkh 120.0 2005/05/31 01:00:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_object_version_number        in number
  ,p_item_property_id             in number
  ,p_form_item_id                 in number
  ,p_template_item_id             in number
  ,p_template_item_context_id     in number
  ,p_alignment                    in number
  ,p_bevel                        in number
  ,p_case_restriction             in number
  ,p_enabled                      in number
  ,p_format_mask                  in varchar2
  ,p_height                       in number
  ,p_information_formula_id       in number
  ,p_information_param_item_id1   in number
  ,p_information_param_item_id2   in number
  ,p_information_param_item_id3   in number
  ,p_information_param_item_id4   in number
  ,p_information_param_item_id5   in number
  ,p_insert_allowed               in number
  ,p_prompt_alignment_offset      in number
  ,p_prompt_display_style         in number
  ,p_prompt_edge                  in number
  ,p_prompt_edge_alignment        in number
  ,p_prompt_edge_offset           in number
  ,p_prompt_text_alignment        in number
  ,p_query_allowed                in number
  ,p_required                     in number
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
  ,p_object_version_number_o      in number
  ,p_form_item_id_o               in number
  ,p_template_item_id_o           in number
  ,p_template_item_context_id_o   in number
  ,p_alignment_o                  in number
  ,p_bevel_o                      in number
  ,p_case_restriction_o           in number
  ,p_enabled_o                    in number
  ,p_format_mask_o                in varchar2
  ,p_height_o                     in number
  ,p_information_formula_id_o     in number
  ,p_information_param_item_id1_o in number
  ,p_information_param_item_id2_o in number
  ,p_information_param_item_id3_o in number
  ,p_information_param_item_id4_o in number
  ,p_information_param_item_id5_o in number
  ,p_insert_allowed_o             in number
  ,p_prompt_alignment_offset_o    in number
  ,p_prompt_display_style_o       in number
  ,p_prompt_edge_o                in number
  ,p_prompt_edge_alignment_o      in number
  ,p_prompt_edge_offset_o         in number
  ,p_prompt_text_alignment_o      in number
  ,p_query_allowed_o              in number
  ,p_required_o                   in number
  ,p_update_allowed_o             in number
  ,p_validation_formula_id_o      in number
  ,p_validation_param_item_id1_o  in number
  ,p_validation_param_item_id2_o  in number
  ,p_validation_param_item_id3_o  in number
  ,p_validation_param_item_id4_o  in number
  ,p_validation_param_item_id5_o  in number
  ,p_visible_o                    in number
  ,p_width_o                      in number
  ,p_x_position_o                 in number
  ,p_y_position_o                 in number
  ,p_information_category_o       in varchar2
  ,p_information1_o               in varchar2
  ,p_information2_o               in varchar2
  ,p_information3_o               in varchar2
  ,p_information4_o               in varchar2
  ,p_information5_o               in varchar2
  ,p_information6_o               in varchar2
  ,p_information7_o               in varchar2
  ,p_information8_o               in varchar2
  ,p_information9_o               in varchar2
  ,p_information10_o              in varchar2
  ,p_information11_o              in varchar2
  ,p_information12_o              in varchar2
  ,p_information13_o              in varchar2
  ,p_information14_o              in varchar2
  ,p_information15_o              in varchar2
  ,p_information16_o              in varchar2
  ,p_information17_o              in varchar2
  ,p_information18_o              in varchar2
  ,p_information19_o              in varchar2
  ,p_information20_o              in varchar2
  ,p_information21_o              in varchar2
  ,p_information22_o              in varchar2
  ,p_information23_o              in varchar2
  ,p_information24_o              in varchar2
  ,p_information25_o              in varchar2
  ,p_information26_o              in varchar2
  ,p_information27_o              in varchar2
  ,p_information28_o              in varchar2
  ,p_information29_o              in varchar2
  ,p_information30_o              in varchar2
  ,p_next_navigation_item_id_o    in number
  ,p_prev_navigation_item_id_o    in number
  );
--
end hr_itp_rku;

 

/
