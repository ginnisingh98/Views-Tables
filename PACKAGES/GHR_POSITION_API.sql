--------------------------------------------------------
--  DDL for Package GHR_POSITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_POSITION_API" AUTHID CURRENT_USER as
/* $Header: ghposapi.pkh 120.0.12010000.3 2009/05/26 12:01:40 utokachi noship $ */
--
-- Package Variables
--
-- ---------------------------------------------------------------------------
-- |--------------------------< create_position >-----------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_position
  (p_validate                      in     boolean  default false
  ,p_job_id                        in     number
  ,p_organization_id               in     number
  ,p_date_effective                in     date
  ,p_successor_position_id         in     number   default null
  ,p_relief_position_id            in     number   default null
  ,p_location_id                   in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_frequency                     in     varchar2 default null
  ,p_probation_period              in     number   default null
  ,p_probation_period_units        in     varchar2 default null
  ,p_replacement_required_flag     in     varchar2 default null
  ,p_time_normal_finish            in     varchar2 default null
  ,p_time_normal_start             in     varchar2 default null
  ,p_status                        in     varchar2 default null
  ,p_working_hours                 in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_concat_segments               in     varchar2 default null
  ,p_position_id                      out NOCOPY number
  ,p_object_version_number            out NOCOPY number
  ,p_position_definition_id           out NOCOPY number
  ,p_name                             out NOCOPY varchar2
  );
--
-- ---------------------------------------------------------------------------
-- |--------------------------< update_position >-----------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_position
  (p_validate                      in     boolean  default false
  ,p_position_id                   in     number
  ,p_object_version_number         in out NOCOPY number
  ,p_successor_position_id         in     number   default hr_api.g_number
  ,p_relief_position_id            in     number   default hr_api.g_number
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_date_effective                in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_end                      in     date     default hr_api.g_date
  ,p_frequency                     in     varchar2 default hr_api.g_varchar2
  ,p_probation_period              in     number   default hr_api.g_number
  ,p_probation_period_units        in     varchar2 default hr_api.g_varchar2
  ,p_replacement_required_flag     in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish	           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start             in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_working_hours                 in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments               in     varchar2 default hr_api.g_varchar2
  ,p_position_definition_id           out NOCOPY number
  ,p_name                             out NOCOPY varchar2
  ,p_valid_grades_changed_warning     out NOCOPY boolean
  );

end ghr_position_api;

/
