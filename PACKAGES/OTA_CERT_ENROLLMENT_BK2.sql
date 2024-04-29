--------------------------------------------------------
--  DDL for Package OTA_CERT_ENROLLMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_ENROLLMENT_BK2" AUTHID CURRENT_USER as
/* $Header: otcreapi.pkh 120.7.12010000.2 2009/03/12 12:17:48 psengupt ship $ */
-- ----------------------------------------------------------------------------
-- |----------------< update_cert_enrollment_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_cert_enrollment_b
  (p_effective_date              in date,
  p_cert_enrollment_id           in number,
  p_object_version_number        in number,
  p_certification_id             in number,
  p_person_id                    in number,
  p_contact_id                   in number,
  p_certification_status_code    in varchar2,
  p_completion_date              in date,
  p_UNENROLLMENT_DATE            in date,
  p_EXPIRATION_DATE              in date,
  p_EARLIEST_ENROLL_DATE         in date,
  p_IS_HISTORY_FLAG              in varchar2,
  p_business_group_id            in number,
  p_attribute_category           in varchar2 ,
  p_attribute1                   in varchar2 ,
  p_attribute2                   in varchar2 ,
  p_attribute3                   in varchar2 ,
  p_attribute4                   in varchar2 ,
  p_attribute5                   in varchar2 ,
  p_attribute6                   in varchar2 ,
  p_attribute7                   in varchar2 ,
  p_attribute8                   in varchar2 ,
  p_attribute9                   in varchar2 ,
  p_attribute10                  in varchar2 ,
  p_attribute11                  in varchar2 ,
  p_attribute12                  in varchar2 ,
  p_attribute13                  in varchar2 ,
  p_attribute14                  in varchar2 ,
  p_attribute15                  in varchar2 ,
  p_attribute16                  in varchar2 ,
  p_attribute17                  in varchar2 ,
  p_attribute18                  in varchar2 ,
  p_attribute19                  in varchar2 ,
  p_attribute20                  in varchar2 ,
  p_enrollment_date	         in date
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cert_enrollment_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cert_enrollment_a
  (p_effective_date              in date,
  p_cert_enrollment_id           in number,
  p_object_version_number        in number,
  p_certification_id             in number,
  p_person_id                    in number,
  p_contact_id                   in number,
  p_certification_status_code    in varchar2,
  p_completion_date              in date,
  p_UNENROLLMENT_DATE            in date,
  p_EXPIRATION_DATE              in date,
  p_EARLIEST_ENROLL_DATE         in date,
  p_IS_HISTORY_FLAG              in varchar2,
  p_business_group_id            in number,
  p_attribute_category           in varchar2 ,
  p_attribute1                   in varchar2 ,
  p_attribute2                   in varchar2 ,
  p_attribute3                   in varchar2 ,
  p_attribute4                   in varchar2 ,
  p_attribute5                   in varchar2 ,
  p_attribute6                   in varchar2 ,
  p_attribute7                   in varchar2 ,
  p_attribute8                   in varchar2 ,
  p_attribute9                   in varchar2 ,
  p_attribute10                  in varchar2 ,
  p_attribute11                  in varchar2 ,
  p_attribute12                  in varchar2 ,
  p_attribute13                  in varchar2 ,
  p_attribute14                  in varchar2 ,
  p_attribute15                  in varchar2 ,
  p_attribute16                  in varchar2 ,
  p_attribute17                  in varchar2 ,
  p_attribute18                  in varchar2 ,
  p_attribute19                  in varchar2 ,
  p_attribute20                  in varchar2 ,
  p_enrollment_date	         in date
  );

end ota_cert_enrollment_bk2;

/
