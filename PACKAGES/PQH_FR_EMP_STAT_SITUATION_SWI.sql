--------------------------------------------------------
--  DDL for Package PQH_FR_EMP_STAT_SITUATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_EMP_STAT_SITUATION_SWI" AUTHID CURRENT_USER As
/* $Header: pqpsuswi.pkh 120.0 2005/05/29 02:20 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_emp_stat_situation >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_emp_stat_situation_api.create_emp_stat_situation
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
PROCEDURE create_emp_stat_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_statutory_situation_id       in     number
  ,p_person_id                    in     number
  ,p_provisional_start_date       in     date
  ,p_provisional_end_date         in     date
  ,p_actual_start_date            in     date      default null
  ,p_actual_end_date              in     date      default null
  ,p_approval_flag                in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_contact_person_id            in     number    default null
  ,p_contact_relationship         in     varchar2  default null
  ,p_external_organization_id     in     number    default null
  ,p_renewal_flag                 in     varchar2  default null
  ,p_renew_stat_situation_id      in     number    default null
  ,p_seconded_career_id           in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_emp_stat_situation_id           out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_emp_stat_situation >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_emp_stat_situation_api.update_emp_stat_situation
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
PROCEDURE update_emp_stat_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_emp_stat_situation_id        in     number
  ,p_statutory_situation_id       in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_provisional_start_date       in     date      default hr_api.g_date
  ,p_provisional_end_date         in     date      default hr_api.g_date
  ,p_actual_start_date            in     date      default hr_api.g_date
  ,p_actual_end_date              in     date      default hr_api.g_date
  ,p_approval_flag                in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_contact_person_id            in     number    default hr_api.g_number
  ,p_contact_relationship         in     varchar2  default hr_api.g_varchar2
  ,p_external_organization_id     in     number    default hr_api.g_number
  ,p_renewal_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_renew_stat_situation_id      in     number    default hr_api.g_number
  ,p_seconded_career_id           in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_emp_stat_situation >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_emp_stat_situation_api.delete_emp_stat_situation
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
PROCEDURE delete_emp_stat_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_emp_stat_situation_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< renew_emp_stat_situation >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_emp_stat_situation_api.renew_emp_stat_situation
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
PROCEDURE renew_emp_stat_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_emp_stat_situation_id        in out nocopy number
  ,p_renew_stat_situation_id      in     number
  ,p_renewal_duration             in     number
  ,p_duration_units               in     varchar2
  ,p_approval_flag                in     varchar2
  ,p_comments                     in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< reinstate_emp_stat_situation >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_emp_stat_situation_api.reinstate_emp_stat_situation
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
PROCEDURE reinstate_emp_stat_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_emp_stat_situation_id        in     number
  ,p_reinstate_date               in     date
  ,p_comments                     in     varchar2
  ,p_new_emp_stat_situation_id       out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end pqh_fr_emp_stat_situation_swi;

 

/
