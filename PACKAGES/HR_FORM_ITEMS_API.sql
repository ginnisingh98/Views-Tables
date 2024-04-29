--------------------------------------------------------
--  DDL for Package HR_FORM_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_ITEMS_API" AUTHID CURRENT_USER as
/* $Header: hrfimapi.pkh 120.0 2005/05/31 00:20:34 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_item >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new form item in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                        Reqd Type     Description
--   p_language_code                N Varchar2
--   p_application_id               Y Number
--   p_form_id                      Y Number
--   p_full_item_name               Y Number
--   p_item_type                    Y Number
--   p_form_canvas_id               Y Number
--   p_user_item_name               Y Varchar2
--   p_description                  N Varchar2
--   p_form_tab_page_id             N Number
--   p_radio_button_name            N Varchar2
--   p_required_override            N Number
--   p_form_tab_page_id_override    N Number
--   p_visible_override             N Number
--   p_alignment                    N Number
--   p_bevel                        N Number
--   p_case_restriction             N Number
--   p_default_value                N Number
--   p_enabled                      N Number
--   p_format_mask                  N Varchar2
--   p_height                       N Number
--   p_information_formula_id       N Number
--   p_information_param_item_id1   N Number
--   p_information_param_item_id2   N Number
--   p_information_param_item_id3   N Number
--   p_information_param_item_id4   N Number
--   p_information_param_item_id5   N Number
--   p_information_prompt           N Varchar2
--   p_insert_allowed               N Number
--   p_label                        N Varchar2
--   p_prompt_text                  N Varchar2
--   p_prompt_alignment_offset      N Number
--   p_prompt_display_style         N Number
--   p_prompt_edge                  N Number
--   p_prompt_edge_alignment        N Number
--   p_prompt_edge_offset           N Number
--   p_prompt_text_alignment        N Number
--   p_query_allowed                N Number
--   p_required                     N Number
--   p_tooltip_text                 N Varchar2
--   p_update_allowed               N Number
--   p_validation_formula_id        N Number
--   p_validation_param_item_id1    N Number
--   p_validation_param_item_id2    N Number
--   p_validation_param_item_id3    N Number
--   p_validation_param_item_id4    N Number
--   p_validation_param_item_id5    N Number
--   p_visible                      N Number
--   p_width                        N Number
--   p_x_position                   N Number
--   p_y_position                   N Number
--   p_information_category         N Varchar2
--   p_information1                 N Varchar2
--   p_information2                 N Varchar2
--   p_information3                 N Varchar2
--   p_information4                 N Varchar2
--   p_information5                 N Varchar2
--   p_information6                 N Varchar2
--   p_information7                 N Varchar2
--   p_information8                 N Varchar2
--   p_information9                 N Varchar2
--   p_information10                N Varchar2
--   p_information11                N Varchar2
--   p_information12                N Varchar2
--   p_information13                N Varchar2
--   p_information14                N Varchar2
--   p_information15                N Varchar2
--   p_information16                N Varchar2
--   p_information17                N Varchar2
--   p_information18                N Varchar2
--   p_information19                N Varchar2
--   p_information20                N Varchar2
--   p_information21                N Varchar2
--   p_information22                N Varchar2
--   p_information23                N Varchar2
--   p_information24                N Varchar2
--   p_information25                N Varchar2
--   p_information26                N Varchar2
--   p_information27                N Varchar2
--   p_information28                N Varchar2
--   p_information29                N Varchar2
--   p_information30                N Varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_form_item_id                 Number
--   p_object_version_number        Number
--   p_override_value_warning       Boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_form_item
  (p_validate                    in boolean  default false
  ,p_effective_date              in date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  ,p_application_id              in number
  ,p_form_id                     in number
  ,p_full_item_name              in varchar2
  ,p_item_type                   in varchar2
  ,p_form_canvas_id              in number
  ,p_user_item_name              in varchar2
  ,p_description                 in varchar2 default null
  ,p_form_tab_page_id            in number default null
  ,p_radio_button_name           in varchar2 default null
  ,p_required_override           in number default null
  ,p_form_tab_page_id_override   in number default null
  ,p_visible_override            in number default null
  ,p_alignment                   in number default null
  ,p_bevel                       in number default null
  ,p_case_restriction            in number default null
  ,p_default_value               in varchar2 default null
  ,p_enabled                     in number default null
  ,p_format_mask                 in varchar2 default null
  ,p_height                      in number default null
  ,p_information_formula_id      in number default null
  ,p_information_param_item_id1  in number default null
  ,p_information_param_item_id2  in number default null
  ,p_information_param_item_id3  in number default null
  ,p_information_param_item_id4  in number default null
  ,p_information_param_item_id5  in number default null
  ,p_information_prompt          in varchar2 default null
  ,p_insert_allowed              in number default null
  ,p_label                       in varchar2 default null
  ,p_prompt_text                 in varchar2 default null
  ,p_prompt_alignment_offset     in number default null
  ,p_prompt_display_style        in number default null
  ,p_prompt_edge                 in number default null
  ,p_prompt_edge_alignment       in number default null
  ,p_prompt_edge_offset          in number default null
  ,p_prompt_text_alignment       in number default null
  ,p_query_allowed               in number default null
  ,p_required                    in number default null
  ,p_tooltip_text                in varchar2 default null
  ,p_update_allowed              in number default null
  ,p_validation_formula_id       in number default null
  ,p_validation_param_item_id1   in number default null
  ,p_validation_param_item_id2   in number default null
  ,p_validation_param_item_id3   in number default null
  ,p_validation_param_item_id4   in number default null
  ,p_validation_param_item_id5   in number default null
  ,p_visible                     in number default null
  ,p_width                       in number default null
  ,p_x_position                  in number default null
  ,p_y_position                  in number default null
  ,p_information_category        in varchar2 default null
  ,p_information1                in varchar2 default null
  ,p_information2                in varchar2 default null
  ,p_information3                in varchar2 default null
  ,p_information4                in varchar2 default null
  ,p_information5                in varchar2 default null
  ,p_information6                in varchar2 default null
  ,p_information7                in varchar2 default null
  ,p_information8                in varchar2 default null
  ,p_information9                in varchar2 default null
  ,p_information10               in varchar2 default null
  ,p_information11               in varchar2 default null
  ,p_information12               in varchar2 default null
  ,p_information13               in varchar2 default null
  ,p_information14               in varchar2 default null
  ,p_information15               in varchar2 default null
  ,p_information16               in varchar2 default null
  ,p_information17               in varchar2 default null
  ,p_information18               in varchar2 default null
  ,p_information19               in varchar2 default null
  ,p_information20               in varchar2 default null
  ,p_information21               in varchar2 default null
  ,p_information22               in varchar2 default null
  ,p_information23               in varchar2 default null
  ,p_information24               in varchar2 default null
  ,p_information25               in varchar2 default null
  ,p_information26               in varchar2 default null
  ,p_information27               in varchar2 default null
  ,p_information28               in varchar2 default null
  ,p_information29               in varchar2 default null
  ,p_information30               in varchar2 default null
  ,p_next_navigation_item_id     in number default null
  ,p_previous_navigation_item_id in number default null
  ,p_form_item_id                   out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_override_value_warning         out nocopy boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_item >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form item from the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_form_item_id                 Y    Number
--   p_object_version_number        Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure delete_form_item
  (p_validate                      in     boolean  default false
  ,p_form_item_id                  in     number
  ,p_object_version_number         in     number
  );
--
--
-- --------------------------------------------------------------------------
-- |--------------------------< update_form_item >--------------------------|
-- --------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a form item in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                        Reqd Type     Description
--   p_language_code                N Varchar2
--   p_form_item_id                 N Number
--   p_full_item_name               Y Number
--   p_item_type                    Y Number
--   p_user_item_name               Y Varchar2
--   p_description                  N Varchar2
--   p_radio_button_name            N Varchar2
--   p_required_override            N Number
--   p_form_tab_page_id_override    N Number
--   p_visible_override             N Number
--   p_alignment                    N Number
--   p_bevel                        N Number
--   p_case_restriction             N Number
--   p_default_value                N Number
--   p_enabled                      N Number
--   p_format_mask                  N Varchar2
--   p_height                       N Number
--   p_information_formula_id       N Number
--   p_information_param_item_id1   N Number
--   p_information_param_item_id2   N Number
--   p_information_param_item_id3   N Number
--   p_information_param_item_id4   N Number
--   p_information_param_item_id5   N Number
--   p_information_prompt           N Varchar2
--   p_insert_allowed               N Number
--   p_label                        N Varchar2
--   p_prompt_text                  N Varchar2
--   p_prompt_alignment_offset      N Number
--   p_prompt_display_style         N Number
--   p_prompt_edge                  N Number
--   p_prompt_edge_alignment        N Number
--   p_prompt_edge_offset           N Number
--   p_prompt_text_alignment        N Number
--   p_query_allowed                N Number
--   p_required                     N Number
--   p_tooltip_text                 N Varchar2
--   p_update_allowed               N Number
--   p_validation_formula_id        N Number
--   p_validation_param_item_id1    N Number
--   p_validation_param_item_id2    N Number
--   p_validation_param_item_id3    N Number
--   p_validation_param_item_id4    N Number
--   p_validation_param_item_id5    N Number
--   p_visible                      N Number
--   p_width                        N Number
--   p_x_position                   N Number
--   p_y_position                   N Number
--   p_information_category         N Varchar2
--   p_information1                 N Varchar2
--   p_information2                 N Varchar2
--   p_information3                 N Varchar2
--   p_information4                 N Varchar2
--   p_information5                 N Varchar2
--   p_information6                 N Varchar2
--   p_information7                 N Varchar2
--   p_information8                 N Varchar2
--   p_information9                 N Varchar2
--   p_information10                N Varchar2
--   p_information11                N Varchar2
--   p_information12                N Varchar2
--   p_information13                N Varchar2
--   p_information14                N Varchar2
--   p_information15                N Varchar2
--   p_information16                N Varchar2
--   p_information17                N Varchar2
--   p_information18                N Varchar2
--   p_information19                N Varchar2
--   p_information20                N Varchar2
--   p_information21                N Varchar2
--   p_information22                N Varchar2
--   p_information23                N Varchar2
--   p_information24                N Varchar2
--   p_information25                N Varchar2
--   p_information26                N Varchar2
--   p_information27                N Varchar2
--   p_information28                N Varchar2
--   p_information29                N Varchar2
--   p_information30                N Varchar2
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Number
--   p_override_value_warning       Boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure update_form_item
  (p_validate                    in     boolean  default false
  ,p_effective_date              in     date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  ,p_form_item_id                in  number
  ,p_object_version_number       in out nocopy     number
  ,p_full_item_name              in varchar2  default hr_api.g_varchar2
  --,p_item_type                   in varchar2 default hr_api.g_varchar2
  ,p_user_item_name              in varchar2  default hr_api.g_varchar2
  ,p_description                 in varchar2 default hr_api.g_varchar2
  ,p_radio_button_name           in varchar2 default hr_api.g_varchar2
  ,p_required_override           in number default hr_api.g_number
  ,p_form_tab_page_id_override   in number default hr_api.g_number
  ,p_visible_override            in number default hr_api.g_number
  ,p_alignment                   in number default hr_api.g_number
  ,p_bevel                       in number default hr_api.g_number
  ,p_case_restriction            in number default hr_api.g_number
  ,p_default_value               in varchar2 default hr_api.g_varchar2
  ,p_enabled                     in number default hr_api.g_number
  ,p_format_mask                 in varchar2 default hr_api.g_varchar2
  ,p_height                      in number default hr_api.g_number
  ,p_information_formula_id      in number default hr_api.g_number
  ,p_information_param_item_id1  in number default hr_api.g_number
  ,p_information_param_item_id2  in number default hr_api.g_number
  ,p_information_param_item_id3  in number default hr_api.g_number
  ,p_information_param_item_id4  in number default hr_api.g_number
  ,p_information_param_item_id5  in number default hr_api.g_number
  ,p_information_prompt          in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed              in number default hr_api.g_number
  ,p_label                       in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                 in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset     in number default hr_api.g_number
  ,p_prompt_display_style        in number default hr_api.g_number
  ,p_prompt_edge                 in number default hr_api.g_number
  ,p_prompt_edge_alignment       in number default hr_api.g_number
  ,p_prompt_edge_offset          in number default hr_api.g_number
  ,p_prompt_text_alignment       in number default hr_api.g_number
  ,p_query_allowed               in number default hr_api.g_number
  ,p_required                    in number default hr_api.g_number
  ,p_tooltip_text                in varchar2 default hr_api.g_varchar2
  ,p_update_allowed              in number default hr_api.g_number
  ,p_validation_formula_id       in number default hr_api.g_number
  ,p_validation_param_item_id1   in number default hr_api.g_number
  ,p_validation_param_item_id2   in number default hr_api.g_number
  ,p_validation_param_item_id3   in number default hr_api.g_number
  ,p_validation_param_item_id4   in number default hr_api.g_number
  ,p_validation_param_item_id5   in number default hr_api.g_number
  ,p_visible                     in number default hr_api.g_number
  ,p_width                       in number default hr_api.g_number
  ,p_x_position                  in number default hr_api.g_number
  ,p_y_position                  in number default hr_api.g_number
  ,p_information_category        in varchar2 default hr_api.g_varchar2
  ,p_information1                in varchar2 default hr_api.g_varchar2
  ,p_information2                in varchar2 default hr_api.g_varchar2
  ,p_information3                in varchar2 default hr_api.g_varchar2
  ,p_information4                in varchar2 default hr_api.g_varchar2
  ,p_information5                in varchar2 default hr_api.g_varchar2
  ,p_information6                in varchar2 default hr_api.g_varchar2
  ,p_information7                in varchar2 default hr_api.g_varchar2
  ,p_information8                in varchar2 default hr_api.g_varchar2
  ,p_information9                in varchar2 default hr_api.g_varchar2
  ,p_information10               in varchar2 default hr_api.g_varchar2
  ,p_information11               in varchar2 default hr_api.g_varchar2
  ,p_information12               in varchar2 default hr_api.g_varchar2
  ,p_information13               in varchar2 default hr_api.g_varchar2
  ,p_information14               in varchar2 default hr_api.g_varchar2
  ,p_information15               in varchar2 default hr_api.g_varchar2
  ,p_information16               in varchar2 default hr_api.g_varchar2
  ,p_information17               in varchar2 default hr_api.g_varchar2
  ,p_information18               in varchar2 default hr_api.g_varchar2
  ,p_information19               in varchar2 default hr_api.g_varchar2
  ,p_information20               in varchar2 default hr_api.g_varchar2
  ,p_information21               in varchar2 default hr_api.g_varchar2
  ,p_information22               in varchar2 default hr_api.g_varchar2
  ,p_information23               in varchar2 default hr_api.g_varchar2
  ,p_information24               in varchar2 default hr_api.g_varchar2
  ,p_information25               in varchar2 default hr_api.g_varchar2
  ,p_information26               in varchar2 default hr_api.g_varchar2
  ,p_information27               in varchar2 default hr_api.g_varchar2
  ,p_information28               in varchar2 default hr_api.g_varchar2
  ,p_information29               in varchar2 default hr_api.g_varchar2
  ,p_information30               in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id     in number default hr_api.g_number
  ,p_previous_navigation_item_id in number default hr_api.g_number
  ,p_override_value_warning      out nocopy boolean
  );
--
end hr_form_items_api;

 

/
