--------------------------------------------------------
--  DDL for Package Body IRC_INTERVIEW_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_INTERVIEW_DETAILS_API" as
/* $Header: iriidapi.pkb 120.0.12010000.2 2010/04/07 09:55:12 vmummidi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  irc_interview_details_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_irc_interview_details >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_irc_interview_details
  (p_validate                      in     boolean  default false
  ,p_status                        in     varchar2  default hr_api.g_varchar2
  ,p_feedback                      in     varchar2  default hr_api.g_varchar2
  ,p_notes                         in     varchar2  default hr_api.g_varchar2
  ,p_notes_to_candidate            in     varchar2  default hr_api.g_varchar2
  ,p_category                      in     varchar2  default hr_api.g_varchar2
  ,p_result                        in     varchar2  default hr_api.g_varchar2
  ,p_iid_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_iid_information1              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information2              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information3              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information4              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information5              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information6              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information7              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information8              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information9              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information10             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information11             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information12             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information13             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information14             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information15             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information16             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information17             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information18             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information19             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information20             in     varchar2  default hr_api.g_varchar2
  ,p_event_id                      in     number
  ,p_interview_details_id            out nocopy   number
  ,p_object_version_number        out nocopy   number
  ,p_start_date                   out nocopy   date
  ,p_end_date                     out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                     varchar2(72) := g_package||'create_irc_interview_details';
  l_interview_details_id        number;
  l_object_version_number    number;
  l_start_date               date;
  l_end_date                 date;
  l_swi_package_name         varchar2(30) := 'IRC_INTERVIEW_DETAILS_SWI';
  l_effective_date               date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_irc_interview_details;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_interview_details_bk1.create_irc_interview_details_b
                 (p_status                    => p_status
                 ,p_feedback                  => p_feedback
                 ,p_notes                     => p_notes
		 ,p_notes_to_candidate        => p_notes_to_candidate
		 ,p_category                  => p_category
                 ,p_result                    => p_result
		 ,p_iid_information_category  => p_iid_information_category
		 ,p_iid_information1          => p_iid_information1
		 ,p_iid_information2          => p_iid_information2
		 ,p_iid_information3          => p_iid_information3
		 ,p_iid_information4          => p_iid_information4
		 ,p_iid_information5          => p_iid_information5
		 ,p_iid_information6          => p_iid_information6
		 ,p_iid_information7          => p_iid_information7
		 ,p_iid_information8          => p_iid_information8
		 ,p_iid_information9          => p_iid_information9
		 ,p_iid_information10         => p_iid_information10
		 ,p_iid_information11         => p_iid_information11
		 ,p_iid_information12         => p_iid_information12
		 ,p_iid_information13         => p_iid_information13
		 ,p_iid_information14         => p_iid_information14
		 ,p_iid_information15         => p_iid_information15
		 ,p_iid_information16         => p_iid_information16
		 ,p_iid_information17         => p_iid_information17
		 ,p_iid_information18         => p_iid_information18
		 ,p_iid_information19         => p_iid_information19
		 ,p_iid_information20         => p_iid_information20
                 ,p_event_id                  => p_event_id
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_irc_interview_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;

  irc_iid_ins.ins(p_effective_date            => l_effective_date
                 ,p_status                    => p_status
                 ,p_feedback                  => p_feedback
                 ,p_notes                     => p_notes
		 ,p_notes_to_candidate        => p_notes_to_candidate
		 ,p_category                  => p_category
                 ,p_result                    => p_result
		 ,p_iid_information_category  => p_iid_information_category
		 ,p_iid_information1          => p_iid_information1
		 ,p_iid_information2          => p_iid_information2
		 ,p_iid_information3          => p_iid_information3
		 ,p_iid_information4          => p_iid_information4
		 ,p_iid_information5          => p_iid_information5
		 ,p_iid_information6          => p_iid_information6
		 ,p_iid_information7          => p_iid_information7
		 ,p_iid_information8          => p_iid_information8
		 ,p_iid_information9          => p_iid_information9
		 ,p_iid_information10         => p_iid_information10
		 ,p_iid_information11         => p_iid_information11
		 ,p_iid_information12         => p_iid_information12
		 ,p_iid_information13         => p_iid_information13
		 ,p_iid_information14         => p_iid_information14
		 ,p_iid_information15         => p_iid_information15
		 ,p_iid_information16         => p_iid_information16
		 ,p_iid_information17         => p_iid_information17
		 ,p_iid_information18         => p_iid_information18
		 ,p_iid_information19         => p_iid_information19
		 ,p_iid_information20         => p_iid_information20
                 ,p_event_id                  => p_event_id
                 ,p_interview_details_id      => l_interview_details_id
                 ,p_object_version_number     => l_object_version_number
                 ,p_start_date                => l_start_date
                 ,p_end_date                  => l_end_date
                 );
  -- Call After Process User Hook
  --
  begin
    irc_interview_details_bk1.create_irc_interview_details_a
                 (p_interview_details_id      => l_interview_details_id
                 ,p_status                    => p_status
                 ,p_feedback                  => p_feedback
                 ,p_notes                     => p_notes
		 ,p_notes_to_candidate        => p_notes_to_candidate
		 ,p_category                  => p_category
                 ,p_result                    => p_result
		 ,p_iid_information_category  => p_iid_information_category
		 ,p_iid_information1          => p_iid_information1
		 ,p_iid_information2          => p_iid_information2
		 ,p_iid_information3          => p_iid_information3
		 ,p_iid_information4          => p_iid_information4
		 ,p_iid_information5          => p_iid_information5
		 ,p_iid_information6          => p_iid_information6
		 ,p_iid_information7          => p_iid_information7
		 ,p_iid_information8          => p_iid_information8
		 ,p_iid_information9          => p_iid_information9
		 ,p_iid_information10         => p_iid_information10
		 ,p_iid_information11         => p_iid_information11
		 ,p_iid_information12         => p_iid_information12
		 ,p_iid_information13         => p_iid_information13
		 ,p_iid_information14         => p_iid_information14
		 ,p_iid_information15         => p_iid_information15
		 ,p_iid_information16         => p_iid_information16
		 ,p_iid_information17         => p_iid_information17
		 ,p_iid_information18         => p_iid_information18
		 ,p_iid_information19         => p_iid_information19
		 ,p_iid_information20         => p_iid_information20
                 ,p_event_id                  => p_event_id
                 ,p_object_version_number     => l_object_version_number
                 ,p_start_date                => l_start_date
                 ,p_end_date                  => l_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_irc_interview_details'
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
  p_interview_details_id          := l_interview_details_id;
  p_object_version_number      := l_object_version_number;
  p_start_date                 := l_start_date;
  p_end_date                   := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_irc_interview_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_interview_details_id          := null;
    p_object_version_number      := null;
    p_start_date                 := null;
    p_end_date                   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_irc_interview_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_interview_details_id          := null;
    p_object_version_number      := null;
    p_start_date                 := null;
    p_end_date                   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_irc_interview_details;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_irc_interview_details >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_irc_interview_details
  (p_validate                      in     boolean  default false
  ,p_interview_details_id          in     number
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_feedback                      in     varchar2 default hr_api.g_varchar2
  ,p_notes                         in     varchar2 default hr_api.g_varchar2
  ,p_notes_to_candidate            in     varchar2  default hr_api.g_varchar2
  ,p_category                      in     varchar2  default hr_api.g_varchar2
  ,p_result                        in     varchar2  default hr_api.g_varchar2
  ,p_iid_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_iid_information1              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information2              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information3              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information4              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information5              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information6              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information7              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information8              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information9              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information10             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information11             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information12             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information13             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information14             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information15             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information16             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information17             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information18             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information19             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information20             in     varchar2  default hr_api.g_varchar2
  ,p_event_id                      in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_start_date               date;
  l_end_date                 date;
  l_effective_date               date;
  l_proc                         varchar2(72) := g_package||'update_irc_interview_details';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_irc_interview_details;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_interview_details_bk2.update_irc_interview_details_b
                 (p_interview_details_id         => p_interview_details_id
                 ,p_status                    => p_status
                 ,p_feedback                  => p_feedback
                 ,p_notes                     => p_notes
		 ,p_notes_to_candidate        => p_notes_to_candidate
		 ,p_category                  => p_category
                 ,p_result                    => p_result
		 ,p_iid_information_category  => p_iid_information_category
		 ,p_iid_information1          => p_iid_information1
		 ,p_iid_information2          => p_iid_information2
		 ,p_iid_information3          => p_iid_information3
		 ,p_iid_information4          => p_iid_information4
		 ,p_iid_information5          => p_iid_information5
		 ,p_iid_information6          => p_iid_information6
		 ,p_iid_information7          => p_iid_information7
		 ,p_iid_information8          => p_iid_information8
		 ,p_iid_information9          => p_iid_information9
		 ,p_iid_information10         => p_iid_information10
		 ,p_iid_information11         => p_iid_information11
		 ,p_iid_information12         => p_iid_information12
		 ,p_iid_information13         => p_iid_information13
		 ,p_iid_information14         => p_iid_information14
		 ,p_iid_information15         => p_iid_information15
		 ,p_iid_information16         => p_iid_information16
		 ,p_iid_information17         => p_iid_information17
		 ,p_iid_information18         => p_iid_information18
		 ,p_iid_information19         => p_iid_information19
		 ,p_iid_information20         => p_iid_information20
                 ,p_object_version_number     => p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_irc_interview_details'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  if p_interview_details_id is null then
    -- RAISE ERROR SAYING INVALID INTERVIEW_DETAILS_ID
    fnd_message.set_name('PER', 'IRC_INV_INT_DET_ID');
    fnd_message.raise_error;
  end if;
  irc_iid_upd.upd(p_effective_date            => l_effective_date
                 ,p_datetrack_mode            => 'UPDATE'
                 ,p_interview_details_id      => p_interview_details_id
                 ,p_object_version_number     => l_object_version_number
                 ,p_status                    => p_status
                 ,p_feedback                  => p_feedback
                 ,p_notes                     => p_notes
 		 ,p_notes_to_candidate        => p_notes_to_candidate
		 ,p_category                  => p_category
                 ,p_result                    => p_result
		 ,p_iid_information_category  => p_iid_information_category
		 ,p_iid_information1          => p_iid_information1
		 ,p_iid_information2          => p_iid_information2
		 ,p_iid_information3          => p_iid_information3
		 ,p_iid_information4          => p_iid_information4
		 ,p_iid_information5          => p_iid_information5
		 ,p_iid_information6          => p_iid_information6
		 ,p_iid_information7          => p_iid_information7
		 ,p_iid_information8          => p_iid_information8
		 ,p_iid_information9          => p_iid_information9
		 ,p_iid_information10         => p_iid_information10
		 ,p_iid_information11         => p_iid_information11
		 ,p_iid_information12         => p_iid_information12
		 ,p_iid_information13         => p_iid_information13
		 ,p_iid_information14         => p_iid_information14
		 ,p_iid_information15         => p_iid_information15
		 ,p_iid_information16         => p_iid_information16
		 ,p_iid_information17         => p_iid_information17
		 ,p_iid_information18         => p_iid_information18
		 ,p_iid_information19         => p_iid_information19
		 ,p_iid_information20         => p_iid_information20
                 ,p_event_id                  => p_event_id
                 ,p_start_date                => l_start_date
                 ,p_end_date                  => l_end_date
                 );
  --
  -- Call After Process User Hook
  --
  begin
    irc_interview_details_bk2.update_irc_interview_details_a
                 (p_interview_details_id         => p_interview_details_id
                 ,p_status                    => p_status
                 ,p_feedback                  => p_feedback
                 ,p_notes                     => p_notes
		 ,p_notes_to_candidate        => p_notes_to_candidate
		 ,p_category                  => p_category
                 ,p_result                    => p_result
		 ,p_iid_information_category  => p_iid_information_category
		 ,p_iid_information1          => p_iid_information1
		 ,p_iid_information2          => p_iid_information2
		 ,p_iid_information3          => p_iid_information3
		 ,p_iid_information4          => p_iid_information4
		 ,p_iid_information5          => p_iid_information5
		 ,p_iid_information6          => p_iid_information6
		 ,p_iid_information7          => p_iid_information7
		 ,p_iid_information8          => p_iid_information8
		 ,p_iid_information9          => p_iid_information9
		 ,p_iid_information10         => p_iid_information10
		 ,p_iid_information11         => p_iid_information11
		 ,p_iid_information12         => p_iid_information12
		 ,p_iid_information13         => p_iid_information13
		 ,p_iid_information14         => p_iid_information14
		 ,p_iid_information15         => p_iid_information15
		 ,p_iid_information16         => p_iid_information16
		 ,p_iid_information17         => p_iid_information17
		 ,p_iid_information18         => p_iid_information18
		 ,p_iid_information19         => p_iid_information19
		 ,p_iid_information20         => p_iid_information20
                 ,p_object_version_number     => p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_irc_interview_details'
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
  p_object_version_number := l_object_version_number;
  p_start_date            := l_start_date;
  p_end_date              := l_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_irc_interview_details;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date  := null;
    p_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_irc_interview_details;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date  := null;
    p_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_irc_interview_details;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_interview_details >--------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_interview_details
  (p_source_assignment_id in number
  ,p_target_assignment_id in number
  ,p_target_party_id      in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'copy_interview_details';
  --
  l_event_id per_events.event_id%type;
  l_event_ovn per_events.object_version_number%type;
  l_interview_details_id irc_interview_details.interview_details_id%type;
  --
  l_event_rec per_events%rowtype;
  l_interview_det_rec irc_interview_details%rowtype;
  --
  Cursor C_Sel1 is select irc_interview_details_s.nextval from sys.dual;
  --
  Cursor csr_event_rec (p_assignment_id per_events.assignment_id%type)
  is
  select *
  from per_events
  where assignment_id=p_assignment_id;
  --
  Cursor csr_interview_details(p_event_id irc_interview_details.event_id%type)
  is
  select *
  from irc_interview_details
  where event_id = p_event_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_interview_details;
  --
  --
  -- Process Logic
  --
  --
  FOR l_event_rec IN csr_event_rec(p_source_assignment_id)
  LOOP
  --
    per_events_api.create_event
     (p_validate                      =>   false
     ,p_date_start                    =>   l_event_rec.date_start
     ,p_type                          =>   l_event_rec.type
     ,p_business_group_id             =>   l_event_rec.business_group_id
     ,p_location_id                   =>   l_event_rec.location_id
     ,p_internal_contact_person_id    =>   l_event_rec.internal_contact_person_id
     ,p_organization_run_by_id        =>   l_event_rec.organization_run_by_id
     ,p_assignment_id                 =>   p_target_assignment_id
     ,p_contact_telephone_number      =>   l_event_rec.contact_telephone_number
     ,p_date_end                      =>   l_event_rec.date_end
     ,p_emp_or_apl                    =>   l_event_rec.emp_or_apl
     ,p_event_or_interview            =>   l_event_rec.event_or_interview
     ,p_external_contact              =>   l_event_rec.external_contact
     ,p_time_end                      =>   l_event_rec.time_end
     ,p_time_start                    =>   l_event_rec.time_start
     ,p_attribute_category            =>   l_event_rec.attribute_category
     ,p_attribute1                    =>   l_event_rec.attribute1
     ,p_attribute2                    =>   l_event_rec.attribute2
     ,p_attribute3                    =>   l_event_rec.attribute3
     ,p_attribute4                    =>   l_event_rec.attribute4
     ,p_attribute5                    =>   l_event_rec.attribute5
     ,p_attribute6                    =>   l_event_rec.attribute6
     ,p_attribute7                    =>   l_event_rec.attribute7
     ,p_attribute8                    =>   l_event_rec.attribute8
     ,p_attribute9                    =>   l_event_rec.attribute9
     ,p_attribute10                   =>   l_event_rec.attribute10
     ,p_attribute11                   =>   l_event_rec.attribute11
     ,p_attribute12                   =>   l_event_rec.attribute12
     ,p_attribute13                   =>   l_event_rec.attribute13
     ,p_attribute14                   =>   l_event_rec.attribute14
     ,p_attribute15                   =>   l_event_rec.attribute15
     ,p_attribute16                   =>   l_event_rec.attribute16
     ,p_attribute17                   =>   l_event_rec.attribute17
     ,p_attribute18                   =>   l_event_rec.attribute18
     ,p_attribute19                   =>   l_event_rec.attribute19
     ,p_attribute20                   =>   l_event_rec.attribute20
     ,p_party_id                      =>   p_target_party_id
     ,p_event_id                      =>   l_event_id
     ,p_object_version_number         =>   l_event_ovn
     );
  --
  Open C_Sel1;
  Fetch C_Sel1 Into l_interview_details_id;
  Close C_Sel1;
  --
  FOR l_interview_det_rec IN csr_interview_details(l_event_rec.event_id)
  LOOP
  --
  insert into irc_interview_details
      (interview_details_id
      ,status
      ,feedback
      ,notes
      ,notes_to_candidate
      ,category
      ,result
      ,iid_information_category
      ,iid_information1
      ,iid_information2
      ,iid_information3
      ,iid_information4
      ,iid_information5
      ,iid_information6
      ,iid_information7
      ,iid_information8
      ,iid_information9
      ,iid_information10
      ,iid_information11
      ,iid_information12
      ,iid_information13
      ,iid_information14
      ,iid_information15
      ,iid_information16
      ,iid_information17
      ,iid_information18
      ,iid_information19
      ,iid_information20
      ,start_date
      ,end_date
      ,event_id
      ,object_version_number
      )
  Values
     (l_interview_details_id
     ,l_interview_det_rec.status
     ,l_interview_det_rec.feedback
     ,l_interview_det_rec.notes
     ,l_interview_det_rec.notes_to_candidate
     ,l_interview_det_rec.category
     ,l_interview_det_rec.result
     ,l_interview_det_rec.iid_information_category
     ,l_interview_det_rec.iid_information1
     ,l_interview_det_rec.iid_information2
     ,l_interview_det_rec.iid_information3
     ,l_interview_det_rec.iid_information4
     ,l_interview_det_rec.iid_information5
     ,l_interview_det_rec.iid_information6
     ,l_interview_det_rec.iid_information7
     ,l_interview_det_rec.iid_information8
     ,l_interview_det_rec.iid_information9
     ,l_interview_det_rec.iid_information10
     ,l_interview_det_rec.iid_information11
     ,l_interview_det_rec.iid_information12
     ,l_interview_det_rec.iid_information13
     ,l_interview_det_rec.iid_information14
     ,l_interview_det_rec.iid_information15
     ,l_interview_det_rec.iid_information16
     ,l_interview_det_rec.iid_information17
     ,l_interview_det_rec.iid_information18
     ,l_interview_det_rec.iid_information19
     ,l_interview_det_rec.iid_information20
     ,l_interview_det_rec.start_date
     ,l_interview_det_rec.end_date
     ,l_event_id
     ,l_interview_det_rec.object_version_number
     );
   --
  END LOOP;
  --
  END LOOP;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_interview_details;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_interview_details;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 40);
    raise;
end copy_interview_details;
--
end irc_interview_details_api;

/
