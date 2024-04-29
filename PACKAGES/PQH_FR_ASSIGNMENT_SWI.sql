--------------------------------------------------------
--  DDL for Package PQH_FR_ASSIGNMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_ASSIGNMENT_SWI" AUTHID CURRENT_USER As
/* $Header: pqastswi.pkh 120.0 2005/05/29 01:26 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_affectation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_assignment_api.create_affectation
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
PROCEDURE create_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_organization_id              in     number
  ,p_position_id                  in     number
  ,p_person_id                    in     number
  ,p_job_id                       in     number
  ,p_supervisor_id                in     number    default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_assignment_status_type_id    in     number
  ,p_identifier                   in     varchar2
  ,p_affectation_type             in     varchar2
  ,p_percent_effected             in     varchar2
  ,p_primary_affectation          in     varchar2  default null
  ,p_group_name                      out nocopy varchar2
  ,p_scl_concat_segments          in     varchar2  default null
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |--------------------------< terminate_affectation >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE terminate_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_primary_affectation          in     varchar2  default null
  ,p_group_name                      out nocopy varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |--------------------------< update_affectation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_assignment_api.update_affectation
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
PROCEDURE update_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_person_id                    in     number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_identifier                   in     varchar2  default hr_api.g_varchar2
  ,p_affectation_type             in     varchar2  default hr_api.g_varchar2
  ,p_percent_effected             in     varchar2  default hr_api.g_varchar2
  ,p_primary_affectation          in     varchar2  default hr_api.g_varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_scl_concat_segments          in     varchar2  default hr_api.g_varchar2
  ,p_assignment_id                in     number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_employment_terms >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_assignment_api.update_employment_terms
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
PROCEDURE update_employment_terms
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_establishment_id             in     number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_assignment_category          in     varchar2
  ,p_reason_for_parttime          in     varchar2  default hr_api.g_varchar2
  ,p_working_hours_share          in     varchar2  default hr_api.g_varchar2
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_administrative_career >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_assignment_api.update_administrative_career
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
PROCEDURE update_administrative_career
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_corps_id                     in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_step_id                      in     number    default hr_api.g_number
  ,p_progression_speed           in     varchar2
  ,p_personal_gross_index         in     varchar2
  ,p_employee_category            in     varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_return_status                   out nocopy varchar2
  );

PROCEDURE suspend_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );

PROCEDURE activate_affectation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );

 end pqh_fr_assignment_swi;

 

/
