--------------------------------------------------------
--  DDL for Package HR_JOB_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JOB_API_BK2" AUTHID CURRENT_USER as
/* $Header: pejobapi.pkh 120.1.12010000.1 2008/07/28 04:55:31 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_job_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_job_b
  (p_job_id          in     number
  ,p_date_from                     in     date
  ,p_comments                      in     varchar2
  ,p_date_to                       in     date
  ,p_approval_authority            in     number
  ,p_benchmark_job_flag            in     varchar2
  ,p_benchmark_job_id              in     number
  ,p_emp_rights_flag               in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_job_information_category      in     varchar2
  ,p_job_information1              in     varchar2
  ,p_job_information2              in     varchar2
  ,p_job_information3              in     varchar2
  ,p_job_information4              in     varchar2
  ,p_job_information5              in     varchar2
  ,p_job_information6              in     varchar2
  ,p_job_information7              in     varchar2
  ,p_job_information8              in     varchar2
  ,p_job_information9              in     varchar2
  ,p_job_information10             in     varchar2
  ,p_job_information11             in     varchar2
  ,p_job_information12             in     varchar2
  ,p_job_information13             in     varchar2
  ,p_job_information14             in     varchar2
  ,p_job_information15             in     varchar2
  ,p_job_information16             in     varchar2
  ,p_job_information17             in     varchar2
  ,p_job_information18             in     varchar2
  ,p_job_information19             in     varchar2
  ,p_job_information20             in     varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_name            in     varchar2
  ,p_object_version_number    in     number
  ,p_job_definition_id        in   number
  ,p_effective_date              in      date      --Added for bug# 1760707
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_job_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_job_a
  (p_job_id          in      number
  ,p_date_from                     in     date
  ,p_comments                      in     varchar2
  ,p_date_to                       in     date
  ,p_approval_authority            in     number
  ,p_benchmark_job_flag            in     varchar2
  ,p_benchmark_job_id              in     number
  ,p_emp_rights_flag               in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_job_information_category      in     varchar2
  ,p_job_information1              in     varchar2
  ,p_job_information2              in     varchar2
  ,p_job_information3              in     varchar2
  ,p_job_information4              in     varchar2
  ,p_job_information5              in     varchar2
  ,p_job_information6              in     varchar2
  ,p_job_information7              in     varchar2
  ,p_job_information8              in     varchar2
  ,p_job_information9              in     varchar2
  ,p_job_information10             in     varchar2
  ,p_job_information11             in     varchar2
  ,p_job_information12             in     varchar2
  ,p_job_information13             in     varchar2
  ,p_job_information14             in     varchar2
  ,p_job_information15             in     varchar2
  ,p_job_information16             in     varchar2
  ,p_job_information17             in     varchar2
  ,p_job_information18             in     varchar2
  ,p_job_information19             in     varchar2
  ,p_job_information20             in     varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_job_definition_id        in   number
  ,p_effective_date        in      date   --Added for Bug# 1760707
  );
--
end hr_job_api_bk2;

/
