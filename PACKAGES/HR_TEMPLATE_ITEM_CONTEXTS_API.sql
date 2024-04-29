--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_CONTEXTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_CONTEXTS_API" AUTHID CURRENT_USER as
/* $Header: hrticapi.pkh 120.0 2005/05/31 03:08:47 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_template_item_context >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template item context in
--              the HR Schema based on an existing template item context . It
--              also creates a copy of every object within the copied from
--              template item context in the new template item context.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_language_code                N    Varchar2
--   p_template_item_context_id_frm Y    Number
--   p_template_item_id             Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_template_item_context_id_to  Number
--   p_object_version_number        Number
--   p_item_context_id              Number
--   p_concatenated_segments        Varchar2
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure copy_template_item_context
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in varchar2 default hr_api.userenv_lang
  ,p_template_item_context_id_frm  in number
  ,p_template_item_id              in number
  ,p_template_item_context_id_to   out nocopy number
  ,p_object_version_number         out nocopy number
  ,p_item_context_id               out nocopy number
  ,p_concatenated_segments         out nocopy varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_template_item_context >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template item context
--              in the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_template_item_id                Y number
--      p_context_type                    Y varchar2
--      p_segment1                        N varchar2
--      p_segment2                        N varchar2
--      p_segment3                        N varchar2
--      p_segment4                        N varchar2
--      p_segment5                        N varchar2
--      p_segment6                        N varchar2
--      p_segment7                        N varchar2
--      p_segment8                        N varchar2
--      p_segment9                        N varchar2
--      p_segment10                       N varchar2
--      p_segment11                       N varchar2
--      p_segment12                       N varchar2
--      p_segment13                       N varchar2
--      p_segment14                       N varchar2
--      p_segment15                       N varchar2
--      p_segment16                       N varchar2
--      p_segment17                       N varchar2
--      p_segment18                       N varchar2
--      p_segment19                       N varchar2
--      p_segment20                       N varchar2
--      p_segment21                       N varchar2
--      p_segment22                       N varchar2
--      p_segment23                       N varchar2
--      p_segment24                       N varchar2
--      p_segment25                       N varchar2
--      p_segment26                       N varchar2
--      p_segment27                       N varchar2
--      p_segment28                       N varchar2
--      p_segment29                       N varchar2
--      p_segment30                       N varchar2
--      p_template_tab_page_id            N number
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
-- Post Success:
--
--      Name                           Type     Description
--      p_template_item_context_id     number
--      p_object_version_number        number
--      p_item_context_id              number
--      p_concatenated_segments        varchar2
--      p_override_value_warning       boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_template_item_context
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  ,p_template_item_id             in number
  ,p_context_type                 in varchar2
  ,p_segment1                     in varchar2 default null
  ,p_segment2                     in varchar2 default null
  ,p_segment3                     in varchar2 default null
  ,p_segment4                     in varchar2 default null
  ,p_segment5                     in varchar2 default null
  ,p_segment6                     in varchar2 default null
  ,p_segment7                     in varchar2 default null
  ,p_segment8                     in varchar2 default null
  ,p_segment9                     in varchar2 default null
  ,p_segment10                    in varchar2 default null
  ,p_segment11                    in varchar2 default null
  ,p_segment12                    in varchar2 default null
  ,p_segment13                    in varchar2 default null
  ,p_segment14                    in varchar2 default null
  ,p_segment15                    in varchar2 default null
  ,p_segment16                    in varchar2 default null
  ,p_segment17                    in varchar2 default null
  ,p_segment18                    in varchar2 default null
  ,p_segment19                    in varchar2 default null
  ,p_segment20                    in varchar2 default null
  ,p_segment21                    in varchar2 default null
  ,p_segment22                    in varchar2 default null
  ,p_segment23                    in varchar2 default null
  ,p_segment24                    in varchar2 default null
  ,p_segment25                    in varchar2 default null
  ,p_segment26                    in varchar2 default null
  ,p_segment27                    in varchar2 default null
  ,p_segment28                    in varchar2 default null
  ,p_segment29                    in varchar2 default null
  ,p_segment30                    in varchar2 default null
  ,p_template_tab_page_id         in number default null
  ,p_alignment                    in number default hr_api.g_number
  ,p_bevel                        in number default hr_api.g_number
  ,p_case_restriction             in number default hr_api.g_number
  ,p_default_value                in varchar2 default hr_api.g_varchar2
  ,p_enabled                      in number default hr_api.g_number
  ,p_format_mask                  in varchar2 default hr_api.g_varchar2
  ,p_height                       in number default hr_api.g_number
  ,p_information_formula_id       in number default hr_api.g_number
  ,p_information_param_item_id1   in number default hr_api.g_number
  ,p_information_param_item_id2   in number default hr_api.g_number
  ,p_information_param_item_id3   in number default hr_api.g_number
  ,p_information_param_item_id4   in number default hr_api.g_number
  ,p_information_param_item_id5   in number default hr_api.g_number
  ,p_information_prompt           in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed               in number default hr_api.g_number
  ,p_label                        in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                  in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset      in number default hr_api.g_number
  ,p_prompt_display_style         in number default hr_api.g_number
  ,p_prompt_edge                  in number default hr_api.g_number
  ,p_prompt_edge_alignment        in number default hr_api.g_number
  ,p_prompt_edge_offset           in number default hr_api.g_number
  ,p_prompt_text_alignment        in number default hr_api.g_number
  ,p_query_allowed                in number default hr_api.g_number
  ,p_required                     in number default hr_api.g_number
  ,p_tooltip_text                 in varchar2 default hr_api.g_varchar2
  ,p_update_allowed               in number default hr_api.g_number
  ,p_validation_formula_id        in number default hr_api.g_number
  ,p_validation_param_item_id1    in number default hr_api.g_number
  ,p_validation_param_item_id2    in number default hr_api.g_number
  ,p_validation_param_item_id3    in number default hr_api.g_number
  ,p_validation_param_item_id4    in number default hr_api.g_number
  ,p_validation_param_item_id5    in number default hr_api.g_number
  ,p_visible                      in number default hr_api.g_number
  ,p_width                        in number default hr_api.g_number
  ,p_x_position                   in number default hr_api.g_number
  ,p_y_position                   in number default hr_api.g_number
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id      in number default hr_api.g_number
  ,p_previous_navigation_item_id  in number default hr_api.g_number
  ,p_template_item_context_id     out nocopy number
  ,p_object_version_number        out nocopy number
  ,p_item_context_id              out nocopy number
  ,p_concatenated_segments        out nocopy varchar2
  ,p_override_value_warning       out nocopy boolean
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------< delete_template_item_context >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a template item context from
--              the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_template_item_context_id     Y    number
--   p_object_version_number        Y    number
--   p_delete_children_flag         N    varchar2
--
-- Post Success:
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
procedure delete_template_item_context
  (p_validate                      in     boolean  default false
   ,p_template_item_context_id     in    number
   ,p_object_version_number        in    number
   --,p_delete_children_flag         in    varchar2 default 'N'
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_template_item_context >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process updates a template item context in
--              the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--      Name                           Reqd Type     Description
--      p_language_code                   N varchar2
--      p_template_item_context_id        Y number
--      p_object_version_number           Y number
--      p_context_type                    N varchar2
--      p_segment1                        N varchar2
--      p_segment2                        N varchar2
--      p_segment3                        N varchar2
--      p_segment4                        N varchar2
--      p_segment5                        N varchar2
--      p_segment6                        N varchar2
--      p_segment7                        N varchar2
--      p_segment8                        N varchar2
--      p_segment9                        N varchar2
--      p_segment10                       N varchar2
--      p_segment11                       N varchar2
--      p_segment12                       N varchar2
--      p_segment13                       N varchar2
--      p_segment14                       N varchar2
--      p_segment15                       N varchar2
--      p_segment16                       N varchar2
--      p_segment17                       N varchar2
--      p_segment18                       N varchar2
--      p_segment19                       N varchar2
--      p_segment20                       N varchar2
--      p_segment21                       N varchar2
--      p_segment22                       N varchar2
--      p_segment23                       N varchar2
--      p_segment24                       N varchar2
--      p_segment25                       N varchar2
--      p_segment26                       N varchar2
--      p_segment27                       N varchar2
--      p_segment28                       N varchar2
--      p_segment29                       N varchar2
--      p_segment30                       N varchar2
--      p_template_tab_page_id            N number
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
-- Post Success:
--
--      Name                           Type     Description
--      p_object_version_number        number
--      p_item_context_id              number
--      p_concatenated_segments        varchar2
--      p_override_value_warning       boolean
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure update_template_item_context
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  --,p_context_type                 in varchar2 default hr_api.g_varchar2
  ,p_template_item_context_id     in number
  ,p_object_version_number        in out nocopy number
--  ,p_segment1                     in varchar2 default hr_api.g_varchar2
--  ,p_segment2                     in varchar2 default hr_api.g_varchar2
--  ,p_segment3                     in varchar2 default hr_api.g_varchar2
--  ,p_segment4                     in varchar2 default hr_api.g_varchar2
--  ,p_segment5                     in varchar2 default hr_api.g_varchar2
--  ,p_segment6                     in varchar2 default hr_api.g_varchar2
--  ,p_segment7                     in varchar2 default hr_api.g_varchar2
--  ,p_segment8                     in varchar2 default hr_api.g_varchar2
--  ,p_segment9                     in varchar2 default hr_api.g_varchar2
--  ,p_segment10                    in varchar2 default hr_api.g_varchar2
--  ,p_segment11                    in varchar2 default hr_api.g_varchar2
--  ,p_segment12                    in varchar2 default hr_api.g_varchar2
--  ,p_segment13                    in varchar2 default hr_api.g_varchar2
--  ,p_segment14                    in varchar2 default hr_api.g_varchar2
--  ,p_segment15                    in varchar2 default hr_api.g_varchar2
--  ,p_segment16                    in varchar2 default hr_api.g_varchar2
--  ,p_segment17                    in varchar2 default hr_api.g_varchar2
--  ,p_segment18                    in varchar2 default hr_api.g_varchar2
--  ,p_segment19                    in varchar2 default hr_api.g_varchar2
--  ,p_segment20                    in varchar2 default hr_api.g_varchar2
--  ,p_segment21                    in varchar2 default hr_api.g_varchar2
--  ,p_segment22                    in varchar2 default hr_api.g_varchar2
--  ,p_segment23                    in varchar2 default hr_api.g_varchar2
--  ,p_segment24                    in varchar2 default hr_api.g_varchar2
--  ,p_segment25                    in varchar2 default hr_api.g_varchar2
--  ,p_segment26                    in varchar2 default hr_api.g_varchar2
--  ,p_segment27                    in varchar2 default hr_api.g_varchar2
--  ,p_segment28                    in varchar2 default hr_api.g_varchar2
--  ,p_segment29                    in varchar2 default hr_api.g_varchar2
--  ,p_segment30                    in varchar2 default hr_api.g_varchar2
  ,p_template_tab_page_id         in number default hr_api.g_number
  ,p_alignment                    in number default hr_api.g_number
  ,p_bevel                        in number default hr_api.g_number
  ,p_case_restriction             in number default hr_api.g_number
  ,p_default_value                in varchar2 default hr_api.g_varchar2
  ,p_enabled                      in number default hr_api.g_number
  ,p_format_mask                  in varchar2 default hr_api.g_varchar2
  ,p_height                       in number default hr_api.g_number
  ,p_information_formula_id       in number default hr_api.g_number
  ,p_information_param_item_id1   in number default hr_api.g_number
  ,p_information_param_item_id2   in number default hr_api.g_number
  ,p_information_param_item_id3   in number default hr_api.g_number
  ,p_information_param_item_id4   in number default hr_api.g_number
  ,p_information_param_item_id5   in number default hr_api.g_number
  ,p_information_prompt           in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed               in number default hr_api.g_number
  ,p_label                        in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                  in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset      in number default hr_api.g_number
  ,p_prompt_display_style         in number default hr_api.g_number
  ,p_prompt_edge                  in number default hr_api.g_number
  ,p_prompt_edge_alignment        in number default hr_api.g_number
  ,p_prompt_edge_offset           in number default hr_api.g_number
  ,p_prompt_text_alignment        in number default hr_api.g_number
  ,p_query_allowed                in number default hr_api.g_number
  ,p_required                     in number default hr_api.g_number
  ,p_tooltip_text                 in varchar2 default hr_api.g_varchar2
  ,p_update_allowed               in number default hr_api.g_number
  ,p_validation_formula_id        in number default hr_api.g_number
  ,p_validation_param_item_id1    in number default hr_api.g_number
  ,p_validation_param_item_id2    in number default hr_api.g_number
  ,p_validation_param_item_id3    in number default hr_api.g_number
  ,p_validation_param_item_id4    in number default hr_api.g_number
  ,p_validation_param_item_id5    in number default hr_api.g_number
  ,p_visible                      in number default hr_api.g_number
  ,p_width                        in number default hr_api.g_number
  ,p_x_position                   in number default hr_api.g_number
  ,p_y_position                   in number default hr_api.g_number
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id      in number default hr_api.g_number
  ,p_previous_navigation_item_id  in number default hr_api.g_number
  --,p_item_context_id              out number
  --,p_concatenated_segments        out varchar2
  ,p_override_value_warning       out nocopy boolean
  );

--
end hr_template_item_contexts_api;

 

/
