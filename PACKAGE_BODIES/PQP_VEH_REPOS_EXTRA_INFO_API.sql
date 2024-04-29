--------------------------------------------------------
--  DDL for Package Body PQP_VEH_REPOS_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEH_REPOS_EXTRA_INFO_API" as
/* $Header: pqvriapi.pkb 120.0.12010000.2 2008/08/08 07:23:34 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQP_VEH_REPOS_EXTRA_INFO_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------< CREATE_VEH_REPOS_EXTRA_INFO >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_veh_repos_extra_info
  (p_validate                      in     boolean
  ,p_vehicle_repository_id          in     number
  ,p_information_type               in     varchar2
  ,p_vrei_attribute_category        in     varchar2
  ,p_vrei_attribute1                in     varchar2
  ,p_vrei_attribute2                in     varchar2
  ,p_vrei_attribute3                in     varchar2
  ,p_vrei_attribute4                in     varchar2
  ,p_vrei_attribute5                in     varchar2
  ,p_vrei_attribute6                in     varchar2
  ,p_vrei_attribute7                in     varchar2
  ,p_vrei_attribute8                in     varchar2
  ,p_vrei_attribute9                in     varchar2
  ,p_vrei_attribute10               in     varchar2
  ,p_vrei_attribute11               in     varchar2
  ,p_vrei_attribute12               in     varchar2
  ,p_vrei_attribute13               in     varchar2
  ,p_vrei_attribute14               in     varchar2
  ,p_vrei_attribute15               in     varchar2
  ,p_vrei_attribute16               in     varchar2
  ,p_vrei_attribute17               in     varchar2
  ,p_vrei_attribute18               in     varchar2
  ,p_vrei_attribute19               in     varchar2
  ,p_vrei_attribute20               in     varchar2
  ,p_vrei_information_category      in     varchar2
  ,p_vrei_information1              in     varchar2
  ,p_vrei_information2              in     varchar2
  ,p_vrei_information3              in     varchar2
  ,p_vrei_information4              in     varchar2
  ,p_vrei_information5              in     varchar2
  ,p_vrei_information6              in     varchar2
  ,p_vrei_information7              in     varchar2
  ,p_vrei_information8              in     varchar2
  ,p_vrei_information9              in     varchar2
  ,p_vrei_information10             in     varchar2
  ,p_vrei_information11             in     varchar2
  ,p_vrei_information12             in     varchar2
  ,p_vrei_information13             in     varchar2
  ,p_vrei_information14             in     varchar2
  ,p_vrei_information15             in     varchar2
  ,p_vrei_information16             in     varchar2
  ,p_vrei_information17             in     varchar2
  ,p_vrei_information18             in     varchar2
  ,p_vrei_information19             in     varchar2
  ,p_vrei_information20             in     varchar2
  ,p_vrei_information21             in     varchar2
  ,p_vrei_information22             in     varchar2
  ,p_vrei_information23             in     varchar2
  ,p_vrei_information24             in     varchar2
  ,p_vrei_information25             in     varchar2
  ,p_vrei_information26             in     varchar2
  ,p_vrei_information27             in     varchar2
  ,p_vrei_information28             in     varchar2
  ,p_vrei_information29             in     varchar2
  ,p_vrei_information30             in     varchar2
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_veh_repos_extra_info_id        out nocopy number
  ,p_object_version_number          out nocopy number
  )
IS
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'CREATE_VEH_REPOS_EXTRA_INFO';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_VEH_REPOS_EXTRA_INFO;
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
    pqp_veh_repos_extra_info_bk1.create_veh_repos_extra_info_b
 ( p_vehicle_repository_id          =>p_vehicle_repository_id
  ,p_information_type               =>p_information_type
  ,p_vrei_attribute_category        =>p_vrei_attribute_category
  ,p_vrei_attribute1                =>p_vrei_attribute1
  ,p_vrei_attribute2                =>p_vrei_attribute2
  ,p_vrei_attribute3                =>p_vrei_attribute3
  ,p_vrei_attribute4                =>p_vrei_attribute4
  ,p_vrei_attribute5                =>p_vrei_attribute5
  ,p_vrei_attribute6                =>p_vrei_attribute6
  ,p_vrei_attribute7                =>p_vrei_attribute7
  ,p_vrei_attribute8                =>p_vrei_attribute8
  ,p_vrei_attribute9                =>p_vrei_attribute9
  ,p_vrei_attribute10               =>p_vrei_attribute10
  ,p_vrei_attribute11               =>p_vrei_attribute11
  ,p_vrei_attribute12               =>p_vrei_attribute12
  ,p_vrei_attribute13               =>p_vrei_attribute13
  ,p_vrei_attribute14               =>p_vrei_attribute14
  ,p_vrei_attribute15               =>p_vrei_attribute15
  ,p_vrei_attribute16               =>p_vrei_attribute16
  ,p_vrei_attribute17               =>p_vrei_attribute17
  ,p_vrei_attribute18               =>p_vrei_attribute18
  ,p_vrei_attribute19               =>p_vrei_attribute19
  ,p_vrei_attribute20               =>p_vrei_attribute20
  ,p_vrei_information_category      =>p_vrei_information_category
  ,p_vrei_information1              =>p_vrei_information1
  ,p_vrei_information2              =>p_vrei_information2
  ,p_vrei_information3              =>p_vrei_information3
  ,p_vrei_information4              =>p_vrei_information4
  ,p_vrei_information5              =>p_vrei_information5
  ,p_vrei_information6              =>p_vrei_information6
  ,p_vrei_information7              =>p_vrei_information7
  ,p_vrei_information8              =>p_vrei_information8
  ,p_vrei_information9              =>p_vrei_information9
  ,p_vrei_information10             =>p_vrei_information10
  ,p_vrei_information11             =>p_vrei_information11
  ,p_vrei_information12             =>p_vrei_information12
  ,p_vrei_information13             =>p_vrei_information13
  ,p_vrei_information14             =>p_vrei_information14
  ,p_vrei_information15             =>p_vrei_information15
  ,p_vrei_information16             =>p_vrei_information16
  ,p_vrei_information17             =>p_vrei_information17
  ,p_vrei_information18             =>p_vrei_information18
  ,p_vrei_information19             =>p_vrei_information19
  ,p_vrei_information20             =>p_vrei_information20
  ,p_vrei_information21             =>p_vrei_information21
  ,p_vrei_information22             =>p_vrei_information22
  ,p_vrei_information23             =>p_vrei_information23
  ,p_vrei_information24             =>p_vrei_information24
  ,p_vrei_information25             =>p_vrei_information25
  ,p_vrei_information26             =>p_vrei_information26
  ,p_vrei_information27             =>p_vrei_information27
  ,p_vrei_information28             =>p_vrei_information28
  ,p_vrei_information29             =>p_vrei_information29
  ,p_vrei_information30             =>p_vrei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

hr_utility.set_location('Entering row handler:'|| p_vrei_information9, 10);
 pqp_vri_ins.ins
 ( p_vehicle_repository_id          =>p_vehicle_repository_id
  ,p_information_type               =>p_information_type
  ,p_vrei_attribute_category        =>p_vrei_attribute_category
  ,p_vrei_attribute1                =>p_vrei_attribute1
  ,p_vrei_attribute2                =>p_vrei_attribute2
  ,p_vrei_attribute3                =>p_vrei_attribute3
  ,p_vrei_attribute4                =>p_vrei_attribute4
  ,p_vrei_attribute5                =>p_vrei_attribute5
  ,p_vrei_attribute6                =>p_vrei_attribute6
  ,p_vrei_attribute7                =>p_vrei_attribute7
  ,p_vrei_attribute8                =>p_vrei_attribute8
  ,p_vrei_attribute9                =>p_vrei_attribute9
  ,p_vrei_attribute10               =>p_vrei_attribute10
  ,p_vrei_attribute11               =>p_vrei_attribute11
  ,p_vrei_attribute12               =>p_vrei_attribute12
  ,p_vrei_attribute13               =>p_vrei_attribute13
  ,p_vrei_attribute14               =>p_vrei_attribute14
  ,p_vrei_attribute15               =>p_vrei_attribute15
  ,p_vrei_attribute16               =>p_vrei_attribute16
  ,p_vrei_attribute17               =>p_vrei_attribute17
  ,p_vrei_attribute18               =>p_vrei_attribute18
  ,p_vrei_attribute19               =>p_vrei_attribute19
  ,p_vrei_attribute20               =>p_vrei_attribute20
  ,p_vrei_information_category      =>p_vrei_information_category
  ,p_vrei_information1              =>p_vrei_information1
  ,p_vrei_information2              =>p_vrei_information2
  ,p_vrei_information3              =>p_vrei_information3
  ,p_vrei_information4              =>p_vrei_information4
  ,p_vrei_information5              =>p_vrei_information5
  ,p_vrei_information6              =>p_vrei_information6
  ,p_vrei_information7              =>p_vrei_information7
  ,p_vrei_information8              =>p_vrei_information8
  ,p_vrei_information9              =>p_vrei_information9
  ,p_vrei_information10             =>p_vrei_information10
  ,p_vrei_information11             =>p_vrei_information11
  ,p_vrei_information12             =>p_vrei_information12
  ,p_vrei_information13             =>p_vrei_information13
  ,p_vrei_information14             =>p_vrei_information14
  ,p_vrei_information15             =>p_vrei_information15
  ,p_vrei_information16             =>p_vrei_information16
  ,p_vrei_information17             =>p_vrei_information17
  ,p_vrei_information18             =>p_vrei_information18
  ,p_vrei_information19             =>p_vrei_information19
  ,p_vrei_information20             =>p_vrei_information20
  ,p_vrei_information21             =>p_vrei_information21
  ,p_vrei_information22             =>p_vrei_information22
  ,p_vrei_information23             =>p_vrei_information23
  ,p_vrei_information24             =>p_vrei_information24
  ,p_vrei_information25             =>p_vrei_information25
  ,p_vrei_information26             =>p_vrei_information26
  ,p_vrei_information27             =>p_vrei_information27
  ,p_vrei_information28             =>p_vrei_information28
  ,p_vrei_information29             =>p_vrei_information29
  ,p_vrei_information30             =>p_vrei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  ,p_veh_repos_extra_info_id        =>p_veh_repos_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  );
  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
  pqp_veh_repos_extra_info_bk1.create_veh_repos_extra_info_a
 ( p_vehicle_repository_id          =>p_vehicle_repository_id
  ,p_information_type               =>p_information_type
  ,p_vrei_attribute_category        =>p_vrei_attribute_category
  ,p_vrei_attribute1                =>p_vrei_attribute1
  ,p_vrei_attribute2                =>p_vrei_attribute2
  ,p_vrei_attribute3                =>p_vrei_attribute3
  ,p_vrei_attribute4                =>p_vrei_attribute4
  ,p_vrei_attribute5                =>p_vrei_attribute5
  ,p_vrei_attribute6                =>p_vrei_attribute6
  ,p_vrei_attribute7                =>p_vrei_attribute7
  ,p_vrei_attribute8                =>p_vrei_attribute8
  ,p_vrei_attribute9                =>p_vrei_attribute9
  ,p_vrei_attribute10               =>p_vrei_attribute10
  ,p_vrei_attribute11               =>p_vrei_attribute11
  ,p_vrei_attribute12               =>p_vrei_attribute12
  ,p_vrei_attribute13               =>p_vrei_attribute13
  ,p_vrei_attribute14               =>p_vrei_attribute14
  ,p_vrei_attribute15               =>p_vrei_attribute15
  ,p_vrei_attribute16               =>p_vrei_attribute16
  ,p_vrei_attribute17               =>p_vrei_attribute17
  ,p_vrei_attribute18               =>p_vrei_attribute18
  ,p_vrei_attribute19               =>p_vrei_attribute19
  ,p_vrei_attribute20               =>p_vrei_attribute20
  ,p_vrei_information_category      =>p_vrei_information_category
  ,p_vrei_information1              =>p_vrei_information1
  ,p_vrei_information2              =>p_vrei_information2
  ,p_vrei_information3              =>p_vrei_information3
  ,p_vrei_information4              =>p_vrei_information4
  ,p_vrei_information5              =>p_vrei_information5
  ,p_vrei_information6              =>p_vrei_information6
  ,p_vrei_information7              =>p_vrei_information7
  ,p_vrei_information8              =>p_vrei_information8
  ,p_vrei_information9              =>p_vrei_information9
  ,p_vrei_information10             =>p_vrei_information10
  ,p_vrei_information11             =>p_vrei_information11
  ,p_vrei_information12             =>p_vrei_information12
  ,p_vrei_information13             =>p_vrei_information13
  ,p_vrei_information14             =>p_vrei_information14
  ,p_vrei_information15             =>p_vrei_information15
  ,p_vrei_information16             =>p_vrei_information16
  ,p_vrei_information17             =>p_vrei_information17
  ,p_vrei_information18             =>p_vrei_information18
  ,p_vrei_information19             =>p_vrei_information19
  ,p_vrei_information20             =>p_vrei_information20
  ,p_vrei_information21             =>p_vrei_information21
  ,p_vrei_information22             =>p_vrei_information22
  ,p_vrei_information23             =>p_vrei_information23
  ,p_vrei_information24             =>p_vrei_information24
  ,p_vrei_information25             =>p_vrei_information25
  ,p_vrei_information26             =>p_vrei_information26
  ,p_vrei_information27             =>p_vrei_information27
  ,p_vrei_information28             =>p_vrei_information28
  ,p_vrei_information29             =>p_vrei_information29
  ,p_vrei_information30             =>p_vrei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  ,p_veh_repos_extra_info_id        =>p_veh_repos_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO_API'
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
  p_veh_repos_extra_info_id        :=p_veh_repos_extra_info_id;
  p_object_version_number          :=p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_VEH_REPOS_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_veh_repos_extra_info_id        :=null;
  p_object_version_number          :=null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_VEH_REPOS_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_veh_repos_extra_info_id        :=null;
  p_object_version_number          :=null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_veh_repos_extra_info;

-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_VEH_REPOS_EXTRA_INFO >--------------------|
-- ----------------------------------------------------------------------------
--
--
 procedure update_veh_repos_extra_info
 ( p_validate                     in    boolean
  ,p_veh_repos_extra_info_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_repository_id        in     number
  ,p_information_type             in     varchar2
  ,p_vrei_attribute_category      in     varchar2
  ,p_vrei_attribute1              in     varchar2
  ,p_vrei_attribute2              in     varchar2
  ,p_vrei_attribute3              in     varchar2
  ,p_vrei_attribute4              in     varchar2
  ,p_vrei_attribute5              in     varchar2
  ,p_vrei_attribute6              in     varchar2
  ,p_vrei_attribute7              in     varchar2
  ,p_vrei_attribute8              in     varchar2
  ,p_vrei_attribute9              in     varchar2
  ,p_vrei_attribute10             in     varchar2
  ,p_vrei_attribute11             in     varchar2
  ,p_vrei_attribute12             in     varchar2
  ,p_vrei_attribute13             in     varchar2
  ,p_vrei_attribute14             in     varchar2
  ,p_vrei_attribute15             in     varchar2
  ,p_vrei_attribute16             in     varchar2
  ,p_vrei_attribute17             in     varchar2
  ,p_vrei_attribute18             in     varchar2
  ,p_vrei_attribute19             in     varchar2
  ,p_vrei_attribute20             in     varchar2
  ,p_vrei_information_category    in     varchar2
  ,p_vrei_information1            in     varchar2
  ,p_vrei_information2            in     varchar2
  ,p_vrei_information3            in     varchar2
  ,p_vrei_information4            in     varchar2
  ,p_vrei_information5            in     varchar2
  ,p_vrei_information6            in     varchar2
  ,p_vrei_information7            in     varchar2
  ,p_vrei_information8            in     varchar2
  ,p_vrei_information9            in     varchar2
  ,p_vrei_information10           in     varchar2
  ,p_vrei_information11           in     varchar2
  ,p_vrei_information12           in     varchar2
  ,p_vrei_information13           in     varchar2
  ,p_vrei_information14           in     varchar2
  ,p_vrei_information15           in     varchar2
  ,p_vrei_information16           in     varchar2
  ,p_vrei_information17           in     varchar2
  ,p_vrei_information18           in     varchar2
  ,p_vrei_information19           in     varchar2
  ,p_vrei_information20           in     varchar2
  ,p_vrei_information21           in     varchar2
  ,p_vrei_information22           in     varchar2
  ,p_vrei_information23           in     varchar2
  ,p_vrei_information24           in     varchar2
  ,p_vrei_information25           in     varchar2
  ,p_vrei_information26           in     varchar2
  ,p_vrei_information27           in     varchar2
  ,p_vrei_information28           in     varchar2
  ,p_vrei_information29           in     varchar2
  ,p_vrei_information30           in     varchar2
  ,p_request_id                   in     number
  ,p_program_application_id       in     number
  ,p_program_id                   in     number
  ,p_program_update_date          in     date
  )
is
 l_effective_date      date;
 l_proc                varchar2(72) := g_package||'UPDATE_VEH_REPOS_EXTRA_INFO';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_VEH_REPOS_EXTRA_INFO;
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
    pqp_veh_repos_extra_info_bk2.update_veh_repos_extra_info_b
 ( p_veh_repos_extra_info_id        =>p_veh_repos_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  ,p_vehicle_repository_id          =>p_vehicle_repository_id
  ,p_information_type               =>p_information_type
  ,p_vrei_attribute_category        =>p_vrei_attribute_category
  ,p_vrei_attribute1                =>p_vrei_attribute1
  ,p_vrei_attribute2                =>p_vrei_attribute2
  ,p_vrei_attribute3                =>p_vrei_attribute3
  ,p_vrei_attribute4                =>p_vrei_attribute4
  ,p_vrei_attribute5                =>p_vrei_attribute5
  ,p_vrei_attribute6                =>p_vrei_attribute6
  ,p_vrei_attribute7                =>p_vrei_attribute7
  ,p_vrei_attribute8                =>p_vrei_attribute8
  ,p_vrei_attribute9                =>p_vrei_attribute9
  ,p_vrei_attribute10               =>p_vrei_attribute10
  ,p_vrei_attribute11               =>p_vrei_attribute11
  ,p_vrei_attribute12               =>p_vrei_attribute12
  ,p_vrei_attribute13               =>p_vrei_attribute13
  ,p_vrei_attribute14               =>p_vrei_attribute14
  ,p_vrei_attribute15               =>p_vrei_attribute15
  ,p_vrei_attribute16               =>p_vrei_attribute16
  ,p_vrei_attribute17               =>p_vrei_attribute17
  ,p_vrei_attribute18               =>p_vrei_attribute18
  ,p_vrei_attribute19               =>p_vrei_attribute19
  ,p_vrei_attribute20               =>p_vrei_attribute20
  ,p_vrei_information_category      =>p_vrei_information_category
  ,p_vrei_information1              =>p_vrei_information1
  ,p_vrei_information2              =>p_vrei_information2
  ,p_vrei_information3              =>p_vrei_information3
  ,p_vrei_information4              =>p_vrei_information4
  ,p_vrei_information5              =>p_vrei_information5
  ,p_vrei_information6              =>p_vrei_information6
  ,p_vrei_information7              =>p_vrei_information7
  ,p_vrei_information8              =>p_vrei_information8
  ,p_vrei_information9              =>p_vrei_information9
  ,p_vrei_information10             =>p_vrei_information10
  ,p_vrei_information11             =>p_vrei_information11
  ,p_vrei_information12             =>p_vrei_information12
  ,p_vrei_information13             =>p_vrei_information13
  ,p_vrei_information14             =>p_vrei_information14
  ,p_vrei_information15             =>p_vrei_information15
  ,p_vrei_information16             =>p_vrei_information16
  ,p_vrei_information17             =>p_vrei_information17
  ,p_vrei_information18             =>p_vrei_information18
  ,p_vrei_information19             =>p_vrei_information19
  ,p_vrei_information20             =>p_vrei_information20
  ,p_vrei_information21             =>p_vrei_information21
  ,p_vrei_information22             =>p_vrei_information22
  ,p_vrei_information23             =>p_vrei_information23
  ,p_vrei_information24             =>p_vrei_information24
  ,p_vrei_information25             =>p_vrei_information25
  ,p_vrei_information26             =>p_vrei_information26
  ,p_vrei_information27             =>p_vrei_information27
  ,p_vrei_information28             =>p_vrei_information28
  ,p_vrei_information29             =>p_vrei_information29
  ,p_vrei_information30             =>p_vrei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --


 pqp_vri_upd.upd
 ( p_veh_repos_extra_info_id        =>p_veh_repos_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  ,p_vehicle_repository_id          =>p_vehicle_repository_id
  ,p_information_type               =>p_information_type
  ,p_vrei_attribute_category        =>p_vrei_attribute_category
  ,p_vrei_attribute1                =>p_vrei_attribute1
  ,p_vrei_attribute2                =>p_vrei_attribute2
  ,p_vrei_attribute3                =>p_vrei_attribute3
  ,p_vrei_attribute4                =>p_vrei_attribute4
  ,p_vrei_attribute5                =>p_vrei_attribute5
  ,p_vrei_attribute6                =>p_vrei_attribute6
  ,p_vrei_attribute7                =>p_vrei_attribute7
  ,p_vrei_attribute8                =>p_vrei_attribute8
  ,p_vrei_attribute9                =>p_vrei_attribute9
  ,p_vrei_attribute10               =>p_vrei_attribute10
  ,p_vrei_attribute11               =>p_vrei_attribute11
  ,p_vrei_attribute12               =>p_vrei_attribute12
  ,p_vrei_attribute13               =>p_vrei_attribute13
  ,p_vrei_attribute14               =>p_vrei_attribute14
  ,p_vrei_attribute15               =>p_vrei_attribute15
  ,p_vrei_attribute16               =>p_vrei_attribute16
  ,p_vrei_attribute17               =>p_vrei_attribute17
  ,p_vrei_attribute18               =>p_vrei_attribute18
  ,p_vrei_attribute19               =>p_vrei_attribute19
  ,p_vrei_attribute20               =>p_vrei_attribute20
  ,p_vrei_information_category      =>p_vrei_information_category
  ,p_vrei_information1              =>p_vrei_information1
  ,p_vrei_information2              =>p_vrei_information2
  ,p_vrei_information3              =>p_vrei_information3
  ,p_vrei_information4              =>p_vrei_information4
  ,p_vrei_information5              =>p_vrei_information5
  ,p_vrei_information6              =>p_vrei_information6
  ,p_vrei_information7              =>p_vrei_information7
  ,p_vrei_information8              =>p_vrei_information8
  ,p_vrei_information9              =>p_vrei_information9
  ,p_vrei_information10             =>p_vrei_information10
  ,p_vrei_information11             =>p_vrei_information11
  ,p_vrei_information12             =>p_vrei_information12
  ,p_vrei_information13             =>p_vrei_information13
  ,p_vrei_information14             =>p_vrei_information14
  ,p_vrei_information15             =>p_vrei_information15
  ,p_vrei_information16             =>p_vrei_information16
  ,p_vrei_information17             =>p_vrei_information17
  ,p_vrei_information18             =>p_vrei_information18
  ,p_vrei_information19             =>p_vrei_information19
  ,p_vrei_information20             =>p_vrei_information20
  ,p_vrei_information21             =>p_vrei_information21
  ,p_vrei_information22             =>p_vrei_information22
  ,p_vrei_information23             =>p_vrei_information23
  ,p_vrei_information24             =>p_vrei_information24
  ,p_vrei_information25             =>p_vrei_information25
  ,p_vrei_information26             =>p_vrei_information26
  ,p_vrei_information27             =>p_vrei_information27
  ,p_vrei_information28             =>p_vrei_information28
  ,p_vrei_information29             =>p_vrei_information29
  ,p_vrei_information30             =>p_vrei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  );
  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
  pqp_veh_repos_extra_info_bk2.update_veh_repos_extra_info_a
 ( p_veh_repos_extra_info_id        => p_veh_repos_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  ,p_vehicle_repository_id          =>p_vehicle_repository_id
  ,p_information_type               =>p_information_type
  ,p_vrei_attribute_category        =>p_vrei_attribute_category
  ,p_vrei_attribute1                =>p_vrei_attribute1
  ,p_vrei_attribute2                =>p_vrei_attribute2
  ,p_vrei_attribute3                =>p_vrei_attribute3
  ,p_vrei_attribute4                =>p_vrei_attribute4
  ,p_vrei_attribute5                =>p_vrei_attribute5
  ,p_vrei_attribute6                =>p_vrei_attribute6
  ,p_vrei_attribute7                =>p_vrei_attribute7
  ,p_vrei_attribute8                =>p_vrei_attribute8
  ,p_vrei_attribute9                =>p_vrei_attribute9
  ,p_vrei_attribute10               =>p_vrei_attribute10
  ,p_vrei_attribute11               =>p_vrei_attribute11
  ,p_vrei_attribute12               =>p_vrei_attribute12
  ,p_vrei_attribute13               =>p_vrei_attribute13
  ,p_vrei_attribute14               =>p_vrei_attribute14
  ,p_vrei_attribute15               =>p_vrei_attribute15
  ,p_vrei_attribute16               =>p_vrei_attribute16
  ,p_vrei_attribute17               =>p_vrei_attribute17
  ,p_vrei_attribute18               =>p_vrei_attribute18
  ,p_vrei_attribute19               =>p_vrei_attribute19
  ,p_vrei_attribute20               =>p_vrei_attribute20
  ,p_vrei_information_category      =>p_vrei_information_category
  ,p_vrei_information1              =>p_vrei_information1
  ,p_vrei_information2              =>p_vrei_information2
  ,p_vrei_information3              =>p_vrei_information3
  ,p_vrei_information4              =>p_vrei_information4
  ,p_vrei_information5              =>p_vrei_information5
  ,p_vrei_information6              =>p_vrei_information6
  ,p_vrei_information7              =>p_vrei_information7
  ,p_vrei_information8              =>p_vrei_information8
  ,p_vrei_information9              =>p_vrei_information9
  ,p_vrei_information10             =>p_vrei_information10
  ,p_vrei_information11             =>p_vrei_information11
  ,p_vrei_information12             =>p_vrei_information12
  ,p_vrei_information13             =>p_vrei_information13
  ,p_vrei_information14             =>p_vrei_information14
  ,p_vrei_information15             =>p_vrei_information15
  ,p_vrei_information16             =>p_vrei_information16
  ,p_vrei_information17             =>p_vrei_information17
  ,p_vrei_information18             =>p_vrei_information18
  ,p_vrei_information19             =>p_vrei_information19
  ,p_vrei_information20             =>p_vrei_information20
  ,p_vrei_information21             =>p_vrei_information21
  ,p_vrei_information22             =>p_vrei_information22
  ,p_vrei_information23             =>p_vrei_information23
  ,p_vrei_information24             =>p_vrei_information24
  ,p_vrei_information25             =>p_vrei_information25
  ,p_vrei_information26             =>p_vrei_information26
  ,p_vrei_information27             =>p_vrei_information27
  ,p_vrei_information28             =>p_vrei_information28
  ,p_vrei_information29             =>p_vrei_information29
  ,p_vrei_information30             =>p_vrei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO_API'
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
    rollback to UPDATE_VEH_REPOS_EXTRA_INFO;
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
    rollback to UPDATE_VEH_REPOS_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_veh_repos_extra_info;
-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_VEH_REPOS_EXTRA_INFO >--------------------|
-- ----------------------------------------------------------------------------
--
--
procedure delete_veh_repos_extra_info
( p_validate                       in     boolean  default false
 ,p_veh_repos_extra_info_id        in     number
,p_object_version_number           in     number
 )
is
  cursor csr_vr_id(c_veh_repos_extra_info_id in number) is
  select vre.vehicle_repository_id
    from pqp_veh_repos_extra_info vre
   where vre.veh_repos_extra_info_id = c_veh_repos_extra_info_id;

 l_vehicle_repository_id number;
 l_effective_date        date;
 l_proc                  varchar2(72) := g_package||'DELETE_VEH_REPOS_EXTRA_INFO';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_VEH_REPOS_EXTRA_INFO;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  open csr_vr_id(p_veh_repos_extra_info_id);
  fetch csr_vr_id into l_vehicle_repository_id;
  close csr_vr_id;
  --
  -- Call Before Process User Hook
  --
  begin
  pqp_veh_repos_extra_info_bk3.delete_veh_repos_extra_info_b
  (p_veh_repos_extra_info_id  => p_veh_repos_extra_info_id
  ,p_vehicle_repository_id    => l_vehicle_repository_id
  ,p_object_version_number    =>p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
 pqp_vri_del.del
 (p_veh_repos_extra_info_id            =>p_veh_repos_extra_info_id
 ,p_object_version_number              =>p_object_version_number
  );
  --
  -- Process Logic
  --

  --
  -- Call After Process User Hook
  --
  begin
  pqp_veh_repos_extra_info_bk3.delete_veh_repos_extra_info_a
  (p_veh_repos_extra_info_id  => p_veh_repos_extra_info_id
  ,p_vehicle_repository_id    => l_vehicle_repository_id
  ,p_object_version_number    => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_REPOS_EXTRA_INFO_API'
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
    rollback to DELETE_VEH_REPOS_EXTRA_INFO;
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
    rollback to DELETE_VEH_REPOS_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end  delete_veh_repos_extra_info;
end PQP_VEH_REPOS_EXTRA_INFO_API;

/
