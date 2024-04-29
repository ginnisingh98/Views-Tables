--------------------------------------------------------
--  DDL for Package PQH_FR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_ASSIGNMENT_API" AUTHID CURRENT_USER As
/* $Header: pqasgapi.pkh 120.0.12000000.1 2007/01/16 21:49:49 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_affecation >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description: This is used in French PS, Administrative Sitaution -> Affectation SS Module
-- Create affectation will create one secondary assignment for a person
-- While creating the secondary assignment, system will reuse primary assignments
-- information like , 1. People Group 2. Any other Localization mandatory values 3. Establishment
--
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--  Employee Primary assignment must be defined, including the mandatory arguments in PUI
--
-- Post Success:
--  p_return_status will return value indicating success.
--  Primary Assinment's (Organization, Job, Position ) field values will be updated with
--  primary affecation (Organization, Job, Position ) field values.
--
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- Field Description
--------------------
-- p_validate                       validate=true, will rollback the txn after validation
--                                  validate=false, will commit the data
-- p_organization_id                Organization Name
-- p_person_id                      Person Id
-- p_affectation_type               Is the Affectation is Temporary or Perminent
-- p_primary_affectation            Is this is a Primary Affectation? possible values Yes (Y)/ No (N)
-- {End of comments}
-- ----------------------------------------------------------------------------
-- create_secondary_emp_asg

procedure create_affectation
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_organization_id              in     number
  ,p_position_id                  in     number
  ,p_person_id                    in     number
  ,p_job_id                       in     number
  ,p_supervisor_id                in     number  default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_assignment_status_type_id    in     number

  ,p_identifier                   in     varchar2
  ,p_affectation_type             in     varchar2
  ,p_percent_effected             in     varchar2
  ,p_primary_affectation          in     varchar2 default 'N'
  ,p_group_name                      out nocopy varchar2

  ,p_scl_concat_segments          in     varchar2 default null

  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number

  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  );

--
-- Updating an existing Affectation
--
procedure  update_affectation
  (p_validate                     in     boolean  default false
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_organization_id              in     number  default hr_api.g_number
  ,p_position_id                  in     number  default hr_api.g_number
  ,p_person_id                    in     number
  ,p_job_id                       in     number  default hr_api.g_number
  ,p_supervisor_id                in     number  default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number  default hr_api.g_number
  ,p_identifier                   in     varchar2 default hr_api.g_varchar2
  ,p_affectation_type             in     varchar2 default hr_api.g_varchar2
  ,p_percent_effected             in     varchar2 default hr_api.g_varchar2
  ,p_primary_affectation          in     varchar2 default 'N'
  ,p_group_name                      out nocopy varchar2

  ,p_scl_concat_segments          in     varchar2 default hr_api.g_varchar2

  ,p_assignment_id                in  number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  );
--
--Employment Terms Update Routine
  PROCEDURE update_employment_terms
  (p_validate               IN            BOOLEAN  DEFAULT FALSE
  ,p_datetrack_update_mode  IN            VARCHAR2
  ,p_effective_date         IN            DATE
  ,p_assignment_id          IN            NUMBER
  ,p_establishment_id       IN            NUMBER
  ,p_comments               IN            VARCHAR2 DEFAULT HR_API.g_varchar2
  ,p_assignment_category    IN            VARCHAR2
  ,p_reason_for_parttime    IN            VARCHAR2 DEFAULT HR_API.g_varchar2
  ,p_working_hours_share    IN            VARCHAR2 DEFAULT HR_API.g_varchar2
  ,p_contract_id            IN            NUMBER   DEFAULT HR_API.g_number
  ,p_change_reason          IN            VARCHAR2 DEFAULT HR_API.g_varchar2
  ,p_normal_hours           IN            NUMBER   DEFAULT HR_API.g_number
  ,p_frequency              IN            VARCHAR2 DEFAULT HR_API.g_varchar2
  ,p_soft_coding_keyflex_id    OUT NOCOPY NUMBER
  ,p_object_version_number  IN OUT NOCOPY NUMBER
  ,p_effective_start_date      OUT NOCOPY DATE
  ,p_effective_end_date        OUT NOCOPY DATE
  ,p_assignment_sequence       OUT NOCOPY NUMBER
  );
--
--
Procedure update_administrative_career
(
   p_validate                    in     boolean default false
  ,p_datetrack_update_mode       in     varchar2
  ,p_effective_date              in     date
  ,p_assignment_id               in     number
  ,p_corps_id                    in     number
  ,p_grade_id                    in     number
  ,p_step_id                     in     number
  ,p_progression_speed           in     varchar2
  ,p_personal_gross_index        in     varchar2
  ,p_employee_category	          in     varchar2


  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number


  );

 procedure terminate_affectation
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_primary_affectation          in     varchar2 default 'N'
  ,p_group_name                   out nocopy varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );

 procedure suspend_affectation
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );

 procedure activate_affectation
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
end pqh_fr_assignment_api;

 

/
