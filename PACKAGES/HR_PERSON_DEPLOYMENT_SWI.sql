--------------------------------------------------------
--  DDL for Package HR_PERSON_DEPLOYMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_DEPLOYMENT_SWI" AUTHID CURRENT_USER As
/* $Header: hrpdtswi.pkh 120.0 2005/09/23 06:45 adhunter noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_person_deployment >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_deployment_api.create_person_deployment
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
PROCEDURE create_person_deployment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_from_business_group_id       in     number
  ,p_to_business_group_id         in     number
  ,p_from_person_id               in     number
  ,p_to_person_id                 in     number    default null
  ,p_person_type_id               in     number    default null
  ,p_start_date                   in     date
  ,p_end_date                     in     date      default null
  ,p_employee_number              in     varchar2  default null
  ,p_leaving_reason               in     varchar2  default null
  ,p_leaving_person_type_id       in     number    default null
  ,p_permanent                    in     varchar2  default null
  ,p_deplymt_policy_id            in     number    default null
  ,p_organization_id              in     number
  ,p_location_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_position_id                  in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_retain_direct_reports        in     varchar2  default null
  ,p_payroll_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_proposed_salary              in     varchar2  default null
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_assignment_status_type_id    in     number    default null
  ,p_ass_status_change_reason     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_deployment_reason            in     varchar2  default null
  ,p_person_deployment_id         in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_deployment >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_deployment_api.update_person_deployment
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
PROCEDURE update_person_deployment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_deployment_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_employee_number              in     varchar2  default hr_api.g_varchar2
  ,p_leaving_reason               in     varchar2  default hr_api.g_varchar2
  ,p_leaving_person_type_id       in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_status_change_reason         in     varchar2  default hr_api.g_varchar2
  ,p_deplymt_policy_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_retain_direct_reports        in     varchar2  default hr_api.g_varchar2
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_proposed_salary              in     varchar2  default hr_api.g_varchar2
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_ass_status_change_reason     in     varchar2  default hr_api.g_varchar2
  ,p_assignment_category          in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_deployment_reason            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_person_deployment >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_deployment_api.delete_person_deployment
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
PROCEDURE delete_person_deployment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_deployment_id         in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< initiate_deployment >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_deployment_api.initiate_deployment
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
PROCEDURE initiate_deployment
  (p_validate                      in     number   default hr_api.g_false_num
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_host_person_id                   out nocopy number
  ,p_host_per_ovn                     out nocopy number
  ,p_host_assignment_id               out nocopy number
  ,p_host_asg_ovn                     out nocopy number
  ,p_return_status                    out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< change_deployment_dates >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_deployment_api.change_deployment_dates
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
PROCEDURE change_deployment_dates
  (p_validate                      in     number     default hr_api.g_false_num
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_start_date                    in     date       default hr_api.g_date
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_deplymt_policy_id             in     number     default hr_api.g_number
  ,p_return_status                    out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< return_from_deployment >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_deployment_api.return_from_deployment
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
PROCEDURE return_from_deployment
  (p_validate                      in     number     default hr_api.g_false_num
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_leaving_reason                in     varchar2   default hr_api.g_varchar2
  ,p_leaving_person_type_id        in     number     default hr_api.g_number
  ,p_return_status                    out nocopy varchar2
  );
end hr_person_deployment_swi;

 

/
