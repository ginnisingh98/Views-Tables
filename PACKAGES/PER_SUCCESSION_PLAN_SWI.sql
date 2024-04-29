--------------------------------------------------------
--  DDL for Package PER_SUCCESSION_PLAN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUCCESSION_PLAN_SWI" AUTHID CURRENT_USER AS
/* $Header: pesucswi.pkh 120.0.12010000.4 2010/02/13 19:35:43 schowdhu ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_succession_plan >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_succession_plan_api.create_succession_plan
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
   PROCEDURE create_succession_plan (
      p_validate                  IN              NUMBER DEFAULT hr_api.g_false_num,
      p_person_id                 IN              NUMBER,
      p_position_id               IN              NUMBER DEFAULT NULL,
      p_business_group_id         IN              NUMBER,
      p_start_date                IN              DATE,
      p_time_scale                IN              VARCHAR2,
      p_end_date                  IN              DATE DEFAULT NULL,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT NULL,
      p_manager_comments          IN              VARCHAR2 DEFAULT NULL,
      p_attribute_category        IN              VARCHAR2 DEFAULT NULL,
      p_attribute1                IN              VARCHAR2 DEFAULT NULL,
      p_attribute2                IN              VARCHAR2 DEFAULT NULL,
      p_attribute3                IN              VARCHAR2 DEFAULT NULL,
      p_attribute4                IN              VARCHAR2 DEFAULT NULL,
      p_attribute5                IN              VARCHAR2 DEFAULT NULL,
      p_attribute6                IN              VARCHAR2 DEFAULT NULL,
      p_attribute7                IN              VARCHAR2 DEFAULT NULL,
      p_attribute8                IN              VARCHAR2 DEFAULT NULL,
      p_attribute9                IN              VARCHAR2 DEFAULT NULL,
      p_attribute10               IN              VARCHAR2 DEFAULT NULL,
      p_attribute11               IN              VARCHAR2 DEFAULT NULL,
      p_attribute12               IN              VARCHAR2 DEFAULT NULL,
      p_attribute13               IN              VARCHAR2 DEFAULT NULL,
      p_attribute14               IN              VARCHAR2 DEFAULT NULL,
      p_attribute15               IN              VARCHAR2 DEFAULT NULL,
      p_attribute16               IN              VARCHAR2 DEFAULT NULL,
      p_attribute17               IN              VARCHAR2 DEFAULT NULL,
      p_attribute18               IN              VARCHAR2 DEFAULT NULL,
      p_attribute19               IN              VARCHAR2 DEFAULT NULL,
      p_attribute20               IN              VARCHAR2 DEFAULT NULL,
      p_effective_date            IN              DATE,
      p_job_id                    IN              NUMBER DEFAULT NULL,
      p_successee_person_id       IN              NUMBER DEFAULT NULL,
      p_person_rank               IN              NUMBER,
      p_performance               IN              VARCHAR2,
      p_plan_status               IN              VARCHAR2 DEFAULT NULL,
      p_readiness_percentage      IN              NUMBER DEFAULT NULL,
      p_succession_plan_id        IN              NUMBER,
      p_object_version_number     OUT NOCOPY      NUMBER,
      p_return_status             OUT NOCOPY      VARCHAR2
   );

-- ----------------------------------------------------------------------------
-- |------------------------< delete_succession_plan >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_succession_plan_api.delete_succession_plan
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
   PROCEDURE delete_succession_plan (
      p_validate                IN              NUMBER DEFAULT hr_api.g_false_num,
      p_succession_plan_id      IN              NUMBER,
      p_object_version_number   IN              NUMBER,
      p_return_status           OUT NOCOPY      VARCHAR2
   );

-- ----------------------------------------------------------------------------
-- |------------------------< update_succession_plan >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_succession_plan_api.update_succession_plan
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
   PROCEDURE update_succession_plan (
      p_validate                  IN              NUMBER DEFAULT hr_api.g_false_num,
      p_succession_plan_id        IN              NUMBER,
      p_person_id                 IN              NUMBER DEFAULT hr_api.g_number,
      p_position_id               IN              NUMBER DEFAULT hr_api.g_number,
      p_business_group_id         IN              NUMBER DEFAULT hr_api.g_number,
      p_start_date                IN              DATE DEFAULT hr_api.g_date,
      p_time_scale                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_end_date                  IN              DATE DEFAULT hr_api.g_date,
      p_available_for_promotion   IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_manager_comments          IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute_category        IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute1                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute2                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute3                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute4                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute5                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute6                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute7                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute8                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute9                IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute10               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute11               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute12               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute13               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute14               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute15               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute16               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute17               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute18               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute19               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_attribute20               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_effective_date            IN              DATE,
      p_job_id                    IN              NUMBER DEFAULT hr_api.g_number,
      p_person_rank               IN              NUMBER DEFAULT hr_api.g_number,
      p_performance               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_plan_status               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_readiness_percentage      IN              NUMBER DEFAULT hr_api.g_number,
      p_successee_person_id       IN              NUMBER DEFAULT hr_api.g_number,
      p_object_version_number     IN OUT NOCOPY   NUMBER,
      p_return_status             OUT NOCOPY      VARCHAR2
   );
END per_succession_plan_swi;

/
