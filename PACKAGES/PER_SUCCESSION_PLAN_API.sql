--------------------------------------------------------
--  DDL for Package PER_SUCCESSION_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUCCESSION_PLAN_API" AUTHID CURRENT_USER AS
/* $Header: pesucapi.pkh 120.3.12010000.3 2010/02/13 19:29:42 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SUCCESSION_PLAN> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- It creates succession Plan.
--
-- Prerequisites:
--
--
-- In Parameters:
-- Name
-- p_validate
-- p_person_id
-- p_position_id
-- p_business_group_id
-- p_start_date
-- p_time_scale
-- p_end_date
-- p_available_for_promotion
-- p_manager_comments
-- p_attribute_category
-- p_attribute1
-- p_attribute2
-- p_attribute3
-- p_attribute4
-- p_attribute5
-- p_attribute6
-- p_attribute7
-- p_attribute8
-- p_attribute9
-- p_attribute10
-- p_attribute11
-- p_attribute12
-- p_attribute13
-- p_attribute14
-- p_attribute15
-- p_attribute16
-- p_attribute17
-- p_attribute18
-- p_attribute19
-- p_attribute20
-- p_effective_date
-- p_job_id
-- p_successee_person_id
-- p_person_rank
-- p_performance
-- p_plan_status
-- p_readiness_percentage
-- p_succession_plan_id
-- p_object_version_number
--
-- Post Failure:
--   The API does not create the plan and raises an error.
--
-- Post Success:
--   The API creates the plan.

   --
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE create_succession_plan (
      p_validate                  IN              BOOLEAN DEFAULT FALSE,
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
      p_person_rank               IN              NUMBER DEFAULT NULL,
      p_performance               IN              VARCHAR2 DEFAULT NULL,
      p_plan_status               IN              VARCHAR2 DEFAULT NULL,
      p_readiness_percentage      IN              NUMBER DEFAULT NULL,
      p_succession_plan_id        OUT NOCOPY      NUMBER,
      p_object_version_number     OUT NOCOPY      NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_SUCCESSION_PLAN> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  It Updates an existing Succession Planning record.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name
-- p_validate
-- p_person_id
-- p_position_id
-- p_business_group_id
-- p_start_date
-- p_time_scale
-- p_end_date
-- p_available_for_promotion
-- p_manager_comments
-- p_attribute_category
-- p_attribute1
-- p_attribute2
-- p_attribute3
-- p_attribute4
-- p_attribute5
-- p_attribute6
-- p_attribute7
-- p_attribute8
-- p_attribute9
-- p_attribute10
-- p_attribute11
-- p_attribute12
-- p_attribute13
-- p_attribute14
-- p_attribute15
-- p_attribute16
-- p_attribute17
-- p_attribute18
-- p_attribute19
-- p_attribute20
-- p_effective_date
-- p_job_id
-- p_successee_person_id
-- p_person_rank
-- p_performance
-- p_plan_status
-- p_readiness_percentage
-- p_succession_plan_id
-- p_object_version_number

   --
--
-- Post Success:
--
--
--  Name                           Type     Description
--  p_object_version_number       NUMBER    Object Version Number.

   -- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
   PROCEDURE update_succession_plan (
      p_validate                  IN              BOOLEAN DEFAULT FALSE,
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
      p_successee_person_id       IN              NUMBER DEFAULT hr_api.g_number,
      p_person_rank               IN              NUMBER DEFAULT hr_api.g_number,
      p_performance               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_plan_status               IN              VARCHAR2 DEFAULT hr_api.g_varchar2,
      p_readiness_percentage      IN              NUMBER DEFAULT hr_api.g_number,
      p_object_version_number     IN OUT NOCOPY   NUMBER
   );

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_succession_plan >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- This API deletes an existing Succession Plan.
--
-- Pre Conditions:
--  A valid Succession Plan must already exist.
-- In Parameters:
-- p_validate
-- If true, then validation alone will be performed and the
-- database will remain unchanged. If false and all validation checks pass,
-- then the database will be modified.
--
-- p_succession_plan_id
-- Id of the plan to be deleted. If p_validate is false,
-- uniquely identifies the plan to be deleted. If p_validate is true, set
-- to null.
--
-- p_object_version_number
-- Current version number of the succession Plan to be
-- deleted.
--
-- Post Success:
--   The specified row will be validated and deleted for the specified
--   entity without being committed (or rollbacked depending on the
--   p_validate status).
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
--
-- {End Of Comments}
--
   PROCEDURE delete_succession_plan (
      p_validate                IN   BOOLEAN DEFAULT FALSE,
      p_succession_plan_id      IN   NUMBER,
      p_object_version_number   IN   NUMBER
   );
--
END per_succession_plan_api;

/
