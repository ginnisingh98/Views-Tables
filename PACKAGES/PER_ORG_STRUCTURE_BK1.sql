--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_BK1" AUTHID CURRENT_USER AS
/* $Header: peorsapi.pkh 120.2 2005/10/22 01:24:14 aroussel noship $ */

Procedure create_org_Structure_b
  (p_validate                       IN     BOOLEAN
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number
  ,p_comments                       in     varchar2
  ,p_primary_structure_flag         in     varchar2
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
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
  ,p_position_control_structure_f   in     varchar2);

 procedure create_org_Structure_a
  (p_validate                       IN     BOOLEAN
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number
  ,p_comments                       in     varchar2
  ,p_primary_structure_flag         in     varchar2
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
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
  ,p_position_control_structure_f   in     varchar2
  ,p_object_version_number          in     number
  ,p_organization_structure_id      in     number
);

end per_org_structure_bk1;

 

/
