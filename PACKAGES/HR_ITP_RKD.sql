--------------------------------------------------------
--  DDL for Package HR_ITP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITP_RKD" AUTHID CURRENT_USER as
/* $Header: hritprhi.pkh 120.0 2005/05/31 01:00:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_item_property_id             in number
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
end hr_itp_rkd;

 

/
