--------------------------------------------------------
--  DDL for Package PER_HIERARCHY_NODES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HIERARCHY_NODES_BK2" AUTHID CURRENT_USER as
/* $Header: pepgnapi.pkh 120.2 2005/10/22 01:24:34 aroussel noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_hierarchy_nodes_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_nodes_b
  (
   p_hierarchy_node_id              in  number
  ,p_entity_id                      in  varchar2
  ,p_node_type                      in  varchar2
  ,p_seq                            in  number
  ,p_parent_hierarchy_node_id       in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  ,p_information_category           in  varchar2
  ,p_information1                   in  varchar2
  ,p_information2                   in  varchar2
  ,p_information3                   in  varchar2
  ,p_information4                   in  varchar2
  ,p_information5                   in  varchar2
  ,p_information6                   in  varchar2
  ,p_information7                   in  varchar2
  ,p_information8                   in  varchar2
  ,p_information9                   in  varchar2
  ,p_information10                  in  varchar2
  ,p_information11                  in  varchar2
  ,p_information12                  in  varchar2
  ,p_information13                  in  varchar2
  ,p_information14                  in  varchar2
  ,p_information15                  in  varchar2
  ,p_information16                  in  varchar2
  ,p_information17                  in  varchar2
  ,p_information18                  in  varchar2
  ,p_information19                  in  varchar2
  ,p_information20                  in  varchar2
  ,p_information21                  in  varchar2
  ,p_information22                  in  varchar2
  ,p_information23                  in  varchar2
  ,p_information24                  in  varchar2
  ,p_information25                  in  varchar2
  ,p_information26                  in  varchar2
  ,p_information27                  in  varchar2
  ,p_information28                  in  varchar2
  ,p_information29                  in  varchar2
  ,p_information30                  in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_hierarchy_nodes_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_nodes_a
  (
   p_hierarchy_node_id              in  number
  ,p_entity_id                      in  varchar2
  ,p_node_type                      in  varchar2
  ,p_seq                            in  number
  ,p_parent_hierarchy_node_id       in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  ,p_information_category           in  varchar2
  ,p_information1                   in  varchar2
  ,p_information2                   in  varchar2
  ,p_information3                   in  varchar2
  ,p_information4                   in  varchar2
  ,p_information5                   in  varchar2
  ,p_information6                   in  varchar2
  ,p_information7                   in  varchar2
  ,p_information8                   in  varchar2
  ,p_information9                   in  varchar2
  ,p_information10                  in  varchar2
  ,p_information11                  in  varchar2
  ,p_information12                  in  varchar2
  ,p_information13                  in  varchar2
  ,p_information14                  in  varchar2
  ,p_information15                  in  varchar2
  ,p_information16                  in  varchar2
  ,p_information17                  in  varchar2
  ,p_information18                  in  varchar2
  ,p_information19                  in  varchar2
  ,p_information20                  in  varchar2
  ,p_information21                  in  varchar2
  ,p_information22                  in  varchar2
  ,p_information23                  in  varchar2
  ,p_information24                  in  varchar2
  ,p_information25                  in  varchar2
  ,p_information26                  in  varchar2
  ,p_information27                  in  varchar2
  ,p_information28                  in  varchar2
  ,p_information29                  in  varchar2
  ,p_information30                  in  varchar2
  ,p_effective_date                 in  date
  );
--
end per_hierarchy_nodes_bk2;

 

/
