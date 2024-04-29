--------------------------------------------------------
--  DDL for Package OTA_LPS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LPS_RKD" AUTHID CURRENT_USER as
/* $Header: otlpsrhi.pkh 120.0 2005/05/29 07:24:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_learning_path_id             in number
  ,p_business_group_id_o          in number
  ,p_duration_o                   in number
  ,p_duration_units_o             in varchar2
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
  ,p_path_source_code_o           in varchar2
  ,p_source_function_code_o       in varchar2
  ,p_assignment_id_o              in number
  ,p_source_id_o                  in number
  ,p_notify_days_before_target_o  in number
  ,p_person_id_o                  in number
  ,p_contact_id_o                 in number
  ,p_display_to_learner_flag_o    in varchar2
  ,p_public_flag_o                in varchar2
    ,p_competency_update_level_o      in varchar2
  );
--
end ota_lps_rkd;

 

/
