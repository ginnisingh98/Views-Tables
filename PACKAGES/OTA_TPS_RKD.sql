--------------------------------------------------------
--  DDL for Package OTA_TPS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPS_RKD" AUTHID CURRENT_USER as
/* $Header: ottpsrhi.pkh 120.0 2005/05/29 07:50:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_training_plan_id             in number
  ,p_time_period_id_o             in number
  ,p_plan_status_type_id_o        in varchar2
  ,p_organization_id_o            in number
  ,p_person_id_o                  in number
  ,p_budget_currency_o            in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_business_group_id_o          in number
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
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_plan_source_o                  in varchar2
  ,p_start_date_o                   in date
  ,p_end_date_o                     in date
  ,p_creator_person_id_o            in number
  ,p_additional_member_flag_o       in varchar2
  ,p_learning_path_id_o             in number
  ,p_contact_id_o                         in number
  );
--
end ota_tps_rkd;

 

/
