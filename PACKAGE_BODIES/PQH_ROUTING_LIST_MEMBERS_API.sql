--------------------------------------------------------
--  DDL for Package Body PQH_ROUTING_LIST_MEMBERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROUTING_LIST_MEMBERS_API" as
/* $Header: pqrlmapi.pkb 115.5 2002/12/06 18:08:08 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_ROUTING_LIST_MEMBERS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_routing_list_member >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_list_member
  (p_validate                       in  boolean   default false
  ,p_role_id                        in  number    default null
  ,p_routing_list_id                in  number    default null
  ,p_routing_list_member_id         out nocopy number
  ,p_seq_no                         in  number    default null
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_object_version_number          out nocopy number
  ,p_user_id                        in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_routing_list_member_id pqh_routing_list_members.routing_list_member_id%TYPE;
  l_proc varchar2(72) := g_package||'create_routing_list_member';
  l_object_version_number pqh_routing_list_members.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_routing_list_member;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_routing_list_member
    --
    PQH_ROUTING_LIST_MEMBERS_bk1.create_routing_list_member_b
      (
       p_role_id                        =>  p_role_id
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_seq_no                         =>  p_seq_no
      ,p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag			=>  p_enable_flag
      ,p_user_id                        =>  p_user_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ROUTING_LIST_MEMBER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_routing_list_member
    --
  end;
  --
  pqh_rlm_ins.ins
    (
     p_routing_list_member_id        => l_routing_list_member_id
    ,p_role_id                       => p_role_id
    ,p_routing_list_id               => p_routing_list_id
    ,p_seq_no                        => p_seq_no
    ,p_approver_flag                 => p_approver_flag
    ,p_enable_flag		     => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    ,p_user_id                       => p_user_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_routing_list_member
    --
    PQH_ROUTING_LIST_MEMBERS_bk1.create_routing_list_member_a
      (
       p_role_id                        =>  p_role_id
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_routing_list_member_id         =>  l_routing_list_member_id
      ,p_seq_no                         =>  p_seq_no
      ,p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag			=>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_user_id                        =>  p_user_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ROUTING_LIST_MEMBER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_routing_list_member
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
  p_routing_list_member_id := l_routing_list_member_id;
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
    ROLLBACK TO create_routing_list_member;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_routing_list_member_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_routing_list_member_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_routing_list_member;
    raise;
    --
end create_routing_list_member;
-- ----------------------------------------------------------------------------
-- |------------------------< update_routing_list_member >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_list_member
  (p_validate                       in  boolean   default false
  ,p_role_id                        in  number    default hr_api.g_number
  ,p_routing_list_id                in  number    default hr_api.g_number
  ,p_routing_list_member_id         in  number
  ,p_seq_no                         in  number    default hr_api.g_number
  ,p_approver_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_user_id                        in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_routing_list_member';
  l_object_version_number pqh_routing_list_members.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_routing_list_member;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_routing_list_member
    --
    PQH_ROUTING_LIST_MEMBERS_bk2.update_routing_list_member_b
      (
       p_role_id                        =>  p_role_id
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_seq_no                         =>  p_seq_no
      ,p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag			=>  p_enable_flag
      ,p_object_version_number          =>  p_object_version_number
      ,p_user_id                        =>  p_user_id
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_LIST_MEMBER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_routing_list_member
    --
  end;
  --
  pqh_rlm_upd.upd
    (
     p_routing_list_member_id        => p_routing_list_member_id
    ,p_role_id                       => p_role_id
    ,p_routing_list_id               => p_routing_list_id
    ,p_seq_no                        => p_seq_no
    ,p_approver_flag                 => p_approver_flag
    ,p_enable_flag		     => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    ,p_user_id                       => p_user_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_routing_list_member
    --
    PQH_ROUTING_LIST_MEMBERS_bk2.update_routing_list_member_a
      (
       p_role_id                        =>  p_role_id
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_seq_no                         =>  p_seq_no
      ,p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag			=>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_user_id                        =>  p_user_id
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_LIST_MEMBER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_routing_list_member
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
    ROLLBACK TO update_routing_list_member;
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
    ROLLBACK TO update_routing_list_member;
    raise;
    --
end update_routing_list_member;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_routing_list_member >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_list_member
  (p_validate                       in  boolean  default false
  ,p_routing_list_member_id         in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_routing_list_member';
  l_object_version_number pqh_routing_list_members.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_routing_list_member;
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
    -- Start of API User Hook for the before hook of delete_routing_list_member
    --
    PQH_ROUTING_LIST_MEMBERS_bk3.delete_routing_list_member_b
      (
       p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_LIST_MEMBER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_routing_list_member
    --
  end;
  --
  pqh_rlm_del.del
    (
     p_routing_list_member_id        => p_routing_list_member_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_routing_list_member
    --
    PQH_ROUTING_LIST_MEMBERS_bk3.delete_routing_list_member_a
      (
       p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_LIST_MEMBER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_routing_list_member
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
    ROLLBACK TO delete_routing_list_member;
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
    ROLLBACK TO delete_routing_list_member;
    raise;
    --
end delete_routing_list_member;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_routing_list_member_id                   in     number
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
  pqh_rlm_shd.lck
    (
      p_routing_list_member_id                 => p_routing_list_member_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end PQH_ROUTING_LIST_MEMBERS_api;

/
