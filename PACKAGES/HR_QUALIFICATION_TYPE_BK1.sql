--------------------------------------------------------
--  DDL for Package HR_QUALIFICATION_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUALIFICATION_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: peeqtapi.pkh 120.1 2005/10/02 02:16 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< create_qualification_type_b >--------------------------|
-- ----------------------------------------------------------------------------
--
 procedure create_qualification_type_b
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_name                          in     varchar2
  ,p_category                      in     varchar2
  ,p_rank                          in     number
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
  ,p_qual_framework_id             in     number            -- BUG3356369
  ,p_qualification_type            in     varchar2
  ,p_credit_type                   in     varchar2
  ,p_credits                       in     number
  ,p_level_type                    in     varchar2
  ,p_level_number                  in     number
  ,p_field                         in     varchar2
  ,p_sub_field                     in     varchar2
  ,p_provider                      in     varchar2
  ,p_qa_organization               in     varchar2
 );
-- ----------------------------------------------------------------------------
-- |------------------< create_qualification_type_a >--------------------------|
-- ----------------------------------------------------------------------------
--
 procedure create_qualification_type_a
  (p_effective_date                in     date
  ,p_qualification_type_id         in     number
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  ,p_name                          in     varchar2
  ,p_category                      in     varchar2
  ,p_rank                          in     number
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
  ,p_qual_framework_id             in     number            -- BUG3356369
  ,p_qualification_type            in     varchar2
  ,p_credit_type                   in     varchar2
  ,p_credits                       in     number
  ,p_level_type                    in     varchar2
  ,p_level_number                  in     number
  ,p_field                         in     varchar2
  ,p_sub_field                     in     varchar2
  ,p_provider                      in     varchar2
  ,p_qa_organization               in     varchar2
 );
--
end hr_qualification_type_bk1;

 

/
