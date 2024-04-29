--------------------------------------------------------
--  DDL for Package OTA_LPE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LPE_RKD" AUTHID CURRENT_USER as
/* $Header: otlperhi.pkh 120.2 2005/06/15 03:26 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_lp_enrollment_id             in number
  ,p_learning_path_id_o           in number
  ,p_person_id_o                  in number
  ,p_contact_id_o                 in number
  ,p_path_status_code_o           in varchar2
  ,p_enrollment_source_code_o     in varchar2
  ,p_no_of_mandatory_courses_o    in number
  ,p_no_of_completed_courses_o    in number
  ,p_completion_target_date_o     in date
  ,p_completion_date_o             in date
  ,p_creator_person_id_o          in number
  ,p_object_version_number_o      in number
  ,p_business_group_id_o          in number
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
  ,p_is_history_flag_o            in varchar2
  );
--
end ota_lpe_rkd;

 

/
