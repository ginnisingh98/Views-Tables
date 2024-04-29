--------------------------------------------------------
--  DDL for Package OTA_CPE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CPE_RKD" AUTHID CURRENT_USER as
/* $Header: otcperhi.pkh 120.1 2005/07/15 14:06 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cert_prd_enrollment_id       in number
  ,p_cert_enrollment_id_o         in number
  ,p_object_version_number_o      in number
  ,p_period_status_code_o         in varchar2
  ,p_completion_date_o            in date
  ,p_cert_period_start_date_o     in date
  ,p_cert_period_end_date_o       in date
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
  ,p_expiration_date_o            in date
  );
--
end ota_cpe_rkd;

 

/
