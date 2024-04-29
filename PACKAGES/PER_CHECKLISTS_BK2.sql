--------------------------------------------------------
--  DDL for Package PER_CHECKLISTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CHECKLISTS_BK2" AUTHID CURRENT_USER as
/* $Header: pecklapi.pkh 120.1 2005/12/13 03:13:45 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_checklist_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_checklist_b
  (p_effective_date                in     date
  ,p_checklist_id                  in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_business_group_id             in     number
  ,p_life_event_reason_id          in     number
  ,p_checklist_category            in     varchar2
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
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_checklist_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_checklist_a
  (p_effective_date                in     date
  ,p_checklist_id                  in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_business_group_id             in     number
  ,p_life_event_reason_id          in     number
  ,p_checklist_category            in     varchar2
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
  ,p_object_version_number         in     number
  );
--
end PER_CHECKLISTS_BK2;

 

/
