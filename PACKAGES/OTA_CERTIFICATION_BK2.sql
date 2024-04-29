--------------------------------------------------------
--  DDL for Package OTA_CERTIFICATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERTIFICATION_BK2" AUTHID CURRENT_USER as
/* $Header: otcrtapi.pkh 120.5 2006/07/14 09:29:45 niarora noship $ */
-- ----------------------------------------------------------------------------
-- |----------------< update_certification_b >----------------------------|
-- ----------------------------------------------------------------------------
procedure update_certification_b
  (p_effective_date                 in     date
  ,p_certification_id               in     number
  ,p_object_version_number        in  number
  ,p_name                           in     varchar2
  ,p_public_flag                    in     varchar2
  ,p_initial_completion_date        in     date
  ,p_initial_completion_duration    in     number
  ,p_initial_compl_duration_units   in     varchar2
  ,p_renewal_duration               in     number
  ,p_renewal_duration_units         in     varchar2
  ,p_notify_days_before_expire      in     number
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date
  ,p_description                    in     varchar2
  ,p_objectives                     in     varchar2
  ,p_purpose                        in     varchar2
  ,p_keywords                       in     varchar2
  ,p_end_date_comments              in     varchar2
  ,p_initial_period_comments        in     varchar2
  ,p_renewal_period_comments        in     varchar2
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_business_group_id              in     number
  ,p_VALIDITY_DURATION              in     NUMBER
  ,p_VALIDITY_DURATION_UNITS        in     VARCHAR2
  ,p_RENEWABLE_FLAG                 in     VARCHAR2
  ,p_VALIDITY_START_TYPE            in     VARCHAR2
  ,p_COMPETENCY_UPDATE_LEVEL        in     VARCHAR2
  ,p_validate                       in     boolean
);

-- ----------------------------------------------------------------------------
-- |-------------------< update_certification_a >-------------------------|
-- ----------------------------------------------------------------------------
procedure update_certification_a
  (p_effective_date                 in     date
  ,p_certification_id               in     number
  ,p_object_version_number        in  number
  ,p_name                           in     varchar2
  ,p_public_flag                    in     varchar2
  ,p_initial_completion_date        in     date
  ,p_initial_completion_duration    in     number
  ,p_initial_compl_duration_units   in     varchar2
  ,p_renewal_duration               in     number
  ,p_renewal_duration_units         in     varchar2
  ,p_notify_days_before_expire      in     number
  ,p_start_date_active              in     date
  ,p_end_date_active                in     date
  ,p_description                    in     varchar2
  ,p_objectives                     in     varchar2
  ,p_purpose                        in     varchar2
  ,p_keywords                       in     varchar2
  ,p_end_date_comments              in     varchar2
  ,p_initial_period_comments        in     varchar2
  ,p_renewal_period_comments        in     varchar2
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_business_group_id              in     number
  ,p_VALIDITY_DURATION              in     NUMBER
  ,p_VALIDITY_DURATION_UNITS        in     VARCHAR2
  ,p_RENEWABLE_FLAG                 in     VARCHAR2
  ,p_VALIDITY_START_TYPE            in     VARCHAR2
  ,p_COMPETENCY_UPDATE_LEVEL        in     VARCHAR2
  ,p_validate                       in     boolean
);

end ota_certification_bk2;


 

/
