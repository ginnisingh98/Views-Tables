--------------------------------------------------------
--  DDL for Package OTA_CERT_MEMBER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_MEMBER_BK1" AUTHID CURRENT_USER as
/* $Header: otcmbapi.pkh 120.3 2006/07/13 11:48:43 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_certification_member_b >----------------------|
-- ----------------------------------------------------------------------------
procedure create_certification_member_b
  (p_effective_date               in     date
  ,p_certification_id               in     number
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_member_sequence                in     number
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date
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
);

-- ----------------------------------------------------------------------------
-- |----------------< create_certification_member_a >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_certification_member_a
  (p_effective_date                 in     date
  ,p_certification_id               in     number
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_member_sequence                in     number
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date
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
);

end ota_cert_member_bk1;

 

/
