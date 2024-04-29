--------------------------------------------------------
--  DDL for Package HR_DEPLOYMENT_FACTOR_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DEPLOYMENT_FACTOR_BK6" AUTHID CURRENT_USER as
/* $Header: pedpfapi.pkh 120.1 2005/10/02 02:15:01 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_job_dpmt_factor_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_job_dpmt_factor_b
  (p_effective_date               in     date
  ,p_job_id                       in     number
  ,p_business_group_id            in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2
  ,p_country2                     in     varchar2
  ,p_country3                     in     varchar2
  ,p_work_duration                in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_work_hours                   in     varchar2
  ,p_fte_capacity                 in     varchar2
  ,p_relocation_required          in     varchar2
  ,p_passport_required            in     varchar2
  ,p_location1                    in     varchar2
  ,p_location2                    in     varchar2
  ,p_location3                    in     varchar2
  ,p_other_requirements           in     varchar2
  ,p_service_minimum              in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_job_dpmt_factor_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_job_dpmt_factor_a
  (p_effective_date               in     date
  ,p_job_id                       in     number
  ,p_business_group_id            in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2
  ,p_country2                     in     varchar2
  ,p_country3                     in     varchar2
  ,p_work_duration                in     varchar2
  ,p_work_schedule                in     varchar2
  ,p_work_hours                   in     varchar2
  ,p_fte_capacity                 in     varchar2
  ,p_relocation_required          in     varchar2
  ,p_passport_required            in     varchar2
  ,p_location1                    in     varchar2
  ,p_location2                    in     varchar2
  ,p_location3                    in     varchar2
  ,p_other_requirements           in     varchar2
  ,p_service_minimum              in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in     number
  );
--
end hr_deployment_factor_bk6;

 

/
