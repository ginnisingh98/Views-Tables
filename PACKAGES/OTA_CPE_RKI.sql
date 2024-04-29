--------------------------------------------------------
--  DDL for Package OTA_CPE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CPE_RKI" AUTHID CURRENT_USER as
/* $Header: otcperhi.pkh 120.1 2005/07/15 14:06 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cert_prd_enrollment_id       in number
  ,p_cert_enrollment_id           in number
  ,p_object_version_number        in number
  ,p_period_status_code           in varchar2
  ,p_completion_date              in date
  ,p_cert_period_start_date       in date
  ,p_cert_period_end_date         in date
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
  ,p_expiration_date                 date
  );
end ota_cpe_rki;

 

/
