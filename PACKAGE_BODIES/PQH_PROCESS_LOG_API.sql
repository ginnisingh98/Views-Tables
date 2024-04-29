--------------------------------------------------------
--  DDL for Package Body PQH_PROCESS_LOG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PROCESS_LOG_API" as
/* $Header: pqplgapi.pkb 115.5 2002/12/06 18:06:42 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_process_log_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_process_log >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_process_log
  (p_validate                       in  boolean   default false
  ,p_process_log_id                 out nocopy number
  ,p_module_cd                      in  varchar2  default null
  ,p_txn_id                         in  number    default null
  ,p_master_process_log_id          in  number    default null
  ,p_message_text                   in  varchar2  default null
  ,p_message_type_cd                in  varchar2  default null
  ,p_batch_status                   in  varchar2  default null
  ,p_batch_start_date               in  date      default null
  ,p_batch_end_date                 in  date      default null
  ,p_txn_table_route_id             in  number    default null
  ,p_log_context                    in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_process_log_id pqh_process_log.process_log_id%TYPE;
  l_proc varchar2(72) := g_package||'create_process_log';
  l_object_version_number pqh_process_log.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_process_log;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_process_log
    --
    pqh_process_log_bk1.create_process_log_b
      (
       p_module_cd                      =>  p_module_cd
      ,p_txn_id                         =>  p_txn_id
      ,p_master_process_log_id          =>  p_master_process_log_id
      ,p_message_text                   =>  p_message_text
      ,p_message_type_cd                =>  p_message_type_cd
      ,p_batch_status                   =>  p_batch_status
      ,p_batch_start_date               =>  p_batch_start_date
      ,p_batch_end_date                 =>  p_batch_end_date
      ,p_txn_table_route_id             =>  p_txn_table_route_id
      ,p_log_context                    =>  p_log_context
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PROCESS_LOG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_process_log
    --
  end;
  --
  pqh_plg_ins.ins
    (
     p_process_log_id                => l_process_log_id
    ,p_module_cd                     => p_module_cd
    ,p_txn_id                        => p_txn_id
    ,p_master_process_log_id         => p_master_process_log_id
    ,p_message_text                  => p_message_text
    ,p_message_type_cd               => p_message_type_cd
    ,p_batch_status                  => p_batch_status
    ,p_batch_start_date              => p_batch_start_date
    ,p_batch_end_date                => p_batch_end_date
    ,p_txn_table_route_id            => p_txn_table_route_id
    ,p_log_context                   => p_log_context
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_process_log
    --
    pqh_process_log_bk1.create_process_log_a
      (
       p_process_log_id                 =>  l_process_log_id
      ,p_module_cd                      =>  p_module_cd
      ,p_txn_id                         =>  p_txn_id
      ,p_master_process_log_id          =>  p_master_process_log_id
      ,p_message_text                   =>  p_message_text
      ,p_message_type_cd                =>  p_message_type_cd
      ,p_batch_status                   =>  p_batch_status
      ,p_batch_start_date               =>  p_batch_start_date
      ,p_batch_end_date                 =>  p_batch_end_date
      ,p_txn_table_route_id             =>  p_txn_table_route_id
      ,p_log_context                    =>  p_log_context
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PROCESS_LOG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_process_log
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_process_log_id := l_process_log_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_process_log;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_process_log_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_process_log_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_process_log;
    raise;
    --
end create_process_log;
-- ----------------------------------------------------------------------------
-- |------------------------< update_process_log >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_process_log
  (p_validate                       in  boolean   default false
  ,p_process_log_id                 in  number
  ,p_module_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_txn_id                         in  number    default hr_api.g_number
  ,p_master_process_log_id          in  number    default hr_api.g_number
  ,p_message_text                   in  varchar2  default hr_api.g_varchar2
  ,p_message_type_cd                in  varchar2  default hr_api.g_varchar2
  ,p_batch_status                   in  varchar2  default hr_api.g_varchar2
  ,p_batch_start_date               in  date      default hr_api.g_date
  ,p_batch_end_date                 in  date      default hr_api.g_date
  ,p_txn_table_route_id             in  number    default hr_api.g_number
  ,p_log_context                    in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_process_log';
  l_object_version_number pqh_process_log.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_process_log;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_process_log
    --
    pqh_process_log_bk2.update_process_log_b
      (
       p_process_log_id                 =>  p_process_log_id
      ,p_module_cd                      =>  p_module_cd
      ,p_txn_id                         =>  p_txn_id
      ,p_master_process_log_id          =>  p_master_process_log_id
      ,p_message_text                   =>  p_message_text
      ,p_message_type_cd                =>  p_message_type_cd
      ,p_batch_status                   =>  p_batch_status
      ,p_batch_start_date               =>  p_batch_start_date
      ,p_batch_end_date                 =>  p_batch_end_date
      ,p_txn_table_route_id             =>  p_txn_table_route_id
      ,p_log_context                    =>  p_log_context
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROCESS_LOG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_process_log
    --
  end;
  --
  pqh_plg_upd.upd
    (
     p_process_log_id                => p_process_log_id
    ,p_module_cd                     => p_module_cd
    ,p_txn_id                        => p_txn_id
    ,p_master_process_log_id         => p_master_process_log_id
    ,p_message_text                  => p_message_text
    ,p_message_type_cd               => p_message_type_cd
    ,p_batch_status                  => p_batch_status
    ,p_batch_start_date              => p_batch_start_date
    ,p_batch_end_date                => p_batch_end_date
    ,p_txn_table_route_id            => p_txn_table_route_id
    ,p_log_context                   => p_log_context
    ,p_information_category          => p_information_category
    ,p_information1                  => p_information1
    ,p_information2                  => p_information2
    ,p_information3                  => p_information3
    ,p_information4                  => p_information4
    ,p_information5                  => p_information5
    ,p_information6                  => p_information6
    ,p_information7                  => p_information7
    ,p_information8                  => p_information8
    ,p_information9                  => p_information9
    ,p_information10                 => p_information10
    ,p_information11                 => p_information11
    ,p_information12                 => p_information12
    ,p_information13                 => p_information13
    ,p_information14                 => p_information14
    ,p_information15                 => p_information15
    ,p_information16                 => p_information16
    ,p_information17                 => p_information17
    ,p_information18                 => p_information18
    ,p_information19                 => p_information19
    ,p_information20                 => p_information20
    ,p_information21                 => p_information21
    ,p_information22                 => p_information22
    ,p_information23                 => p_information23
    ,p_information24                 => p_information24
    ,p_information25                 => p_information25
    ,p_information26                 => p_information26
    ,p_information27                 => p_information27
    ,p_information28                 => p_information28
    ,p_information29                 => p_information29
    ,p_information30                 => p_information30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_process_log
    --
    pqh_process_log_bk2.update_process_log_a
      (
       p_process_log_id                 =>  p_process_log_id
      ,p_module_cd                      =>  p_module_cd
      ,p_txn_id                         =>  p_txn_id
      ,p_master_process_log_id          =>  p_master_process_log_id
      ,p_message_text                   =>  p_message_text
      ,p_message_type_cd                =>  p_message_type_cd
      ,p_batch_status                   =>  p_batch_status
      ,p_batch_start_date               =>  p_batch_start_date
      ,p_batch_end_date                 =>  p_batch_end_date
      ,p_txn_table_route_id             =>  p_txn_table_route_id
      ,p_log_context                    =>  p_log_context
      ,p_information_category           =>  p_information_category
      ,p_information1                   =>  p_information1
      ,p_information2                   =>  p_information2
      ,p_information3                   =>  p_information3
      ,p_information4                   =>  p_information4
      ,p_information5                   =>  p_information5
      ,p_information6                   =>  p_information6
      ,p_information7                   =>  p_information7
      ,p_information8                   =>  p_information8
      ,p_information9                   =>  p_information9
      ,p_information10                  =>  p_information10
      ,p_information11                  =>  p_information11
      ,p_information12                  =>  p_information12
      ,p_information13                  =>  p_information13
      ,p_information14                  =>  p_information14
      ,p_information15                  =>  p_information15
      ,p_information16                  =>  p_information16
      ,p_information17                  =>  p_information17
      ,p_information18                  =>  p_information18
      ,p_information19                  =>  p_information19
      ,p_information20                  =>  p_information20
      ,p_information21                  =>  p_information21
      ,p_information22                  =>  p_information22
      ,p_information23                  =>  p_information23
      ,p_information24                  =>  p_information24
      ,p_information25                  =>  p_information25
      ,p_information26                  =>  p_information26
      ,p_information27                  =>  p_information27
      ,p_information28                  =>  p_information28
      ,p_information29                  =>  p_information29
      ,p_information30                  =>  p_information30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROCESS_LOG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_process_log
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_process_log;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
     p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_process_log;
    raise;
    --
end update_process_log;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_process_log >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_process_log
  (p_validate                       in  boolean  default false
  ,p_process_log_id                 in  number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_process_log';
  l_object_version_number pqh_process_log.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_process_log;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_process_log
    --
    pqh_process_log_bk3.delete_process_log_b
      (
       p_process_log_id                 =>  p_process_log_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROCESS_LOG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_process_log
    --
  end;
  --
  pqh_plg_del.del
    (
     p_process_log_id                => p_process_log_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_process_log
    --
    pqh_process_log_bk3.delete_process_log_a
      (
       p_process_log_id                 =>  p_process_log_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROCESS_LOG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_process_log
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_process_log;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_process_log;
    raise;
    --
end delete_process_log;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_process_log_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pqh_plg_shd.lck
    (
      p_process_log_id                 => p_process_log_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_process_log_api;

/
