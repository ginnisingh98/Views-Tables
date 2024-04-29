--------------------------------------------------------
--  DDL for Package OTA_CTU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTU_RKI" AUTHID CURRENT_USER as
/* $Header: otcturhi.pkh 120.0.12010000.2 2009/07/24 10:53:23 shwnayak ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_category_usage_id            in number
  ,p_business_group_id            in number
  ,p_category                     in varchar2
  ,p_object_version_number        in number
  ,p_type                         in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_parent_cat_usage_id          in number
  ,p_synchronous_flag             in varchar2
  ,p_online_flag                  in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_data_source                  in varchar2
  ,p_comments                     in varchar2
  );
end ota_ctu_rki;

/
