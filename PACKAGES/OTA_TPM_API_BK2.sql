--------------------------------------------------------
--  DDL for Package OTA_TPM_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPM_API_BK2" AUTHID CURRENT_USER as
/* $Header: ottpmapi.pkh 120.1 2005/10/02 02:08:35 aroussel $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< update_training_plan_member_b >---------------------------------|
-- ----------------------------------------------------------------------------
procedure update_training_plan_member_b
  (p_effective_date                in     date
  ,p_training_plan_member_id       in     number
  ,p_object_version_number         in     number
  ,p_activity_version_id           in     number
  ,p_activity_definition_id        in     number
  ,p_member_status_type_id         in     varchar2
  ,p_target_completion_date        in     date
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
  ,p_assignment_id                in number
  ,p_source_id                    in number
  ,p_source_function              in varchar2
  ,p_cancellation_reason          in varchar2
  ,P_earliest_start_date          in date
  ,p_creator_person_id             in    number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_training_plan_member_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_training_plan_member_a
  (p_effective_date                in     date
  ,p_training_plan_member_id       in     number
  ,p_object_version_number         in     number
  ,p_activity_version_id           in     number
  ,p_activity_definition_id        in     number
  ,p_member_status_type_id         in     varchar2
  ,p_target_completion_date        in     date
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
  ,p_assignment_id                in number
  ,p_source_id                    in number
  ,p_source_function              in varchar2
  ,p_cancellation_reason          in varchar2
  ,P_earliest_start_date          in date
  ,p_creator_person_id             in    number
  );
end ota_tpm_api_bk2;

 

/
