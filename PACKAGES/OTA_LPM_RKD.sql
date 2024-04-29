--------------------------------------------------------
--  DDL for Package OTA_LPM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LPM_RKD" AUTHID CURRENT_USER as
/* $Header: otlpmrhi.pkh 120.0 2005/05/29 07:22:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_learning_path_member_id      in number
  ,p_learning_path_id_o           in number
  ,p_activity_version_id_o        in number
  ,p_course_sequence_o            in number
  ,p_business_group_id_o          in number
  ,p_duration_o                   in number
  ,p_duration_units_o             in varchar2
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
  ,p_learning_path_section_id_o   in number
  ,p_notify_days_before_target_o  in number
  );
--
end ota_lpm_rkd;

 

/
