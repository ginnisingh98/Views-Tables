--------------------------------------------------------
--  DDL for Package OTA_LPE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LPE_RKU" AUTHID CURRENT_USER as
/* $Header: otlperhi.pkh 120.2 2005/06/15 03:26 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_lp_enrollment_id             in number
  ,p_learning_path_id             in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_path_status_code             in varchar2
  ,p_enrollment_source_code       in varchar2
  ,p_no_of_mandatory_courses      in number
  ,p_no_of_completed_courses      in number
  ,p_completion_target_date       in date
  ,p_completion_date              in date
  ,p_creator_person_id            in number
  ,p_object_version_number        in number
  ,p_business_group_id            in number
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
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_is_history_flag              in varchar2
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
end ota_lpe_rku;

 

/
