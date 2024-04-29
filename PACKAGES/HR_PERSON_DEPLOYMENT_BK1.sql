--------------------------------------------------------
--  DDL for Package HR_PERSON_DEPLOYMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_DEPLOYMENT_BK1" AUTHID CURRENT_USER as
/* $Header: hrpdtapi.pkh 120.5 2007/10/01 10:00:52 ghshanka noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_deployment_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_deployment_b
  (p_from_business_group_id        in     number
  ,p_to_business_group_id          in     number
  ,p_from_person_id                in     number
  ,p_to_person_id                  in     number
  ,p_person_type_id                in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_deployment_reason             in     varchar2
  ,p_employee_number               in     varchar2
  ,p_leaving_reason                in     varchar2
  ,p_leaving_person_type_id        in     number
  ,p_permanent                     in     varchar2
  ,p_deplymt_policy_id             in     number
  ,p_organization_id               in     number
  ,p_location_id                   in     number
  ,p_job_id                        in     number
  ,p_position_id                   in     number
  ,p_grade_id                      in     number
  ,p_supervisor_id                 in     number
  ,p_supervisor_assignment_id      in     number
  ,p_retain_direct_reports         in     varchar2
  ,p_payroll_id                    in     number
  ,p_pay_basis_id                  in     number
  ,p_proposed_salary               in     varchar2
  ,p_people_group_id               in     number
  ,p_soft_coding_keyflex_id        in     number
  ,p_assignment_status_type_id     in     number
  ,p_ass_status_change_reason      in     varchar2
  ,p_assignment_category           in     varchar2
  ,p_per_information1              in     varchar2
  ,p_per_information2              in     varchar2
  ,p_per_information3              in     varchar2
  ,p_per_information4              in     varchar2
  ,p_per_information5              in     varchar2
  ,p_per_information6              in     varchar2
  ,p_per_information7              in     varchar2
  ,p_per_information8              in     varchar2
  ,p_per_information9              in     varchar2
  ,p_per_information10             in     varchar2
  ,p_per_information11             in     varchar2
  ,p_per_information12             in     varchar2
  ,p_per_information13             in     varchar2
  ,p_per_information14             in     varchar2
  ,p_per_information15             in     varchar2
  ,p_per_information16             in     varchar2
  ,p_per_information17             in     varchar2
  ,p_per_information18             in     varchar2
  ,p_per_information19             in     varchar2
  ,p_per_information20             in     varchar2
  ,p_per_information21             in     varchar2
  ,p_per_information22             in     varchar2
  ,p_per_information23             in     varchar2
  ,p_per_information24             in     varchar2
  ,p_per_information25             in     varchar2
  ,p_per_information26             in     varchar2
  ,p_per_information27             in     varchar2
  ,p_per_information28             in     varchar2
  ,p_per_information29             in     varchar2
  ,p_per_information30             in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_deployment_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_deployment_a
  (p_from_business_group_id        in     number
  ,p_to_business_group_id          in     number
  ,p_from_person_id                in     number
  ,p_to_person_id                  in     number
  ,p_person_type_id                in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_deployment_reason             in     varchar2
  ,p_employee_number               in     varchar2
  ,p_leaving_reason                in     varchar2
  ,p_leaving_person_type_id        in     number
  ,p_permanent                     in     varchar2
  ,p_deplymt_policy_id             in     number
  ,p_organization_id               in     number
  ,p_location_id                   in     number
  ,p_job_id                        in     number
  ,p_position_id                   in     number
  ,p_grade_id                      in     number
  ,p_supervisor_id                 in     number
  ,p_supervisor_assignment_id      in     number
  ,p_retain_direct_reports         in     varchar2
  ,p_payroll_id                    in     number
  ,p_pay_basis_id                  in     number
  ,p_proposed_salary               in     varchar2
  ,p_people_group_id               in     number
  ,p_soft_coding_keyflex_id        in     number
  ,p_assignment_status_type_id     in     number
  ,p_ass_status_change_reason      in     varchar2
  ,p_assignment_category           in     varchar2
  ,p_per_information1              in     varchar2
  ,p_per_information2              in     varchar2
  ,p_per_information3              in     varchar2
  ,p_per_information4              in     varchar2
  ,p_per_information5              in     varchar2
  ,p_per_information6              in     varchar2
  ,p_per_information7              in     varchar2
  ,p_per_information8              in     varchar2
  ,p_per_information9              in     varchar2
  ,p_per_information10             in     varchar2
  ,p_per_information11             in     varchar2
  ,p_per_information12             in     varchar2
  ,p_per_information13             in     varchar2
  ,p_per_information14             in     varchar2
  ,p_per_information15             in     varchar2
  ,p_per_information16             in     varchar2
  ,p_per_information17             in     varchar2
  ,p_per_information18             in     varchar2
  ,p_per_information19             in     varchar2
  ,p_per_information20             in     varchar2
  ,p_per_information21             in     varchar2
  ,p_per_information22             in     varchar2
  ,p_per_information23             in     varchar2
  ,p_per_information24             in     varchar2
  ,p_per_information25             in     varchar2
  ,p_per_information26             in     varchar2
  ,p_per_information27             in     varchar2
  ,p_per_information28             in     varchar2
  ,p_per_information29             in     varchar2
  ,p_per_information30             in     varchar2
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in     number
  ,p_policy_duration_warning       in     boolean
  );
--
end HR_PERSON_DEPLOYMENT_BK1;

/
