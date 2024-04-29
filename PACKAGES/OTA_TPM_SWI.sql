--------------------------------------------------------
--  DDL for Package OTA_TPM_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPM_SWI" AUTHID CURRENT_USER AS
/* $Header: ottpmswi.pkh 115.2 2003/07/03 06:05:44 rdola noship $ */

-- ----------------------------------------------------------------------------
-- |----------------------< create_training_plan_member >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tpm_api.create_training_plan_member
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_training_plan_member
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     DATE
  ,p_business_group_id            IN     NUMBER
  ,p_training_plan_id             IN     NUMBER    DEFAULT NULL
  ,p_activity_version_id          IN     NUMBER
  ,p_activity_definition_id       IN     NUMBER    DEFAULT NULL
  ,p_member_status_type_id        IN     VARCHAR2  DEFAULT NULL
  ,p_target_completion_date       IN     DATE
  ,p_attribute_category           IN     VARCHAR2  DEFAULT NULL
  ,p_attribute1                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute2                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute3                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute4                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute5                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute6                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute7                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute8                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute9                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute10                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute11                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute12                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute13                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute14                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute15                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute16                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute17                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute18                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute19                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute20                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute21                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute22                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute23                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute24                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute25                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute26                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute27                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute28                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute29                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute30                  IN     VARCHAR2  DEFAULT NULL
  ,p_assignment_id                IN     NUMBER    DEFAULT NULL
  ,p_source_id                    IN     NUMBER    DEFAULT NULL
  ,p_source_function              IN     VARCHAR2  DEFAULT NULL
  ,p_cancellation_reason          IN     VARCHAR2  DEFAULT NULL
  ,p_earliest_start_date          IN     DATE
  ,p_training_plan_member_id      IN     NUMBER
  ,p_creator_person_id            IN    NUMBER DEFAULT NULL
  ,p_person_id                    IN    NUMBER DEFAULT NULL
  ,p_plan_start_date              IN    DATE   DEFAULT NULL
  ,p_object_version_NUMBER           OUT NOCOPY NUMBER
  ,p_return_status                   OUT NOCOPY VARCHAR2
  );



-- ----------------------------------------------------------------------------
-- |----------------------< delete_training_plan_member >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tpm_api.delete_training_plan_member
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_training_plan_member
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_training_plan_member_id      IN     number
  ,p_object_version_NUMBER        IN     number
  ,p_return_status                   OUT NOCOPY VARCHAR2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_training_plan_member >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tpm_api.update_training_plan_member
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_training_plan_member
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     date
  ,p_training_plan_member_id      IN     number
  ,p_object_version_NUMBER        IN OUT NOCOPY number
  ,p_activity_version_id          IN     NUMBER    DEFAULT hr_api.g_number
  ,p_activity_definition_id       IN     NUMBER    DEFAULT hr_api.g_number
  ,p_member_status_type_id        IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_target_completion_date       IN     date      DEFAULT hr_api.g_date
  ,p_attribute_category           IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute1                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute2                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute3                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute4                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute5                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute6                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute7                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute8                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute9                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute10                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute11                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute12                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute13                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute14                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute15                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute16                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute17                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute18                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute19                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute20                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute21                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute22                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute23                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute24                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute25                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute26                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute27                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute28                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute29                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute30                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_assignment_id                IN     NUMBER    DEFAULT hr_api.g_number
  ,p_source_id                    IN     NUMBER    DEFAULT hr_api.g_number
  ,p_source_function              IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_cancellation_reason          IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_earliest_start_date          IN     date      DEFAULT hr_api.g_date
  ,p_creator_person_id            IN    NUMBER    DEFAULT hr_api.g_number
  ,p_return_status                OUT NOCOPY VARCHAR2
  );
END ota_tpm_swi;

 

/
