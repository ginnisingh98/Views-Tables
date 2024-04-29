--------------------------------------------------------
--  DDL for Package HR_ITEM_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITEM_PROPERTIES_BSI" AUTHID CURRENT_USER as
/* $Header: hritpbsi.pkh 115.2 2003/09/24 02:00:25 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_item_property >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process inserts a new item property
--              in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_form_item_id                    N number
--      p_template_item_id                N number
--      p_template_item_context_id        N number
--      p_alignment                       N number
--      p_bevel                           N number
--      p_case_restriction                N number
--      p_default_value                   N varchar2
--      p_enabled                         N number
--      p_format_mask                     N varchar2
--      p_height                          N number
--      p_information_formula_id          N number
--      p_information_param_item_id1      N number
--      p_information_param_item_id2      N number
--      p_information_param_item_id3      N number
--      p_information_param_item_id4      N number
--      p_information_param_item_id5      N number
--      p_information_prompt              N varchar2
--      p_insert_allowed                  N number
--      p_label                           N varchar2
--      p_prompt_text                     N varchar2
--      p_prompt_alignment_offset         N number
--      p_prompt_display_style            N number
--      p_prompt_edge                     N number
--      p_prompt_edge_alignment           N number
--      p_prompt_edge_offset              N number
--      p_prompt_text_alignment           N number
--      p_query_allowed                   N number
--      p_required                        N number
--      p_tooltip_text                    N varchar2
--      p_update_allowed                  N number
--      p_validation_formula_id           N number
--      p_validation_param_item_id2       N number
--      p_validation_param_item_id3       N number
--      p_validation_param_item_id4       N number
--      p_validation_param_item_id5       N number
--      p_validation_param_item_id6       N number
--      p_visible                         N number
--      p_width                           N number
--      p_x_position                      N number
--      p_y_position                      N number
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
-- Post Success:
--
--
--      Name                           Type     Description
--      p_item_property_id             Number
----      p_override_value_warning       Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_item_id                    in number default null
  ,p_template_item_id                in number default null
  ,p_template_item_context_id        in number default null
  ,p_alignment                       in number default null
  ,p_bevel                           in number default null
  ,p_case_restriction                in number default null
  ,p_default_value                   in varchar2 default null
  ,p_enabled                         in number default null
  ,p_format_mask                     in varchar2 default null
  ,p_height                          in number default null
  ,p_information_formula_id          in number default null
  ,p_information_param_item_id1      in number default null
  ,p_information_param_item_id2      in number default null
  ,p_information_param_item_id3      in number default null
  ,p_information_param_item_id4      in number default null
  ,p_information_param_item_id5      in number default null
  ,p_information_prompt              in varchar2 default null
  ,p_insert_allowed                  in number default null
  ,p_label                           in varchar2 default null
  ,p_prompt_text                     in varchar2 default null
  ,p_prompt_alignment_offset         in number default null
  ,p_prompt_display_style            in number default null
  ,p_prompt_edge                     in number default null
  ,p_prompt_edge_alignment           in number default null
  ,p_prompt_edge_offset              in number default null
  ,p_prompt_text_alignment           in number default null
  ,p_query_allowed                   in number default null
  ,p_required                        in number default null
  ,p_tooltip_text                    in varchar2 default null
  ,p_update_allowed                  in number default null
  ,p_validation_formula_id           in number default null
  ,p_validation_param_item_id1       in number default null
  ,p_validation_param_item_id2       in number default null
  ,p_validation_param_item_id3       in number default null
  ,p_validation_param_item_id4       in number default null
  ,p_validation_param_item_id5       in number default null
  ,p_visible                         in number default null
  ,p_width                           in number default null
  ,p_x_position                      in number default null
  ,p_y_position                      in number default null
  ,p_information_category            in varchar2 default null
  ,p_information1                    in varchar2 default null
  ,p_information2                    in varchar2 default null
  ,p_information3                    in varchar2 default null
  ,p_information4                    in varchar2 default null
  ,p_information5                    in varchar2 default null
  ,p_information6                    in varchar2 default null
  ,p_information7                    in varchar2 default null
  ,p_information8                    in varchar2 default null
  ,p_information9                    in varchar2 default null
  ,p_information10                   in varchar2 default null
  ,p_information11                   in varchar2 default null
  ,p_information12                   in varchar2 default null
  ,p_information13                   in varchar2 default null
  ,p_information14                   in varchar2 default null
  ,p_information15                   in varchar2 default null
  ,p_information16                   in varchar2 default null
  ,p_information17                   in varchar2 default null
  ,p_information18                   in varchar2 default null
  ,p_information19                   in varchar2 default null
  ,p_information20                   in varchar2 default null
  ,p_information21                   in varchar2 default null
  ,p_information22                   in varchar2 default null
  ,p_information23                   in varchar2 default null
  ,p_information24                   in varchar2 default null
  ,p_information25                   in varchar2 default null
  ,p_information26                   in varchar2 default null
  ,p_information27                   in varchar2 default null
  ,p_information28                   in varchar2 default null
  ,p_information29                   in varchar2 default null
  ,p_information30                   in varchar2 default null
  ,p_next_navigation_item_id         in number default null
  ,p_previous_navigation_item_id     in number default null
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_item_property >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_item_property_id                N number
--      p_form_item_id                    N number
--      p_template_item_id                N number
--      p_template_item_context_id        N number
--      p_alignment                       N number
--      p_bevel                           N number
--      p_case_restriction                N number
--      p_default_value                   N varchar2
--      p_enabled                         N number
--      p_format_mask                     N varchar2
--      p_height                          N number
--      p_information_formula_id          N number
--      p_information_param_item_id1      N number
--      p_information_param_item_id2      N number
--      p_information_param_item_id3      N number
--      p_information_param_item_id4      N number
--      p_information_param_item_id5      N number
--      p_information_prompt              N varchar2
--      p_insert_allowed                  N number
--      p_label                           N varchar2
--      p_prompt_text                     N varchar2
--      p_prompt_alignment_offset         N number
--      p_prompt_display_style            N number
--      p_prompt_edge                     N number
--      p_prompt_edge_alignment           N number
--      p_prompt_edge_offset              N number
--      p_prompt_text_alignment           N number
--      p_query_allowed                   N number
--      p_required                        N number
--      p_tooltip_text                    N varchar2
--      p_update_allowed                  N number
--      p_validation_formula_id           N number
--      p_validation_param_item_id1       N number
--      p_validation_param_item_id2       N number
--      p_validation_param_item_id3       N number
--      p_validation_param_item_id4       N number
--      p_validation_param_item_id5       N number
--      p_visible                         N number
--      p_width                           N number
--      p_x_position                      N number
--      p_y_position                      N number
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--      Name                           Type     Description
--      p_override_value_warning       Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_item_property_id                in number default null
  ,p_object_version_number           in out nocopy number
  ,p_form_item_id                    in number default null
  ,p_template_item_id                in number default null
  ,p_template_item_context_id        in number default null
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  --,p_override_value_warning            out boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_item_property >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process deletes an item property from
--              the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_item_property_id                N number
--      p_form_item_id                    N number
--      p_template_item_id                N number
--      p_template_item_context_id        N number
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
--   Public.
--
-- {End Of Comments}
--
procedure delete_item_property
  (p_validate                        in     boolean  default false
  ,p_item_property_id                in number default null
  ,p_form_item_id                    in number default null
  ,p_template_item_id                in number default null
  ,p_template_item_context_id        in number default null
  ,p_object_version_number           in     number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_item_property >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a form
--              item to a template item. Any property may not be copied by
--              specifying the value required in the parameter list.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_form_item_id                    Y number
--      p_template_item_id                Y number
--      p_alignment                       N number
--      p_bevel                           N number
--      p_case_restriction                N number
--      p_default_value                   N varchar2
--      p_enabled                         N number
--      p_format_mask                     N varchar2
--      p_height                          N number
--      p_information_formula_id          N number
--      p_information_param_item_id1      N number
--      p_information_param_item_id2      N number
--      p_information_param_item_id3      N number
--      p_information_param_item_id4      N number
--      p_information_param_item_id5      N number
--      p_information_prompt              N varchar2
--      p_insert_allowed                  N number
--      p_label                           N varchar2
--      p_prompt_text                     N varchar2
--      p_prompt_alignment_offset         N number
--      p_prompt_display_style            N number
--      p_prompt_edge                     N number
--      p_prompt_edge_alignment           N number
--      p_prompt_edge_offset              N number
--      p_prompt_text_alignment           N number
--      p_query_allowed                   N number
--      p_required                        N number
--      p_tooltip_text                    N varchar2
--      p_update_allowed                  N number
--      p_validation_formula_id           N number
--      p_validation_param_item_id1       N number
--      p_validation_param_item_id2       N number
--      p_validation_param_item_id3       N number
--      p_validation_param_item_id4       N number
--      p_validation_param_item_id5       N number
--      p_visible                         N number
--      p_width                           N number
--      p_x_position                      N number
--      p_y_position                      N number
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--      Name                           Type     Description
--      p_item_property_id             Number
--      p_override_value_warning       Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_item_id                    in number
  ,p_template_item_id                in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< copy_item_property - overload 1>-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a
--              template item to a template item context. Any property may
--              not be copied by specifying the value required in the
--              parameter list
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_template_item_id                Y number
--      p_template_item_context_id        Y number
--      p_alignment                       N number
--      p_bevel                           N number
--      p_case_restriction                N number
--      p_default_value                   N varchar2
--      p_enabled                         N number
--      p_format_mask                     N varchar2
--      p_height                          N number
--      p_information_formula_id          N number
--      p_information_param_item_id1      N number
--      p_information_param_item_id2      N number
--      p_information_param_item_id3      N number
--      p_information_param_item_id4      N number
--      p_information_param_item_id5      N number
--      p_information_prompt              N varchar2
--      p_insert_allowed                  N number
--      p_label                           N varchar2
--      p_prompt_text                     N varchar2
--      p_prompt_alignment_offset         N number
--      p_prompt_display_style            N number
--      p_prompt_edge                     N number
--      p_prompt_edge_alignment           N number
--      p_prompt_edge_offset              N number
--      p_prompt_text_alignment           N number
--      p_query_allowed                   N number
--      p_required                        N number
--      p_tooltip_text                    N varchar2
--      p_update_allowed                  N number
--      p_validation_formula_id           N number
--      p_validation_param_item_id1       N number
--      p_validation_param_item_id2       N number
--      p_validation_param_item_id3       N number
--      p_validation_param_item_id4       N number
--      p_validation_param_item_id5       N number
--      p_visible                         N number
--      p_width                           N number
--      p_x_position                      N number
--      p_y_position                      N number
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--      Name                           Type     Description
--      p_item_property_id             Number
--      p_override_value_warning       Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_item_id                in number
  ,p_template_item_context_id        in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------< copy_item_property overload -2 >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a
--              template item to another template item. Any property may not
--              be copied by specifying the value required in the parameter
--              list.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_template_item_id_from           Y number
--      p_template_item_id_to             Y number
--      p_alignment                       N number
--      p_bevel                           N number
--      p_case_restriction                N number
--      p_default_value                   N varchar2
--      p_enabled                         N number
--      p_format_mask                     N varchar2
--      p_height                          N number
--      p_information_formula_id          N number
--      p_information_param_item_id1      N number
--      p_information_param_item_id2      N number
--      p_information_param_item_id3      N number
--      p_information_param_item_id4      N number
--      p_information_param_item_id5      N number
--      p_information_prompt              N varchar2
--      p_insert_allowed                  N number
--      p_label                           N varchar2
--      p_prompt_text                     N varchar2
--      p_prompt_alignment_offset         N number
--      p_prompt_display_style            N number
--      p_prompt_edge                     N number
--      p_prompt_edge_alignment           N number
--      p_prompt_edge_offset              N number
--      p_prompt_text_alignment           N number
--      p_query_allowed                   N number
--      p_required                        N number
--      p_tooltip_text                    N varchar2
--      p_update_allowed                  N number
--      p_validation_formula_id           N number
--      p_validation_param_item_id1       N number
--      p_validation_param_item_id2       N number
--      p_validation_param_item_id3       N number
--      p_validation_param_item_id4       N number
--      p_validation_param_item_id5       N number
--      p_visible                         N number
--      p_width                           N number
--      p_x_position                      N number
--      p_y_position                      N number
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
--
-- Post Success:
--
--
--      Name                           Type     Description
--      p_item_property_id             Number
--      p_override_value_warning       Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_item_id_from           in number
  ,p_template_item_id_to             in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< copy_item_property overload 3 >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a
--              template item context to another template item context.
--              Any property may not be copied by specifying the value
--              required in the parameter list.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_template_item_context_id_from   Y number
--      p_template_item_context_id_to     Y number
--      p_alignment                       N number
--      p_bevel                           N number
--      p_case_restriction                N number
--      p_default_value                   N varchar2
--      p_enabled                         N number
--      p_format_mask                     N varchar2
--      p_height                          N number
--      p_information_formula_id          N number
--      p_information_param_item_id1      N number
--      p_information_param_item_id2      N number
--      p_information_param_item_id3      N number
--      p_information_param_item_id4      N number
--      p_information_param_item_id5      N number
--      p_information_prompt              N varchar2
--      p_insert_allowed                  N number
--      p_label                           N varchar2
--      p_prompt_text                     N varchar2
--      p_prompt_alignment_offset         N number
--      p_prompt_display_style            N number
--      p_prompt_edge                     N number
--      p_prompt_edge_alignment           N number
--      p_prompt_edge_offset              N number
--      p_prompt_text_alignment           N number
--      p_query_allowed                   N number
--      p_required                        N number
--      p_tooltip_text                    N varchar2
--      p_update_allowed                  N number
--      p_validation_formula_id           N number
--      p_validation_param_item_id2       N number
--      p_validation_param_item_id3       N number
--      p_validation_param_item_id4       N number
--      p_validation_param_item_id5       N number
--      p_validation_param_item_id6       N number
--      p_visible                         N number
--      p_width                           N number
--      p_x_position                      N number
--      p_y_position                      N number
--      p_information_category            N varchar2
--      p_information1                    N varchar2
--      p_information2                    N varchar2
--      p_information3                    N varchar2
--      p_information4                    N varchar2
--      p_information5                    N varchar2
--      p_information6                    N varchar2
--      p_information7                    N varchar2
--      p_information8                    N varchar2
--      p_information9                    N varchar2
--      p_information10                   N varchar2
--      p_information11                   N varchar2
--      p_information12                   N varchar2
--      p_information13                   N varchar2
--      p_information14                   N varchar2
--      p_information15                   N varchar2
--      p_information16                   N varchar2
--      p_information17                   N varchar2
--      p_information18                   N varchar2
--      p_information19                   N varchar2
--      p_information20                   N varchar2
--      p_information21                   N varchar2
--      p_information22                   N varchar2
--      p_information23                   N varchar2
--      p_information24                   N varchar2
--      p_information25                   N varchar2
--      p_information26                   N varchar2
--      p_information27                   N varchar2
--      p_information28                   N varchar2
--      p_information29                   N varchar2
--      p_information30                   N varchar2
--
-- Post Success:
--
--      Name                           Type     Description
--      p_item_property_id             Number
--      p_override_value_warning       Number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_item_context_id_frm    in number
  ,p_template_item_context_id_to     in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  );
--
end hr_item_properties_bsi;

 

/
