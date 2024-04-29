--------------------------------------------------------
--  DDL for Package OTA_CMB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CMB_RKD" AUTHID CURRENT_USER as
/* $Header: otcmbrhi.pkh 120.2 2005/08/16 13:21 estreacy noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_certification_member_id      in number
  ,p_certification_id_o           in number
  ,p_object_id_o                  in number
  ,p_object_type_o                in varchar2
  ,p_member_sequence_o            in number
  ,p_business_group_id_o          in number
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_object_version_number_o      in number
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
end ota_cmb_rkd;

 

/
