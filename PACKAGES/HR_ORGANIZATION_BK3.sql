--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK3" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_organization >-----------------------|
-- ----------------------------------------------------------------------------
--


PROCEDURE create_organization_b
     (p_effective_date              IN  DATE
     ,p_language_code               IN  VARCHAR2
     ,p_business_group_id           IN  NUMBER
     ,p_date_from                   IN  DATE
     ,p_name                        IN  VARCHAR2
     ,p_location_id                 in  number
     ,p_date_to                     in  date
     ,p_internal_external_flag      in  varchar2
     ,p_internal_address_line       in  varchar2
     ,p_type                        in  varchar2
     ,p_attribute_category          in  varchar2
     ,p_attribute1                  in  varchar2
     ,p_attribute2                  in  varchar2
     ,p_attribute3                  in  varchar2
     ,p_attribute4                  in  varchar2
     ,p_attribute5                  in  varchar2
     ,p_attribute6                  in  varchar2
     ,p_attribute7                  in  varchar2
     ,p_attribute8                  in  varchar2
     ,p_attribute9                  in  varchar2
     ,p_attribute10                 in  varchar2
     ,p_attribute11                 in  varchar2
     ,p_attribute12                 in  varchar2
     ,p_attribute13                 in  varchar2
     ,p_attribute14                 in  varchar2
     ,p_attribute15                 in  varchar2
     ,p_attribute16                 in  varchar2
     ,p_attribute17                 in  varchar2
     ,p_attribute18                 in  varchar2
     ,p_attribute19                 in  varchar2
     ,p_attribute20                 in  varchar2
     -- Enhancement 4040086
     ,p_attribute21                 in  varchar2
     ,p_attribute22                 in  varchar2
     ,p_attribute23                 in  varchar2
     ,p_attribute24                 in  varchar2
     ,p_attribute25                 in  varchar2
     ,p_attribute26                 in  varchar2
     ,p_attribute27                 in  varchar2
     ,p_attribute28                 in  varchar2
     ,p_attribute29                 in  varchar2
     ,p_attribute30                 in  varchar2
     --End Enhancement 4040086
--   ,p_organization_id             OUT NUMBER
--   ,p_object_version_number       OUT NUMBER
 );



PROCEDURE create_organization_a
     (p_effective_date              IN  DATE
     ,p_language_code               IN  VARCHAR2
     ,p_business_group_id           IN  NUMBER
     ,p_date_from                   IN  DATE
     ,p_name                        IN  VARCHAR2
     ,p_location_id                 in  number
     ,p_date_to                     in  date
     ,p_internal_external_flag      in  varchar2
     ,p_internal_address_line       in  varchar2
     ,p_type                        in  varchar2
     ,p_attribute_category          in  varchar2
     ,p_attribute1                  in  varchar2
     ,p_attribute2                  in  varchar2
     ,p_attribute3                  in  varchar2
     ,p_attribute4                  in  varchar2
     ,p_attribute5                  in  varchar2
     ,p_attribute6                  in  varchar2
     ,p_attribute7                  in  varchar2
     ,p_attribute8                  in  varchar2
     ,p_attribute9                  in  varchar2
     ,p_attribute10                 in  varchar2
     ,p_attribute11                 in  varchar2
     ,p_attribute12                 in  varchar2
     ,p_attribute13                 in  varchar2
     ,p_attribute14                 in  varchar2
     ,p_attribute15                 in  varchar2
     ,p_attribute16                 in  varchar2
     ,p_attribute17                 in  varchar2
     ,p_attribute18                 in  varchar2
     ,p_attribute19                 in  varchar2
     ,p_attribute20                 in  varchar2
     -- Enhancement 4040086
     ,p_attribute21                 in  varchar2
     ,p_attribute22                 in  varchar2
     ,p_attribute23                 in  varchar2
     ,p_attribute24                 in  varchar2
     ,p_attribute25                 in  varchar2
     ,p_attribute26                 in  varchar2
     ,p_attribute27                 in  varchar2
     ,p_attribute28                 in  varchar2
     ,p_attribute29                 in  varchar2
     ,p_attribute30                 in  varchar2
     --End Enhancement 4040086
     ,p_organization_id             in  NUMBER
     ,p_object_version_number       in  NUMBER
     ,p_duplicate_org_warning       in  boolean
 );

end hr_organization_bk3;

/
