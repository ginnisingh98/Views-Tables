--------------------------------------------------------
--  DDL for Package OTA_CRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CRT_RKD" AUTHID CURRENT_USER as
/* $Header: otcrtrhi.pkh 120.1 2005/07/28 14:19 estreacy noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_certification_id             in number
  ,p_business_group_id_o          in number
  ,p_public_flag_o                in varchar2
  ,p_initial_completion_date_o    in date
  ,p_initial_completion_duratio_o in number
  ,p_initial_compl_duration_uni_o in varchar2
  ,p_renewal_duration_o           in number
  ,p_renewal_duration_units_o     in varchar2
  ,p_notify_days_before_expire_o  in number
  ,p_object_version_number_o      in number
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
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
  ,p_VALIDITY_DURATION_o          in NUMBER
  ,p_VALIDITY_DURATION_UNITS_o    in VARCHAR2
  ,p_RENEWABLE_FLAG_o             in VARCHAR2
  ,p_VALIDITY_START_TYPE_o        in VARCHAR2
  ,p_COMPETENCY_UPDATE_LEVEL_o    in VARCHAR2
  );
--
end ota_crt_rkd;

 

/
