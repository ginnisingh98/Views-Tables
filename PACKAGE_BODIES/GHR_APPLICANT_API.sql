--------------------------------------------------------
--  DDL for Package Body GHR_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_APPLICANT_API" as
/* $Header: ghappapi.pkb 120.0.12010000.1 2009/05/25 12:03:36 utokachi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ghr_applicant_api.';
--
-- ---------------------------------------------------------------------------
-- |--------------------------< create_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_applicant
  (p_validate                     in     boolean  default false
  ,p_date_received                in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_person_type_id               in     number   default null
  ,p_applicant_number             in out nocopy  varchar2
  ,p_per_comments                 in     varchar2 default null
  ,p_date_employee_data_verified  in     date     default null
  ,p_date_of_birth                in     date     default null
  ,p_email_address                in     varchar2 default null
  ,p_expense_check_send_to_addres in     varchar2 default null
  ,p_first_name                   in     varchar2 default null
  ,p_known_as                     in     varchar2 default null
  ,p_marital_status               in     varchar2 default null
  ,p_middle_names                 in     varchar2 default null
  ,p_nationality                  in     varchar2 default null
  ,p_national_identifier          in     varchar2 default null
  ,p_previous_last_name           in     varchar2 default null
  ,p_registered_disabled_flag     in     varchar2 default null
  ,p_sex                          in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_work_telephone               in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_attribute21                  in     varchar2 default null
  ,p_attribute22                  in     varchar2 default null
  ,p_attribute23                  in     varchar2 default null
  ,p_attribute24                  in     varchar2 default null
  ,p_attribute25                  in     varchar2 default null
  ,p_attribute26                  in     varchar2 default null
  ,p_attribute27                  in     varchar2 default null
  ,p_attribute28                  in     varchar2 default null
  ,p_attribute29                  in     varchar2 default null
  ,p_attribute30                  in     varchar2 default null
  ,p_per_information_category     in     varchar2 default null -- Obsolete parameter, do not use
  ,p_per_information1             in     varchar2 default null
  ,p_per_information2             in     varchar2 default null
  ,p_per_information3             in     varchar2 default null
  ,p_per_information4             in     varchar2 default null
  ,p_per_information5             in     varchar2 default null
  ,p_per_information6             in     varchar2 default null
  ,p_per_information7             in     varchar2 default null
  ,p_per_information8             in     varchar2 default null
  ,p_per_information9             in     varchar2 default null
  ,p_per_information10            in     varchar2 default null
  ,p_per_information11            in     varchar2 default null
  ,p_per_information12            in     varchar2 default null
  ,p_per_information13            in     varchar2 default null
  ,p_per_information14            in     varchar2 default null
  ,p_per_information15            in     varchar2 default null
  ,p_per_information16            in     varchar2 default null
  ,p_per_information17            in     varchar2 default null
  ,p_per_information18            in     varchar2 default null
  ,p_per_information19            in     varchar2 default null
  ,p_per_information20            in     varchar2 default null
  ,p_per_information21            in     varchar2 default null
  ,p_per_information22            in     varchar2 default null
  ,p_per_information23            in     varchar2 default null
  ,p_per_information24            in     varchar2 default null
  ,p_per_information25            in     varchar2 default null
  ,p_per_information26            in     varchar2 default null
  ,p_per_information27            in     varchar2 default null
  ,p_per_information28            in     varchar2 default null
  ,p_per_information29            in     varchar2 default null
  ,p_per_information30            in     varchar2 default null
  ,p_background_check_status      in     varchar2 default null
  ,p_background_date_check        in     date     default null
  ,p_correspondence_language      in     varchar2 default null
  ,p_fte_capacity                 in     number   default null
  ,p_hold_applicant_date_until    in     date     default null
  ,p_honors                       in     varchar2 default null
  ,p_mailstop                     in     varchar2 default null
  ,p_office_number                in     varchar2 default null
  ,p_pre_name_adjunct             in     varchar2 default null
  ,p_projected_start_date         in     date     default null
  ,p_resume_exists                in     varchar2 default null
  ,p_resume_last_updated          in     date     default null
  ,p_work_schedule                in     varchar2 default null
  ,p_suffix                       in     varchar2 default null
  ,p_person_id                       out nocopy  number
  ,p_assignment_id                   out nocopy number
  ,p_application_id                  out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_apl_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_name_combination_warning        out nocopy boolean
  ,p_orig_hire_warning               out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'create_applicant';
  l_date_received           per_applications.date_received%TYPE;
  l_applicant_number        per_people_f.applicant_number%TYPE;
  l_person_type_id          per_people_f.person_type_id%TYPE;
  l_person_id               per_people_f.person_id%TYPE;
  l_application_id          per_applications.application_id%TYPE;
  l_assignment_id           per_assignments_f.assignment_id%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
    savepoint ghr_create_applicant;
  --
  -- Initialise local variables
  --
  l_date_received       := trunc(p_date_received);
  l_applicant_number    := p_applicant_number;
  --
  hr_utility.set_location(l_proc, 10);
  --

  ghr_Session.set_session_var_for_core
  (p_effective_date    =>  l_date_received
  );
  --

   hr_applicant_api.create_applicant
              (p_date_received                => p_date_received
              ,p_business_group_id            => p_business_group_id
              ,p_person_type_id               => p_person_type_id
              ,p_last_name                    => p_last_name
              ,p_applicant_number             => l_applicant_number
              ,p_per_comments                 => p_per_comments
              ,p_date_employee_data_verified  => trunc(p_date_employee_data_verified)
              ,p_date_of_birth                => trunc(p_date_of_birth)
              ,p_email_address                => p_email_address
              ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
              ,p_first_name                   => p_first_name
              ,p_known_as                     => p_known_as
              ,p_marital_status               => p_marital_status
              ,p_middle_names                 => p_middle_names
              ,p_nationality                  => p_nationality
              ,p_national_identifier          => p_national_identifier
              ,p_previous_last_name           => p_previous_last_name
              ,p_registered_disabled_flag     => p_registered_disabled_flag
              ,p_sex                          => p_sex
              ,p_title                        => p_title
              ,p_work_telephone               => p_work_telephone
              ,p_attribute_category           => p_attribute_category
              ,p_attribute1                   => p_attribute1
              ,p_attribute2                   => p_attribute2
              ,p_attribute3                   => p_attribute3
              ,p_attribute4                   => p_attribute4
              ,p_attribute5                   => p_attribute5
              ,p_attribute6                   => p_attribute6
              ,p_attribute7                   => p_attribute7
              ,p_attribute8                   => p_attribute8
              ,p_attribute9                   => p_attribute9
              ,p_attribute10                  => p_attribute10
              ,p_attribute11                  => p_attribute11
              ,p_attribute12                  => p_attribute12
              ,p_attribute13                  => p_attribute13
              ,p_attribute14                  => p_attribute14
              ,p_attribute15                  => p_attribute15
              ,p_attribute16                  => p_attribute16
              ,p_attribute17                  => p_attribute17
              ,p_attribute18                  => p_attribute18
              ,p_attribute19                  => p_attribute19
              ,p_attribute20                  => p_attribute20
              ,p_attribute21                  => p_attribute21
              ,p_attribute22                  => p_attribute22
              ,p_attribute23                  => p_attribute23
              ,p_attribute24                  => p_attribute24
              ,p_attribute25                  => p_attribute25
              ,p_attribute26                  => p_attribute26
              ,p_attribute27                  => p_attribute27
              ,p_attribute28                  => p_attribute28
              ,p_attribute29                  => p_attribute29
              ,p_attribute30                  => p_attribute30
              ,p_per_information_category     => p_per_information_category
              ,p_per_information1             => p_per_information1
              ,p_per_information2             => p_per_information2
              ,p_per_information3             => p_per_information3
              ,p_per_information4             => p_per_information4
              ,p_per_information5             => p_per_information5
              ,p_per_information6             => p_per_information6
              ,p_per_information7             => p_per_information7
              ,p_per_information8             => p_per_information8
              ,p_per_information9             => p_per_information9
              ,p_per_information10            => p_per_information10
              ,p_per_information11            => p_per_information11
              ,p_per_information12            => p_per_information12
              ,p_per_information13            => p_per_information13
              ,p_per_information14            => p_per_information14
              ,p_per_information15            => p_per_information15
              ,p_per_information16            => p_per_information16
              ,p_per_information17            => p_per_information17
              ,p_per_information18            => p_per_information18
              ,p_per_information19            => p_per_information19
              ,p_per_information20            => p_per_information20
              ,p_per_information21            => p_per_information21
              ,p_per_information22            => p_per_information22
              ,p_per_information23            => p_per_information23
              ,p_per_information24            => p_per_information24
              ,p_per_information25            => p_per_information25
              ,p_per_information26            => p_per_information26
              ,p_per_information27            => p_per_information27
              ,p_per_information28            => p_per_information28
              ,p_per_information29            => p_per_information29
              ,p_per_information30            => p_per_information30
              ,p_background_check_status      => p_background_check_status
              ,p_background_date_check        => p_background_date_check
              ,p_correspondence_language      => p_correspondence_language
              ,p_fte_capacity                 => p_fte_capacity
  	        ,p_hold_applicant_date_until    => p_hold_applicant_date_until
              ,p_honors                       => p_honors
              ,p_mailstop                     => p_mailstop
              ,p_office_number                => p_office_number
              ,p_pre_name_adjunct             => p_pre_name_adjunct
              ,p_projected_start_date         => p_projected_start_date
              ,p_resume_exists                => p_resume_exists
              ,p_resume_last_updated          => p_resume_last_updated
              ,p_work_schedule                => p_work_schedule
              ,p_suffix                       => p_suffix
              ,p_validate                     => FALSE
              ,p_person_id                    => l_person_id
              ,p_assignment_id                => l_assignment_id
              ,p_application_id               => l_application_id
              ,p_per_object_version_number    => p_per_object_version_number
              ,p_asg_object_version_number    => p_asg_object_version_number
              ,p_apl_object_version_number    => p_apl_object_version_number
              ,p_per_effective_start_date     => p_per_effective_start_date
              ,p_per_effective_end_date       => p_per_effective_end_date
              ,p_full_name                    => p_full_name
              ,p_per_comment_id               => p_per_comment_id
              ,p_assignment_sequence          => p_assignment_sequence
              ,p_name_combination_warning     => p_name_combination_warning
              ,p_orig_hire_warning            => p_orig_hire_warning
              );

  hr_utility.set_location(l_proc, 20);
  --
    ghr_history_api.post_update_process;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set id OUT parameters
  --
  p_person_id      := l_person_id;
  p_application_id := l_application_id;
  p_assignment_id  := l_assignment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ghr_create_applicant;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_applicant_number          := l_applicant_number;
    p_person_id                 := null;
    p_assignment_id             := null;
    p_application_id            := null;
    p_per_object_version_number := null;
    p_asg_object_version_number := null;
    p_apl_object_version_number := null;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_full_name                 := null;
    p_per_comment_id            := null;
    p_assignment_sequence       := null;

  when others then
     ROLLBACK TO ghr_create_applicant;
     raise;
    --
end create_applicant;
--
--
end ghr_applicant_api;

/
