--------------------------------------------------------
--  DDL for Package Body OTA_BOOKING_STATUS_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BOOKING_STATUS_TYPE_API" as
/* $Header: otbstapi.pkb 120.0 2005/05/29 07:04:39 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_BOOKING_STATUS_TYPE_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_BOOKING_STATUS_TYPE >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_BOOKING_STATUS_TYPE(
 p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_active_flag                    in     varchar2 default null
  ,p_default_flag                   in     varchar2 default null
  ,p_name                           in     varchar2 default null
  ,p_type                           in     varchar2 default null
  ,p_place_used_flag                in     varchar2 default null
  ,p_comments                       in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_bst_information_category       in     varchar2 default null
  ,p_bst_information1               in     varchar2 default null
  ,p_bst_information2               in     varchar2 default null
  ,p_bst_information3               in     varchar2 default null
  ,p_bst_information4               in     varchar2 default null
  ,p_bst_information5               in     varchar2 default null
  ,p_bst_information6               in     varchar2 default null
  ,p_bst_information7               in     varchar2 default null
  ,p_bst_information8               in     varchar2 default null
  ,p_bst_information9               in     varchar2 default null
  ,p_bst_information10              in     varchar2 default null
  ,p_bst_information11              in     varchar2 default null
  ,p_bst_information12              in     varchar2 default null
  ,p_bst_information13              in     varchar2 default null
  ,p_bst_information14              in     varchar2 default null
  ,p_bst_information15              in     varchar2 default null
  ,p_bst_information16              in     varchar2 default null
  ,p_bst_information17              in     varchar2 default null
  ,p_bst_information18              in     varchar2 default null
  ,p_bst_information19              in     varchar2 default null
  ,p_bst_information20              in     varchar2 default null
  ,   p_object_version_number      out nocopy	   number
  ,   p_booking_status_type_id       out    nocopy number
--  ,p_data_source                    in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Training Plan';
  l_booking_status_type_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_BOOKING_STATUS_TYPE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  l_name := rtrim(p_name);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_BOOKING_STATUS_TYPE_BK1.CREATE_BOOKING_STATUS_TYPE_B
  (p_effective_date                 => l_effective_date
      ,p_business_group_id	        => p_business_group_id
      ,p_active_flag                    => p_active_flag
      ,p_default_flag                   => p_default_flag
      ,p_place_used_flag                => p_place_used_flag
      ,p_name                           => p_name
      ,p_type                           => p_type
      ,p_comments                       => p_comments
      ,p_description                    => p_description
      ,p_bst_information_category       => p_bst_information_category
      ,p_bst_information1		=> p_bst_information1
      ,p_bst_information2		=> p_bst_information2
      ,p_bst_information3		=> p_bst_information3
      ,p_bst_information4		=> p_bst_information4
      ,p_bst_information5		=> p_bst_information5
      ,p_bst_information6		=> p_bst_information6
      ,p_bst_information7		=> p_bst_information7
      ,p_bst_information8		=> p_bst_information8
      ,p_bst_information9		=> p_bst_information9
      ,p_bst_information10		=> p_bst_information10
      ,p_bst_information11		=> p_bst_information11
      ,p_bst_information12		=> p_bst_information12
      ,p_bst_information13		=> p_bst_information13
      ,p_bst_information14		=> p_bst_information14
      ,p_bst_information15		=> p_bst_information15
      ,p_bst_information16		=> p_bst_information16
      ,p_bst_information17		=> p_bst_information17
      ,p_bst_information18		=> p_bst_information18
      ,p_bst_information19		=> p_bst_information19
      ,p_bst_information20		=> p_bst_information20
--      ,p_data_source			=> p_data_source
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BOOKING_STATUS_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
/*
  l_end_date :=  END_DATE(
                        p_start_date ,
                        p_end_date ,
                        p_duration    ,
                        p_duration_units         );
*/
  ota_bst_api.ins
  ( -- p_effective_date                 => l_effective_date
       p_booking_status_type_id         => l_booking_status_type_id
      ,p_business_group_id	        => p_business_group_id
      ,p_active_flag                    => p_active_flag
      ,p_default_flag                   => p_default_flag
     -- ,p_place_used_flag                => p_place_used_flag
      ,p_name                           => p_name
      ,p_object_version_number          => l_object_version_number
      ,p_type                           => p_type
      ,p_comments                       => p_comments
      ,p_description                    => p_description
      ,p_bst_information_category       => p_bst_information_category
      ,p_bst_information1		=> p_bst_information1
      ,p_bst_information2		=> p_bst_information2
      ,p_bst_information3		=> p_bst_information3
      ,p_bst_information4		=> p_bst_information4
      ,p_bst_information5		=> p_bst_information5
      ,p_bst_information6		=> p_bst_information6
      ,p_bst_information7		=> p_bst_information7
      ,p_bst_information8		=> p_bst_information8
      ,p_bst_information9		=> p_bst_information9
      ,p_bst_information10		=> p_bst_information10
      ,p_bst_information11		=> p_bst_information11
      ,p_bst_information12		=> p_bst_information12
      ,p_bst_information13		=> p_bst_information13
      ,p_bst_information14		=> p_bst_information14
      ,p_bst_information15		=> p_bst_information15
      ,p_bst_information16		=> p_bst_information16
      ,p_bst_information17		=> p_bst_information17
      ,p_bst_information18		=> p_bst_information18
      ,p_bst_information19		=> p_bst_information19
      ,p_bst_information20		=> p_bst_information20

  );

   ota_bsl_ins.ins_tl
    (p_effective_date               => l_effective_date
  ,p_language_code                  => USERENV('LANG')
  ,p_booking_status_type_id                    => l_booking_status_type_id
  ,p_name                           => l_name
  ,p_description                    => p_description  );
  --
  -- Call After Process User Hook
  --

  begin
  OTA_BOOKING_STATUS_TYPE_BK1.CREATE_BOOKING_STATUS_TYPE_A
  (p_effective_date                 => l_effective_date
      ,p_business_group_id	        => p_business_group_id
      ,p_active_flag                    => p_active_flag
      ,p_default_flag                   => p_default_flag
      ,p_place_used_flag                => p_place_used_flag
      ,p_name                           => p_name
      ,p_type                           => p_type
      ,p_comments                       => p_comments
      ,p_description                    => p_description
      ,p_bst_information_category       => p_bst_information_category
      ,p_bst_information1		=> p_bst_information1
      ,p_bst_information2		=> p_bst_information2
      ,p_bst_information3		=> p_bst_information3
      ,p_bst_information4		=> p_bst_information4
      ,p_bst_information5		=> p_bst_information5
      ,p_bst_information6		=> p_bst_information6
      ,p_bst_information7		=> p_bst_information7
      ,p_bst_information8		=> p_bst_information8
      ,p_bst_information9		=> p_bst_information9
      ,p_bst_information10		=> p_bst_information10
      ,p_bst_information11		=> p_bst_information11
      ,p_bst_information12		=> p_bst_information12
      ,p_bst_information13		=> p_bst_information13
      ,p_bst_information14		=> p_bst_information14
      ,p_bst_information15		=> p_bst_information15
      ,p_bst_information16		=> p_bst_information16
      ,p_bst_information17		=> p_bst_information17
      ,p_bst_information18		=> p_bst_information18
      ,p_bst_information19		=> p_bst_information19
      ,p_bst_information20		=> p_bst_information20
      ,p_booking_status_type_id         => l_booking_status_type_id
      ,p_object_version_number          => l_object_version_number
 --          ,p_data_source           => p_data_source
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BOOKING_STATUS_TYPE'
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
  p_booking_status_type_id := l_booking_status_type_id;
  p_object_version_number   := l_object_version_number;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_BOOKING_STATUS_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_booking_status_type_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_BOOKING_STATUS_TYPE;
    p_booking_status_type_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_BOOKING_STATUS_TYPE;
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_BOOKING_STATUS_TYPE >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_BOOKING_STATUS_TYPE
  (p_validate                     in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_active_flag                    in     varchar2 default hr_api.g_varchar2
  ,p_default_flag                   in     varchar2 default hr_api.g_varchar2
  ,p_name                           in     varchar2 default hr_api.g_varchar2
  ,p_type                           in     varchar2 default hr_api.g_varchar2
  ,p_place_used_flag                in     varchar2 default hr_api.g_varchar2
  ,p_comments                       in     varchar2 default hr_api.g_varchar2
  ,p_description                    in     varchar2 default hr_api.g_varchar2
  ,p_bst_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_bst_information1               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information2               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information3               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information4               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information5               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information6               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information7               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information8               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information9               in     varchar2 default hr_api.g_varchar2
  ,p_bst_information10              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information11              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information12              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information13              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information14              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information15              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information16              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information17              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information18              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information19              in     varchar2 default hr_api.g_varchar2
  ,p_bst_information20              in     varchar2 default hr_api.g_varchar2
  ,p_booking_status_type_id         in	   number default hr_api.g_number
  ,p_object_version_number          in out    nocopy number
--  ,p_data_source                    in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Training Plan';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  l_name varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_BOOKING_STATUS_TYPE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_name := rtrim(p_name);
  --
  -- Call Before Process User Hook
  --

  begin
    OTA_BOOKING_STATUS_TYPE_BK2.UPDATE_BOOKING_STATUS_TYPE_B
  (p_effective_date                 => l_effective_date
      ,p_business_group_id	        => p_business_group_id
      ,p_active_flag                    => p_active_flag
      ,p_default_flag                   => p_default_flag
      ,p_place_used_flag                => p_place_used_flag
      ,p_name                           => p_name
      ,p_type                           => p_type
      ,p_comments                       => p_comments
      ,p_description                    => p_description
      ,p_bst_information_category       => p_bst_information_category
      ,p_bst_information1		=> p_bst_information1
      ,p_bst_information2		=> p_bst_information2
      ,p_bst_information3		=> p_bst_information3
      ,p_bst_information4		=> p_bst_information4
      ,p_bst_information5		=> p_bst_information5
      ,p_bst_information6		=> p_bst_information6
      ,p_bst_information7		=> p_bst_information7
      ,p_bst_information8		=> p_bst_information8
      ,p_bst_information9		=> p_bst_information9
      ,p_bst_information10		=> p_bst_information10
      ,p_bst_information11		=> p_bst_information11
      ,p_bst_information12		=> p_bst_information12
      ,p_bst_information13		=> p_bst_information13
      ,p_bst_information14		=> p_bst_information14
      ,p_bst_information15		=> p_bst_information15
      ,p_bst_information16		=> p_bst_information16
      ,p_bst_information17		=> p_bst_information17
      ,p_bst_information18		=> p_bst_information18
      ,p_bst_information19		=> p_bst_information19
      ,p_bst_information20		=> p_bst_information20
      ,p_booking_status_type_id         => p_booking_status_type_id
      ,p_object_version_number          => p_object_version_number
 --   ,p_data_source           => p_data_source
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BOOKING_STATUS_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  ota_bst_api.upd
    (--p_effective_date                 => l_effective_date
       p_booking_status_type_id         => p_booking_status_type_id
      ,p_business_group_id	        => p_business_group_id
      ,p_active_flag                    => p_active_flag
      ,p_default_flag                   => p_default_flag
  --    ,p_place_used_flag                => p_place_used_flag
      ,p_name                           => p_name
      ,p_object_version_number          => p_object_version_number
      ,p_type                           => p_type
      ,p_comments                       => p_comments
      ,p_description                    => p_description
      ,p_bst_information_category       => p_bst_information_category
      ,p_bst_information1		=> p_bst_information1
      ,p_bst_information2		=> p_bst_information2
      ,p_bst_information3		=> p_bst_information3
      ,p_bst_information4		=> p_bst_information4
      ,p_bst_information5		=> p_bst_information5
      ,p_bst_information6		=> p_bst_information6
      ,p_bst_information7		=> p_bst_information7
      ,p_bst_information8		=> p_bst_information8
      ,p_bst_information9		=> p_bst_information9
      ,p_bst_information10		=> p_bst_information10
      ,p_bst_information11		=> p_bst_information11
      ,p_bst_information12		=> p_bst_information12
      ,p_bst_information13		=> p_bst_information13
      ,p_bst_information14		=> p_bst_information14
      ,p_bst_information15		=> p_bst_information15
      ,p_bst_information16		=> p_bst_information16
      ,p_bst_information17		=> p_bst_information17
      ,p_bst_information18		=> p_bst_information18
      ,p_bst_information19		=> p_bst_information19
      ,p_bst_information20		=> p_bst_information20

    );

  ota_bsl_upd.upd_tl(p_effective_date   =>  p_effective_date
    ,p_language_code     =>  USERENV('LANG')
    ,P_BOOKING_STATUS_TYPE_ID    =>    P_BOOKING_STATUS_TYPE_ID
    ,p_name           =>    l_name
    ,p_description                    => p_description   );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_BOOKING_STATUS_TYPE_BK2.UPDATE_BOOKING_STATUS_TYPE_A
  (p_effective_date                 => l_effective_date
      ,p_business_group_id	        => p_business_group_id
      ,p_active_flag                    => p_active_flag
      ,p_default_flag                   => p_default_flag
      ,p_place_used_flag                => p_place_used_flag
      ,p_name                           => p_name
      ,p_type                           => p_type
      ,p_comments                       => p_comments
      ,p_description                    => p_description
      ,p_bst_information_category       => p_bst_information_category
      ,p_bst_information1		=> p_bst_information1
      ,p_bst_information2		=> p_bst_information2
      ,p_bst_information3		=> p_bst_information3
      ,p_bst_information4		=> p_bst_information4
      ,p_bst_information5		=> p_bst_information5
      ,p_bst_information6		=> p_bst_information6
      ,p_bst_information7		=> p_bst_information7
      ,p_bst_information8		=> p_bst_information8
      ,p_bst_information9		=> p_bst_information9
      ,p_bst_information10		=> p_bst_information10
      ,p_bst_information11		=> p_bst_information11
      ,p_bst_information12		=> p_bst_information12
      ,p_bst_information13		=> p_bst_information13
      ,p_bst_information14		=> p_bst_information14
      ,p_bst_information15		=> p_bst_information15
      ,p_bst_information16		=> p_bst_information16
      ,p_bst_information17		=> p_bst_information17
      ,p_bst_information18		=> p_bst_information18
      ,p_bst_information19		=> p_bst_information19
      ,p_bst_information20		=> p_bst_information20
      ,p_booking_status_type_id         => p_booking_status_type_id
      ,p_object_version_number          => p_object_version_number
 --     ,p_data_source           => p_data_source
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BOOKING_STATUS_TYPE'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_BOOKING_STATUS_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_BOOKING_STATUS_TYPE;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_BOOKING_STATUS_TYPE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_BOOKING_STATUS_TYPE >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BOOKING_STATUS_TYPE
  (p_validate                      in     boolean  default false
  ,p_booking_status_type_id                   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Training Plan';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_BOOKING_STATUS_TYPE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    OTA_BOOKING_STATUS_TYPE_BK3.DELETE_BOOKING_STATUS_TYPE_B
  (p_BOOKING_STATUS_TYPE_id            => p_BOOKING_STATUS_TYPE_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BOOKING_STATUS_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_bst_api.del
  (P_BOOKING_STATUS_TYPE_ID        => P_BOOKING_STATUS_TYPE_ID
  ,p_object_version_number   => p_object_version_number
  ,p_validate    =>    p_validate
  );

  ota_bsl_del.del_tl
  (P_BOOKING_STATUS_TYPE_ID        => P_BOOKING_STATUS_TYPE_ID
   --,p_language =>  USERENV('LANG')
  );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_BOOKING_STATUS_TYPE_BK3.DELETE_BOOKING_STATUS_TYPE_A
  (P_BOOKING_STATUS_TYPE_ID            => P_BOOKING_STATUS_TYPE_ID
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BOOKING_STATUS_TYPE'
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
    rollback to DELETE_BOOKING_STATUS_TYPE;
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
    rollback to DELETE_BOOKING_STATUS_TYPE;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_BOOKING_STATUS_TYPE;
--


END OTA_BOOKING_STATUS_TYPE_API;

/
