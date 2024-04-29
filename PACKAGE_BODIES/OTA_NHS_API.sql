--------------------------------------------------------
--  DDL for Package Body OTA_NHS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_NHS_API" as
/* $Header: otnhsapi.pkb 120.1 2006/01/09 03:20:12 dbatra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'OTA_NHS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_non_ota_histories> >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_non_ota_histories
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_nota_history_id               out nocopy number
  ,p_person_id                   in    number
  ,p_contact_id                in   number   default null
  ,p_trng_title              in  varchar2
  ,p_provider                      in  varchar2
  ,p_type                    in  varchar2    default null
  ,p_centre                     in  varchar2    default null
  ,p_completion_date            in  date
  ,p_award                      in  varchar2    default null
  ,p_rating                     in  varchar2    default null
  ,p_duration                in  number   default null
  ,p_duration_units                in  varchar2    default null
  ,p_activity_version_id           in  number   default null
  ,p_status                        in  varchar2    default null
  ,p_verified_by_id                in  number   default null
  ,p_nth_information_category      in  varchar2    default null
  ,p_nth_information1              in  varchar2 default null
  ,p_nth_information2              in  varchar2 default null
  ,p_nth_information3              in  varchar2 default null
  ,p_nth_information4              in  varchar2    default null
  ,p_nth_information5              in  varchar2    default null
  ,p_nth_information6              in  varchar2    default null
  ,p_nth_information7              in  varchar2    default null
  ,p_nth_information8              in  varchar2  default null
  ,p_nth_information9              in  varchar2  default null
  ,p_nth_information10             in  varchar2 default null
  ,p_nth_information11             in  varchar2 default null
  ,p_nth_information12             in  varchar2 default null
  ,p_nth_information13             in  varchar2 default null
  ,p_nth_information15             in  varchar2    default null
  ,p_nth_information16             in  varchar2 default null
  ,p_nth_information17             in  varchar2 default null
  ,p_nth_information18             in  varchar2    default null
  ,p_nth_information19             in  varchar2 default null
  ,p_nth_information20             in  varchar2 default null
  ,p_org_id                        in  number   default null
  ,p_object_version_number         out nocopy   number
  ,p_business_group_id             in  number
  ,p_nth_information14             in  varchar2    default null
  ,p_customer_id             in  number   default null
  ,p_organization_id         in  number   default null
  ,p_some_warning                  out nocopy   boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date   date;
  l_completion_date  date;
  l_proc                varchar2(72) := g_package||'create_non_ota_histories';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_histories;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_completion_date := trunc(p_completion_date);

  --
  -- Call Before Process User Hook
  --
 begin
    OTA_NHS_BK1.create_non_ota_histories_b
  (p_effective_date          => l_effective_date
  ,p_nota_history_id    => p_nota_history_id
  ,p_person_id            => p_person_id
  ,p_contact_id                 => p_contact_id
  ,p_trng_title         => p_trng_title
  ,p_provider                 => p_provider
  ,p_type               => p_type
  ,p_centre                => p_centre
  ,p_completion_date       => l_completion_date
  ,p_award                 => p_award
  ,p_rating                => p_rating
  ,p_duration           => p_duration
  ,p_duration_units           => p_duration_units
  ,p_activity_version_id      => p_activity_version_id
  ,p_status                   => p_status
  ,p_verified_by_id           => p_verified_by_id
  ,p_nth_information_category => p_nth_information_category
  ,p_nth_information1         => p_nth_information1
  ,p_nth_information2         => p_nth_information2
  ,p_nth_information3         => p_nth_information3
  ,p_nth_information4         => p_nth_information4
  ,p_nth_information5         => p_nth_information5
  ,p_nth_information6         => p_nth_information6
  ,p_nth_information7         => p_nth_information7
  ,p_nth_information8         => p_nth_information8
  ,p_nth_information9         => p_nth_information9
  ,p_nth_information10        => p_nth_information10
  ,p_nth_information11        => p_nth_information11
  ,p_nth_information12        => p_nth_information12
  ,p_nth_information13        => p_nth_information13
  ,p_nth_information15        => p_nth_information15
  ,p_nth_information16        => p_nth_information16
  ,p_nth_information17        => p_nth_information17
  ,p_nth_information18        => p_nth_information18
  ,p_nth_information19        => p_nth_information19
  ,p_nth_information20        => p_nth_information20
  ,p_org_id                   => p_org_id
  ,p_object_version_number    => p_object_version_number
  ,p_business_group_id        => p_business_group_id
  ,p_nth_information14        => p_nth_information14
  ,p_customer_id        => p_customer_id
  ,p_organization_id    => p_organization_id
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_non_ota_histories_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

ota_nhs_ins.ins
(p_effective_date         => l_effective_date
  ,p_nota_history_id    => p_nota_history_id
  ,p_person_id            => p_person_id
  ,p_contact_id                 => p_contact_id
  ,p_trng_title         => p_trng_title
  ,p_provider                 => p_provider
  ,p_type               => p_type
  ,p_centre                => p_centre
  ,p_completion_date       => l_completion_date
  ,p_award                 => p_award
  ,p_rating                => p_rating
  ,p_duration           => p_duration
  ,p_duration_units           => p_duration_units
  ,p_activity_version_id      => p_activity_version_id
  ,p_status                   => p_status
  ,p_verified_by_id           => p_verified_by_id
  ,p_nth_information_category => p_nth_information_category
  ,p_nth_information1         => p_nth_information1
  ,p_nth_information2         => p_nth_information2
  ,p_nth_information3         => p_nth_information3
  ,p_nth_information4         => p_nth_information4
  ,p_nth_information5         => p_nth_information5
  ,p_nth_information6         => p_nth_information6
  ,p_nth_information7         => p_nth_information7
  ,p_nth_information8         => p_nth_information8
  ,p_nth_information9         => p_nth_information9
  ,p_nth_information10        => p_nth_information10
  ,p_nth_information11        => p_nth_information11
  ,p_nth_information12        => p_nth_information12
  ,p_nth_information13        => p_nth_information13
  ,p_nth_information15        => p_nth_information15
  ,p_nth_information16        => p_nth_information16
  ,p_nth_information17        => p_nth_information17
  ,p_nth_information18        => p_nth_information18
  ,p_nth_information19        => p_nth_information19
  ,p_nth_information20        => p_nth_information20
  ,p_org_id                   => p_org_id
  ,p_object_version_number    => p_object_version_number
  ,p_business_group_id        => p_business_group_id
  ,p_nth_information14        => p_nth_information14
  ,p_customer_id        => p_customer_id
  ,p_organization_id    => p_organization_id
  );

  --
  -- Call After Process User Hook
  --
 begin
    OTA_NHS_BK1.create_non_ota_histories_a
  (p_effective_date          => l_effective_date
  ,p_nota_history_id    => p_nota_history_id
  ,p_person_id            => p_person_id
  ,p_contact_id                 => p_contact_id
  ,p_trng_title         => p_trng_title
  ,p_provider                 => p_provider
  ,p_type               => p_type
  ,p_centre                => p_centre
  ,p_completion_date       => l_completion_date
  ,p_award                 => p_award
  ,p_rating                => p_rating
  ,p_duration           => p_duration
  ,p_duration_units           => p_duration_units
  ,p_activity_version_id      => p_activity_version_id
  ,p_status                   => p_status
  ,p_verified_by_id           => p_verified_by_id
  ,p_nth_information_category => p_nth_information_category
  ,p_nth_information1         => p_nth_information1
  ,p_nth_information2         => p_nth_information2
  ,p_nth_information3         => p_nth_information3
  ,p_nth_information4         => p_nth_information4
  ,p_nth_information5         => p_nth_information5
  ,p_nth_information6         => p_nth_information6
  ,p_nth_information7         => p_nth_information7
  ,p_nth_information8         => p_nth_information8
  ,p_nth_information9         => p_nth_information9
  ,p_nth_information10        => p_nth_information10
  ,p_nth_information11        => p_nth_information11
  ,p_nth_information12        => p_nth_information12
  ,p_nth_information13        => p_nth_information13
  ,p_nth_information15        => p_nth_information15
  ,p_nth_information16        => p_nth_information16
  ,p_nth_information17        => p_nth_information17
  ,p_nth_information18        => p_nth_information18
  ,p_nth_information19        => p_nth_information19
  ,p_nth_information20        => p_nth_information20
  ,p_org_id                   => p_org_id
  ,p_object_version_number    => p_object_version_number
  ,p_business_group_id        => p_business_group_id
  ,p_nth_information14        => p_nth_information14
  ,p_customer_id        => p_customer_id
  ,p_organization_id    => p_organization_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_non_ota_histories_a'
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
  -- Set all output arguments
  --
  /*p_id                     := <local_var_set_in_process_logic>;
  p_object_version_number  := <local_var_set_in_process_logic>;
  p_some_warning           := <local_var_set_in_process_logic>; */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_histories;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  /*  p_id                     := null;
    p_object_version_number  := null;
    p_some_warning           := <local_var_set_in_process_logic>;*/
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_histories;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_non_ota_histories;
--


-- ----------------------------------------------------------------------------
-- |--------------------------< <update_non_ota_histories> >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_non_ota_histories
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_nota_history_id               in  number
  ,p_person_id                   in    number
  ,p_contact_id                in   number   default hr_api.g_number
  ,p_trng_title              in  varchar2
  ,p_provider                      in  varchar2
  ,p_type                    in  varchar2    default hr_api.g_varchar2
  ,p_centre                     in  varchar2    default hr_api.g_varchar2
  ,p_completion_date            in  date
  ,p_award                      in  varchar2    default hr_api.g_varchar2
  ,p_rating                     in  varchar2    default hr_api.g_varchar2
  ,p_duration                in  number   default hr_api.g_number
  ,p_duration_units                in  varchar2    default hr_api.g_varchar2
  ,p_activity_version_id           in  number   default hr_api.g_number
  ,p_status                        in  varchar2    default hr_api.g_varchar2
  ,p_verified_by_id                in  number   default hr_api.g_number
  ,p_nth_information_category      in  varchar2    default hr_api.g_varchar2
  ,p_nth_information1              in  varchar2 default hr_api.g_varchar2
  ,p_nth_information2              in  varchar2 default hr_api.g_varchar2
  ,p_nth_information3              in  varchar2 default hr_api.g_varchar2
  ,p_nth_information4              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information5              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information6              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information7              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information8              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information9              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information10             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information11             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information12             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information13             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information15             in  varchar2    default hr_api.g_varchar2
  ,p_nth_information16             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information17             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information18             in  varchar2    default hr_api.g_varchar2
  ,p_nth_information19             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information20             in  varchar2 default hr_api.g_varchar2
  ,p_org_id                        in  number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in  number
  ,p_nth_information14             in  varchar2    default hr_api.g_varchar2
  ,p_customer_id             in  number   default hr_api.g_number
  ,p_organization_id         in  number   default hr_api.g_number
  ,p_some_warning                  out nocopy   boolean
  ) is


  l_effective_date   date;
  l_completion_date  date;
  l_proc                varchar2(72) := g_package||'update_non_ota_histories';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_histories;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_completion_date := trunc(p_completion_date);

  --
  -- Call Before Process User Hook
  --
  begin
    OTA_NHS_BK2.update_non_ota_histories_b
  (p_effective_date     => l_effective_date
  ,p_nota_history_id    => p_nota_history_id
  ,p_person_id       => p_person_id
  ,p_contact_id            => p_contact_id
  ,p_trng_title         => p_trng_title
  ,p_provider                 => p_provider
  ,p_type               => p_type
  ,p_centre                => p_centre
  ,p_completion_date       => l_completion_date
  ,p_award                 => p_award
  ,p_rating                => p_rating
  ,p_duration           => p_duration
  ,p_duration_units           => p_duration_units
  ,p_activity_version_id      => p_activity_version_id
  ,p_status                   => p_status
  ,p_verified_by_id           => p_verified_by_id
  ,p_nth_information_category => p_nth_information_category
  ,p_nth_information1         => p_nth_information1
  ,p_nth_information2         => p_nth_information2
  ,p_nth_information3         => p_nth_information3
  ,p_nth_information4         => p_nth_information4
  ,p_nth_information5         => p_nth_information5
  ,p_nth_information6         => p_nth_information6
  ,p_nth_information7         => p_nth_information7
  ,p_nth_information8         => p_nth_information8
  ,p_nth_information9         => p_nth_information9
  ,p_nth_information10        => p_nth_information10
  ,p_nth_information11        => p_nth_information11
  ,p_nth_information12        => p_nth_information12
  ,p_nth_information13        => p_nth_information13
  ,p_nth_information15        => p_nth_information15
  ,p_nth_information16        => p_nth_information16
  ,p_nth_information17        => p_nth_information17
  ,p_nth_information18        => p_nth_information18
  ,p_nth_information19        => p_nth_information19
  ,p_nth_information20        => p_nth_information20
  ,p_org_id                   => p_org_id
  ,p_object_version_number    => p_object_version_number
  ,p_business_group_id        => p_business_group_id
  ,p_nth_information14        => p_nth_information14
  ,p_customer_id        => p_customer_id
  ,p_organization_id    => p_organization_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_non_ota_histories_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

ota_nhs_upd.upd
(p_effective_date    => l_effective_date
  ,p_nota_history_id    => p_nota_history_id
  ,p_person_id       => p_person_id
  ,p_contact_id            => p_contact_id
  ,p_trng_title         => p_trng_title
  ,p_provider                 => p_provider
  ,p_type               => p_type
  ,p_centre                => p_centre
  ,p_completion_date       => l_completion_date
  ,p_award                 => p_award
  ,p_rating                => p_rating
  ,p_duration           => p_duration
  ,p_duration_units           => p_duration_units
  ,p_activity_version_id      => p_activity_version_id
  ,p_status                   => p_status
  ,p_verified_by_id           => p_verified_by_id
  ,p_nth_information_category => p_nth_information_category
  ,p_nth_information1         => p_nth_information1
  ,p_nth_information2         => p_nth_information2
  ,p_nth_information3         => p_nth_information3
  ,p_nth_information4         => p_nth_information4
  ,p_nth_information5         => p_nth_information5
  ,p_nth_information6         => p_nth_information6
  ,p_nth_information7         => p_nth_information7
  ,p_nth_information8         => p_nth_information8
  ,p_nth_information9         => p_nth_information9
  ,p_nth_information10        => p_nth_information10
  ,p_nth_information11        => p_nth_information11
  ,p_nth_information12        => p_nth_information12
  ,p_nth_information13        => p_nth_information13
  ,p_nth_information15        => p_nth_information15
  ,p_nth_information16        => p_nth_information16
  ,p_nth_information17        => p_nth_information17
  ,p_nth_information18        => p_nth_information18
  ,p_nth_information19        => p_nth_information19
  ,p_nth_information20        => p_nth_information20
  ,p_org_id                   => p_org_id
  ,p_object_version_number    => p_object_version_number
  ,p_business_group_id        => p_business_group_id
  ,p_nth_information14        => p_nth_information14
  ,p_customer_id        => p_customer_id
  ,p_organization_id    => p_organization_id
  );


  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
    OTA_NHS_BK2.update_non_ota_histories_b
  (p_effective_date     => l_effective_date
  ,p_nota_history_id    => p_nota_history_id
  ,p_person_id       => p_person_id
  ,p_contact_id            => p_contact_id
  ,p_trng_title         => p_trng_title
  ,p_provider                 => p_provider
  ,p_type               => p_type
  ,p_centre                => p_centre
  ,p_completion_date       => l_completion_date
  ,p_award                 => p_award
  ,p_rating                => p_rating
  ,p_duration           => p_duration
  ,p_duration_units           => p_duration_units
  ,p_activity_version_id      => p_activity_version_id
  ,p_status                   => p_status
  ,p_verified_by_id           => p_verified_by_id
  ,p_nth_information_category => p_nth_information_category
  ,p_nth_information1         => p_nth_information1
  ,p_nth_information2         => p_nth_information2
  ,p_nth_information3         => p_nth_information3
  ,p_nth_information4         => p_nth_information4
  ,p_nth_information5         => p_nth_information5
  ,p_nth_information6         => p_nth_information6
  ,p_nth_information7         => p_nth_information7
  ,p_nth_information8         => p_nth_information8
  ,p_nth_information9         => p_nth_information9
  ,p_nth_information10        => p_nth_information10
  ,p_nth_information11        => p_nth_information11
  ,p_nth_information12        => p_nth_information12
  ,p_nth_information13        => p_nth_information13
  ,p_nth_information15        => p_nth_information15
  ,p_nth_information16        => p_nth_information16
  ,p_nth_information17        => p_nth_information17
  ,p_nth_information18        => p_nth_information18
  ,p_nth_information19        => p_nth_information19
  ,p_nth_information20        => p_nth_information20
  ,p_org_id                   => p_org_id
  ,p_object_version_number    => p_object_version_number
  ,p_business_group_id        => p_business_group_id
  ,p_nth_information14        => p_nth_information14
  ,p_customer_id        => p_customer_id
  ,p_organization_id    => p_organization_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_non_ota_histories_a'
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
  -- Set all output arguments
  --
 /* p_id                     := <local_var_set_in_process_logic>;
  p_object_version_number  := <local_var_set_in_process_logic>;
  p_some_warning           := <local_var_set_in_process_logic>;*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_histories;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  /*  p_id                     := null;
    p_object_version_number  := null;
    p_some_warning           := <local_var_set_in_process_logic>; */
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_histories;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_non_ota_histories;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< <delete_external_learning> >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_external_learning
  (p_validate                      in   boolean    default false
  ,p_nota_history_id                    in number
  ,p_object_version_number              in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' delete external learning';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_external_learning;

  -- Call Before Process User Hook
  --
  begin
  ota_external_learning_bk3.delete_external_learning_b
  (p_nota_history_id            => p_nota_history_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_external_learning_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_nhs_del.del
  (p_nota_history_id       => p_nota_history_id
  ,p_object_version_number   => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
  ota_external_learning_bk3.delete_external_learning_a
  (p_nota_history_id            => p_nota_history_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_external_learning_a'
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
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_external_learning;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_external_learning;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;

end delete_external_learning;
end OTA_NHS_API;


/
