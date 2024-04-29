--------------------------------------------------------
--  DDL for Package OTA_CRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CRE_RKI" AUTHID CURRENT_USER as
/* $Header: otcrerhi.pkh 120.1 2005/08/23 15:00 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cert_enrollment_id           in number
  ,p_certification_id             in number
  ,p_person_id                    in number
  ,p_contact_id                   in number
  ,p_object_version_number        in number
  ,p_certification_status_code    in varchar2
  ,p_completion_date              in date
  ,p_business_group_id            in number
  ,p_unenrollment_date            in date
  ,p_expiration_date              in date
  ,p_earliest_enroll_date         in date
  ,p_is_history_flag              in varchar2
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
  ,p_enrollment_date	          in date
  );
end ota_cre_rki;

 

/
