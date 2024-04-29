--------------------------------------------------------
--  DDL for Package OTA_CONFERENCE_SERVER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CONFERENCE_SERVER_BK2" AUTHID CURRENT_USER as
/* $Header: otcfsapi.pkh 120.3 2006/07/13 12:24:25 niarora noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------< update_conference_server_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_conference_server_b
  (p_effective_date                in     date
  ,p_conference_server_id          in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_url                           in     varchar2
  ,p_type                          in     varchar2
  ,p_owc_site_id                   in     varchar2
  ,p_owc_auth_token                in     varchar2
  ,p_end_date_active               in     date
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
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
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_conference_server_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_conference_server_a
  (p_effective_date                in     date
  ,p_conference_server_id          in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_url                           in     varchar2
  ,p_type                          in     varchar2
  ,p_owc_site_id                   in     varchar2
  ,p_owc_auth_token                in     varchar2
  ,p_end_date_active               in     date
  ,p_business_group_id             in     number
  ,p_object_version_number         in     number
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
  );
end ota_conference_server_bk2;

 

/
