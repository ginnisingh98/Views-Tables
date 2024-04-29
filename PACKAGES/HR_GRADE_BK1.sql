--------------------------------------------------------
--  DDL for Package HR_GRADE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_BK1" AUTHID CURRENT_USER as
/* $Header: pegrdapi.pkh 120.1.12010000.3 2008/12/05 08:02:39 sidsaxen ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_grade_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_grade_b
  (p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_sequence			   in	  number
  ,p_date_to                       in     date
  ,p_effective_date		   in     date
  ,p_request_id			   in 	  number
  ,p_program_application_id        in 	  number
  ,p_program_id                    in 	  number
  ,p_program_update_date           in 	  date
  ,p_last_update_date              in 	  date
  ,p_last_updated_by               in 	  number
  ,p_last_update_login             in 	  number
  ,p_created_by                    in 	  number
  ,p_creation_date                 in 	  date
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
  ,p_information_category          in     varchar2
  ,p_information1 	           in     varchar2
  ,p_information2 	           in     varchar2
  ,p_information3 	           in     varchar2
  ,p_information4 	           in     varchar2
  ,p_information5 	           in     varchar2
  ,p_information6 	           in     varchar2
  ,p_information7 	           in     varchar2
  ,p_information8 	           in     varchar2
  ,p_information9 	           in     varchar2
  ,p_information10 	           in     varchar2
  ,p_information11 	           in     varchar2
  ,p_information12 	           in     varchar2
  ,p_information13 	           in     varchar2
  ,p_information14 	           in     varchar2
  ,p_information15 	           in     varchar2
  ,p_information16 	           in     varchar2
  ,p_information17 	           in     varchar2
  ,p_information18 	           in     varchar2
  ,p_information19 	           in     varchar2
  ,p_information20 	           in     varchar2
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
  ,p_language_code                 in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_grade_id                      in    number
  ,p_object_version_number         in    number
  ,p_grade_definition_id           in  number
  ,p_name                          in    varchar2
  ,p_short_name	          	   in    varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_grade_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_grade_a
  (p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_sequence			   in	  number
  ,p_date_to                       in     date
  ,p_effective_date		   in     date
  ,p_request_id			   in 	  number
  ,p_program_application_id        in 	  number
  ,p_program_id                    in 	  number
  ,p_program_update_date           in 	  date
  ,p_last_update_date              in 	  date
  ,p_last_updated_by               in 	  number
  ,p_last_update_login             in 	  number
  ,p_created_by                    in 	  number
  ,p_creation_date                 in 	  date
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
  ,p_information_category          in     varchar2
  ,p_information1 	           in     varchar2
  ,p_information2 	           in     varchar2
  ,p_information3 	           in     varchar2
  ,p_information4 	           in     varchar2
  ,p_information5 	           in     varchar2
  ,p_information6 	           in     varchar2
  ,p_information7 	           in     varchar2
  ,p_information8 	           in     varchar2
  ,p_information9 	           in     varchar2
  ,p_information10 	           in     varchar2
  ,p_information11 	           in     varchar2
  ,p_information12 	           in     varchar2
  ,p_information13 	           in     varchar2
  ,p_information14 	           in     varchar2
  ,p_information15 	           in     varchar2
  ,p_information16 	           in     varchar2
  ,p_information17 	           in     varchar2
  ,p_information18 	           in     varchar2
  ,p_information19 	           in     varchar2
  ,p_information20 	           in     varchar2
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
  ,p_language_code                 in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_grade_id                      in     number
  ,p_object_version_number         in     number
  ,p_grade_definition_id           in     number
  ,p_name                          in     varchar2
  ,p_short_name  		   in     varchar2
  );
--
end hr_grade_bk1;

/
