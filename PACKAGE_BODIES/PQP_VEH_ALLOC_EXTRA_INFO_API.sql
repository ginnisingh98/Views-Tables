--------------------------------------------------------
--  DDL for Package Body PQP_VEH_ALLOC_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEH_ALLOC_EXTRA_INFO_API" as
/* $Header: pqvaiapi.pkb 120.0.12010000.2 2008/08/08 07:17:43 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQP_VEH_ALLOC_EXTRA_INFO_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------< CREATE_VEH_ALLOC_EXTRA_INFO >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_veh_alloc_extra_info
  (p_validate                      in     boolean  default false
  ,p_vehicle_allocation_id          in     number
  ,p_information_type               in     varchar2
  ,p_vaei_attribute_category        in     varchar2
  ,p_vaei_attribute1                in     varchar2
  ,p_vaei_attribute2                in     varchar2
  ,p_vaei_attribute3                in     varchar2
  ,p_vaei_attribute4                in     varchar2
  ,p_vaei_attribute5                in     varchar2
  ,p_vaei_attribute6                in     varchar2
  ,p_vaei_attribute7                in     varchar2
  ,p_vaei_attribute8                in     varchar2
  ,p_vaei_attribute9                in     varchar2
  ,p_vaei_attribute10               in     varchar2
  ,p_vaei_attribute11               in     varchar2
  ,p_vaei_attribute12               in     varchar2
  ,p_vaei_attribute13               in     varchar2
  ,p_vaei_attribute14               in     varchar2
  ,p_vaei_attribute15               in     varchar2
  ,p_vaei_attribute16               in     varchar2
  ,p_vaei_attribute17               in     varchar2
  ,p_vaei_attribute18               in     varchar2
  ,p_vaei_attribute19               in     varchar2
  ,p_vaei_attribute20               in     varchar2
  ,p_vaei_information_category      in     varchar2
  ,p_vaei_information1              in     varchar2
  ,p_vaei_information2              in     varchar2
  ,p_vaei_information3              in     varchar2
  ,p_vaei_information4              in     varchar2
  ,p_vaei_information5              in     varchar2
  ,p_vaei_information6              in     varchar2
  ,p_vaei_information7              in     varchar2
  ,p_vaei_information8              in     varchar2
  ,p_vaei_information9              in     varchar2
  ,p_vaei_information10             in     varchar2
  ,p_vaei_information11             in     varchar2
  ,p_vaei_information12             in     varchar2
  ,p_vaei_information13             in     varchar2
  ,p_vaei_information14             in     varchar2
  ,p_vaei_information15             in     varchar2
  ,p_vaei_information16             in     varchar2
  ,p_vaei_information17             in     varchar2
  ,p_vaei_information18             in     varchar2
  ,p_vaei_information19             in     varchar2
  ,p_vaei_information20             in     varchar2
  ,p_vaei_information21             in     varchar2
  ,p_vaei_information22             in     varchar2
  ,p_vaei_information23             in     varchar2
  ,p_vaei_information24             in     varchar2
  ,p_vaei_information25             in     varchar2
  ,p_vaei_information26             in     varchar2
  ,p_vaei_information27             in     varchar2
  ,p_vaei_information28             in     varchar2
  ,p_vaei_information29             in     varchar2
  ,p_vaei_information30             in     varchar2
  ,p_request_id                     in     number
  ,p_program_application_id         in     number
  ,p_program_id                     in     number
  ,p_program_update_date            in     date
  ,p_veh_alloc_extra_info_id        out nocopy number
  ,p_object_version_number          out nocopy number
  )
IS
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'CREATE_VEH_ALLOC_EXTRA_INFO';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_VEH_ALLOC_EXTRA_INFO;
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
    pqp_veh_alloc_extra_info_bk1.create_veh_alloc_extra_info_b
 ( p_vehicle_allocation_id          =>p_vehicle_allocation_id
  ,p_information_type               =>p_information_type
  ,p_vaei_attribute_category        =>p_vaei_attribute_category
  ,p_vaei_attribute1                =>p_vaei_attribute1
  ,p_vaei_attribute2                =>p_vaei_attribute2
  ,p_vaei_attribute3                =>p_vaei_attribute3
  ,p_vaei_attribute4                =>p_vaei_attribute4
  ,p_vaei_attribute5                =>p_vaei_attribute5
  ,p_vaei_attribute6                =>p_vaei_attribute6
  ,p_vaei_attribute7                =>p_vaei_attribute7
  ,p_vaei_attribute8                =>p_vaei_attribute8
  ,p_vaei_attribute9                =>p_vaei_attribute9
  ,p_vaei_attribute10               =>p_vaei_attribute10
  ,p_vaei_attribute11               =>p_vaei_attribute11
  ,p_vaei_attribute12               =>p_vaei_attribute12
  ,p_vaei_attribute13               =>p_vaei_attribute13
  ,p_vaei_attribute14               =>p_vaei_attribute14
  ,p_vaei_attribute15               =>p_vaei_attribute15
  ,p_vaei_attribute16               =>p_vaei_attribute16
  ,p_vaei_attribute17               =>p_vaei_attribute17
  ,p_vaei_attribute18               =>p_vaei_attribute18
  ,p_vaei_attribute19               =>p_vaei_attribute19
  ,p_vaei_attribute20               =>p_vaei_attribute20
  ,p_vaei_information_category      =>p_vaei_information_category
  ,p_vaei_information1              =>p_vaei_information1
  ,p_vaei_information2              =>p_vaei_information2
  ,p_vaei_information3              =>p_vaei_information3
  ,p_vaei_information4              =>p_vaei_information4
  ,p_vaei_information5              =>p_vaei_information5
  ,p_vaei_information6              =>p_vaei_information6
  ,p_vaei_information7              =>p_vaei_information7
  ,p_vaei_information8              =>p_vaei_information8
  ,p_vaei_information9              =>p_vaei_information9
  ,p_vaei_information10             =>p_vaei_information10
  ,p_vaei_information11             =>p_vaei_information11
  ,p_vaei_information12             =>p_vaei_information12
  ,p_vaei_information13             =>p_vaei_information13
  ,p_vaei_information14             =>p_vaei_information14
  ,p_vaei_information15             =>p_vaei_information15
  ,p_vaei_information16             =>p_vaei_information16
  ,p_vaei_information17             =>p_vaei_information17
  ,p_vaei_information18             =>p_vaei_information18
  ,p_vaei_information19             =>p_vaei_information19
  ,p_vaei_information20             =>p_vaei_information20
  ,p_vaei_information21             =>p_vaei_information21
  ,p_vaei_information22             =>p_vaei_information22
  ,p_vaei_information23             =>p_vaei_information23
  ,p_vaei_information24             =>p_vaei_information24
  ,p_vaei_information25             =>p_vaei_information25
  ,p_vaei_information26             =>p_vaei_information26
  ,p_vaei_information27             =>p_vaei_information27
  ,p_vaei_information28             =>p_vaei_information28
  ,p_vaei_information29             =>p_vaei_information29
  ,p_vaei_information30             =>p_vaei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

hr_utility.set_location('Entering row handler:'|| p_vaei_information9, 10);
 pqp_vai_ins.ins
 ( p_vehicle_allocation_id          =>p_vehicle_allocation_id
  ,p_information_type               =>p_information_type
  ,p_vaei_attribute_category        =>p_vaei_attribute_category
  ,p_vaei_attribute1                =>p_vaei_attribute1
  ,p_vaei_attribute2                =>p_vaei_attribute2
  ,p_vaei_attribute3                =>p_vaei_attribute3
  ,p_vaei_attribute4                =>p_vaei_attribute4
  ,p_vaei_attribute5                =>p_vaei_attribute5
  ,p_vaei_attribute6                =>p_vaei_attribute6
  ,p_vaei_attribute7                =>p_vaei_attribute7
  ,p_vaei_attribute8                =>p_vaei_attribute8
  ,p_vaei_attribute9                =>p_vaei_attribute9
  ,p_vaei_attribute10               =>p_vaei_attribute10
  ,p_vaei_attribute11               =>p_vaei_attribute11
  ,p_vaei_attribute12               =>p_vaei_attribute12
  ,p_vaei_attribute13               =>p_vaei_attribute13
  ,p_vaei_attribute14               =>p_vaei_attribute14
  ,p_vaei_attribute15               =>p_vaei_attribute15
  ,p_vaei_attribute16               =>p_vaei_attribute16
  ,p_vaei_attribute17               =>p_vaei_attribute17
  ,p_vaei_attribute18               =>p_vaei_attribute18
  ,p_vaei_attribute19               =>p_vaei_attribute19
  ,p_vaei_attribute20               =>p_vaei_attribute20
  ,p_vaei_information_category      =>p_vaei_information_category
  ,p_vaei_information1              =>p_vaei_information1
  ,p_vaei_information2              =>p_vaei_information2
  ,p_vaei_information3              =>p_vaei_information3
  ,p_vaei_information4              =>p_vaei_information4
  ,p_vaei_information5              =>p_vaei_information5
  ,p_vaei_information6              =>p_vaei_information6
  ,p_vaei_information7              =>p_vaei_information7
  ,p_vaei_information8              =>p_vaei_information8
  ,p_vaei_information9              =>p_vaei_information9
  ,p_vaei_information10             =>p_vaei_information10
  ,p_vaei_information11             =>p_vaei_information11
  ,p_vaei_information12             =>p_vaei_information12
  ,p_vaei_information13             =>p_vaei_information13
  ,p_vaei_information14             =>p_vaei_information14
  ,p_vaei_information15             =>p_vaei_information15
  ,p_vaei_information16             =>p_vaei_information16
  ,p_vaei_information17             =>p_vaei_information17
  ,p_vaei_information18             =>p_vaei_information18
  ,p_vaei_information19             =>p_vaei_information19
  ,p_vaei_information20             =>p_vaei_information20
  ,p_vaei_information21             =>p_vaei_information21
  ,p_vaei_information22             =>p_vaei_information22
  ,p_vaei_information23             =>p_vaei_information23
  ,p_vaei_information24             =>p_vaei_information24
  ,p_vaei_information25             =>p_vaei_information25
  ,p_vaei_information26             =>p_vaei_information26
  ,p_vaei_information27             =>p_vaei_information27
  ,p_vaei_information28             =>p_vaei_information28
  ,p_vaei_information29             =>p_vaei_information29
  ,p_vaei_information30             =>p_vaei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  ,p_veh_alloc_extra_info_id        =>p_veh_alloc_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  );
  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
  pqp_veh_alloc_extra_info_bk1.create_veh_alloc_extra_info_a
 ( p_vehicle_allocation_id          =>p_vehicle_allocation_id
  ,p_information_type               =>p_information_type
  ,p_vaei_attribute_category        =>p_vaei_attribute_category
  ,p_vaei_attribute1                =>p_vaei_attribute1
  ,p_vaei_attribute2                =>p_vaei_attribute2
  ,p_vaei_attribute3                =>p_vaei_attribute3
  ,p_vaei_attribute4                =>p_vaei_attribute4
  ,p_vaei_attribute5                =>p_vaei_attribute5
  ,p_vaei_attribute6                =>p_vaei_attribute6
  ,p_vaei_attribute7                =>p_vaei_attribute7
  ,p_vaei_attribute8                =>p_vaei_attribute8
  ,p_vaei_attribute9                =>p_vaei_attribute9
  ,p_vaei_attribute10               =>p_vaei_attribute10
  ,p_vaei_attribute11               =>p_vaei_attribute11
  ,p_vaei_attribute12               =>p_vaei_attribute12
  ,p_vaei_attribute13               =>p_vaei_attribute13
  ,p_vaei_attribute14               =>p_vaei_attribute14
  ,p_vaei_attribute15               =>p_vaei_attribute15
  ,p_vaei_attribute16               =>p_vaei_attribute16
  ,p_vaei_attribute17               =>p_vaei_attribute17
  ,p_vaei_attribute18               =>p_vaei_attribute18
  ,p_vaei_attribute19               =>p_vaei_attribute19
  ,p_vaei_attribute20               =>p_vaei_attribute20
  ,p_vaei_information_category      =>p_vaei_information_category
  ,p_vaei_information1              =>p_vaei_information1
  ,p_vaei_information2              =>p_vaei_information2
  ,p_vaei_information3              =>p_vaei_information3
  ,p_vaei_information4              =>p_vaei_information4
  ,p_vaei_information5              =>p_vaei_information5
  ,p_vaei_information6              =>p_vaei_information6
  ,p_vaei_information7              =>p_vaei_information7
  ,p_vaei_information8              =>p_vaei_information8
  ,p_vaei_information9              =>p_vaei_information9
  ,p_vaei_information10             =>p_vaei_information10
  ,p_vaei_information11             =>p_vaei_information11
  ,p_vaei_information12             =>p_vaei_information12
  ,p_vaei_information13             =>p_vaei_information13
  ,p_vaei_information14             =>p_vaei_information14
  ,p_vaei_information15             =>p_vaei_information15
  ,p_vaei_information16             =>p_vaei_information16
  ,p_vaei_information17             =>p_vaei_information17
  ,p_vaei_information18             =>p_vaei_information18
  ,p_vaei_information19             =>p_vaei_information19
  ,p_vaei_information20             =>p_vaei_information20
  ,p_vaei_information21             =>p_vaei_information21
  ,p_vaei_information22             =>p_vaei_information22
  ,p_vaei_information23             =>p_vaei_information23
  ,p_vaei_information24             =>p_vaei_information24
  ,p_vaei_information25             =>p_vaei_information25
  ,p_vaei_information26             =>p_vaei_information26
  ,p_vaei_information27             =>p_vaei_information27
  ,p_vaei_information28             =>p_vaei_information28
  ,p_vaei_information29             =>p_vaei_information29
  ,p_vaei_information30             =>p_vaei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  ,p_veh_alloc_extra_info_id        =>p_veh_alloc_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO_API'
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
  p_veh_alloc_extra_info_id        :=p_veh_alloc_extra_info_id;
  p_object_version_number          :=p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_VEH_ALLOC_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_veh_alloc_extra_info_id        :=null;
  p_object_version_number          :=null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_VEH_ALLOC_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_veh_alloc_extra_info_id        :=null;
  p_object_version_number          :=null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_veh_alloc_extra_info;

-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_VEH_ALLOC_EXTRA_INFO >--------------------|
-- ----------------------------------------------------------------------------
--
--
 procedure update_veh_alloc_extra_info
 ( p_validate                     in    boolean
  ,p_veh_alloc_extra_info_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_allocation_id        in     number
  ,p_information_type             in     varchar2
  ,p_vaei_attribute_category      in     varchar2
  ,p_vaei_attribute1              in     varchar2
  ,p_vaei_attribute2              in     varchar2
  ,p_vaei_attribute3              in     varchar2
  ,p_vaei_attribute4              in     varchar2
  ,p_vaei_attribute5              in     varchar2
  ,p_vaei_attribute6              in     varchar2
  ,p_vaei_attribute7              in     varchar2
  ,p_vaei_attribute8              in     varchar2
  ,p_vaei_attribute9              in     varchar2
  ,p_vaei_attribute10             in     varchar2
  ,p_vaei_attribute11             in     varchar2
  ,p_vaei_attribute12             in     varchar2
  ,p_vaei_attribute13             in     varchar2
  ,p_vaei_attribute14             in     varchar2
  ,p_vaei_attribute15             in     varchar2
  ,p_vaei_attribute16             in     varchar2
  ,p_vaei_attribute17             in     varchar2
  ,p_vaei_attribute18             in     varchar2
  ,p_vaei_attribute19             in     varchar2
  ,p_vaei_attribute20             in     varchar2
  ,p_vaei_information_category    in     varchar2
  ,p_vaei_information1            in     varchar2
  ,p_vaei_information2            in     varchar2
  ,p_vaei_information3            in     varchar2
  ,p_vaei_information4            in     varchar2
  ,p_vaei_information5            in     varchar2
  ,p_vaei_information6            in     varchar2
  ,p_vaei_information7            in     varchar2
  ,p_vaei_information8            in     varchar2
  ,p_vaei_information9            in     varchar2
  ,p_vaei_information10           in     varchar2
  ,p_vaei_information11           in     varchar2
  ,p_vaei_information12           in     varchar2
  ,p_vaei_information13           in     varchar2
  ,p_vaei_information14           in     varchar2
  ,p_vaei_information15           in     varchar2
  ,p_vaei_information16           in     varchar2
  ,p_vaei_information17           in     varchar2
  ,p_vaei_information18           in     varchar2
  ,p_vaei_information19           in     varchar2
  ,p_vaei_information20           in     varchar2
  ,p_vaei_information21           in     varchar2
  ,p_vaei_information22           in     varchar2
  ,p_vaei_information23           in     varchar2
  ,p_vaei_information24           in     varchar2
  ,p_vaei_information25           in     varchar2
  ,p_vaei_information26           in     varchar2
  ,p_vaei_information27           in     varchar2
  ,p_vaei_information28           in     varchar2
  ,p_vaei_information29           in     varchar2
  ,p_vaei_information30           in     varchar2
  ,p_request_id                   in     number
  ,p_program_application_id       in     number
  ,p_program_id                   in     number
  ,p_program_update_date          in     date
  )
is
 l_effective_date      date;
 l_proc                varchar2(72) := g_package||'UPDATE_VEH_ALLOC_EXTRA_INFO';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_VEH_ALLOC_EXTRA_INFO;
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
    pqp_veh_alloc_extra_info_bk2.update_veh_alloc_extra_info_b
 ( p_veh_alloc_extra_info_id        =>p_veh_alloc_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  ,p_vehicle_allocation_id          =>p_vehicle_allocation_id
  ,p_information_type               =>p_information_type
  ,p_vaei_attribute_category        =>p_vaei_attribute_category
  ,p_vaei_attribute1                =>p_vaei_attribute1
  ,p_vaei_attribute2                =>p_vaei_attribute2
  ,p_vaei_attribute3                =>p_vaei_attribute3
  ,p_vaei_attribute4                =>p_vaei_attribute4
  ,p_vaei_attribute5                =>p_vaei_attribute5
  ,p_vaei_attribute6                =>p_vaei_attribute6
  ,p_vaei_attribute7                =>p_vaei_attribute7
  ,p_vaei_attribute8                =>p_vaei_attribute8
  ,p_vaei_attribute9                =>p_vaei_attribute9
  ,p_vaei_attribute10               =>p_vaei_attribute10
  ,p_vaei_attribute11               =>p_vaei_attribute11
  ,p_vaei_attribute12               =>p_vaei_attribute12
  ,p_vaei_attribute13               =>p_vaei_attribute13
  ,p_vaei_attribute14               =>p_vaei_attribute14
  ,p_vaei_attribute15               =>p_vaei_attribute15
  ,p_vaei_attribute16               =>p_vaei_attribute16
  ,p_vaei_attribute17               =>p_vaei_attribute17
  ,p_vaei_attribute18               =>p_vaei_attribute18
  ,p_vaei_attribute19               =>p_vaei_attribute19
  ,p_vaei_attribute20               =>p_vaei_attribute20
  ,p_vaei_information_category      =>p_vaei_information_category
  ,p_vaei_information1              =>p_vaei_information1
  ,p_vaei_information2              =>p_vaei_information2
  ,p_vaei_information3              =>p_vaei_information3
  ,p_vaei_information4              =>p_vaei_information4
  ,p_vaei_information5              =>p_vaei_information5
  ,p_vaei_information6              =>p_vaei_information6
  ,p_vaei_information7              =>p_vaei_information7
  ,p_vaei_information8              =>p_vaei_information8
  ,p_vaei_information9              =>p_vaei_information9
  ,p_vaei_information10             =>p_vaei_information10
  ,p_vaei_information11             =>p_vaei_information11
  ,p_vaei_information12             =>p_vaei_information12
  ,p_vaei_information13             =>p_vaei_information13
  ,p_vaei_information14             =>p_vaei_information14
  ,p_vaei_information15             =>p_vaei_information15
  ,p_vaei_information16             =>p_vaei_information16
  ,p_vaei_information17             =>p_vaei_information17
  ,p_vaei_information18             =>p_vaei_information18
  ,p_vaei_information19             =>p_vaei_information19
  ,p_vaei_information20             =>p_vaei_information20
  ,p_vaei_information21             =>p_vaei_information21
  ,p_vaei_information22             =>p_vaei_information22
  ,p_vaei_information23             =>p_vaei_information23
  ,p_vaei_information24             =>p_vaei_information24
  ,p_vaei_information25             =>p_vaei_information25
  ,p_vaei_information26             =>p_vaei_information26
  ,p_vaei_information27             =>p_vaei_information27
  ,p_vaei_information28             =>p_vaei_information28
  ,p_vaei_information29             =>p_vaei_information29
  ,p_vaei_information30             =>p_vaei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --


 pqp_vai_upd.upd
 ( p_veh_alloc_extra_info_id        =>p_veh_alloc_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  ,p_vehicle_allocation_id          =>p_vehicle_allocation_id
  ,p_information_type               =>p_information_type
  ,p_vaei_attribute_category        =>p_vaei_attribute_category
  ,p_vaei_attribute1                =>p_vaei_attribute1
  ,p_vaei_attribute2                =>p_vaei_attribute2
  ,p_vaei_attribute3                =>p_vaei_attribute3
  ,p_vaei_attribute4                =>p_vaei_attribute4
  ,p_vaei_attribute5                =>p_vaei_attribute5
  ,p_vaei_attribute6                =>p_vaei_attribute6
  ,p_vaei_attribute7                =>p_vaei_attribute7
  ,p_vaei_attribute8                =>p_vaei_attribute8
  ,p_vaei_attribute9                =>p_vaei_attribute9
  ,p_vaei_attribute10               =>p_vaei_attribute10
  ,p_vaei_attribute11               =>p_vaei_attribute11
  ,p_vaei_attribute12               =>p_vaei_attribute12
  ,p_vaei_attribute13               =>p_vaei_attribute13
  ,p_vaei_attribute14               =>p_vaei_attribute14
  ,p_vaei_attribute15               =>p_vaei_attribute15
  ,p_vaei_attribute16               =>p_vaei_attribute16
  ,p_vaei_attribute17               =>p_vaei_attribute17
  ,p_vaei_attribute18               =>p_vaei_attribute18
  ,p_vaei_attribute19               =>p_vaei_attribute19
  ,p_vaei_attribute20               =>p_vaei_attribute20
  ,p_vaei_information_category      =>p_vaei_information_category
  ,p_vaei_information1              =>p_vaei_information1
  ,p_vaei_information2              =>p_vaei_information2
  ,p_vaei_information3              =>p_vaei_information3
  ,p_vaei_information4              =>p_vaei_information4
  ,p_vaei_information5              =>p_vaei_information5
  ,p_vaei_information6              =>p_vaei_information6
  ,p_vaei_information7              =>p_vaei_information7
  ,p_vaei_information8              =>p_vaei_information8
  ,p_vaei_information9              =>p_vaei_information9
  ,p_vaei_information10             =>p_vaei_information10
  ,p_vaei_information11             =>p_vaei_information11
  ,p_vaei_information12             =>p_vaei_information12
  ,p_vaei_information13             =>p_vaei_information13
  ,p_vaei_information14             =>p_vaei_information14
  ,p_vaei_information15             =>p_vaei_information15
  ,p_vaei_information16             =>p_vaei_information16
  ,p_vaei_information17             =>p_vaei_information17
  ,p_vaei_information18             =>p_vaei_information18
  ,p_vaei_information19             =>p_vaei_information19
  ,p_vaei_information20             =>p_vaei_information20
  ,p_vaei_information21             =>p_vaei_information21
  ,p_vaei_information22             =>p_vaei_information22
  ,p_vaei_information23             =>p_vaei_information23
  ,p_vaei_information24             =>p_vaei_information24
  ,p_vaei_information25             =>p_vaei_information25
  ,p_vaei_information26             =>p_vaei_information26
  ,p_vaei_information27             =>p_vaei_information27
  ,p_vaei_information28             =>p_vaei_information28
  ,p_vaei_information29             =>p_vaei_information29
  ,p_vaei_information30             =>p_vaei_information30
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
  pqp_veh_alloc_extra_info_bk2.update_veh_alloc_extra_info_a
 ( p_veh_alloc_extra_info_id        => p_veh_alloc_extra_info_id
  ,p_object_version_number          =>p_object_version_number
  ,p_vehicle_allocation_id          =>p_vehicle_allocation_id
  ,p_information_type               =>p_information_type
  ,p_vaei_attribute_category        =>p_vaei_attribute_category
  ,p_vaei_attribute1                =>p_vaei_attribute1
  ,p_vaei_attribute2                =>p_vaei_attribute2
  ,p_vaei_attribute3                =>p_vaei_attribute3
  ,p_vaei_attribute4                =>p_vaei_attribute4
  ,p_vaei_attribute5                =>p_vaei_attribute5
  ,p_vaei_attribute6                =>p_vaei_attribute6
  ,p_vaei_attribute7                =>p_vaei_attribute7
  ,p_vaei_attribute8                =>p_vaei_attribute8
  ,p_vaei_attribute9                =>p_vaei_attribute9
  ,p_vaei_attribute10               =>p_vaei_attribute10
  ,p_vaei_attribute11               =>p_vaei_attribute11
  ,p_vaei_attribute12               =>p_vaei_attribute12
  ,p_vaei_attribute13               =>p_vaei_attribute13
  ,p_vaei_attribute14               =>p_vaei_attribute14
  ,p_vaei_attribute15               =>p_vaei_attribute15
  ,p_vaei_attribute16               =>p_vaei_attribute16
  ,p_vaei_attribute17               =>p_vaei_attribute17
  ,p_vaei_attribute18               =>p_vaei_attribute18
  ,p_vaei_attribute19               =>p_vaei_attribute19
  ,p_vaei_attribute20               =>p_vaei_attribute20
  ,p_vaei_information_category      =>p_vaei_information_category
  ,p_vaei_information1              =>p_vaei_information1
  ,p_vaei_information2              =>p_vaei_information2
  ,p_vaei_information3              =>p_vaei_information3
  ,p_vaei_information4              =>p_vaei_information4
  ,p_vaei_information5              =>p_vaei_information5
  ,p_vaei_information6              =>p_vaei_information6
  ,p_vaei_information7              =>p_vaei_information7
  ,p_vaei_information8              =>p_vaei_information8
  ,p_vaei_information9              =>p_vaei_information9
  ,p_vaei_information10             =>p_vaei_information10
  ,p_vaei_information11             =>p_vaei_information11
  ,p_vaei_information12             =>p_vaei_information12
  ,p_vaei_information13             =>p_vaei_information13
  ,p_vaei_information14             =>p_vaei_information14
  ,p_vaei_information15             =>p_vaei_information15
  ,p_vaei_information16             =>p_vaei_information16
  ,p_vaei_information17             =>p_vaei_information17
  ,p_vaei_information18             =>p_vaei_information18
  ,p_vaei_information19             =>p_vaei_information19
  ,p_vaei_information20             =>p_vaei_information20
  ,p_vaei_information21             =>p_vaei_information21
  ,p_vaei_information22             =>p_vaei_information22
  ,p_vaei_information23             =>p_vaei_information23
  ,p_vaei_information24             =>p_vaei_information24
  ,p_vaei_information25             =>p_vaei_information25
  ,p_vaei_information26             =>p_vaei_information26
  ,p_vaei_information27             =>p_vaei_information27
  ,p_vaei_information28             =>p_vaei_information28
  ,p_vaei_information29             =>p_vaei_information29
  ,p_vaei_information30             =>p_vaei_information30
  ,p_request_id                     =>p_request_id
  ,p_program_application_id         =>p_program_application_id
  ,p_program_id                     =>p_program_id
  ,p_program_update_date            =>p_program_update_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO_API'
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
    rollback to UPDATE_VEH_ALLOC_EXTRA_INFO;
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
    rollback to UPDATE_VEH_ALLOC_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_veh_alloc_extra_info;
-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_VEH_ALLOC_EXTRA_INFO >--------------------|
-- ----------------------------------------------------------------------------
--
--
procedure delete_veh_alloc_extra_info
( p_validate                       in     boolean  default false
 ,p_veh_alloc_extra_info_id        in     number
 ,p_object_version_number           in     number
 )
is
 cursor csr_veh_id (c_veh_alloc_extra_info_id in number) is
 select vae.vehicle_allocation_id
   from pqp_veh_alloc_extra_info vae
  where vae.veh_alloc_extra_info_id = c_veh_alloc_extra_info_id;

 l_vehicle_allocation_id number;
 l_effective_date        date;
 l_proc                  varchar2(72) := g_package||'DELETE_VEH_ALLOC_EXTRA_INFO';

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_veh_alloc_extra_info;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  open csr_veh_id(p_veh_alloc_extra_info_id);
  fetch csr_veh_id into l_vehicle_allocation_id;
  close csr_veh_id;
  --
  -- Call Before Process User Hook
  --
  begin
  pqp_veh_alloc_extra_info_bk3.delete_veh_alloc_extra_info_b
  (p_veh_alloc_extra_info_id  => p_veh_alloc_extra_info_id
  ,p_vehicle_allocation_id    => l_vehicle_allocation_id
  ,p_object_version_number    =>p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  pqp_vai_del.del
  (p_veh_alloc_extra_info_id => p_veh_alloc_extra_info_id
  ,p_object_version_number   => p_object_version_number
  );
  --
  -- Process Logic
  --

  --
  -- Call After Process User Hook
  --
  begin
  pqp_veh_alloc_extra_info_bk3.delete_veh_alloc_extra_info_a
  (p_veh_alloc_extra_info_id  => p_veh_alloc_extra_info_id
  ,p_vehicle_allocation_id    => l_vehicle_allocation_id
  ,p_object_version_number    =>p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEH_ALLOC_EXTRA_INFO_API'
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
    rollback to DELETE_VEH_ALLOC_EXTRA_INFO;
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
    rollback to DELETE_VEH_ALLOC_EXTRA_INFO;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end  delete_veh_alloc_extra_info;
end PQP_VEH_ALLOC_EXTRA_INFO_API;

/
