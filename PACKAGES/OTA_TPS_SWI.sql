--------------------------------------------------------
--  DDL for Package OTA_TPS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPS_SWI" AUTHID CURRENT_USER AS
/* $Header: ottpsswi.pkh 115.4 2004/03/03 05:17:33 rdola noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_training_plan >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tps_api.create_training_plan
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
PROCEDURE create_training_plan
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     date
  ,p_business_group_id            IN     number
  ,p_time_period_id               IN     NUMBER    DEFAULT NULL
  ,p_plan_status_type_id          IN     VARCHAR2
  ,p_organization_id              IN     NUMBER    DEFAULT NULL
  ,p_person_id                    IN     NUMBER    DEFAULT NULL
  ,p_budget_currency              IN     VARCHAR2  DEFAULT NULL
  ,p_name                         IN     VARCHAR2
  ,p_description                  IN     VARCHAR2  DEFAULT NULL
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
  ,p_plan_source                  IN     VARCHAR2  DEFAULT NULL
  ,p_start_date                   IN     date      DEFAULT NULL
  ,p_end_date                     IN     date      DEFAULT NULL
  ,p_training_plan_id             IN     number
  ,p_creator_person_id            IN     NUMBER    DEFAULT NULL
  ,p_additional_member_flag       IN     VARCHAR2  DEFAULT NULL
  ,p_learning_path_id             IN     NUMBER    DEFAULT NULL
  -- Modified for Bug#3479186
  ,p_contact_id                         IN NUMBER DEFAULT NULL
  ,p_object_version_NUMBER        OUT NOCOPY       number
  ,p_return_status                OUT NOCOPY       VARCHAR2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_training_plan >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tps_api.delete_training_plan
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
PROCEDURE delete_training_plan
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_training_plan_id             IN     number
  ,p_object_version_NUMBER        IN     number
  ,p_return_status                OUT NOCOPY VARCHAR2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_training_plan >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tps_api.update_training_plan
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
PROCEDURE update_training_plan
  (p_validate                     IN     NUMBER    DEFAULT hr_api.g_false_num
  ,p_effective_date               IN     date
  ,p_training_plan_id             IN     number
  ,p_object_version_NUMBER        IN OUT NOCOPY number
  ,p_time_period_id               IN     number    DEFAULT hr_api.g_number
  ,p_plan_status_type_id          IN     VARCHAR2
  ,p_budget_currency              IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_name                         IN     VARCHAR2
  ,p_description                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
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
  ,p_plan_source                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_start_date                   IN     date      DEFAULT hr_api.g_date
  ,p_end_date                     IN     date      DEFAULT hr_api.g_date
  ,p_creator_person_id            IN     NUMBER    DEFAULT hr_api.g_number
  ,p_additional_member_flag       IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_learning_path_id             IN     NUMBER    DEFAULT hr_api.g_number
  ,p_contact_id             IN     NUMBER    DEFAULT hr_api.g_number
  ,p_return_status                OUT    NOCOPY VARCHAR2
  );
END ota_tps_swi;

 

/
