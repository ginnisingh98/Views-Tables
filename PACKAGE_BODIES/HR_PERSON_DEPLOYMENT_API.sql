--------------------------------------------------------
--  DDL for Package Body HR_PERSON_DEPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_DEPLOYMENT_API" as
/* $Header: hrpdtapi.pkb 120.23.12010000.2 2009/07/22 11:02:05 ghshanka ship $ */
--
-- Type declarations
--
TYPE t_contact_created IS RECORD
    (home_contact_person_id number, host_contact_person_id number);
TYPE t_contacts_created is table of t_contact_created;
--
-- Package Variables
--
g_package  varchar2(33) := '  HR_PERSON_DEPLOYMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_PERSON_DEPLOYMENT >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_deployment
  (p_validate                      in     boolean    default false
  ,p_from_business_group_id        in     number
  ,p_to_business_group_id          in     number
  ,p_from_person_id                in     number
  ,p_to_person_id                  in     number     default null
  ,p_person_type_id                in     number     default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date       default null
  ,p_deployment_reason             in     varchar2   default null
  ,p_employee_number               in     varchar2   default null
  ,p_leaving_reason                in     varchar2   default null
  ,p_leaving_person_type_id        in     number     default null
  ,p_permanent                     in     varchar2   default null
  ,p_deplymt_policy_id             in     number     default null
  ,p_organization_id               in     number
  ,p_location_id                   in     number     default null
  ,p_job_id                        in     number     default null
  ,p_position_id                   in     number     default null
  ,p_grade_id                      in     number     default null
  ,p_supervisor_id                 in     number     default null
  ,p_supervisor_assignment_id      in     number     default null
  ,p_retain_direct_reports         in     varchar2   default null
  ,p_payroll_id                    in     number     default null
  ,p_pay_basis_id                  in     number     default null
  ,p_proposed_salary               in     varchar2   default null
  ,p_people_group_id               in     number     default null
  ,p_soft_coding_keyflex_id        in     number     default null
  ,p_assignment_status_type_id     in     number     default null
  ,p_ass_status_change_reason      in     varchar2   default null
  ,p_assignment_category           in     varchar2   default null
  ,p_per_information1              in     varchar2   default null
  ,p_per_information2              in     varchar2   default null
  ,p_per_information3              in     varchar2   default null
  ,p_per_information4              in     varchar2   default null
  ,p_per_information5              in     varchar2   default null
  ,p_per_information6              in     varchar2   default null
  ,p_per_information7              in     varchar2   default null
  ,p_per_information8              in     varchar2   default null
  ,p_per_information9              in     varchar2   default null
  ,p_per_information10             in     varchar2   default null
  ,p_per_information11             in     varchar2   default null
  ,p_per_information12             in     varchar2   default null
  ,p_per_information13             in     varchar2   default null
  ,p_per_information14             in     varchar2   default null
  ,p_per_information15             in     varchar2   default null
  ,p_per_information16             in     varchar2   default null
  ,p_per_information17             in     varchar2   default null
  ,p_per_information18             in     varchar2   default null
  ,p_per_information19             in     varchar2   default null
  ,p_per_information20             in     varchar2   default null
  ,p_per_information21             in     varchar2   default null
  ,p_per_information22             in     varchar2   default null
  ,p_per_information23             in     varchar2   default null
  ,p_per_information24             in     varchar2   default null
  ,p_per_information25             in     varchar2   default null
  ,p_per_information26             in     varchar2   default null
  ,p_per_information27             in     varchar2   default null
  ,p_per_information28             in     varchar2   default null
  ,p_per_information29             in     varchar2   default null
  ,p_per_information30             in     varchar2   default null
  ,p_person_deployment_id             out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_policy_duration_warning          out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_person_deployment_id             number;
  l_object_version_number            number;
  l_policy_duration_warning          boolean := false;
  l_start_date                       date;
  l_end_date                         date;
  l_status_change_date               date;
  l_per_information_category         varchar2(30);
  l_proc                varchar2(72) := g_package||'create_person_deployment';
  --
  cursor csr_derive_legislation(p_business_group_id number) is
  select pbg.legislation_code
  from   per_business_groups pbg
  where  pbg.business_group_id = p_business_group_id;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_person_deployment;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date     := trunc(p_start_date);
  l_end_date       := trunc(p_end_date);
  --
  -- Call Before Process User Hook
  --
  begin
    HR_PERSON_DEPLOYMENT_BK1.CREATE_PERSON_DEPLOYMENT_B
	(p_from_business_group_id        => p_from_business_group_id
	,p_to_business_group_id          => p_to_business_group_id
	,p_from_person_id                => p_from_person_id
	,p_to_person_id                  => p_to_person_id
	,p_person_type_id                => p_person_type_id
	,p_start_date                    => l_start_date
	,p_end_date                      => l_end_date
        ,p_deployment_reason             => p_deployment_reason
	,p_employee_number               => p_employee_number
	,p_leaving_reason                => p_leaving_reason
	,p_leaving_person_type_id        => p_leaving_person_type_id
	,p_permanent                     => p_permanent
	,p_deplymt_policy_id             => p_deplymt_policy_id
	,p_organization_id               => p_organization_id
	,p_location_id                   => p_location_id
	,p_job_id                        => p_job_id
	,p_position_id                   => p_position_id
	,p_grade_id                      => p_grade_id
	,p_supervisor_id                 => p_supervisor_id
	,p_supervisor_assignment_id      => p_supervisor_assignment_id
        ,p_retain_direct_reports         => p_retain_direct_reports
	,p_payroll_id                    => p_payroll_id
	,p_pay_basis_id                  => p_pay_basis_id
	,p_proposed_salary               => p_proposed_salary
	,p_people_group_id               => p_people_group_id
	,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
	,p_assignment_status_type_id     => p_assignment_status_type_id
	,p_ass_status_change_reason      => p_ass_status_change_reason
	,p_assignment_category           => p_assignment_category
	,p_per_information1              => p_per_information1
	,p_per_information2              => p_per_information2
	,p_per_information3              => p_per_information3
	,p_per_information4              => p_per_information4
	,p_per_information5              => p_per_information5
	,p_per_information6              => p_per_information6
	,p_per_information7              => p_per_information7
	,p_per_information8              => p_per_information8
	,p_per_information9              => p_per_information9
	,p_per_information10             => p_per_information10
	,p_per_information11             => p_per_information11
	,p_per_information12             => p_per_information12
	,p_per_information13             => p_per_information13
	,p_per_information14             => p_per_information14
	,p_per_information15             => p_per_information15
	,p_per_information16             => p_per_information16
	,p_per_information17             => p_per_information17
	,p_per_information18             => p_per_information18
	,p_per_information19             => p_per_information19
	,p_per_information20             => p_per_information20
	,p_per_information21             => p_per_information21
	,p_per_information22             => p_per_information22
	,p_per_information23             => p_per_information23
	,p_per_information24             => p_per_information24
	,p_per_information25             => p_per_information25
	,p_per_information26             => p_per_information26
	,p_per_information27             => p_per_information27
	,p_per_information28             => p_per_information28
	,p_per_information29             => p_per_information29
	,p_per_information30             => p_per_information30
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_DEPLOYMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- derive context for Person Developer DF
  open csr_derive_legislation(p_to_business_group_id);
  fetch csr_derive_legislation into l_per_information_category;
  close csr_derive_legislation;
  --
  -- Process Logic
  --
  hr_pdt_ins.ins
	(p_from_business_group_id        => p_from_business_group_id
	,p_to_business_group_id          => p_to_business_group_id
	,p_from_person_id                => p_from_person_id
        ,p_person_type_id                => p_person_type_id
	,p_start_date                    => l_start_date
	,p_status                        => 'DRAFT'   --always DRAFT on create
	,p_to_person_id                  => p_to_person_id
	,p_end_date                      => l_end_date
        ,p_deployment_reason             => p_deployment_reason
	,p_employee_number               => p_employee_number
	,p_leaving_reason                => p_leaving_reason
	,p_leaving_person_type_id        => p_leaving_person_type_id
	,p_permanent                     => p_permanent
	,p_status_change_reason          => null
	,p_deplymt_policy_id             => p_deplymt_policy_id
	,p_organization_id               => p_organization_id
	,p_location_id                   => p_location_id
	,p_job_id                        => p_job_id
	,p_position_id                   => p_position_id
	,p_grade_id                      => p_grade_id
	,p_supervisor_id                 => p_supervisor_id
	,p_supervisor_assignment_id      => p_supervisor_assignment_id
	,p_retain_direct_reports         => p_retain_direct_reports
	,p_payroll_id                    => p_payroll_id
	,p_pay_basis_id                  => p_pay_basis_id
	,p_proposed_salary               => p_proposed_salary
	,p_people_group_id               => p_people_group_id
	,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
	,p_assignment_status_type_id     => p_assignment_status_type_id
	,p_ass_status_change_reason      => p_ass_status_change_reason
	,p_assignment_category           => p_assignment_category
	,p_per_information_category      => l_per_information_category
	,p_per_information1              => p_per_information1
	,p_per_information2              => p_per_information2
	,p_per_information3              => p_per_information3
	,p_per_information4              => p_per_information4
	,p_per_information5              => p_per_information5
	,p_per_information6              => p_per_information6
	,p_per_information7              => p_per_information7
	,p_per_information8              => p_per_information8
	,p_per_information9              => p_per_information9
	,p_per_information10             => p_per_information10
	,p_per_information11             => p_per_information11
	,p_per_information12             => p_per_information12
	,p_per_information13             => p_per_information13
	,p_per_information14             => p_per_information14
	,p_per_information15             => p_per_information15
	,p_per_information16             => p_per_information16
	,p_per_information17             => p_per_information17
	,p_per_information18             => p_per_information18
	,p_per_information19             => p_per_information19
	,p_per_information20             => p_per_information20
	,p_per_information21             => p_per_information21
	,p_per_information22             => p_per_information22
	,p_per_information23             => p_per_information23
	,p_per_information24             => p_per_information24
	,p_per_information25             => p_per_information25
	,p_per_information26             => p_per_information26
	,p_per_information27             => p_per_information27
	,p_per_information28             => p_per_information28
	,p_per_information29             => p_per_information29
	,p_per_information30             => p_per_information30
	,p_person_deployment_id          => l_person_deployment_id
	,p_object_version_number         => l_object_version_number
	);

  --
  -- Call After Process User Hook
  --
  begin
    HR_PERSON_DEPLOYMENT_BK1.CREATE_PERSON_DEPLOYMENT_A
	(p_from_business_group_id        => p_from_business_group_id
	,p_to_business_group_id          => p_to_business_group_id
	,p_from_person_id                => p_from_person_id
	,p_to_person_id                  => p_to_person_id
	,p_person_type_id                => p_person_type_id
	,p_start_date                    => l_start_date
	,p_end_date                      => l_end_date
        ,p_deployment_reason             => p_deployment_reason
	,p_employee_number               => p_employee_number
	,p_leaving_reason                => p_leaving_reason
	,p_leaving_person_type_id        => p_leaving_person_type_id
	,p_permanent                     => p_permanent
	,p_deplymt_policy_id             => p_deplymt_policy_id
	,p_organization_id               => p_organization_id
	,p_location_id                   => p_location_id
	,p_job_id                        => p_job_id
	,p_position_id                   => p_position_id
	,p_grade_id                      => p_grade_id
	,p_supervisor_id                 => p_supervisor_id
	,p_supervisor_assignment_id      => p_supervisor_assignment_id
        ,p_retain_direct_reports         => p_retain_direct_reports
	,p_payroll_id                    => p_payroll_id
	,p_pay_basis_id                  => p_pay_basis_id
	,p_proposed_salary               => p_proposed_salary
	,p_people_group_id               => p_people_group_id
	,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
	,p_assignment_status_type_id     => p_assignment_status_type_id
	,p_ass_status_change_reason      => p_ass_status_change_reason
	,p_assignment_category           => p_assignment_category
	,p_per_information1              => p_per_information1
	,p_per_information2              => p_per_information2
	,p_per_information3              => p_per_information3
	,p_per_information4              => p_per_information4
	,p_per_information5              => p_per_information5
	,p_per_information6              => p_per_information6
	,p_per_information7              => p_per_information7
	,p_per_information8              => p_per_information8
	,p_per_information9              => p_per_information9
	,p_per_information10             => p_per_information10
	,p_per_information11             => p_per_information11
	,p_per_information12             => p_per_information12
	,p_per_information13             => p_per_information13
	,p_per_information14             => p_per_information14
	,p_per_information15             => p_per_information15
	,p_per_information16             => p_per_information16
	,p_per_information17             => p_per_information17
	,p_per_information18             => p_per_information18
	,p_per_information19             => p_per_information19
	,p_per_information20             => p_per_information20
	,p_per_information21             => p_per_information21
	,p_per_information22             => p_per_information22
	,p_per_information23             => p_per_information23
	,p_per_information24             => p_per_information24
	,p_per_information25             => p_per_information25
	,p_per_information26             => p_per_information26
	,p_per_information27             => p_per_information27
	,p_per_information28             => p_per_information28
	,p_per_information29             => p_per_information29
	,p_per_information30             => p_per_information30
	,p_person_deployment_id          => l_person_deployment_id
	,p_object_version_number         => l_object_version_number
	,p_policy_duration_warning       => l_policy_duration_warning
	);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_DEPLOYMENT'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_person_deployment_id   := l_person_deployment_id;
  p_object_version_number  := l_object_version_number;
  p_policy_duration_warning := l_policy_duration_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_person_deployment;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_deployment_id   := null;
    p_object_version_number  := null;
    p_policy_duration_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_person_deployment;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_person_deployment_id   := null;
    p_object_version_number  := null;
    p_policy_duration_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_person_deployment;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_PERSON_DEPLOYMENT >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_deployment
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_to_person_id                  in     number     default hr_api.g_number
  ,p_person_type_id                in     number     default hr_api.g_number
  ,p_start_date                    in     date       default hr_api.g_date
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_deployment_reason             in     varchar2   default hr_api.g_varchar2
  ,p_employee_number               in     varchar2   default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2   default hr_api.g_varchar2
  ,p_leaving_person_type_id        in     number     default hr_api.g_number
  ,p_status                        in     varchar2   default hr_api.g_varchar2
  ,p_status_change_reason          in     varchar2   default hr_api.g_varchar2
  ,p_deplymt_policy_id             in     number     default hr_api.g_number
  ,p_organization_id               in     number     default hr_api.g_number
  ,p_location_id                   in     number     default hr_api.g_number
  ,p_job_id                        in     number     default hr_api.g_number
  ,p_position_id                   in     number     default hr_api.g_number
  ,p_grade_id                      in     number     default hr_api.g_number
  ,p_supervisor_id                 in     number     default hr_api.g_number
  ,p_supervisor_assignment_id      in     number     default hr_api.g_number
  ,p_retain_direct_reports         in     varchar2   default hr_api.g_varchar2
  ,p_payroll_id                    in     number     default hr_api.g_number
  ,p_pay_basis_id                  in     number     default hr_api.g_number
  ,p_proposed_salary               in     varchar2   default hr_api.g_varchar2
  ,p_people_group_id               in     number     default hr_api.g_number
  ,p_soft_coding_keyflex_id        in     number     default hr_api.g_number
  ,p_assignment_status_type_id     in     number     default hr_api.g_number
  ,p_ass_status_change_reason      in     varchar2   default hr_api.g_varchar2
  ,p_assignment_category           in     varchar2   default hr_api.g_varchar2
  ,p_per_information1              in     varchar2   default hr_api.g_varchar2
  ,p_per_information2              in     varchar2   default hr_api.g_varchar2
  ,p_per_information3              in     varchar2   default hr_api.g_varchar2
  ,p_per_information4              in     varchar2   default hr_api.g_varchar2
  ,p_per_information5              in     varchar2   default hr_api.g_varchar2
  ,p_per_information6              in     varchar2   default hr_api.g_varchar2
  ,p_per_information7              in     varchar2   default hr_api.g_varchar2
  ,p_per_information8              in     varchar2   default hr_api.g_varchar2
  ,p_per_information9              in     varchar2   default hr_api.g_varchar2
  ,p_per_information10             in     varchar2   default hr_api.g_varchar2
  ,p_per_information11             in     varchar2   default hr_api.g_varchar2
  ,p_per_information12             in     varchar2   default hr_api.g_varchar2
  ,p_per_information13             in     varchar2   default hr_api.g_varchar2
  ,p_per_information14             in     varchar2   default hr_api.g_varchar2
  ,p_per_information15             in     varchar2   default hr_api.g_varchar2
  ,p_per_information16             in     varchar2   default hr_api.g_varchar2
  ,p_per_information17             in     varchar2   default hr_api.g_varchar2
  ,p_per_information18             in     varchar2   default hr_api.g_varchar2
  ,p_per_information19             in     varchar2   default hr_api.g_varchar2
  ,p_per_information20             in     varchar2   default hr_api.g_varchar2
  ,p_per_information21             in     varchar2   default hr_api.g_varchar2
  ,p_per_information22             in     varchar2   default hr_api.g_varchar2
  ,p_per_information23             in     varchar2   default hr_api.g_varchar2
  ,p_per_information24             in     varchar2   default hr_api.g_varchar2
  ,p_per_information25             in     varchar2   default hr_api.g_varchar2
  ,p_per_information26             in     varchar2   default hr_api.g_varchar2
  ,p_per_information27             in     varchar2   default hr_api.g_varchar2
  ,p_per_information28             in     varchar2   default hr_api.g_varchar2
  ,p_per_information29             in     varchar2   default hr_api.g_varchar2
  ,p_per_information30             in     varchar2   default hr_api.g_varchar2
  ,p_policy_duration_warning          out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number            number;
  l_policy_duration_warning          boolean := false;
  l_start_date                       date;
  l_end_date                         date;
  l_status_change_date               date;
  l_proc                varchar2(72) := g_package||'update_person_deployment';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_deployment;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date     := trunc(p_start_date);
  l_end_date       := trunc(p_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    HR_PERSON_DEPLOYMENT_BK2.UPDATE_PERSON_DEPLOYMENT_B
      (p_person_deployment_id          => p_person_deployment_id
      ,p_object_version_number         => p_object_version_number
      ,p_to_person_id                  => p_to_person_id
      ,p_person_type_id                => p_person_type_id
      ,p_start_date                    => l_start_date
      ,p_status                        => p_status
      ,p_status_change_reason          => p_status_change_reason
      ,p_end_date                      => l_end_date
      ,p_deployment_reason             => p_deployment_reason
      ,p_employee_number               => p_employee_number
      ,p_leaving_reason                => p_leaving_reason
      ,p_leaving_person_type_id        => p_leaving_person_type_id
      ,p_deplymt_policy_id             => p_deplymt_policy_id
      ,p_organization_id               => p_organization_id
      ,p_location_id                   => p_location_id
      ,p_job_id                        => p_job_id
      ,p_position_id                   => p_position_id
      ,p_grade_id                      => p_grade_id
      ,p_supervisor_id                 => p_supervisor_id
      ,p_supervisor_assignment_id      => p_supervisor_assignment_id
      ,p_retain_direct_reports         => p_retain_direct_reports
      ,p_payroll_id                    => p_payroll_id
      ,p_pay_basis_id                  => p_pay_basis_id
      ,p_proposed_salary               => p_proposed_salary
      ,p_people_group_id               => p_people_group_id
      ,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
      ,p_assignment_status_type_id     => p_assignment_status_type_id
      ,p_ass_status_change_reason      => p_ass_status_change_reason
      ,p_assignment_category           => p_assignment_category
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_DEPLOYMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  hr_pdt_upd.upd
      (p_person_deployment_id          => p_person_deployment_id
      ,p_object_version_number         => p_object_version_number
      ,p_to_person_id                  => p_to_person_id
      ,p_person_type_id                => p_person_type_id
      ,p_start_date                    => l_start_date
      ,p_status                        => p_status
      ,p_status_change_reason          => p_status_change_reason
      ,p_end_date                      => l_end_date
      ,p_deployment_reason             => p_deployment_reason
      ,p_employee_number               => p_employee_number
      ,p_leaving_reason                => p_leaving_reason
      ,p_leaving_person_type_id        => p_leaving_person_type_id
      ,p_deplymt_policy_id             => p_deplymt_policy_id
      ,p_organization_id               => p_organization_id
      ,p_location_id                   => p_location_id
      ,p_job_id                        => p_job_id
      ,p_position_id                   => p_position_id
      ,p_grade_id                      => p_grade_id
      ,p_supervisor_id                 => p_supervisor_id
      ,p_supervisor_assignment_id      => p_supervisor_assignment_id
      ,p_retain_direct_reports         => p_retain_direct_reports
      ,p_payroll_id                    => p_payroll_id
      ,p_pay_basis_id                  => p_pay_basis_id
      ,p_proposed_salary               => p_proposed_salary
      ,p_people_group_id               => p_people_group_id
      ,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
      ,p_assignment_status_type_id     => p_assignment_status_type_id
      ,p_ass_status_change_reason      => p_ass_status_change_reason
      ,p_assignment_category           => p_assignment_category
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      );

  --
  -- Call After Process User Hook
  --
  begin
    HR_PERSON_DEPLOYMENT_BK2.UPDATE_PERSON_DEPLOYMENT_A
      (p_person_deployment_id          => p_person_deployment_id
      ,p_object_version_number         => p_object_version_number
      ,p_to_person_id                  => p_to_person_id
      ,p_person_type_id                => p_person_type_id
      ,p_start_date                    => l_start_date
      ,p_status                        => p_status
      ,p_status_change_reason          => p_status_change_reason
      ,p_end_date                      => l_end_date
      ,p_deployment_reason             => p_deployment_reason
      ,p_employee_number               => p_employee_number
      ,p_leaving_reason                => p_leaving_reason
      ,p_leaving_person_type_id        => p_leaving_person_type_id
      ,p_deplymt_policy_id             => p_deplymt_policy_id
      ,p_organization_id               => p_organization_id
      ,p_location_id                   => p_location_id
      ,p_job_id                        => p_job_id
      ,p_position_id                   => p_position_id
      ,p_grade_id                      => p_grade_id
      ,p_supervisor_id                 => p_supervisor_id
      ,p_supervisor_assignment_id      => p_supervisor_assignment_id
      ,p_retain_direct_reports         => p_retain_direct_reports
      ,p_payroll_id                    => p_payroll_id
      ,p_pay_basis_id                  => p_pay_basis_id
      ,p_proposed_salary               => p_proposed_salary
      ,p_people_group_id               => p_people_group_id
      ,p_soft_coding_keyflex_id        => p_soft_coding_keyflex_id
      ,p_assignment_status_type_id     => p_assignment_status_type_id
      ,p_ass_status_change_reason      => p_ass_status_change_reason
      ,p_assignment_category           => p_assignment_category
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      ,p_policy_duration_warning       => l_policy_duration_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_DEPLOYMENT'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_policy_duration_warning := l_policy_duration_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_person_deployment;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_policy_duration_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_person_deployment;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_object_version_number;
    p_policy_duration_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_person_deployment;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_PERSON_DEPLOYMENT >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_deployment
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_person_deployment';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_person_deployment;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    HR_PERSON_DEPLOYMENT_BK3.DELETE_PERSON_DEPLOYMENT_B
      (p_person_deployment_id                 => p_person_deployment_id
      ,p_object_version_number                => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_DEPLOYMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
    hr_pdt_del.del
      (p_person_deployment_id                 => p_person_deployment_id
      ,p_object_version_number                => p_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    HR_PERSON_DEPLOYMENT_BK3.DELETE_PERSON_DEPLOYMENT_A
      (p_person_deployment_id                 => p_person_deployment_id
      ,p_object_version_number                => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_DEPLOYMENT'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_person_deployment;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_person_deployment;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_person_deployment;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< initiate_deployment >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure initiate_deployment
  (p_validate                        in     boolean    default false
  ,p_person_deployment_id            in     number
  ,p_object_version_number           in out nocopy number
  ,p_host_person_id                     out nocopy number
  ,p_host_per_ovn                       out nocopy number
  ,p_host_assignment_id                 out nocopy number
  ,p_host_asg_ovn                       out nocopy number
  ,p_already_applicant_warning          out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  l_home_first_name                     per_all_people_f.last_name%type;  -- 8605683
  --
  l_proc                varchar2(72) := g_package||'initiate_deployment';
  l_object_version_number              hr_person_deployments.object_version_number%type;
  --
  -- Key data from per and asg
  l_host_employee_number               per_all_people_f.employee_number%type;
  l_host_applicant_number              per_all_people_f.applicant_number%type;
  l_home_last_name                     per_all_people_f.last_name%type;
  l_home_sex                           per_all_people_f.sex%type;
  l_home_party_id                      per_all_people_f.party_id%type;
  l_home_original_date_of_hire         per_all_people_f.original_date_of_hire%type;
  l_host_person_id                     number;
  l_host_per_ovn                       number;
  l_host_assignment_id                 number;
  l_host_asg_ovn                       number;
  l_host_asg_ovn1                      number;
  l_host_application_id                number;
  l_host_apl_ovn                       number;
  l_host_per_esd                       date;
  l_host_per_eed                       date;
  l_host_asg_esd                       date;
  l_host_asg_eed                       date;
  l_host_per_full_name                 per_all_people_f.full_name%type;
  l_home_asg_esd                       date;
  l_home_asg_eed                       date;
  l_host_person_extra_info_id          number;
  l_host_pei_ovn                       number;
  l_contact_person_id                  number;
  l_host_pyp_id                        number;
  l_host_pyp_ovn                       number;
  l_dummy_n                            number;

--variables for OUT and INOUT in API calls
  l_cagr_grade_def_id                  number;
  l_cagr_concatenated_segments         varchar2(2000);
  l_concatenated_segments              hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_soft_coding_keyflex_id             per_all_assignments_f.soft_coding_keyflex_id%TYPE;
  l_comment_id                         per_all_assignments_f.comment_id%TYPE;
  l_host_per_comment_id                number;
  l_host_asg_sequence                  number;
  l_host_asg_number                    per_all_assignments_f.assignment_number%type;
  l_assignment_status_type_id          number;
  l_special_ceiling_step_id            number;
  l_group_name                         pay_people_groups.group_name%TYPE;
  l_host_contact_person_id             number;
  l_host_ctr_id                        number;
  l_host_ctr_ovn                       number;
  l_host_contact_per_ovn               number;
  l_host_contact_per_esd               date;
  l_host_contact_per_eed               date;
  l_host_contact_full_name             per_all_people_f.full_name%type;
  l_host_contact_per_comment_id        number;
  l_pyp_element_entry_id               number;
  --
  l_name_combination_warning           boolean;
  l_assign_payroll_warning             boolean;
  l_orig_hire_warning                  boolean;
  l_appl_override_warning              boolean;
  l_oversubscribed_vacancy_id          number;
  l_no_managers_warning                boolean;
  l_other_manager_warning              boolean;
  l_org_now_no_manager_warning         boolean;
  l_hourly_salaried_warning            boolean;
  l_gsp_post_process_warning           varchar2(2000);
  l_tax_district_changed_warning       boolean;
  l_entries_changed_warning            varchar2(1);
  l_spp_delete_warning                 boolean;
  l_last_std_process_date_out          date;
  l_supervisor_warning                 boolean;
  l_event_warning                      boolean;
  l_interview_warning                  boolean;
  l_review_warning                     boolean;
  l_recruiter_warning                  boolean;
  l_asg_future_changes_warning         boolean;
  l_pay_proposal_warning               boolean;
  l_dod_warning                        boolean;
  l_inv_next_sal_date_warning          boolean;
  l_proposed_salary_warning            boolean;
  l_approved_warning                   boolean;
  l_payroll_warning                    boolean;
  --new variables declared
  l_created_by          per_all_assignments_f.created_by%TYPE;
  l_creation_date       per_all_assignments_f.creation_date%TYPE;
  l_last_update_date       per_all_assignments_f.last_update_date%TYPE;
  l_last_updated_by     per_all_assignments_f.last_updated_by%TYPE;
  l_last_update_login   per_all_assignments_f.last_update_login%TYPE;
  l_payroll_id_updated           BOOLEAN;
  l_business_group_id            hr_all_organization_units.organization_id%TYPE;
  l_validation_start_date        DATE;
  l_validation_end_date          DATE;
  l_effective_start_date         DATE;
  l_effective_end_date           DATE;
  l_datetrack_update_mode      varchar2(30);
 --
  --
  --Warnings connected sepcifically with deployments
  l_policy_duration_warning            boolean;
  l_already_applicant_warning          boolean := false;
  --
  l_varray_d hr_dflex_utility.l_ignore_dfcode_varray
          := hr_dflex_utility.l_ignore_dfcode_varray();
  --
  --Cursors and related variables
  --
  --
  -- fix for bug 6593649
   l_attachments varchar2(1);
  cursor csr_get_attached_doc  is
    select null
    from   fnd_attached_documents
    where  PK1_VALUE =p_person_deployment_id
         and ENTITY_NAME ='HR_PERSON_DEPLOYMENTS';
--
-- fix for bug 6593649
--
  cursor csr_person_deployment(p_person_deployment_id number) is
  select *
  from  hr_person_deployments dpl
  where dpl.person_deployment_id = p_person_deployment_id;
  --
  l_dpl_rec    csr_person_deployment%rowtype;
  --
  cursor csr_other_active_dpl(p_person_deployment_id number) is
  select 1
  from   hr_person_deployments pdt1
  where  pdt1.person_deployment_id = p_person_deployment_id
  and    exists (select 1
                 from   hr_person_deployments pdt2
                 where  pdt2.person_deployment_id <> pdt1.person_deployment_id
                 and    pdt2.from_person_id = pdt1.from_person_id
                 and    pdt2.status in ('ACTIVE','COMPLETE')
                 and    pdt1.start_date <= nvl(pdt2.end_date,hr_api.g_eot));
  --
  cursor csr_home_per_values(p_person_id number) is
  select papf.last_name, papf.sex, papf.party_id, papf.original_date_of_hire,papf.first_name -- 8605683 , 8688303
  from   per_all_people_f papf
  where  papf.person_id = p_person_id
  and    l_dpl_rec.start_date between
         papf.effective_start_date and papf.effective_end_date;
  --
  cursor csr_host_per_values(p_person_id number) is
  select papf.object_version_number
  from   per_all_people_f papf
  where  papf.person_id = p_person_id
  and    l_dpl_rec.start_date between
         papf.effective_start_date and papf.effective_end_date;
  --
  cursor csr_host_asg_ovn(p_assignment_id number) is
  select paaf.object_version_number
  from   per_all_assignments_f paaf
  where  paaf.assignment_id = p_assignment_id
  and    l_dpl_rec.start_date between
         paaf.effective_start_date and paaf.effective_end_date;
  --
  cursor csr_active_home_asgs(p_person_id number) is
  select paaf.assignment_id, paaf.object_version_number
  from   per_all_assignments_f paaf,
         per_assignment_status_types past
  where  paaf.person_id = p_person_id
  and    l_dpl_rec.start_date between
         paaf.effective_start_date and paaf.effective_end_date
  and    paaf.assignment_type = 'E'
  and    paaf.assignment_status_type_id = past.assignment_status_type_id
  and    past.per_system_status = 'ACTIVE_ASSIGN';
  --
  cursor csr_home_pds_details(p_person_id number) is
  select pds.period_of_service_id, pds.object_version_number
  from   per_periods_of_service pds
  where  pds.person_id = p_person_id
  and    l_dpl_rec.start_date >= pds.date_start
  and    pds.actual_termination_date is null;
  --
  l_home_pds_id    number;
  l_home_pds_ovn   number;
  --
  cursor csr_dpl_contacts(p_person_deployment_id number) is
  select *
  from   hr_person_deplymt_contacts pdc
  where  pdc.person_deployment_id = p_person_deployment_id;
  --
  cursor csr_contact_rel_details(p_contact_relationship_id number) is
  select *
  from   per_contact_relationships ctr
  where  ctr.contact_relationship_id = p_contact_relationship_id;
  --
  l_contact_rel_details csr_contact_rel_details%rowtype;
  --
  cursor csr_contact_person_details(p_person_id number, p_effective_date date) is
  select *
  from   per_all_people_f papf
  where  papf.person_id = p_person_id
  and    p_effective_date between
         papf.effective_start_date and papf.effective_end_date;
  --
  l_contact_person_details csr_contact_person_details%rowtype;
  l_contact_created   t_contact_created;
  l_contacts_created  t_contacts_created := t_contacts_created();
  l_index_number  number;
  --
  cursor csr_dpl_eits(p_person_deployment_id number) is
  select *
  from   hr_person_deplymt_eits pde
  where  pde.person_deployment_id = p_person_deployment_id;
  --
  cursor csr_eit_details(p_person_extra_info_id number) is
  select *
  from   per_people_extra_info pei
  where  pei.person_extra_info_id = p_person_extra_info_id;
  --
  l_eit_details  csr_eit_details%rowtype;
  --
/*  cursor csr_direct_reports(p_person_id number, p_effective_date date) is
  select asg.assignment_id, asg.effective_start_date
  from   per_all_assignments_f asg
  where  asg.supervisor_id = p_person_id
  and    asg.effective_end_date > p_effective_date;*/
  --
   cursor csr_direct_reports(p_person_id number, p_start_date date) is
   select *
   from   per_all_assignments_f asg
   where  asg.supervisor_id = p_person_id
   and p_start_date between asg.effective_start_date and asg.effective_end_date;

------------------
   cursor csr_fut_dt_rows(p_person_id number, p_start_date date) is
   select asg.assignment_id, asg.effective_start_date,asg.effective_end_date
   from   per_all_assignments_f asg
   where  asg.supervisor_id = p_person_id
   and asg.effective_start_date > p_start_date;
-----

   -- local variables for people group
    l_group_id number :=null;
    l_pgp_segment1               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment2               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment3               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment4               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment5               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment6               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment7               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment8               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment9               varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment10              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment11              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment12              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment13              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment14              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment15              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment16              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment17              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment18              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment19              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment20              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment21              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment22              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment23              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment24              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment25              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment26              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment27              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment28              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment29              varchar2(60):=hr_api.g_varchar2;
    l_pgp_segment30              varchar2(60):=hr_api.g_varchar2;

cursor c_pgp_segments (cur_p_people_group_id  number) is
     select segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment17,
            segment18,
            segment19,
            segment20,
            segment21,
            segment22,
            segment23,
            segment24,
            segment25,
            segment26,
            segment27,
            segment28,
            segment29,
            segment30
     from   pay_people_groups
     where  people_group_id = cur_p_people_group_id;
  -- for people group fields population.

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint initiate_deployment;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Validation in addition to Row Handlers
  --
  open csr_person_deployment(p_person_deployment_id);
  fetch csr_person_deployment into l_dpl_rec;
  if csr_person_deployment%notfound then
    close csr_person_deployment;
    fnd_message.set_name('PER','HR_449609_DPL_NOT_EXIST');
    fnd_message.raise_error;
  else
    close csr_person_deployment;
    --
    hr_utility.set_location(l_proc,30);
    --
  end if;
  --
  if l_dpl_rec.status <> 'DRAFT' then
    fnd_message.set_name('PER','HR_449614_PDT_ALREADY_INIT');
    fnd_message.raise_error;
  end if;
  --
  open csr_other_active_dpl(p_person_deployment_id);
  fetch csr_other_active_dpl into l_dummy_n;
  if csr_other_active_dpl%found then
    close csr_other_active_dpl;
    fnd_message.set_name('PER','HR_449615_PDT_OTHER_ACTIVE');
    fnd_message.raise_error;
  else
    close csr_other_active_dpl;
  end if;
  --
  -- Set up the arrays for bypassing flex validation for information that does
  -- not exist in the deployment proposal
  --
  l_varray_d.delete;
  l_varray_d.extend(8);
  l_varray_d(1):='PER_ASSIGNMENTS';
  l_varray_d(2):='PER_PAY_PROPOSALS';
  l_varray_d(3):='PER_CONTACTS';
  l_varray_d(4):='Contact Relship Developer DF';
  l_varray_d(5):='PER_PEOPLE_EXTRA_INFO';
  l_varray_d(6):='PER_PERIODS_OF_SERVICE';
  l_varray_d(7):='PER_PDS_DEVELOPER_DF';
  --
  -- Added for bug 5491169
  l_varray_d(8):='PER_PEOPLE';

  hr_dflex_utility.create_ignore_df_validation(p_rec=>l_varray_d);
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Process Logic
  --
  --
  -- Store parameter values which may be changed by the API calls
  --
  l_host_employee_number := l_dpl_rec.employee_number;
  --
  open csr_home_per_values(l_dpl_rec.from_person_id);
  fetch csr_home_per_values into l_home_last_name,l_home_sex,l_home_party_id,
                                 l_home_original_date_of_hire,l_home_first_name;  -- 8605683 , 8688303
  close csr_home_per_values;
  --
  hr_utility.set_location(l_proc,40);
  --
  -- Set the global transfer in process variable used by person rowhandler validation
  --
  per_per_bus.g_global_transfer_in_process := true;
  --
  -- Start of termination or update to the Home BG records
  --
  if nvl(l_dpl_rec.permanent,'N') = 'Y' then
    --
    hr_utility.set_location(l_proc,170);
    --
    -- termination of home employee record at (l_dpl_rec.start_date-1)
    --

    fnd_profile.put(name => 'HR_PROPAGATE_DATA_CHANGES'
                   ,val  => 'N');

    open csr_home_pds_details(l_dpl_rec.from_person_id);
    fetch csr_home_pds_details into l_home_pds_id, l_home_pds_ovn;
    close csr_home_pds_details;
    --
    hr_ex_employee_api.actual_termination_emp
      (p_validate                      => p_validate
      ,p_effective_date                => l_dpl_rec.start_date-1
      ,p_period_of_service_id          => l_home_pds_id
      ,p_object_version_number         => l_home_pds_ovn
      ,p_actual_termination_date       => l_dpl_rec.start_date-1
      ,p_last_standard_process_date    => null
      ,p_last_std_process_date_out     => l_last_std_process_date_out
      ,p_supervisor_warning            => l_supervisor_warning
      ,p_event_warning                 => l_event_warning
      ,p_interview_warning             => l_interview_warning
      ,p_review_warning                => l_review_warning
      ,p_recruiter_warning             => l_recruiter_warning
      ,p_asg_future_changes_warning    => l_asg_future_changes_warning
      ,p_entries_changed_warning       => l_entries_changed_warning
      ,p_pay_proposal_warning          => l_pay_proposal_warning
      ,p_dod_warning                   => l_dod_warning
       );

     fnd_profile.put(name => 'HR_PROPAGATE_DATA_CHANGES'
                    ,val  => 'Y');
  else
    --
    hr_utility.set_location(l_proc,160);
    --
    -- suspend the active home assignments, leaving the others.
    --
    for l_home_asg_rec in csr_active_home_asgs(l_dpl_rec.from_person_id) loop
      hr_assignment_api.suspend_emp_asg
        (p_validate                     => p_validate
	,p_effective_date               => l_dpl_rec.start_date
	,p_datetrack_update_mode        => 'UPDATE'
	,p_assignment_id                => l_home_asg_rec.assignment_id
	,p_object_version_number        => l_home_asg_rec.object_version_number
	,p_effective_start_date         => l_home_asg_esd
	,p_effective_end_date           => l_home_asg_eed
         );
    end loop;
  end if;
  --
  -- If retain_direct_reports was set, then need to update supervisor_id column for
  -- the direct reports to point to the l_host_person_id
  -- Do direct sql because there may be future updates to the records, and we do not
  -- want this to cause whole initiation to fail.
  --Moved this logic at later stage
 /* if nvl(l_dpl_rec.retain_direct_reports,'N') = 'Y' then
     for l_reports in csr_direct_reports
                      (l_dpl_rec.from_person_id,l_dpl_rec.start_date) loop
         update per_all_assignments_f
         set    supervisor_id            = l_host_person_id,
                supervisor_assignment_id =
                       decode(supervisor_assignment_id,null,null,l_host_assignment_id),
                object_version_number    = object_version_number+1
         where  assignment_id = l_reports.assignment_id
         and    effective_start_date = l_reports.effective_start_date;
     end loop;
  end if;*/
  --
  -- End of termination or update to the Home BG records
  --
  --
  -- Start of create or update person section
  --
  if l_dpl_rec.to_person_id is null then    --creating new emp in host BG
    --
    hr_utility.set_location(l_proc,50);
    --
    hr_employee_api.create_employee
      (p_validate                         => p_validate
      ,p_hire_date                        => l_dpl_rec.start_date
      ,p_business_group_id                => l_dpl_rec.to_business_group_id
      ,p_last_name                        => l_home_last_name
      ,p_first_name                       => l_home_first_name -- 8605683 , 8688303
      ,p_sex                              => l_home_sex
      ,p_person_type_id                   => l_dpl_rec.person_type_id
      ,p_per_information_category         => l_dpl_rec.per_information_category
      ,p_per_information1                 => l_dpl_rec.per_information1
      ,p_per_information2                 => l_dpl_rec.per_information2
      ,p_per_information3                 => l_dpl_rec.per_information3
      ,p_per_information4                 => l_dpl_rec.per_information4
      ,p_per_information5                 => l_dpl_rec.per_information5
      ,p_per_information6                 => l_dpl_rec.per_information6
      ,p_per_information7                 => l_dpl_rec.per_information7
      ,p_per_information8                 => l_dpl_rec.per_information8
      ,p_per_information9                 => l_dpl_rec.per_information9
      ,p_per_information10                => l_dpl_rec.per_information10
      ,p_per_information11                => l_dpl_rec.per_information11
      ,p_per_information12                => l_dpl_rec.per_information12
      ,p_per_information13                => l_dpl_rec.per_information13
      ,p_per_information14                => l_dpl_rec.per_information14
      ,p_per_information15                => l_dpl_rec.per_information15
      ,p_per_information16                => l_dpl_rec.per_information16
      ,p_per_information17                => l_dpl_rec.per_information17
      ,p_per_information18                => l_dpl_rec.per_information18
      ,p_per_information19                => l_dpl_rec.per_information19
      ,p_per_information20                => l_dpl_rec.per_information20
      ,p_per_information21                => l_dpl_rec.per_information21
      ,p_per_information22                => l_dpl_rec.per_information22
      ,p_per_information23                => l_dpl_rec.per_information23
      ,p_per_information24                => l_dpl_rec.per_information24
      ,p_per_information25                => l_dpl_rec.per_information25
      ,p_per_information26                => l_dpl_rec.per_information26
      ,p_per_information27                => l_dpl_rec.per_information27
      ,p_per_information28                => l_dpl_rec.per_information28
      ,p_per_information29                => l_dpl_rec.per_information29
      ,p_per_information30                => l_dpl_rec.per_information30
      ,p_original_date_of_hire            => l_home_original_date_of_hire
      ,p_adjusted_svc_date                => l_home_original_date_of_hire
      ,p_party_id                         => l_home_party_id
      ,p_employee_number                  => l_host_employee_number
      ,p_person_id                        => l_host_person_id
      ,p_assignment_id                    => l_host_assignment_id
      ,p_per_object_version_number        => l_host_per_ovn
      ,p_asg_object_version_number        => l_host_asg_ovn
      ,p_per_effective_start_date         => l_host_per_esd
      ,p_per_effective_end_date           => l_host_per_eed
      ,p_full_name                        => l_host_per_full_name
      ,p_per_comment_id                   => l_host_per_comment_id
      ,p_assignment_sequence              => l_host_asg_sequence
      ,p_assignment_number                => l_host_asg_number
      ,p_name_combination_warning         => l_name_combination_warning
      ,p_assign_payroll_warning           => l_assign_payroll_warning
      ,p_orig_hire_warning                => l_orig_hire_warning
      );
  elsif hr_person_type_usage_info.is_person_of_type
           (p_effective_date      => l_dpl_rec.start_date
           ,p_person_id           => l_dpl_rec.to_person_id
           ,p_system_person_type  => 'EMP') then
                            --already emp so raise error
    fnd_message.set_name('PER','HR_449616_PDT_ALREADY_EMP');
    fnd_message.raise_error;

  elsif hr_person_type_usage_info.is_person_of_type
           (p_effective_date      => l_dpl_rec.start_date
           ,p_person_id           => l_dpl_rec.to_person_id
           ,p_system_person_type  => 'CWK') then
                            --already cwk so raise error
    fnd_message.set_name('PER','HR_449617_PDT_ALREADY_CWK');
    fnd_message.raise_error;

  elsif hr_person_type_usage_info.is_person_of_type
           (p_effective_date      => l_dpl_rec.start_date
           ,p_person_id           => l_dpl_rec.to_person_id
           ,p_system_person_type  => 'APL') then
    --error out in this case, there is no way to create an employee record from here
    fnd_message.set_name('PER','HR_449618_PDT_ALREADY_APL');
    fnd_message.raise_error;
    --
  else        --we should have the all clear to hire existing person
    --
    hr_utility.set_location(l_proc,70);
    --
    l_host_person_id   := l_dpl_rec.to_person_id;
    --
    open csr_host_per_values(l_dpl_rec.to_person_id);
    fetch csr_host_per_values into l_host_per_ovn;
    close csr_host_per_values;
    --
    hr_employee_api.hire_into_job
      (p_validate                    => p_validate
      ,p_effective_date              => l_dpl_rec.start_date
      ,p_person_id                   => l_host_person_id
      ,p_object_version_number       => l_host_per_ovn
      ,p_employee_number             => l_host_employee_number
    --  ,p_datetrack_update_mode       => 'UPDATE'
      ,p_person_type_id              => l_dpl_rec.person_type_id
      ,p_national_identifier         => null
      ,p_per_information7            => l_dpl_rec.per_information7
      ,p_assignment_id               => l_host_assignment_id
      ,p_effective_start_date        => l_host_per_esd
      ,p_effective_end_date          => l_host_per_eed
      ,p_assign_payroll_warning      => l_assign_payroll_warning
      ,p_orig_hire_warning           => l_orig_hire_warning
      );
    --
    open csr_host_asg_ovn(l_host_assignment_id);
    fetch csr_host_asg_ovn into l_host_asg_ovn;
    close csr_host_asg_ovn;
    --
  end if;
  --
  hr_utility.set_location('host person id '||l_host_person_id,77);
  --
  --Code moved here
  if nvl(l_dpl_rec.retain_direct_reports,'N') = 'Y' then

--fetch the reportees
  for l_reports in csr_direct_reports(l_dpl_rec.from_person_id,l_dpl_rec.start_date)
  loop
 --Check for the update mode
     if l_dpl_rec.start_date=l_reports.effective_start_date then
       l_datetrack_update_mode:='CORRECTION';

     elsif ((l_reports.effective_end_date <> hr_api.g_eot)and
           (l_reports.effective_end_date >l_dpl_rec.start_date) ) then
       l_datetrack_update_mode:='UPDATE_CHANGE_INSERT';

     elsif (l_reports.effective_end_date= hr_api.g_eot) then
       l_datetrack_update_mode:='UPDATE';

     end if;


     if  l_datetrack_update_mode = 'CORRECTION' then

         update per_all_assignments_f
         set    supervisor_id            = l_host_person_id,
                supervisor_assignment_id =
                       decode(supervisor_assignment_id,null,null,l_host_assignment_id),
                object_version_number    = object_version_number+1
         where  assignment_id = l_reports.assignment_id
         and    effective_start_date = l_reports.effective_start_date;

   elsif l_datetrack_update_mode ='UPDATE_CHANGE_INSERT'  then

   per_asg_upd.upd
	 (p_assignment_id                => l_reports.assignment_id
	 ,p_effective_start_date         => l_effective_start_date --l_effective_start_date
	 ,p_effective_end_date           => l_effective_end_date
	 ,p_business_group_id            => l_business_group_id
	 ,p_assignment_status_type_id    => l_reports.assignment_status_type_id
	 ,p_assignment_type              => l_reports.assignment_type --modified
	 ,p_supervisor_id                => l_host_person_id --modified
         ,p_supervisor_assignment_id     => l_host_assignment_id --modified
	 ,p_primary_flag                 => l_reports.primary_flag
	 ,p_period_of_service_id         => l_reports.period_of_service_id
	 ,p_comment_id                   => l_comment_id
	 ,p_object_version_number        => l_reports.object_version_number
	 ,p_payroll_id_updated           => l_payroll_id_updated
	 ,p_other_manager_warning        => l_other_manager_warning
	 ,p_no_managers_warning          => l_no_managers_warning
	 ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
	 ,p_validation_start_date        => l_validation_start_date
	 ,p_validation_end_date          => l_validation_end_date
	 ,p_effective_date               => l_dpl_rec.start_date
	 ,p_datetrack_mode               => 'UPDATE_CHANGE_INSERT'
	 ,p_hourly_salaried_warning      => l_hourly_salaried_warning
	 );

   elsif  l_datetrack_update_mode='UPDATE' then

   per_asg_upd.upd
	 (p_assignment_id                => l_reports.assignment_id
	 ,p_effective_start_date         => l_effective_start_date --l_effective_start_date
	 ,p_effective_end_date           => l_effective_end_date
	 ,p_business_group_id            => l_business_group_id
	 ,p_assignment_status_type_id    => l_reports.assignment_status_type_id
	 ,p_assignment_type              => l_reports.assignment_type --modified
	 ,p_supervisor_id                => l_host_person_id --modified
         ,p_supervisor_assignment_id     => l_host_assignment_id --modified
	 ,p_primary_flag                 => l_reports.primary_flag
	 ,p_period_of_service_id         => l_reports.period_of_service_id
	 ,p_comment_id                   => l_comment_id
	 ,p_object_version_number        => l_reports.object_version_number
	 ,p_payroll_id_updated           => l_payroll_id_updated
	 ,p_other_manager_warning        => l_other_manager_warning
	 ,p_no_managers_warning          => l_no_managers_warning
	 ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
	 ,p_validation_start_date        => l_validation_start_date
	 ,p_validation_end_date          => l_validation_end_date
	 ,p_effective_date               => l_dpl_rec.start_date
	 ,p_datetrack_mode               => 'UPDATE'
	 ,p_hourly_salaried_warning      => l_hourly_salaried_warning
	 );
  end if;
 end loop;
end if;

--now write code to handle future dt rows
 for l_fut_dt_rows in csr_fut_dt_rows(l_dpl_rec.from_person_id,l_dpl_rec.start_date)
  loop
        update per_all_assignments_f
         set    supervisor_id            = l_host_person_id,
                supervisor_assignment_id =
                       decode(supervisor_assignment_id,null,null,l_host_assignment_id),
                object_version_number    = object_version_number+1
         where  assignment_id = l_fut_dt_rows.assignment_id
         and    effective_start_date = l_fut_dt_rows.effective_start_date;
 end loop;
  --
  -- End of create or update person section
  --
  -- Start of update new host assignment section
  --
  l_soft_coding_keyflex_id := l_dpl_rec.soft_coding_keyflex_id;
  --
  --
  hr_utility.set_location(l_proc,80);
  --
  hr_assignment_api.update_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => l_dpl_rec.start_date
    ,p_datetrack_update_mode        => 'CORRECTION'
    ,p_assignment_id                => l_host_assignment_id
    ,p_object_version_number        => l_host_asg_ovn
    ,p_supervisor_id                => l_dpl_rec.supervisor_id
    ,p_assignment_number            => l_host_asg_number
    ,p_change_reason                => l_dpl_rec.ass_status_change_reason
--    ,p_assignment_status_type_id    => l_dpl_rec.assignment_status_type_id
    ,p_assignment_status_type_id    =>
                      nvl(l_dpl_rec.assignment_status_type_id,hr_api.g_number)
    ,p_comments                     => null
    ,p_date_probation_end           => hr_api.g_date
    ,p_default_code_comb_id         => hr_api.g_number
    ,p_frequency                    => hr_api.g_varchar2
    ,p_internal_address_line        => hr_api.g_varchar2
    ,p_manager_flag                 => hr_api.g_varchar2
    ,p_normal_hours                 => hr_api.g_number
    ,p_perf_review_period           => hr_api.g_number
    ,p_perf_review_period_frequency => hr_api.g_varchar2
    ,p_projected_assignment_end     => l_dpl_rec.end_date
    ,p_probation_period             => hr_api.g_number
    ,p_probation_unit               => hr_api.g_varchar2
    ,p_sal_review_period            => hr_api.g_number
    ,p_sal_review_period_frequency  => hr_api.g_varchar2
    ,p_set_of_books_id              => hr_api.g_number
    ,p_source_type                  => hr_api.g_varchar2
    ,p_time_normal_finish           => hr_api.g_varchar2
    ,p_time_normal_start            => hr_api.g_varchar2
    ,p_bargaining_unit_code         => hr_api.g_varchar2
    ,p_labour_union_member_flag     => hr_api.g_varchar2
    ,p_hourly_salaried_code         => hr_api.g_varchar2
    ,p_ass_attribute_category       => hr_api.g_varchar2
    ,p_ass_attribute1               => hr_api.g_varchar2
    ,p_ass_attribute2               => hr_api.g_varchar2
    ,p_ass_attribute3               => hr_api.g_varchar2
    ,p_ass_attribute4               => hr_api.g_varchar2
    ,p_ass_attribute5               => hr_api.g_varchar2
    ,p_ass_attribute6               => hr_api.g_varchar2
    ,p_ass_attribute7               => hr_api.g_varchar2
    ,p_ass_attribute8               => hr_api.g_varchar2
    ,p_ass_attribute9               => hr_api.g_varchar2
    ,p_ass_attribute10              => hr_api.g_varchar2
    ,p_ass_attribute11              => hr_api.g_varchar2
    ,p_ass_attribute12              => hr_api.g_varchar2
    ,p_ass_attribute13              => hr_api.g_varchar2
    ,p_ass_attribute14              => hr_api.g_varchar2
    ,p_ass_attribute15              => hr_api.g_varchar2
    ,p_ass_attribute16              => hr_api.g_varchar2
    ,p_ass_attribute17              => hr_api.g_varchar2
    ,p_ass_attribute18              => hr_api.g_varchar2
    ,p_ass_attribute19              => hr_api.g_varchar2
    ,p_ass_attribute20              => hr_api.g_varchar2
    ,p_ass_attribute21              => hr_api.g_varchar2
    ,p_ass_attribute22              => hr_api.g_varchar2
    ,p_ass_attribute23              => hr_api.g_varchar2
    ,p_ass_attribute24              => hr_api.g_varchar2
    ,p_ass_attribute25              => hr_api.g_varchar2
    ,p_ass_attribute26              => hr_api.g_varchar2
    ,p_ass_attribute27              => hr_api.g_varchar2
    ,p_ass_attribute28              => hr_api.g_varchar2
    ,p_ass_attribute29              => hr_api.g_varchar2
    ,p_ass_attribute30              => hr_api.g_varchar2
    ,p_title                        => hr_api.g_varchar2
    ,p_segment1                     => hr_api.g_varchar2
    ,p_segment2                     => hr_api.g_varchar2
    ,p_segment3                     => hr_api.g_varchar2
    ,p_segment4                     => hr_api.g_varchar2
    ,p_segment5                     => hr_api.g_varchar2
    ,p_segment6                     => hr_api.g_varchar2
    ,p_segment7                     => hr_api.g_varchar2
    ,p_segment8                     => hr_api.g_varchar2
    ,p_segment9                     => hr_api.g_varchar2
    ,p_segment10                    => hr_api.g_varchar2
    ,p_segment11                    => hr_api.g_varchar2
    ,p_segment12                    => hr_api.g_varchar2
    ,p_segment13                    => hr_api.g_varchar2
    ,p_segment14                    => hr_api.g_varchar2
    ,p_segment15                    => hr_api.g_varchar2
    ,p_segment16                    => hr_api.g_varchar2
    ,p_segment17                    => hr_api.g_varchar2
    ,p_segment18                    => hr_api.g_varchar2
    ,p_segment19                    => hr_api.g_varchar2
    ,p_segment20                    => hr_api.g_varchar2
    ,p_segment21                    => hr_api.g_varchar2
    ,p_segment22                    => hr_api.g_varchar2
    ,p_segment23                    => hr_api.g_varchar2
    ,p_segment24                    => hr_api.g_varchar2
    ,p_segment25                    => hr_api.g_varchar2
    ,p_segment26                    => hr_api.g_varchar2
    ,p_segment27                    => hr_api.g_varchar2
    ,p_segment28                    => hr_api.g_varchar2
    ,p_segment29                    => hr_api.g_varchar2
    ,p_segment30                    => hr_api.g_varchar2
    ,p_concat_segments              => hr_api.g_varchar2
    ,p_contract_id                  => hr_api.g_number
    ,p_establishment_id             => hr_api.g_number
    ,p_collective_agreement_id      => hr_api.g_number
    ,p_cagr_id_flex_num             => hr_api.g_number
    ,p_cag_segment1                 => hr_api.g_varchar2
    ,p_cag_segment2                 => hr_api.g_varchar2
    ,p_cag_segment3                 => hr_api.g_varchar2
    ,p_cag_segment4                 => hr_api.g_varchar2
    ,p_cag_segment5                 => hr_api.g_varchar2
    ,p_cag_segment6                 => hr_api.g_varchar2
    ,p_cag_segment7                 => hr_api.g_varchar2
    ,p_cag_segment8                 => hr_api.g_varchar2
    ,p_cag_segment9                 => hr_api.g_varchar2
    ,p_cag_segment10                => hr_api.g_varchar2
    ,p_cag_segment11                => hr_api.g_varchar2
    ,p_cag_segment12                => hr_api.g_varchar2
    ,p_cag_segment13                => hr_api.g_varchar2
    ,p_cag_segment14                => hr_api.g_varchar2
    ,p_cag_segment15                => hr_api.g_varchar2
    ,p_cag_segment16                => hr_api.g_varchar2
    ,p_cag_segment17                => hr_api.g_varchar2
    ,p_cag_segment18                => hr_api.g_varchar2
    ,p_cag_segment19                => hr_api.g_varchar2
    ,p_cag_segment20                => hr_api.g_varchar2
    ,p_notice_period		    => hr_api.g_number
    ,p_notice_period_uom	    => hr_api.g_varchar2
    ,p_employee_category	    => hr_api.g_varchar2
    ,p_work_at_home		    => hr_api.g_varchar2
    ,p_job_post_source_name	    => hr_api.g_varchar2
    ,p_supervisor_assignment_id     => l_dpl_rec.supervisor_assignment_id
    ,p_cagr_grade_def_id            => l_cagr_grade_def_id
    ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_comment_id                   => l_comment_id
    ,p_effective_start_date         => l_host_asg_esd
    ,p_effective_end_date           => l_host_asg_eed
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_gsp_post_process_warning     => l_gsp_post_process_warning
    );
  --
  hr_utility.set_location(l_proc,90);
  --
    --   sturlapa start

   if l_dpl_rec.people_group_id is not null then

       open c_pgp_segments(l_dpl_rec.people_group_id);

       fetch c_pgp_segments into l_pgp_segment1,
                                 l_pgp_segment2,
                                 l_pgp_segment3,
                                 l_pgp_segment4,
                                 l_pgp_segment5,
                                 l_pgp_segment6,
                                 l_pgp_segment7,
                                 l_pgp_segment8,
                                 l_pgp_segment9,
                                 l_pgp_segment10,
                                 l_pgp_segment11,
                                 l_pgp_segment12,
                                 l_pgp_segment13,
                                 l_pgp_segment14,
                                 l_pgp_segment15,
                                 l_pgp_segment16,
                                 l_pgp_segment17,
                                 l_pgp_segment18,
                                 l_pgp_segment19,
                                 l_pgp_segment20,
                                 l_pgp_segment21,
                                 l_pgp_segment22,
                                 l_pgp_segment23,
                                 l_pgp_segment24,
                                 l_pgp_segment25,
                                 l_pgp_segment26,
                                 l_pgp_segment27,
                                 l_pgp_segment28,
                                 l_pgp_segment29,
                                 l_pgp_segment30;

        close c_pgp_segments;
  end if;

  /**
   *  pass the people group id as null then internally it is trying to pull
   *  existing ccid with concatatnated list.
   */
  hr_assignment_api.update_emp_asg_criteria
    (p_validate                     => p_validate
    ,p_effective_date               => l_dpl_rec.start_date
    ,p_datetrack_update_mode        => 'CORRECTION'
    ,p_assignment_id                => l_host_assignment_id
    ,p_called_from_mass_update      => false
    ,p_grade_id                     => l_dpl_rec.grade_id
    ,p_position_id                  => l_dpl_rec.position_id
    ,p_job_id                       => l_dpl_rec.job_id
    ,p_payroll_id                   => l_dpl_rec.payroll_id
    ,p_location_id                  => l_dpl_rec.location_id
    ,p_organization_id              => l_dpl_rec.organization_id
    ,p_pay_basis_id                 => l_dpl_rec.pay_basis_id
    ,p_segment1                     => l_pgp_segment1 --hr_api.g_varchar2
    ,p_segment2                     => l_pgp_segment2 --hr_api.g_varchar2
    ,p_segment3                     => l_pgp_segment3 --hr_api.g_varchar2
    ,p_segment4                     => l_pgp_segment4 --hr_api.g_varchar2
    ,p_segment5                     => l_pgp_segment5 --hr_api.g_varchar2
    ,p_segment6                     => l_pgp_segment6 --hr_api.g_varchar2
    ,p_segment7                     => l_pgp_segment7 --hr_api.g_varchar2
    ,p_segment8                     => l_pgp_segment8 --hr_api.g_varchar2
    ,p_segment9                     => l_pgp_segment9 --hr_api.g_varchar2
    ,p_segment10                    => l_pgp_segment10 --hr_api.g_varchar2
    ,p_segment11                    => l_pgp_segment11 --hr_api.g_varchar2
    ,p_segment12                    => l_pgp_segment12 --hr_api.g_varchar2
    ,p_segment13                    => l_pgp_segment13 --hr_api.g_varchar2
    ,p_segment14                    => l_pgp_segment14 --hr_api.g_varchar2
    ,p_segment15                    => l_pgp_segment15 --hr_api.g_varchar2
    ,p_segment16                    => l_pgp_segment16 --hr_api.g_varchar2
    ,p_segment17                    => l_pgp_segment17 --hr_api.g_varchar2
    ,p_segment18                    => l_pgp_segment18 --hr_api.g_varchar2
    ,p_segment19                    => l_pgp_segment19 --hr_api.g_varchar2
    ,p_segment20                    => l_pgp_segment20 --hr_api.g_varchar2
    ,p_segment21                    => l_pgp_segment21 --hr_api.g_varchar2
    ,p_segment22                    => l_pgp_segment22 --hr_api.g_varchar2
    ,p_segment23                    => l_pgp_segment23 --hr_api.g_varchar2
    ,p_segment24                    => l_pgp_segment24 --hr_api.g_varchar2
    ,p_segment25                    => l_pgp_segment25 --hr_api.g_varchar2
    ,p_segment26                    => l_pgp_segment26 --hr_api.g_varchar2
    ,p_segment27                    => l_pgp_segment27 --hr_api.g_varchar2
    ,p_segment28                    => l_pgp_segment28 --hr_api.g_varchar2
    ,p_segment29                    => l_pgp_segment29 --hr_api.g_varchar2
    ,p_segment30                    => l_pgp_segment30 --hr_api.g_varchar2
    ,p_employment_category          => l_dpl_rec.assignment_category
    ,p_concat_segments              => hr_api.g_varchar2
    ,p_contract_id                  => hr_api.g_number
    ,p_establishment_id             => hr_api.g_number
    ,p_scl_segment1                 => hr_api.g_varchar2
    ,p_grade_ladder_pgm_id          => hr_api.g_number
    ,p_supervisor_assignment_id     => l_dpl_rec.supervisor_assignment_id
    ,p_object_version_number        => l_host_asg_ovn
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_people_group_id              => l_group_id  --l_dpl_rec.people_group_id -- sturlapa
    ,p_soft_coding_keyflex_id       => l_dpl_rec.soft_coding_keyflex_id
    ,p_group_name                   => l_group_name
    ,p_effective_start_date         => l_host_asg_esd
    ,p_effective_end_date           => l_host_asg_eed
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_spp_delete_warning           => l_spp_delete_warning
    ,p_entries_changed_warning      => l_entries_changed_warning
    ,p_tax_district_changed_warning => l_tax_district_changed_warning
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_gsp_post_process_warning     => l_gsp_post_process_warning
    );
    --   sturlapa end
  --
  -- End of update new host assignment section
  --
  -- Create a salary proposal
  --
  if nvl(l_dpl_rec.permanent,'N') = 'Y'
  and l_dpl_rec.proposed_salary is not null then
    --
    hr_utility.set_location(l_proc,100);
    --
    hr_maintain_proposal_api.insert_salary_proposal
      (p_validate                     => p_validate
      ,p_pay_proposal_id              => l_host_pyp_id
      ,p_assignment_id                => l_host_assignment_id
      ,p_business_group_id            => l_dpl_rec.to_business_group_id
      ,p_change_date                  => l_dpl_rec.start_date
      ,p_comments                     => null
      ,p_next_sal_review_date         => null
      ,p_proposal_reason              => null
      ,p_proposed_salary_n            => l_dpl_rec.proposed_salary
      ,p_forced_ranking               => null
      ,p_performance_review_id        => null
      ,p_attribute_category           => null
      ,p_attribute1                   => null
      ,p_attribute2                   => null
      ,p_attribute3                   => null
      ,p_attribute4                   => null
      ,p_attribute5                   => null
      ,p_attribute6                   => null
      ,p_attribute7                   => null
      ,p_attribute8                   => null
      ,p_attribute9                   => null
      ,p_attribute10                  => null
      ,p_attribute11                  => null
      ,p_attribute12                  => null
      ,p_attribute13                  => null
      ,p_attribute14                  => null
      ,p_attribute15                  => null
      ,p_attribute16                  => null
      ,p_attribute17                  => null
      ,p_attribute18                  => null
      ,p_attribute19                  => null
      ,p_attribute20                  => null
      ,p_object_version_number        => l_host_pyp_ovn
      ,p_multiple_components          => 'N'
      ,p_approved                     => 'Y'
      ,p_element_entry_id             => l_pyp_element_entry_id
      ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
      ,p_proposed_salary_warning      => l_proposed_salary_warning
      ,p_approved_warning             => l_approved_warning
      ,p_payroll_warning              => l_payroll_warning
       );
    --
  end if;
  --
  -- Create contacts and relationships in host BG
  --
  for l_dpl_contact_rec in csr_dpl_contacts(p_person_deployment_id) loop
  <<contacts>>
    -- Fetch details from home BG
    --
    hr_utility.set_location(l_proc,110);
    --
    open csr_contact_rel_details(l_dpl_contact_rec.contact_relationship_id);
    fetch csr_contact_rel_details into l_contact_rel_details;
    close csr_contact_rel_details;
    --
    open csr_contact_person_details
                    (l_contact_rel_details.contact_person_id,l_dpl_rec.start_date);
    fetch csr_contact_person_details into l_contact_person_details;
    close csr_contact_person_details;
    --
    --Loop around l_contacts_created to see if the contact already created in host
    --
    l_index_number := l_contacts_created.FIRST;
    l_contact_person_id := null;
    --
    WHILE l_index_number is not null loop
    <<created_contacts>>
      --
      hr_utility.set_location(l_proc,120);
      --
      if l_contact_rel_details.contact_person_id =
                  l_contacts_created(l_index_number).home_contact_person_id then
         l_contact_person_id :=
                  l_contacts_created(l_index_number).host_contact_person_id;
         --
         hr_utility.set_location(l_proc||' '||l_contact_person_id,123);
         --
         exit;
      else
 	 --
	 hr_utility.set_location(l_proc,127);
         --
         l_contact_person_id := null;
      end if;
      l_index_number := l_contacts_created.NEXT(l_index_number);
    END LOOP created_contacts;
    --
    hr_utility.set_location(l_proc,130);
    hr_utility.set_location('host person id '||l_host_person_id,131);
    --
    hr_contact_rel_api.create_contact    --use fetched details copying to host BG
      (p_validate                     => p_validate
      ,p_start_date                   => l_dpl_rec.start_date
      ,p_business_group_id            => l_dpl_rec.to_business_group_id
      ,p_person_id                    => l_host_person_id
      ,p_contact_person_id            => l_contact_person_id
      ,p_contact_type                 => l_contact_rel_details.contact_type
      ,p_primary_contact_flag         => l_contact_rel_details.primary_contact_flag
      ,p_date_start                   => l_contact_rel_details.date_start
      ,p_date_end                     => l_contact_rel_details.date_end
      ,p_personal_flag                => l_contact_rel_details.personal_flag
      ,p_last_name                    => l_contact_person_details.last_name
      ,p_sex                          => l_contact_person_details.sex
      ,p_date_of_birth                => l_contact_person_details.date_of_birth
      ,p_email_address                => l_contact_person_details.email_address
      ,p_first_name                   => l_contact_person_details.first_name
      ,p_known_as                     => l_contact_person_details.known_as
      ,p_marital_status               => l_contact_person_details.marital_status
      ,p_middle_names                 => l_contact_person_details.middle_names
      ,p_nationality                  => l_contact_person_details.nationality
      ,p_national_identifier          => l_contact_person_details.national_identifier
      ,p_previous_last_name           => l_contact_person_details.previous_last_name
      ,p_title                        => l_contact_person_details.title
      ,p_work_telephone               => l_contact_person_details.work_telephone
      ,p_correspondence_language      => l_contact_person_details.correspondence_language
      ,p_honors                       => l_contact_person_details.honors
      ,p_pre_name_adjunct             => l_contact_person_details.pre_name_adjunct
      ,p_suffix                       => l_contact_person_details.suffix
      ,p_create_mirror_flag           => 'N'
      ,p_contact_relationship_id      => l_host_ctr_id
      ,p_ctr_object_version_number    => l_host_ctr_ovn
      ,p_per_person_id                => l_host_contact_person_id
      ,p_per_object_version_number    => l_host_contact_per_ovn
      ,p_per_effective_start_date     => l_host_contact_per_esd
      ,p_per_effective_end_date       => l_host_contact_per_eed
      ,p_full_name                    => l_host_contact_full_name
      ,p_per_comment_id               => l_host_contact_per_comment_id
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
       );
    --
    -- Now store the contact person_ids from home and host for checking in next loop
    --
    --
    hr_utility.set_location(l_proc,140);
    --
    l_contact_created.home_contact_person_id := l_contact_rel_details.contact_person_id;
    l_contact_created.host_contact_person_id := l_host_contact_person_id;
    l_contacts_created.EXTEND;
    l_contacts_created(l_contacts_created.LAST) := l_contact_created;
    --
  end loop contacts;
  --
  -- Create EITs in host BG
  --
  for l_dpl_eit_rec in csr_dpl_eits(p_person_deployment_id) loop
    --
    hr_utility.set_location(l_proc,150);
    --
    -- Fetch details of EIT from home BG
    open csr_eit_details(l_dpl_eit_rec.person_extra_info_id);
    fetch csr_eit_details into l_eit_details;
    close csr_eit_details;
    --
    hr_person_extra_info_api.create_person_extra_info
      (p_validate                      => p_validate
      ,p_person_id                     => l_host_person_id
      ,p_information_type              => l_eit_details.information_type
      ,p_pei_information_category      => l_eit_details.pei_information_category
      ,p_pei_information1              => l_eit_details.pei_information1
      ,p_pei_information2              => l_eit_details.pei_information2
      ,p_pei_information3              => l_eit_details.pei_information3
      ,p_pei_information4              => l_eit_details.pei_information4
      ,p_pei_information5              => l_eit_details.pei_information5
      ,p_pei_information6              => l_eit_details.pei_information6
      ,p_pei_information7              => l_eit_details.pei_information7
      ,p_pei_information8              => l_eit_details.pei_information8
      ,p_pei_information9              => l_eit_details.pei_information9
      ,p_pei_information10             => l_eit_details.pei_information10
      ,p_pei_information11             => l_eit_details.pei_information11
      ,p_pei_information12             => l_eit_details.pei_information12
      ,p_pei_information13             => l_eit_details.pei_information13
      ,p_pei_information14             => l_eit_details.pei_information14
      ,p_pei_information15             => l_eit_details.pei_information15
      ,p_pei_information16             => l_eit_details.pei_information16
      ,p_pei_information17             => l_eit_details.pei_information17
      ,p_pei_information18             => l_eit_details.pei_information18
      ,p_pei_information19             => l_eit_details.pei_information19
      ,p_pei_information20             => l_eit_details.pei_information20
      ,p_pei_information21             => l_eit_details.pei_information21
      ,p_pei_information22             => l_eit_details.pei_information22
      ,p_pei_information23             => l_eit_details.pei_information23
      ,p_pei_information24             => l_eit_details.pei_information24
      ,p_pei_information25             => l_eit_details.pei_information25
      ,p_pei_information26             => l_eit_details.pei_information26
      ,p_pei_information27             => l_eit_details.pei_information27
      ,p_pei_information28             => l_eit_details.pei_information28
      ,p_pei_information29             => l_eit_details.pei_information29
      ,p_pei_information30             => l_eit_details.pei_information30
      ,p_person_extra_info_id          => l_host_person_extra_info_id
      ,p_object_version_number         => l_host_pei_ovn
       );
  end loop;
  hr_utility.set_location(l_proc,180);
  --
  -- update the proposal with the new details to keep it up to date
  --
  if nvl(l_dpl_rec.permanent,'N') = 'Y' then
    --
    hr_utility.set_location(l_proc,190);
    --
    hr_person_deployment_api.update_person_deployment
      (p_validate                      => p_validate
      ,p_person_deployment_id          => p_person_deployment_id
      ,p_object_version_number         => p_object_version_number
      ,p_to_person_id                  => l_host_person_id
      ,p_status                        => 'COMPLETE'
      ,p_policy_duration_warning       => l_policy_duration_warning
       );
  else
    --
    hr_utility.set_location(l_proc,200);
    --
    hr_person_deployment_api.update_person_deployment
      (p_validate                      => p_validate
      ,p_person_deployment_id          => p_person_deployment_id
      ,p_object_version_number         => p_object_version_number
      ,p_to_person_id                  => l_host_person_id
      ,p_status                        => 'ACTIVE'
      ,p_policy_duration_warning       => l_policy_duration_warning
       );
  end if;
  --
  hr_dflex_utility.remove_ignore_df_validation;
  --
  --
  -- Raise Workflow Business Event....to be implemented in a later phase
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_host_person_id                     := l_host_person_id;
  p_host_per_ovn                       := l_host_per_ovn;
  p_host_assignment_id                 := l_host_assignment_id;
  p_host_asg_ovn                       := l_host_asg_ovn;
  p_already_applicant_warning          := l_already_applicant_warning;
  --
  --
  -- fix for bug 6593649
 open csr_get_attached_doc;
  fetch csr_get_attached_doc into l_attachments;
  if csr_get_attached_doc%found then
	  close csr_get_attached_doc;
          hr_utility.set_location(l_host_person_id,200);

	update fnd_attached_documents
	set ENTITY_NAME='PER_PEOPLE_F' ,PK1_VALUE =l_host_person_id
	WHERE PK1_VALUE=p_person_deployment_id
	and ENTITY_NAME ='HR_PERSON_DEPLOYMENTS' ;

  else
	 hr_utility.set_location(l_host_person_id,220);
	 close csr_get_attached_doc;
  end if;
--
-- fix for bug 6593649
--
  per_per_bus.g_global_transfer_in_process := false;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 700);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to initiate_deployment;
    --
    hr_dflex_utility.remove_ignore_df_validation;
    --
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number              := l_object_version_number;
    p_host_person_id                     := null;
    p_host_per_ovn                       := null;
    p_host_assignment_id                 := null;
    p_host_asg_ovn                       := null;
    p_already_applicant_warning          := null;
    --
    per_per_bus.g_global_transfer_in_process := false;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 800);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to initiate_deployment;
    --
    hr_dflex_utility.remove_ignore_df_validation;
    --
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number              := l_object_version_number;
    p_host_person_id                     := null;
    p_host_per_ovn                       := null;
    p_host_assignment_id                 := null;
    p_host_asg_ovn                       := null;
    p_already_applicant_warning          := null;
    --
    per_per_bus.g_global_transfer_in_process := false;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 900);
    raise;
end initiate_deployment;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< change_deployment_dates >---------------------|
-- ----------------------------------------------------------------------------
--
procedure change_deployment_dates
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_start_date                    in     date       default hr_api.g_date
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_deplymt_policy_id             in     number     default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'change_deployment_dates';
  --
  l_object_version_number   number;
  l_start_date_in           date;
  l_end_date_in             date;
  l_policy_duration_warning  boolean;
  l_dummy               number;
  l_warn_ee             varchar2(1);
  --
  l_cagr_grade_def_id          number;
  l_cagr_concatenated_segments varchar2(2000);
  l_concatenated_segments      hr_soft_coding_keyflex.concatenated_segments%type;
  l_soft_coding_keyflex_id     number;
  l_comment_id                 number;
  l_host_asg_esd               date;
  l_host_asg_eed               date;
  l_no_managers_warning        boolean;
  l_other_manager_warning      boolean;
  l_hourly_salaried_warning    boolean;
  l_gsp_post_process_warning   varchar2(2000);
  --
  l_varray_d hr_dflex_utility.l_ignore_dfcode_varray
          := hr_dflex_utility.l_ignore_dfcode_varray();

  cursor csr_person_deployment(p_person_deployment_id number) is
  select *
  from  hr_person_deployments dpl
  where dpl.person_deployment_id = p_person_deployment_id;
  --
  l_dpl_rec    csr_person_deployment%rowtype;
  --
  cursor csr_susp_home_asgs(p_person_deployment_id number) is
  select paaf.assignment_id, paaf.effective_start_date
  from   per_all_assignments_f paaf,
         per_assignment_status_types past
  where  paaf.person_id = L_DPL_REC.FROM_PERSON_ID
  and    paaf.effective_start_date = L_DPL_REC.START_DATE
  and    paaf.assignment_status_type_id = past.assignment_status_type_id
  and    past.per_system_status = 'SUSP_ASSIGN';
  --
  cursor csr_overlap_asg_update
         (p_assignment_id number, p_old_date date, p_new_date date) is
  select 1
  from   per_all_assignments_f paaf
  where  paaf.assignment_id = p_assignment_id
  and    paaf.effective_end_date = p_old_date-1
  and    paaf.effective_start_date >= p_new_date;
  --
  cursor csr_host_assignments(p_start_date date) is
  select asg.assignment_id,asg.object_version_number,asg.effective_start_date
  from   per_all_assignments_f asg,
         hr_person_deployments pdt,
         per_periods_of_service pds
  where  asg.person_id = pdt.to_person_id
  and    pdt.person_deployment_id = p_person_deployment_id
  and    asg.period_of_service_id = pds.period_of_service_id
  and    pds.date_start = p_start_date
  and    trunc(sysdate) between asg.effective_start_date and
         asg.effective_end_date;

  -- Commented for bug 5636625
  -- and    asg.projected_assignment_end is not null;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint change_deployment_dates;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date_in := trunc(p_start_date);
  l_end_date_in := trunc(p_end_date);
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Validation in addition to Row Handlers
  --
  open csr_person_deployment(p_person_deployment_id);
  fetch csr_person_deployment into l_dpl_rec;
  if csr_person_deployment%notfound then
    close csr_person_deployment;
    fnd_message.set_name('PER','HR_449609_DPL_NOT_EXIST');
    fnd_message.raise_error;
  else
    close csr_person_deployment;
    --
    hr_utility.set_location(l_proc,30);
    --
  end if;
  --
  if l_dpl_rec.status = 'DRAFT' then
    fnd_message.set_name('PER','HR_449619_PDT_DRAFT_NO_CHG');
    fnd_message.raise_error;
  elsif l_dpl_rec.status = 'COMPLETE' then
    fnd_message.set_name('PER','HR_449620_PDT_COMPLETE_NO_CHG');
    fnd_message.raise_error;
  end if;
  --
  -- Added Bipul
  if (l_dpl_rec.status = 'ACTIVE' and
      l_end_date_in is not null
      and l_end_date_in < trunc(sysdate)) then
  fnd_message.set_name('PER','HR_449772_PDT_INV_END_DATE');
  fnd_message.raise_error;
  end if;


  hr_utility.set_location(l_proc,40);
  --
  if nvl(l_start_date_in,l_dpl_rec.start_date) >=
     nvl(l_end_date_in,l_dpl_rec.end_date) then
    fnd_message.set_name('PER','HR_449621_PDT_CHG_DATES');
    fnd_message.raise_error;
  end if;
  --
  if nvl(l_dpl_rec.permanent,'N') = 'Y' then
    fnd_message.set_name('PER','HR_449622_PDT_PERM_NO_CHG');
    fnd_message.raise_error;
  end if;
  --
  -- Process Logic
  --
  if ((nvl(l_start_date_in,hr_api.g_date) <> hr_api.g_date)
  OR (l_end_date_in is null and l_dpl_rec.end_date is not null)
  OR (l_end_date_in <> hr_api.g_date)) then
    --
    -- At least one date has changed, proceed according to which one changed
    --

    if nvl(l_start_date_in,hr_api.g_date) = hr_api.g_date then
       --
       hr_utility.set_location(l_proc,50);
       --
       --start date the same
	l_start_date_in := l_dpl_rec.start_date;
    else
       --
       hr_utility.set_location(l_proc,60);
       --
       --start date changed
      hr_change_start_date_api.update_start_date
	(p_validate                      => p_validate
	,p_person_id                     => l_dpl_rec.to_person_id
	,p_old_start_date                => l_dpl_rec.start_date
	,p_new_start_date                => l_start_date_in
	,p_update_type                   => 'E'
	,p_applicant_number              => null
	,p_warn_ee                       => l_warn_ee
	 );
      --
      for l_asg in csr_susp_home_asgs(p_person_deployment_id) loop
	--
	hr_utility.set_location(l_proc,70);
        hr_utility.set_location('assignment id '||l_asg.assignment_id,71);
	--
	open csr_overlap_asg_update
                (l_asg.assignment_id,l_dpl_rec.start_date,l_start_date_in);
	fetch csr_overlap_asg_update into l_dummy;
	if csr_overlap_asg_update%notfound then
	  --
	  update per_all_assignments_f paaf
	  set    paaf.effective_start_date = l_start_date_in
	  where  paaf.assignment_id = l_asg.assignment_id
	  and    paaf.effective_start_date = l_dpl_rec.start_date;
	  --
	  update per_all_assignments_f paaf
	  set    paaf.effective_end_date = l_start_date_in-1
	  where  paaf.assignment_id = l_asg.assignment_id
	  and    paaf.effective_end_date = l_dpl_rec.start_date-1;
	  --
	  close csr_overlap_asg_update;
	else
	  close csr_overlap_asg_update;
	  fnd_message.set_name('PER','HR_449623_PDT_CHG_ASG_OVERLAP');
	  fnd_message.raise_error;
	end if;
	--
      end loop;
    end if;
    --
    -- Bug 5635350 modified the following if condition
--  if l_end_date_in = hr_api.g_date then
     if l_end_date_in = hr_api.g_date or l_end_date_in = l_dpl_rec.end_date then
	--
	hr_utility.set_location(l_proc,80);
	--
	--end date the same
	l_end_date_in := l_dpl_rec.end_date;
    else
      --
      hr_utility.set_location(l_proc,90);
      --
      -- The end date has changed, this is simply an update to projected asg end in host
      -- If start_date also moved later than sysdate we have to do correction instead

       l_varray_d.delete;
       l_varray_d.extend(1);
       l_varray_d(1):='PER_ASSIGNMENTS';
       hr_dflex_utility.create_ignore_df_validation(p_rec=>l_varray_d);

      for l_host in csr_host_assignments(l_start_date_in) loop
         --
       --  if l_start_date_in < trunc(sysdate) then
         if l_host.effective_start_date < trunc(sysdate) then
           --
           -- Start date is
           --
	   hr_assignment_api.update_emp_asg
	     (p_validate                     => p_validate
	     ,p_effective_date               => trunc(sysdate)
	     ,p_datetrack_update_mode        => 'UPDATE'
	     ,p_assignment_id                => l_host.assignment_id
	     ,p_object_version_number        => l_host.object_version_number
	     ,p_projected_assignment_end     => l_end_date_in
	     ,p_cagr_grade_def_id            => l_cagr_grade_def_id
	     ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
	     ,p_concatenated_segments        => l_concatenated_segments
	     ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
	     ,p_comment_id                   => l_comment_id
	     ,p_effective_start_date         => l_host_asg_esd
	     ,p_effective_end_date           => l_host_asg_eed
	     ,p_no_managers_warning          => l_no_managers_warning
	     ,p_other_manager_warning        => l_other_manager_warning
	     ,p_hourly_salaried_warning      => l_hourly_salaried_warning
	     ,p_gsp_post_process_warning     => l_gsp_post_process_warning
	     );
         else
	   hr_assignment_api.update_emp_asg
	     (p_validate                     => p_validate
	     ,p_effective_date               => trunc(sysdate)
	     ,p_datetrack_update_mode        => 'CORRECTION'
	     ,p_assignment_id                => l_host.assignment_id
	     ,p_object_version_number        => l_host.object_version_number
	     ,p_projected_assignment_end     => l_end_date_in
	     ,p_cagr_grade_def_id            => l_cagr_grade_def_id
	     ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
	     ,p_concatenated_segments        => l_concatenated_segments
	     ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
	     ,p_comment_id                   => l_comment_id
	     ,p_effective_start_date         => l_host_asg_esd
	     ,p_effective_end_date           => l_host_asg_eed
	     ,p_no_managers_warning          => l_no_managers_warning
	     ,p_other_manager_warning        => l_other_manager_warning
	     ,p_hourly_salaried_warning      => l_hourly_salaried_warning
	     ,p_gsp_post_process_warning     => l_gsp_post_process_warning
	     );
         end if;
          --
      end loop;
    end if;

    hr_dflex_utility.remove_ignore_df_validation;
    --
    -- update the proposal with the new details to keep it up to date
    --
    hr_utility.set_location(l_proc,100);
    --
    hr_person_deployment_api.update_person_deployment
      (p_validate                      => p_validate
      ,p_person_deployment_id          => p_person_deployment_id
      ,p_object_version_number         => p_object_version_number
      ,p_start_date                    => l_start_date_in
      ,p_end_date                      => l_end_date_in
      ,p_policy_duration_warning       => l_policy_duration_warning
       );
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 700);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to change_deployment_dates;
    hr_dflex_utility.remove_ignore_df_validation;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 800);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to change_deployment_dates;
    hr_dflex_utility.remove_ignore_df_validation;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 900);
    raise;
end change_deployment_dates;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< return_from_deployment >----------------------|
-- ----------------------------------------------------------------------------
--
procedure return_from_deployment
  (p_validate                      in     boolean    default false
  ,p_person_deployment_id          in     number
  ,p_object_version_number         in out nocopy     number
  ,p_end_date                      in     date       default hr_api.g_date
  ,p_leaving_reason                in     varchar2   default hr_api.g_varchar2
  ,p_leaving_person_type_id        in     number     default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'return_from_deployment';
  l_object_version_number  number;
  --
  l_end_date_in       date;
  l_leaving_reason    varchar2(30);
  l_leaving_person_type_id   number;
  l_home_assignment_id    number;
  l_home_asg_ovn          number;
  l_home_asg_esd          date;
  l_home_asg_eed          date;
  l_host_pds_id           number;
  l_host_pds_ovn          number;
  --
  l_policy_duration_warning      boolean;
  l_last_std_process_date_out    date;
  l_supervisor_warning           boolean;
  l_event_warning                boolean;
  l_interview_warning            boolean;
  l_review_warning               boolean;
  l_recruiter_warning            boolean;
  l_asg_future_changes_warning   boolean;
  l_entries_changed_warning      varchar2(1);
  l_pay_proposal_warning         boolean;
  l_dod_warning                  boolean;
  --
  cursor csr_person_deployment(p_person_deployment_id number) is
  select *
  from  hr_person_deployments dpl
  where dpl.person_deployment_id = p_person_deployment_id;
  --
  l_dpl_rec    csr_person_deployment%rowtype;
  --
  cursor csr_host_pds(p_person_id number) is
  select pds.period_of_service_id, pds.object_version_number
  from   per_periods_of_service pds
  where  pds.person_id = p_person_id
  and    pds.date_start = L_DPL_REC.START_DATE;
  --
  -- following cursor needs to get the assignments which were suspended in line with
  -- start of deployment, but ignore others
  --
  cursor csr_susp_home_asgs(p_person_id number) is
  select paaf.assignment_id, paaf.object_version_number
  from   per_all_assignments_f paaf,
         per_assignment_status_types past
  where  paaf.person_id = p_person_id
  and    L_END_DATE_IN between
         paaf.effective_start_date and paaf.effective_end_date
  and    paaf.assignment_type = 'E'
  and    paaf.assignment_status_type_id = past.assignment_status_type_id
  and    past.per_system_status = 'SUSP_ASSIGN'
  and exists
            (select 1
             from   per_all_assignments_f paaf1,
                    per_assignment_status_types past1
             where  paaf1.assignment_id = paaf.assignment_id
             and    paaf1.effective_start_date = L_DPL_REC.START_DATE
             and    paaf1.assignment_status_type_id = past1.assignment_status_type_id
             and    past1.per_system_status = 'SUSP_ASSIGN')
  and exists
            (select 1
             from   per_all_assignments_f paaf2,
                    per_assignment_status_types past2
             where  paaf2.assignment_id = paaf.assignment_id
             and    paaf2.effective_end_date = L_DPL_REC.START_DATE-1
             and    paaf2.assignment_status_type_id = past2.assignment_status_type_id
             and    past2.per_system_status = 'ACTIVE_ASSIGN');
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint return_from_deployment;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_end_date_in := trunc(p_end_date);
  --
  -- Validation in addition to Row Handlers
  --
  open csr_person_deployment(p_person_deployment_id);
  fetch csr_person_deployment into l_dpl_rec;
  if csr_person_deployment%notfound then
    close csr_person_deployment;
    fnd_message.set_name('PER','HR_449609_DPL_NOT_EXIST');
    fnd_message.raise_error;
  else
    close csr_person_deployment;
    --
    hr_utility.set_location(l_proc,20);
    --
  end if;
  --
  if l_dpl_rec.status = 'DRAFT' then
    fnd_message.set_name('PER','HR_449624_PDT_DRAFT_NO_END');
    fnd_message.raise_error;
  elsif l_dpl_rec.status = 'COMPLETE' then
    fnd_message.set_name('PER','HR_449625_PDT_COMPLETE_NO_END');
    fnd_message.raise_error;
  end if;
  --
  if l_dpl_rec.start_date > nvl(l_end_date_in,l_dpl_rec.end_date) then
    fnd_message.set_name('PER','HR_449621_PDT_CHG_DATES');
    fnd_message.raise_error;
  end if;
  --
  if nvl(l_dpl_rec.permanent,'N') = 'Y' then
    fnd_message.set_name('PER','HR_449626_PDT_PERM_NO_END');
    fnd_message.raise_error;
  end if;
  --
  -- Process Logic
  --
  l_leaving_reason := p_leaving_reason;
  l_leaving_person_type_id :=  p_leaving_person_type_id;
  --
  if nvl(l_end_date_in,hr_api.g_date) = hr_api.g_date then
     hr_utility.set_location(l_proc,30);
     l_end_date_in := l_dpl_rec.end_date;
  end if;
  --
  if nvl(l_leaving_reason,hr_api.g_varchar2) = hr_api.g_varchar2 then
     hr_utility.set_location(l_proc,40);
     l_leaving_reason := l_dpl_rec.leaving_reason;
  end if;
  --
  if nvl(l_leaving_person_type_id,hr_api.g_number) = hr_api.g_number then
     hr_utility.set_location(l_proc,50);
     l_leaving_person_type_id := l_dpl_rec.leaving_person_type_id;
  end if;

    hr_person_deployment_api.update_person_deployment
    (p_validate                      => p_validate
    ,p_person_deployment_id          => p_person_deployment_id
    ,p_object_version_number         => p_object_version_number
    ,p_end_date                      => l_end_date_in
    ,p_status                        => 'COMPLETE'
    ,p_leaving_reason                => l_leaving_reason
    ,p_leaving_person_type_id        => l_leaving_person_type_id
    ,p_policy_duration_warning       => l_policy_duration_warning
     );

  --
  -- Terminate the host employment
  --
  open csr_host_pds(l_dpl_rec.to_person_id);
  fetch csr_host_pds into l_host_pds_id,l_host_pds_ovn;
  close csr_host_pds;
  --
  hr_utility.set_location(l_proc,60);
  --
  hr_ex_employee_api.actual_termination_emp
    (p_validate                     => p_validate
    ,p_effective_date               => l_end_date_in
    ,p_period_of_service_id         => l_host_pds_id
    ,p_object_version_number        => l_host_pds_ovn
    ,p_actual_termination_date      => l_end_date_in
    ,p_person_type_id               => l_leaving_person_type_id
    ,p_leaving_reason               => l_leaving_reason

  -- Changed for bug 5512320
    ,p_last_standard_process_date   => null
    ,p_last_std_process_date_out    => l_last_std_process_date_out

    ,p_supervisor_warning           => l_supervisor_warning
    ,p_event_warning                => l_event_warning
    ,p_interview_warning            => l_interview_warning
    ,p_review_warning               => l_review_warning
    ,p_recruiter_warning            => l_recruiter_warning
    ,p_asg_future_changes_warning   => l_asg_future_changes_warning
    ,p_entries_changed_warning      => l_entries_changed_warning
    ,p_pay_proposal_warning         => l_pay_proposal_warning
    ,p_dod_warning                  => l_dod_warning
     );
  --
  -- Reactivate the suspended home assignments
  --
  for l_asg_rec in csr_susp_home_asgs(l_dpl_rec.from_person_id) loop
    --
    hr_utility.set_location(l_proc,70);
    hr_utility.set_location('assignment_id '||l_asg_rec.assignment_id,71);
    --
    hr_assignment_api.activate_emp_asg
      (p_validate                     => p_validate
      ,p_effective_date               => l_end_date_in+1
      ,p_datetrack_update_mode        => 'UPDATE'
      ,p_assignment_id                => l_asg_rec.assignment_id
      ,p_change_reason                => null
      ,p_object_version_number        => l_asg_rec.object_version_number
      ,p_assignment_status_type_id    => null  --null causes it to be set to default
      ,p_effective_start_date         => l_home_asg_esd
      ,p_effective_end_date           => l_home_asg_eed
       );
   end loop;
  --
  -- update the proposal with the new details to keep it up to date
  --
  hr_utility.set_location(l_proc,80);
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  hr_utility.set_location(' Leaving:'||l_proc, 700);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to return_from_deployment;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 800);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to return_from_deployment;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 900);
    raise;
end return_from_deployment;
--
end HR_PERSON_DEPLOYMENT_API;

/
