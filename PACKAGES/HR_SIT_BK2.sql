--------------------------------------------------------
--  DDL for Package HR_SIT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SIT_BK2" AUTHID CURRENT_USER as
/* $Header: pesitapi.pkh 120.2.12010000.1 2008/07/28 05:57:54 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_sit_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_sit_b
  (p_person_analysis_id        in     number
  ,p_pea_object_version_number in     number
  ,p_comments                  in     varchar2
  ,p_date_from                 in     date
  ,p_date_to                   in     date
  ,p_request_id                in     number
  ,p_program_application_id    in     number
  ,p_program_id                in     number
  ,p_program_update_date       in     date
  ,p_attribute_category        in     varchar2
  ,p_attribute1                in     varchar2
  ,p_attribute2                in     varchar2
  ,p_attribute3                in     varchar2
  ,p_attribute4                in     varchar2
  ,p_attribute5                in     varchar2
  ,p_attribute6                in     varchar2
  ,p_attribute7                in     varchar2
  ,p_attribute8                in     varchar2
  ,p_attribute9                in     varchar2
  ,p_attribute10               in     varchar2
  ,p_attribute11               in     varchar2
  ,p_attribute12               in     varchar2
  ,p_attribute13               in     varchar2
  ,p_attribute14               in     varchar2
  ,p_attribute15               in     varchar2
  ,p_attribute16               in     varchar2
  ,p_attribute17               in     varchar2
  ,p_attribute18               in     varchar2
  ,p_attribute19               in     varchar2
  ,p_attribute20               in     varchar2
  ,p_segment1                  in     varchar2
  ,p_segment2                  in     varchar2
  ,p_segment3                  in     varchar2
  ,p_segment4                  in     varchar2
  ,p_segment5                  in     varchar2
  ,p_segment6                  in     varchar2
  ,p_segment7                  in     varchar2
  ,p_segment8                  in     varchar2
  ,p_segment9                  in     varchar2
  ,p_segment10                 in     varchar2
  ,p_segment11                 in     varchar2
  ,p_segment12                 in     varchar2
  ,p_segment13                 in     varchar2
  ,p_segment14                 in     varchar2
  ,p_segment15                 in     varchar2
  ,p_segment16                 in     varchar2
  ,p_segment17                 in     varchar2
  ,p_segment18                 in     varchar2
  ,p_segment19                 in     varchar2
  ,p_segment20                 in     varchar2
  ,p_segment21                 in     varchar2
  ,p_segment22                 in     varchar2
  ,p_segment23                 in     varchar2
  ,p_segment24                 in     varchar2
  ,p_segment25                 in     varchar2
  ,p_segment26                 in     varchar2
  ,p_segment27                 in     varchar2
  ,p_segment28                 in     varchar2
  ,p_segment29                 in     varchar2
  ,p_segment30                 in     varchar2
  ,p_concat_segments           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_sit_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_sit_a
  (p_person_analysis_id        in     number
  ,p_pea_object_version_number in     number
  ,p_comments                  in     varchar2
  ,p_date_from                 in     date
  ,p_date_to                   in     date
  ,p_request_id                in     number
  ,p_program_application_id    in     number
  ,p_program_id                in     number
  ,p_program_update_date       in     date
  ,p_attribute_category        in     varchar2
  ,p_attribute1                in     varchar2
  ,p_attribute2                in     varchar2
  ,p_attribute3                in     varchar2
  ,p_attribute4                in     varchar2
  ,p_attribute5                in     varchar2
  ,p_attribute6                in     varchar2
  ,p_attribute7                in     varchar2
  ,p_attribute8                in     varchar2
  ,p_attribute9                in     varchar2
  ,p_attribute10               in     varchar2
  ,p_attribute11               in     varchar2
  ,p_attribute12               in     varchar2
  ,p_attribute13               in     varchar2
  ,p_attribute14               in     varchar2
  ,p_attribute15               in     varchar2
  ,p_attribute16               in     varchar2
  ,p_attribute17               in     varchar2
  ,p_attribute18               in     varchar2
  ,p_attribute19               in     varchar2
  ,p_attribute20               in     varchar2
  ,p_segment1                  in     varchar2
  ,p_segment2                  in     varchar2
  ,p_segment3                  in     varchar2
  ,p_segment4                  in     varchar2
  ,p_segment5                  in     varchar2
  ,p_segment6                  in     varchar2
  ,p_segment7                  in     varchar2
  ,p_segment8                  in     varchar2
  ,p_segment9                  in     varchar2
  ,p_segment10                 in     varchar2
  ,p_segment11                 in     varchar2
  ,p_segment12                 in     varchar2
  ,p_segment13                 in     varchar2
  ,p_segment14                 in     varchar2
  ,p_segment15                 in     varchar2
  ,p_segment16                 in     varchar2
  ,p_segment17                 in     varchar2
  ,p_segment18                 in     varchar2
  ,p_segment19                 in     varchar2
  ,p_segment20                 in     varchar2
  ,p_segment21                 in     varchar2
  ,p_segment22                 in     varchar2
  ,p_segment23                 in     varchar2
  ,p_segment24                 in     varchar2
  ,p_segment25                 in     varchar2
  ,p_segment26                 in     varchar2
  ,p_segment27                 in     varchar2
  ,p_segment28                 in     varchar2
  ,p_segment29                 in     varchar2
  ,p_segment30                 in     varchar2
  ,p_concat_segments           in     varchar2
  ,p_analysis_criteria_id      in     number
  );
--
end hr_sit_bk2;

/
