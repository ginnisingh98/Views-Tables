--------------------------------------------------------
--  DDL for Package OTA_CERT_PRD_ENROLLMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_PRD_ENROLLMENT_BK1" AUTHID CURRENT_USER as
/* $Header: otcpeapi.pkh 120.6.12010000.2 2008/09/22 11:03:17 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_cert_prd_enrollment_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_cert_prd_enrollment_b
  (
  p_effective_date               in date,
  p_cert_enrollment_id           in number,
  p_period_status_code           in varchar2,
  p_completion_date              in date,
  p_cert_period_start_date       in date,
  p_cert_period_end_date         in date,
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
  p_expiration_date              in date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_cert_prd_enrollment_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cert_prd_enrollment_a
  (p_effective_date              in date,
  p_cert_prd_enrollment_id       in number,
  p_cert_enrollment_id           in number,
  p_period_status_code           in varchar2,
  p_completion_date              in date,
  p_cert_period_start_date       in date,
  p_cert_period_end_date         in date,
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
  p_expiration_date              in date
  );

end ota_cert_prd_enrollment_bk1 ;

/
