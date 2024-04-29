--------------------------------------------------------
--  DDL for Package OTA_TPS_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPS_API_BK1" AUTHID CURRENT_USER as
/* $Header: ottpsapi.pkh 120.1 2005/10/02 02:08:40 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_training plan_b >------------------------|
-- ----------------------------------------------------------------------------
procedure create_training_plan_b
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_time_period_id                in     number
  ,p_plan_status_type_id           in     varchar2
  ,p_organization_id               in     number
  ,p_person_id                     in     number
  ,p_budget_currency               in     varchar2
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_plan_source                     in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_creator_person_id              in  number
  ,p_additional_member_flag       in varchar2
  ,p_learning_path_id              in    number
   ,p_contact_id              in    number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_training plan_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_training_plan_a
  (p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_time_period_id                in     number
  ,p_plan_status_type_id           in     varchar2
  ,p_organization_id               in     number
  ,p_person_id                     in     number
  ,p_budget_currency               in     varchar2
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_training_plan_id              in     number
  ,p_object_version_number         in     number
  ,p_plan_source                   in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_creator_person_id             in     number
  ,p_additional_member_flag       in varchar2
  ,p_learning_path_id              in    number
  ,p_contact_id              in    number
  );
end ota_tps_api_bk1;

 

/
