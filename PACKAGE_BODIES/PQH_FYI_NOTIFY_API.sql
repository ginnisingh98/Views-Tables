--------------------------------------------------------
--  DDL for Package Body PQH_FYI_NOTIFY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FYI_NOTIFY_API" as
/* $Header: pqfynapi.pkb 115.4 2002/12/06 18:06:21 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_fyi_notify_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_fyi_notify >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fyi_notify
  (p_validate                       in  boolean   default false
  ,p_fyi_notified_id                out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_notification_event_cd          in  varchar2  default null
  ,p_notified_type_cd               in  varchar2  default null
  ,p_notified_name                  in  varchar2  default null
  ,p_notification_date              in  date      default null
  ,p_status                         in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_fyi_notified_id pqh_fyi_notify.fyi_notified_id%TYPE;
  l_proc varchar2(72) := g_package||'create_fyi_notify';
  l_object_version_number pqh_fyi_notify.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_fyi_notify;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_fyi_notify
    --
    pqh_fyi_notify_bk1.create_fyi_notify_b
      (
       p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_notification_event_cd          =>  p_notification_event_cd
      ,p_notified_type_cd               =>  p_notified_type_cd
      ,p_notified_name                  =>  p_notified_name
      ,p_notification_date              =>  p_notification_date
      ,p_status                         =>  p_status
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_FYI_NOTIFY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_fyi_notify
    --
  end;
  --
  pqh_fyn_ins.ins
    (
     p_fyi_notified_id               => l_fyi_notified_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_transaction_id                => p_transaction_id
    ,p_notification_event_cd         => p_notification_event_cd
    ,p_notified_type_cd              => p_notified_type_cd
    ,p_notified_name                 => p_notified_name
    ,p_notification_date             => p_notification_date
    ,p_status                        => p_status
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_fyi_notify
    --
    pqh_fyi_notify_bk1.create_fyi_notify_a
      (
       p_fyi_notified_id                =>  l_fyi_notified_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_notification_event_cd          =>  p_notification_event_cd
      ,p_notified_type_cd               =>  p_notified_type_cd
      ,p_notified_name                  =>  p_notified_name
      ,p_notification_date              =>  p_notification_date
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_FYI_NOTIFY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_fyi_notify
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
  p_fyi_notified_id := l_fyi_notified_id;
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
    ROLLBACK TO create_fyi_notify;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_fyi_notified_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_fyi_notified_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_fyi_notify;
    raise;
    --
end create_fyi_notify;
-- ----------------------------------------------------------------------------
-- |------------------------< update_fyi_notify >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_fyi_notify
  (p_validate                       in  boolean   default false
  ,p_fyi_notified_id                in  number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_transaction_id                 in  number    default hr_api.g_number
  ,p_notification_event_cd          in  varchar2  default hr_api.g_varchar2
  ,p_notified_type_cd               in  varchar2  default hr_api.g_varchar2
  ,p_notified_name                  in  varchar2  default hr_api.g_varchar2
  ,p_notification_date              in  date      default hr_api.g_date
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_fyi_notify';
  l_object_version_number pqh_fyi_notify.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_fyi_notify;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_fyi_notify
    --
    pqh_fyi_notify_bk2.update_fyi_notify_b
      (
       p_fyi_notified_id                =>  p_fyi_notified_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_notification_event_cd          =>  p_notification_event_cd
      ,p_notified_type_cd               =>  p_notified_type_cd
      ,p_notified_name                  =>  p_notified_name
      ,p_notification_date              =>  p_notification_date
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FYI_NOTIFY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_fyi_notify
    --
  end;
  --
  pqh_fyn_upd.upd
    (
     p_fyi_notified_id               => p_fyi_notified_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_transaction_id                => p_transaction_id
    ,p_notification_event_cd         => p_notification_event_cd
    ,p_notified_type_cd              => p_notified_type_cd
    ,p_notified_name                 => p_notified_name
    ,p_notification_date             => p_notification_date
    ,p_status                        => p_status
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_fyi_notify
    --
    pqh_fyi_notify_bk2.update_fyi_notify_a
      (
       p_fyi_notified_id                =>  p_fyi_notified_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_notification_event_cd          =>  p_notification_event_cd
      ,p_notified_type_cd               =>  p_notified_type_cd
      ,p_notified_name                  =>  p_notified_name
      ,p_notification_date              =>  p_notification_date
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_FYI_NOTIFY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_fyi_notify
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
    ROLLBACK TO update_fyi_notify;
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
    ROLLBACK TO update_fyi_notify;
    raise;
    --
end update_fyi_notify;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_fyi_notify >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fyi_notify
  (p_validate                       in  boolean  default false
  ,p_fyi_notified_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_fyi_notify';
  l_object_version_number pqh_fyi_notify.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_fyi_notify;
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
    -- Start of API User Hook for the before hook of delete_fyi_notify
    --
    pqh_fyi_notify_bk3.delete_fyi_notify_b
      (
       p_fyi_notified_id                =>  p_fyi_notified_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FYI_NOTIFY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_fyi_notify
    --
  end;
  --
  pqh_fyn_del.del
    (
     p_fyi_notified_id               => p_fyi_notified_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_fyi_notify
    --
    pqh_fyi_notify_bk3.delete_fyi_notify_a
      (
       p_fyi_notified_id                =>  p_fyi_notified_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_FYI_NOTIFY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_fyi_notify
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
    ROLLBACK TO delete_fyi_notify;
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
    ROLLBACK TO delete_fyi_notify;
    raise;
    --
end delete_fyi_notify;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_fyi_notified_id                   in     number
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
  pqh_fyn_shd.lck
    (
      p_fyi_notified_id                 => p_fyi_notified_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_fyi_notify_api;

/
