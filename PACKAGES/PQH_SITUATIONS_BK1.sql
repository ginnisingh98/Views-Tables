--------------------------------------------------------
--  DDL for Package PQH_SITUATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_SITUATIONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqlosapi.pkh 120.1 2005/10/02 02:26:58 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<  create_situation_b  >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_situation_b
  (p_effective_date                 in     date
  ,p_situation                      in     varchar2
  ,p_effective_start_date           in     date
  ,p_business_group_id              in     number
  ,p_situation_type                 in     varchar2
  ,p_length_of_service              in     varchar2
  ,p_effective_end_date             in     date
  ,p_employee_type                  in     varchar2
  ,p_entitlement_flag               in     varchar2
  ,p_worktime_proportional          in     varchar2
  ,p_entitlement_value              in     number
  ,p_information_category           in     varchar2
  ,p_information1                   in     varchar2
  ,p_information2                   in     varchar2
  ,p_information3                   in     varchar2
  ,p_information4                   in     varchar2
  ,p_information5                   in     varchar2
  ,p_information6                   in     varchar2
  ,p_information7                   in     varchar2
  ,p_information8                   in     varchar2
  ,p_information9                   in     varchar2
  ,p_information10                  in     varchar2
  ,p_information11                  in     varchar2
  ,p_information12                  in     varchar2
  ,p_information13                  in     varchar2
  ,p_information14                  in     varchar2
  ,p_information15                  in     varchar2
  ,p_information16                  in     varchar2
  ,p_information17                  in     varchar2
  ,p_information18                  in     varchar2
  ,p_information19                  in     varchar2
  ,p_information20                  in     varchar2
  ,p_information21                  in     varchar2
  ,p_information22                  in     varchar2
  ,p_information23                  in     varchar2
  ,p_information24                  in     varchar2
  ,p_information25                  in     varchar2
  ,p_information26                  in     varchar2
  ,p_information27                  in     varchar2
  ,p_information28                  in     varchar2
  ,p_information29                  in     varchar2
  ,p_information30                  in     varchar2
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_attribute21                    in     varchar2
  ,p_attribute22                    in     varchar2
  ,p_attribute23                    in     varchar2
  ,p_attribute24                    in     varchar2
  ,p_attribute25                    in     varchar2
  ,p_attribute26                    in     varchar2
  ,p_attribute27                    in     varchar2
  ,p_attribute28                    in     varchar2
  ,p_attribute29                    in     varchar2
  ,p_attribute30                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------<  create_situation_a  >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_situation_a
  (p_effective_date                 in     date
  ,p_situation                      in     varchar2
  ,p_effective_start_date           in     date
  ,p_business_group_id              in     number
  ,p_situation_type                 in     varchar2
  ,p_length_of_service              in     varchar2
  ,p_effective_end_date             in     date
  ,p_employee_type                  in     varchar2
  ,p_entitlement_flag               in     varchar2
  ,p_worktime_proportional          in     varchar2
  ,p_entitlement_value              in     number
  ,p_information_category           in     varchar2
  ,p_information1                   in     varchar2
  ,p_information2                   in     varchar2
  ,p_information3                   in     varchar2
  ,p_information4                   in     varchar2
  ,p_information5                   in     varchar2
  ,p_information6                   in     varchar2
  ,p_information7                   in     varchar2
  ,p_information8                   in     varchar2
  ,p_information9                   in     varchar2
  ,p_information10                  in     varchar2
  ,p_information11                  in     varchar2
  ,p_information12                  in     varchar2
  ,p_information13                  in     varchar2
  ,p_information14                  in     varchar2
  ,p_information15                  in     varchar2
  ,p_information16                  in     varchar2
  ,p_information17                  in     varchar2
  ,p_information18                  in     varchar2
  ,p_information19                  in     varchar2
  ,p_information20                  in     varchar2
  ,p_information21                  in     varchar2
  ,p_information22                  in     varchar2
  ,p_information23                  in     varchar2
  ,p_information24                  in     varchar2
  ,p_information25                  in     varchar2
  ,p_information26                  in     varchar2
  ,p_information27                  in     varchar2
  ,p_information28                  in     varchar2
  ,p_information29                  in     varchar2
  ,p_information30                  in     varchar2
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_attribute21                    in     varchar2
  ,p_attribute22                    in     varchar2
  ,p_attribute23                    in     varchar2
  ,p_attribute24                    in     varchar2
  ,p_attribute25                    in     varchar2
  ,p_attribute26                    in     varchar2
  ,p_attribute27                    in     varchar2
  ,p_attribute28                    in     varchar2
  ,p_attribute29                    in     varchar2
  ,p_attribute30                    in     varchar2
  ,p_situation_id                   in     number
  ,p_object_version_number          in     number
  );
--
end pqh_situations_bk1;

 

/
