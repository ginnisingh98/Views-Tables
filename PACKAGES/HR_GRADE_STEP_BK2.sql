--------------------------------------------------------
--  DDL for Package HR_GRADE_STEP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_STEP_BK2" AUTHID CURRENT_USER as
/* $Header: pespsapi.pkh 120.3.12000000.1 2007/01/22 04:39:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_grade_step_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_step_b
  (p_effective_date                in     date
  ,p_step_id                       in     number
  ,p_business_group_id             in     number
  ,p_spinal_point_id               in     number
  ,p_grade_spine_id                in     number
  ,p_sequence                      in     varchar2
  ,p_request_id                    in     number
  ,p_program_application_id        in     number
  ,p_program_id                    in     number
  ,p_program_update_date           in     date
  ,p_information_category          in     varchar2
  ,p_information1                  in     varchar2
  ,p_information2                  in     varchar2
  ,p_information3                  in     varchar2
  ,p_information4                  in     varchar2
  ,p_information5                  in     varchar2
  ,p_information6                  in     varchar2
  ,p_information7                  in     varchar2
  ,p_information8                  in     varchar2
  ,p_information9                  in     varchar2
  ,p_information10                 in     varchar2
  ,p_information11                 in     varchar2
  ,p_information12                 in     varchar2
  ,p_information13                 in     varchar2
  ,p_information14                 in     varchar2
  ,p_information15                 in     varchar2
  ,p_information16                 in     varchar2
  ,p_information17                 in     varchar2
  ,p_information18                 in     varchar2
  ,p_information19                 in     varchar2
  ,p_information20                 in     varchar2
  ,p_information21                 in     varchar2
  ,p_information22                 in     varchar2
  ,p_information23                 in     varchar2
  ,p_information24                 in     varchar2
  ,p_information25                 in     varchar2
  ,p_information26                 in     varchar2
  ,p_information27                 in     varchar2
  ,p_information28                 in     varchar2
  ,p_information29                 in     varchar2
  ,p_information30                 in     varchar2
  ,p_datetrack_mode                in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_grade_step_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_grade_step_a
  (p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in     number
  ,p_business_group_id             in     number
  ,p_spinal_point_id               in     number
  ,p_grade_spine_id                in     number
  ,p_sequence                      in     varchar2
  ,p_request_id                    in     number
  ,p_program_application_id        in     number
  ,p_program_id                    in     number
  ,p_program_update_date           in     date
  ,p_information_category          in     varchar2
  ,p_information1                  in     varchar2
  ,p_information2                  in     varchar2
  ,p_information3                  in     varchar2
  ,p_information4                  in     varchar2
  ,p_information5                  in     varchar2
  ,p_information6                  in     varchar2
  ,p_information7                  in     varchar2
  ,p_information8                  in     varchar2
  ,p_information9                  in     varchar2
  ,p_information10                 in     varchar2
  ,p_information11                 in     varchar2
  ,p_information12                 in     varchar2
  ,p_information13                 in     varchar2
  ,p_information14                 in     varchar2
  ,p_information15                 in     varchar2
  ,p_information16                 in     varchar2
  ,p_information17                 in     varchar2
  ,p_information18                 in     varchar2
  ,p_information19                 in     varchar2
  ,p_information20                 in     varchar2
  ,p_information21                 in     varchar2
  ,p_information22                 in     varchar2
  ,p_information23                 in     varchar2
  ,p_information24                 in     varchar2
  ,p_information25                 in     varchar2
  ,p_information26                 in     varchar2
  ,p_information27                 in     varchar2
  ,p_information28                 in     varchar2
  ,p_information29                 in     varchar2
  ,p_information30                 in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end hr_grade_step_bk2;

 

/
