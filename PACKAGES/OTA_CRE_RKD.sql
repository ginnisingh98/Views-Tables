--------------------------------------------------------
--  DDL for Package OTA_CRE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CRE_RKD" AUTHID CURRENT_USER as
/* $Header: otcrerhi.pkh 120.1 2005/08/23 15:00 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cert_enrollment_id           in number
  ,p_certification_id_o           in number
  ,p_person_id_o                  in number
  ,p_contact_id_o                 in number
  ,p_object_version_number_o      in number
  ,p_certification_status_code_o  in varchar2
  ,p_completion_date_o            in date
  ,p_business_group_id_o          in number
  ,p_unenrollment_date_o          in date
  ,p_expiration_date_o            in date
  ,p_earliest_enroll_date_o       in date
  ,p_is_history_flag_o            in varchar2
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
  ,p_enrollment_date_o            in date
  );
--
end ota_cre_rkd;

 

/
