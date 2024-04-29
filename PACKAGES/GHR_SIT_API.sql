--------------------------------------------------------
--  DDL for Package GHR_SIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SIT_API" AUTHID CURRENT_USER as
/* $Header: ghsitapi.pkh 115.2 2003/01/30 16:31:21 asubrahm ship $ */
--
-- Package Variables
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_sit >-------------------------------|
-- ----------------------------------------------------------------------------
procedure create_sit
  (p_validate                  in    boolean default false
  ,p_person_id                 in    number
  ,p_business_group_id         in    number
  ,p_id_flex_num               in    number
  ,p_effective_date            in    date
  ,p_comments                  in    varchar2 default null
  ,p_date_from                 in    date     default null
  ,p_date_to                   in    date     default null
  ,p_request_id                in    number   default null
  ,p_program_application_id    in    number   default null
  ,p_program_id                in    number   default null
  ,p_program_update_date       in    date     default null
  ,p_attribute_category        in    varchar2 default null
  ,p_attribute1                in    varchar2 default null
  ,p_attribute2                in    varchar2 default null
  ,p_attribute3                in    varchar2 default null
  ,p_attribute4                in    varchar2 default null
  ,p_attribute5                in    varchar2 default null
  ,p_attribute6                in    varchar2 default null
  ,p_attribute7                in    varchar2 default null
  ,p_attribute8                in    varchar2 default null
  ,p_attribute9                in    varchar2 default null
  ,p_attribute10               in    varchar2 default null
  ,p_attribute11               in    varchar2 default null
  ,p_attribute12               in    varchar2 default null
  ,p_attribute13               in    varchar2 default null
  ,p_attribute14               in    varchar2 default null
  ,p_attribute15               in    varchar2 default null
  ,p_attribute16               in    varchar2 default null
  ,p_attribute17               in    varchar2 default null
  ,p_attribute18               in    varchar2 default null
  ,p_attribute19               in    varchar2 default null
  ,p_attribute20               in    varchar2 default null
  ,p_segment1                  in    varchar2 default null
  ,p_segment2                  in    varchar2 default null
  ,p_segment3                  in    varchar2 default null
  ,p_segment4                  in    varchar2 default null
  ,p_segment5                  in    varchar2 default null
  ,p_segment6                  in    varchar2 default null
  ,p_segment7                  in    varchar2 default null
  ,p_segment8                  in    varchar2 default null
  ,p_segment9                  in    varchar2 default null
  ,p_segment10                 in    varchar2 default null
  ,p_segment11                 in    varchar2 default null
  ,p_segment12                 in    varchar2 default null
  ,p_segment13                 in    varchar2 default null
  ,p_segment14                 in    varchar2 default null
  ,p_segment15                 in    varchar2 default null
  ,p_segment16                 in    varchar2 default null
  ,p_segment17                 in    varchar2 default null
  ,p_segment18                 in    varchar2 default null
  ,p_segment19                 in    varchar2 default null
  ,p_segment20                 in    varchar2 default null
  ,p_segment21                 in    varchar2 default null
  ,p_segment22                 in    varchar2 default null
  ,p_segment23                 in    varchar2 default null
  ,p_segment24                 in    varchar2 default null
  ,p_segment25                 in    varchar2 default null
  ,p_segment26                 in    varchar2 default null
  ,p_segment27                 in    varchar2 default null
  ,p_segment28                 in    varchar2 default null
  ,p_segment29                 in    varchar2 default null
  ,p_segment30                 in    varchar2 default null
  ,p_analysis_criteria_id      out nocopy   number
  ,p_person_analysis_id        out nocopy   number
  ,p_pea_object_version_number out nocopy   number
  );


--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_sit >-------------------------------|
-- ----------------------------------------------------------------------------
procedure update_sit
  (p_validate                  in     boolean default false
  ,p_person_analysis_id        in     number
  ,p_pea_object_version_number in out nocopy number
  ,p_effective_date            in     date
  ,p_comments                  in     varchar2 default null
  ,p_date_from                 in     date     default null
  ,p_date_to                   in     date     default null
  ,p_request_id                in     number   default null
  ,p_program_application_id    in     number   default null
  ,p_program_id                in     number   default null
  ,p_program_update_date       in     date     default null
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_segment1                  in     varchar2 default null
  ,p_segment2                  in     varchar2 default null
  ,p_segment3                  in     varchar2 default null
  ,p_segment4                  in     varchar2 default null
  ,p_segment5                  in     varchar2 default null
  ,p_segment6                  in     varchar2 default null
  ,p_segment7                  in     varchar2 default null
  ,p_segment8                  in     varchar2 default null
  ,p_segment9                  in     varchar2 default null
  ,p_segment10                 in     varchar2 default null
  ,p_segment11                 in     varchar2 default null
  ,p_segment12                 in     varchar2 default null
  ,p_segment13                 in     varchar2 default null
  ,p_segment14                 in     varchar2 default null
  ,p_segment15                 in     varchar2 default null
  ,p_segment16                 in     varchar2 default null
  ,p_segment17                 in     varchar2 default null
  ,p_segment18                 in     varchar2 default null
  ,p_segment19                 in     varchar2 default null
  ,p_segment20                 in     varchar2 default null
  ,p_segment21                 in     varchar2 default null
  ,p_segment22                 in     varchar2 default null
  ,p_segment23                 in     varchar2 default null
  ,p_segment24                 in     varchar2 default null
  ,p_segment25                 in     varchar2 default null
  ,p_segment26                 in     varchar2 default null
  ,p_segment27                 in     varchar2 default null
  ,p_segment28                 in     varchar2 default null
  ,p_segment29                 in     varchar2 default null
  ,p_segment30                 in     varchar2 default null
  ,p_analysis_criteria_id      out nocopy number
  );

end ghr_sit_api;

 

/
