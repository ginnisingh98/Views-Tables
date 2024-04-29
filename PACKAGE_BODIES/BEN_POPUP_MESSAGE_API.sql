--------------------------------------------------------
--  DDL for Package Body BEN_POPUP_MESSAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POPUP_MESSAGE_API" as
/* $Header: bepumapi.pkb 115.2 2002/12/13 08:31:02 bmanyam ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_popup_message_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_popup_message >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_popup_message
  (p_validate                       in  boolean   default false
  ,p_pop_up_messages_id             out nocopy number
  ,p_pop_name                       in  varchar2  default null
  ,p_formula_id                     in  number    default null
  ,p_function_name                  in  varchar2  default null
  ,p_block_name                     in  varchar2  default null
  ,p_field_name                     in  varchar2  default null
  ,p_event_name                     in  varchar2  default null
  ,p_message                        in  varchar2  default null
  ,p_message_type                   in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_start_date                     in  date      default null
  ,p_end_date                       in  date      default null
  ,p_no_formula_flag                in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pop_up_messages_id ben_pop_up_messages.pop_up_messages_id%TYPE;
  l_proc varchar2(72) := g_package||'create_popup_message';
  l_object_version_number ben_pop_up_messages.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_popup_message;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_popup_message
    --
    ben_popup_message_bk1.create_popup_message_b
      (
       p_pop_name                       =>  p_pop_name
      ,p_formula_id                     =>  p_formula_id
      ,p_function_name                  =>  p_function_name
      ,p_block_name                     =>  p_block_name
      ,p_field_name                     =>  p_field_name
      ,p_event_name                     =>  p_event_name
      ,p_message                        =>  p_message
      ,p_message_type                   =>  p_message_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      ,p_no_formula_flag                =>  p_no_formula_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_popup_message'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_popup_message
    --
  end;
  --
  ben_pum_ins.ins
    (
     p_pop_up_messages_id            => l_pop_up_messages_id
    ,p_pop_name                      => p_pop_name
    ,p_formula_id                    => p_formula_id
    ,p_function_name                 => p_function_name
    ,p_block_name                    => p_block_name
    ,p_field_name                    => p_field_name
    ,p_event_name                    => p_event_name
    ,p_message                       => p_message
    ,p_message_type                  => p_message_type
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_start_date                    => p_start_date
    ,p_end_date                      => p_end_date
    ,p_no_formula_flag               => p_no_formula_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_popup_message
    --
    ben_popup_message_bk1.create_popup_message_a
      (
       p_pop_up_messages_id             =>  l_pop_up_messages_id
      ,p_pop_name                       =>  p_pop_name
      ,p_formula_id                     =>  p_formula_id
      ,p_function_name                  =>  p_function_name
      ,p_block_name                     =>  p_block_name
      ,p_field_name                     =>  p_field_name
      ,p_event_name                     =>  p_event_name
      ,p_message                        =>  p_message
      ,p_message_type                   =>  p_message_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      ,p_no_formula_flag                =>  p_no_formula_flag
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_popup_message'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_popup_message
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
  p_pop_up_messages_id := l_pop_up_messages_id;
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
    ROLLBACK TO create_popup_message;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pop_up_messages_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_popup_message;
    -- NOCOPY Changes
    p_pop_up_messages_id := null;
    p_object_version_number  := null;
    -- NOCOPY Changes
    raise;
    --
end create_popup_message;
-- ----------------------------------------------------------------------------
-- |------------------------< update_popup_message >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_popup_message
  (p_validate                       in  boolean   default false
  ,p_pop_up_messages_id             in  number
  ,p_pop_name                       in  varchar2  default hr_api.g_varchar2
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_function_name                  in  varchar2  default hr_api.g_varchar2
  ,p_block_name                     in  varchar2  default hr_api.g_varchar2
  ,p_field_name                     in  varchar2  default hr_api.g_varchar2
  ,p_event_name                     in  varchar2  default hr_api.g_varchar2
  ,p_message                        in  varchar2  default hr_api.g_varchar2
  ,p_message_type                   in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_end_date                       in  date      default hr_api.g_date
  ,p_no_formula_flag                in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_popup_message';
  l_object_version_number ben_pop_up_messages.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_popup_message;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_popup_message
    --
    ben_popup_message_bk2.update_popup_message_b
      (
       p_pop_up_messages_id             =>  p_pop_up_messages_id
      ,p_pop_name                       =>  p_pop_name
      ,p_formula_id                     =>  p_formula_id
      ,p_function_name                  =>  p_function_name
      ,p_block_name                     =>  p_block_name
      ,p_field_name                     =>  p_field_name
      ,p_event_name                     =>  p_event_name
      ,p_message                        =>  p_message
      ,p_message_type                   =>  p_message_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      ,p_no_formula_flag                =>  p_no_formula_flag
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_popup_message'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_popup_message
    --
  end;
  --
  ben_pum_upd.upd
    (
     p_pop_up_messages_id            => p_pop_up_messages_id
    ,p_pop_name                      => p_pop_name
    ,p_formula_id                    => p_formula_id
    ,p_function_name                 => p_function_name
    ,p_block_name                    => p_block_name
    ,p_field_name                    => p_field_name
    ,p_event_name                    => p_event_name
    ,p_message                       => p_message
    ,p_message_type                  => p_message_type
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_start_date                    => p_start_date
    ,p_end_date                      => p_end_date
    ,p_no_formula_flag               => p_no_formula_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_popup_message
    --
    ben_popup_message_bk2.update_popup_message_a
      (
       p_pop_up_messages_id             =>  p_pop_up_messages_id
      ,p_pop_name                       =>  p_pop_name
      ,p_formula_id                     =>  p_formula_id
      ,p_function_name                  =>  p_function_name
      ,p_block_name                     =>  p_block_name
      ,p_field_name                     =>  p_field_name
      ,p_event_name                     =>  p_event_name
      ,p_message                        =>  p_message
      ,p_message_type                   =>  p_message_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      ,p_no_formula_flag                =>  p_no_formula_flag
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_popup_message'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_popup_message
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
    ROLLBACK TO update_popup_message;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_popup_message;
    raise;
    --
end update_popup_message;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_popup_message >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_popup_message
  (p_validate                       in  boolean  default false
  ,p_pop_up_messages_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_popup_message';
  l_object_version_number ben_pop_up_messages.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_popup_message;
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
    -- Start of API User Hook for the before hook of delete_popup_message
    --
    ben_popup_message_bk3.delete_popup_message_b
      (
       p_pop_up_messages_id             =>  p_pop_up_messages_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_popup_message'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_popup_message
    --
  end;
  --
  ben_pum_del.del
    (
     p_pop_up_messages_id            => p_pop_up_messages_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_popup_message
    --
    ben_popup_message_bk3.delete_popup_message_a
      (
       p_pop_up_messages_id             =>  p_pop_up_messages_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_popup_message'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_popup_message
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
    ROLLBACK TO delete_popup_message;
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
    ROLLBACK TO delete_popup_message;
    raise;
    --
end delete_popup_message;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pop_up_messages_id                   in     number
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
  ben_pum_shd.lck
    (
      p_pop_up_messages_id                 => p_pop_up_messages_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_popup_message_api;

/
