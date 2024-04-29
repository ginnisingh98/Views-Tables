--------------------------------------------------------
--  DDL for Package PQP_RIW_GRADE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_RIW_GRADE_WRAPPER" AUTHID CURRENT_USER as
/* $Header: pqpriwgrwr.pkh 120.0.12010000.2 2009/07/24 07:57:47 sravikum noship $ */
PROCEDURE INSUPD_GRADE
 ( p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_sequence			   in	  number
  ,p_effective_date		   in     date     default null
  ,p_date_to                       in     date     default null
  ,p_request_id			   in 	  number   default null
  ,p_program_application_id        in 	  number   default null
  ,p_program_id                    in 	  number   default null
  ,p_program_update_date           in 	  date     default null
  ,p_last_update_date              in 	  date     default null
  ,p_last_updated_by               in 	  number   default null
  ,p_last_update_login             in 	  number   default null
  ,p_created_by                    in 	  number   default null
  ,p_creation_date                 in 	  date     default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1 	           in     varchar2 default null
  ,p_information2 	           in     varchar2 default null
  ,p_information3 	           in     varchar2 default null
  ,p_information4 	           in     varchar2 default null
  ,p_information5 	           in     varchar2 default null
  ,p_information6 	           in     varchar2 default null
  ,p_information7 	           in     varchar2 default null
  ,p_information8 	           in     varchar2 default null
  ,p_information9 	           in     varchar2 default null
  ,p_information10 	           in     varchar2 default null
  ,p_information11 	           in     varchar2 default null
  ,p_information12 	           in     varchar2 default null
  ,p_information13 	           in     varchar2 default null
  ,p_information14 	           in     varchar2 default null
  ,p_information15 	           in     varchar2 default null
  ,p_information16 	           in     varchar2 default null
  ,p_information17 	           in     varchar2 default null
  ,p_information18 	           in     varchar2 default null
  ,p_information19 	           in     varchar2 default null
  ,p_information20 	           in     varchar2 default null
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
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_concat_segments               in     varchar2 default null
  ,p_short_name			   in     varchar2 default null
  ,p_grade_id                      in     number
  ,p_grade_definition_id           in out nocopy number
  ,P_CRT_UPD			  in 	 varchar2   default null
  ,p_migration_flag                in     varchar2
  ,p_interface_code                in     varchar2
  ) ;
  end PQP_RIW_GRADE_WRAPPER;

/
