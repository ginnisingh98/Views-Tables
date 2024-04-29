--------------------------------------------------------
--  DDL for Package OTA_CATEGORY_USAGE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CATEGORY_USAGE_BK1" AUTHID CURRENT_USER as
/* $Header: otctuapi.pkh 120.1.12010000.2 2009/07/24 10:51:35 shwnayak ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_category_usage_bk1.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_CATEGORY_B >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Create_category_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_category                      in     varchar2
  ,p_type                          in	  varchar2
  ,p_parent_cat_usage_id           in	  number
  ,p_synchronous_flag              in	  varchar2
  ,p_online_flag                   in	  varchar2
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
  ,p_data_source                  in     varchar2
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date
  ,p_comments                      in     varchar2

  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_CATEGORY_A >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Create_Category_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_category                      in     varchar2
  ,p_type                          in	  varchar2
  ,p_parent_cat_usage_id           in	  number
  ,p_synchronous_flag              in	  varchar2
  ,p_online_flag                   in	  varchar2
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
  ,p_data_source                   in     varchar2
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date
  ,p_category_usage_id             in     number
  ,p_object_version_number         in     number
  ,p_comments                      in     varchar2

  );



end ota_category_usage_bk1;

/
