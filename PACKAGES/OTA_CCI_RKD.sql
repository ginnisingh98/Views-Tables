--------------------------------------------------------
--  DDL for Package OTA_CCI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CCI_RKD" AUTHID CURRENT_USER as
/* $Header: otccirhi.pkh 120.1 2005/07/21 15:03 estreacy noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_category_usage_id            in number
  ,p_certification_id             in number
  ,p_object_version_number_o      in number
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_primary_flag_o               in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  );
--
end ota_cci_rkd;

 

/
