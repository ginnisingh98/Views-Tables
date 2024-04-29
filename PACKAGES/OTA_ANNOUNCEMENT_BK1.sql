--------------------------------------------------------
--  DDL for Package OTA_ANNOUNCEMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ANNOUNCEMENT_BK1" AUTHID CURRENT_USER as
/* $Header: otancapi.pkh 120.1 2005/10/02 02:07:19 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_announcement_b >--------------------------------|
-- ----------------------------------------------------------------------------
procedure create_announcement_b
  (p_effective_date               in     date
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date
  ,p_owner_id                       in     number
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
  ,p_object_version_number          in     number);
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_announcement_a >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_announcement_a
  (p_effective_date               in     date
  ,p_announcement_title           in varchar2
  ,p_announcement_body            in varchar2
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date
  ,p_owner_id                       in     number
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
  ,p_announcement_id                in      number
  ,p_object_version_number          in     number);

end ota_announcement_bk1 ;

 

/
