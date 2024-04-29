--------------------------------------------------------
--  DDL for Package OTA_CERT_MBR_ENROLLMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_MBR_ENROLLMENT_BK2" AUTHID CURRENT_USER as
/* $Header: otcmeapi.pkh 120.4 2006/07/13 11:44:44 niarora noship $ */
-- ----------------------------------------------------------------------------
-- |----------------< update_cert_mbr_enrollment_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_cert_mbr_enrollment_b
  (p_effective_date              in date,
  p_cert_mbr_enrollment_id       in number,
  p_object_version_number        in number,
  p_cert_prd_enrollment_id       in number,
  p_cert_member_id               in number,
  p_member_status_code           in varchar2,
  p_completion_date              in date,
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
  p_attribute20                  in varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cert_mbr_enrollment_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cert_mbr_enrollment_a
  (p_effective_date              in date,
  p_cert_mbr_enrollment_id       in number,
  p_object_version_number        in number,
  p_cert_prd_enrollment_id       in number,
  p_cert_member_id               in number,
  p_member_status_code           in varchar2,
  p_completion_date              in date,
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
  p_attribute20                  in varchar2
  );

end ota_cert_mbr_enrollment_bk2;

 

/
