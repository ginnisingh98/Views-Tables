--------------------------------------------------------
--  DDL for Package Body PQH_ROUTING_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROUTING_HISTORY_API" as
/* $Header: pqrhtapi.pkb 115.6 2002/12/06 18:07:57 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_routing_history_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_routing_history >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_history
  (p_validate                       in  boolean   default false
  ,p_routing_history_id             out nocopy number
  ,p_approval_cd                    in  varchar2  default null
  ,p_comments                       in  varchar2  default null
  ,p_forwarded_by_assignment_id     in  number    default null
  ,p_forwarded_by_member_id         in  number    default null
  ,p_forwarded_by_position_id       in  number    default null
  ,p_forwarded_by_user_id           in  number    default null
  ,p_forwarded_by_role_id           in  number    default null
  ,p_forwarded_to_assignment_id     in  number    default null
  ,p_forwarded_to_member_id         in  number    default null
  ,p_forwarded_to_position_id       in  number    default null
  ,p_forwarded_to_user_id           in  number    default null
  ,p_forwarded_to_role_id           in  number    default null
  ,p_notification_date              in  date      default null
  ,p_pos_structure_version_id       in  number    default null
  ,p_routing_category_id            in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_user_action_cd                 in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_from_range_name                in  varchar2  default null
  ,p_to_range_name                  in  varchar2  default null
  ,p_list_range_name                in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_routing_history_id pqh_routing_history.routing_history_id%TYPE;
  l_proc varchar2(72) := g_package||'create_routing_history';
  l_object_version_number pqh_routing_history.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_routing_history;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_routing_history
    --
    pqh_routing_history_bk1.create_routing_history_b
      (
       p_approval_cd                    =>  p_approval_cd
      ,p_comments                       =>  p_comments
      ,p_forwarded_by_assignment_id     =>  p_forwarded_by_assignment_id
      ,p_forwarded_by_member_id         =>  p_forwarded_by_member_id
      ,p_forwarded_by_position_id       =>  p_forwarded_by_position_id
      ,p_forwarded_by_user_id           =>  p_forwarded_by_user_id
      ,p_forwarded_by_role_id           =>  p_forwarded_by_role_id
      ,p_forwarded_to_assignment_id     =>  p_forwarded_to_assignment_id
      ,p_forwarded_to_member_id         =>  p_forwarded_to_member_id
      ,p_forwarded_to_position_id       =>  p_forwarded_to_position_id
      ,p_forwarded_to_user_id           =>  p_forwarded_to_user_id
      ,p_forwarded_to_role_id           =>  p_forwarded_to_role_id
      ,p_notification_date              =>  p_notification_date
      ,p_pos_structure_version_id       =>  p_pos_structure_version_id
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_user_action_cd                 =>  p_user_action_cd
      ,p_from_range_name                =>  p_from_range_name
      ,p_to_range_name                  =>  p_to_range_name
      ,p_list_range_name                =>  p_list_range_name
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ROUTING_HISTORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_routing_history
    --
  end;
  --
  pqh_rht_ins.ins
    (
     p_routing_history_id            => l_routing_history_id
    ,p_approval_cd                   => p_approval_cd
    ,p_comments                      => p_comments
    ,p_forwarded_by_assignment_id    => p_forwarded_by_assignment_id
    ,p_forwarded_by_member_id        => p_forwarded_by_member_id
    ,p_forwarded_by_position_id      => p_forwarded_by_position_id
    ,p_forwarded_by_user_id          => p_forwarded_by_user_id
    ,p_forwarded_by_role_id          => p_forwarded_by_role_id
    ,p_forwarded_to_assignment_id    => p_forwarded_to_assignment_id
    ,p_forwarded_to_member_id        => p_forwarded_to_member_id
    ,p_forwarded_to_position_id      => p_forwarded_to_position_id
    ,p_forwarded_to_user_id          => p_forwarded_to_user_id
    ,p_forwarded_to_role_id          => p_forwarded_to_role_id
    ,p_notification_date             => p_notification_date
    ,p_pos_structure_version_id      => p_pos_structure_version_id
    ,p_routing_category_id           => p_routing_category_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_transaction_id                => p_transaction_id
    ,p_user_action_cd                => p_user_action_cd
    ,p_object_version_number         => l_object_version_number
    ,p_from_range_name               => p_from_range_name
    ,p_to_range_name                 => p_to_range_name
    ,p_list_range_name               => p_list_range_name
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_routing_history
    --
    pqh_routing_history_bk1.create_routing_history_a
      (
       p_routing_history_id             =>  l_routing_history_id
      ,p_approval_cd                    =>  p_approval_cd
      ,p_comments                       =>  p_comments
      ,p_forwarded_by_assignment_id     =>  p_forwarded_by_assignment_id
      ,p_forwarded_by_member_id         =>  p_forwarded_by_member_id
      ,p_forwarded_by_position_id       =>  p_forwarded_by_position_id
      ,p_forwarded_by_user_id           =>  p_forwarded_by_user_id
      ,p_forwarded_by_role_id           =>  p_forwarded_by_role_id
      ,p_forwarded_to_assignment_id     =>  p_forwarded_to_assignment_id
      ,p_forwarded_to_member_id         =>  p_forwarded_to_member_id
      ,p_forwarded_to_position_id       =>  p_forwarded_to_position_id
      ,p_forwarded_to_user_id           =>  p_forwarded_to_user_id
      ,p_forwarded_to_role_id           =>  p_forwarded_to_role_id
      ,p_notification_date              =>  p_notification_date
      ,p_pos_structure_version_id       =>  p_pos_structure_version_id
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_user_action_cd                 =>  p_user_action_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_from_range_name                =>  p_from_range_name
      ,p_to_range_name                  =>  p_to_range_name
      ,p_list_range_name                =>  p_list_range_name
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ROUTING_HISTORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_routing_history
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
  p_routing_history_id := l_routing_history_id;
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
    ROLLBACK TO create_routing_history;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_routing_history_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_routing_history_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_routing_history;
    raise;
    --
end create_routing_history;
-- ----------------------------------------------------------------------------
-- |------------------------< update_routing_history >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_history
  (p_validate                       in  boolean   default false
  ,p_routing_history_id             in  number
  ,p_approval_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_comments                       in  varchar2  default hr_api.g_varchar2
  ,p_forwarded_by_assignment_id     in  number    default hr_api.g_number
  ,p_forwarded_by_member_id         in  number    default hr_api.g_number
  ,p_forwarded_by_position_id       in  number    default hr_api.g_number
  ,p_forwarded_by_user_id           in  number    default hr_api.g_number
  ,p_forwarded_by_role_id           in  number    default hr_api.g_number
  ,p_forwarded_to_assignment_id     in  number    default hr_api.g_number
  ,p_forwarded_to_member_id         in  number    default hr_api.g_number
  ,p_forwarded_to_position_id       in  number    default hr_api.g_number
  ,p_forwarded_to_user_id           in  number    default hr_api.g_number
  ,p_forwarded_to_role_id           in  number    default hr_api.g_number
  ,p_notification_date              in  date      default hr_api.g_date
  ,p_pos_structure_version_id       in  number    default hr_api.g_number
  ,p_routing_category_id            in  number    default hr_api.g_number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_transaction_id                 in  number    default hr_api.g_number
  ,p_user_action_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_from_range_name                in  varchar2  default hr_api.g_varchar2
  ,p_to_range_name                  in  varchar2  default hr_api.g_varchar2
  ,p_list_range_name                in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_routing_history';
  l_object_version_number pqh_routing_history.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_routing_history;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_routing_history
    --
    pqh_routing_history_bk2.update_routing_history_b
      (
       p_routing_history_id             =>  p_routing_history_id
      ,p_approval_cd                    =>  p_approval_cd
      ,p_comments                       =>  p_comments
      ,p_forwarded_by_assignment_id     =>  p_forwarded_by_assignment_id
      ,p_forwarded_by_member_id         =>  p_forwarded_by_member_id
      ,p_forwarded_by_position_id       =>  p_forwarded_by_position_id
      ,p_forwarded_by_user_id           =>  p_forwarded_by_user_id
      ,p_forwarded_by_role_id           =>  p_forwarded_by_role_id
      ,p_forwarded_to_assignment_id     =>  p_forwarded_to_assignment_id
      ,p_forwarded_to_member_id         =>  p_forwarded_to_member_id
      ,p_forwarded_to_position_id       =>  p_forwarded_to_position_id
      ,p_forwarded_to_user_id           =>  p_forwarded_to_user_id
      ,p_forwarded_to_role_id           =>  p_forwarded_to_role_id
      ,p_notification_date              =>  p_notification_date
      ,p_pos_structure_version_id       =>  p_pos_structure_version_id
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_user_action_cd                 =>  p_user_action_cd
      ,p_object_version_number          =>  p_object_version_number
      ,p_from_range_name                =>  p_from_range_name
      ,p_to_range_name                  =>  p_to_range_name
      ,p_list_range_name                =>  p_list_range_name
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_HISTORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_routing_history
    --
  end;
  --
  pqh_rht_upd.upd
    (
     p_routing_history_id            => p_routing_history_id
    ,p_approval_cd                   => p_approval_cd
    ,p_comments                      => p_comments
    ,p_forwarded_by_assignment_id    => p_forwarded_by_assignment_id
    ,p_forwarded_by_member_id        => p_forwarded_by_member_id
    ,p_forwarded_by_position_id      => p_forwarded_by_position_id
    ,p_forwarded_by_user_id          => p_forwarded_by_user_id
    ,p_forwarded_by_role_id          => p_forwarded_by_role_id
    ,p_forwarded_to_assignment_id    => p_forwarded_to_assignment_id
    ,p_forwarded_to_member_id        => p_forwarded_to_member_id
    ,p_forwarded_to_position_id      => p_forwarded_to_position_id
    ,p_forwarded_to_user_id          => p_forwarded_to_user_id
    ,p_forwarded_to_role_id          => p_forwarded_to_role_id
    ,p_notification_date             => p_notification_date
    ,p_pos_structure_version_id      => p_pos_structure_version_id
    ,p_routing_category_id           => p_routing_category_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_transaction_id                => p_transaction_id
    ,p_user_action_cd                => p_user_action_cd
    ,p_object_version_number         => l_object_version_number
    ,p_from_range_name               => p_from_range_name
    ,p_to_range_name                 => p_to_range_name
    ,p_list_range_name               => p_list_range_name
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_routing_history
    --
    pqh_routing_history_bk2.update_routing_history_a
      (
       p_routing_history_id             =>  p_routing_history_id
      ,p_approval_cd                    =>  p_approval_cd
      ,p_comments                       =>  p_comments
      ,p_forwarded_by_assignment_id     =>  p_forwarded_by_assignment_id
      ,p_forwarded_by_member_id         =>  p_forwarded_by_member_id
      ,p_forwarded_by_position_id       =>  p_forwarded_by_position_id
      ,p_forwarded_by_user_id           =>  p_forwarded_by_user_id
      ,p_forwarded_by_role_id           =>  p_forwarded_by_role_id
      ,p_forwarded_to_assignment_id     =>  p_forwarded_to_assignment_id
      ,p_forwarded_to_member_id         =>  p_forwarded_to_member_id
      ,p_forwarded_to_position_id       =>  p_forwarded_to_position_id
      ,p_forwarded_to_user_id           =>  p_forwarded_to_user_id
      ,p_forwarded_to_role_id           =>  p_forwarded_to_role_id
      ,p_notification_date              =>  p_notification_date
      ,p_pos_structure_version_id       =>  p_pos_structure_version_id
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_user_action_cd                 =>  p_user_action_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_from_range_name                =>  p_from_range_name
      ,p_to_range_name                  =>  p_to_range_name
      ,p_list_range_name                =>  p_list_range_name
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_HISTORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_routing_history
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
    ROLLBACK TO update_routing_history;
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
    ROLLBACK TO update_routing_history;
    raise;
    --
end update_routing_history;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_routing_history >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_history
  (p_validate                       in  boolean  default false
  ,p_routing_history_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_routing_history';
  l_object_version_number pqh_routing_history.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_routing_history;
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
    -- Start of API User Hook for the before hook of delete_routing_history
    --
    pqh_routing_history_bk3.delete_routing_history_b
      (
       p_routing_history_id             =>  p_routing_history_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_HISTORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_routing_history
    --
  end;
  --
  --
  -- DELETE rows from pqh_routing_hist_attribs
  --
    delete from pqh_routing_hist_attribs
    where routing_history_id = p_routing_history_id;
  --
  --
  --
  --
  pqh_rht_del.del
    (
     p_routing_history_id            => p_routing_history_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_routing_history
    --
    pqh_routing_history_bk3.delete_routing_history_a
      (
       p_routing_history_id             =>  p_routing_history_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_HISTORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_routing_history
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
    ROLLBACK TO delete_routing_history;
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
    ROLLBACK TO delete_routing_history;
    raise;
    --
end delete_routing_history;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_routing_history_id                   in     number
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
  pqh_rht_shd.lck
    (
      p_routing_history_id                 => p_routing_history_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
--
-- ----------------------------------------------------------------------------
-- -------------------< create_routing_history_bp > ---------------------------
-- ----------------------------------------------------------------------------
--
procedure create_routing_history_bp
(
   p_validate                       in boolean    default false
  ,p_routing_history_id             out nocopy number
  ,p_approval_cd                    in  varchar2  default null
  ,p_comments                       in  varchar2  default null
  ,p_forwarded_by_assignment_id     in  number    default null
  ,p_forwarded_by_member_id         in  number    default null
  ,p_forwarded_by_position_id       in  number    default null
  ,p_forwarded_by_user_id           in  number    default null
  ,p_forwarded_by_role_id           in  number    default null
  ,p_forwarded_to_assignment_id     in  number    default null
  ,p_forwarded_to_member_id         in  number    default null
  ,p_forwarded_to_position_id       in  number    default null
  ,p_forwarded_to_user_id           in  number    default null
  ,p_forwarded_to_role_id           in  number    default null
  ,p_notification_date              in  date      default null
  ,p_pos_structure_version_id       in  number    default null
  ,p_routing_category_id            in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_user_action_cd                 in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_from_range_name                in  varchar2  default null
  ,p_to_range_name                  in  varchar2  default null
  ,p_list_range_name                in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_rha_tab                        in t_rha_tab
 ) is
/*
  This procedure will call the create_routing_history API and then insert records into
  pqh_routing_hist_attribs by calling create_routing_hist_attrib API in loop
*/


l_proc                         varchar2(72) := g_package||'create_routing_history_bp';
l_routing_history_id           pqh_routing_history.routing_history_id%TYPE;
l_object_version_number        pqh_routing_history.object_version_number%TYPE;
l_routing_hist_attrib_id       pqh_routing_hist_attribs.routing_hist_attrib_id%TYPE;

begin

-- call the create_routing_history API

   create_routing_history
(
   p_validate                       => p_validate
  ,p_routing_history_id             => l_routing_history_id
  ,p_approval_cd                    => p_approval_cd
  ,p_comments                       => p_comments
  ,p_forwarded_by_assignment_id     => p_forwarded_by_assignment_id
  ,p_forwarded_by_member_id         => p_forwarded_by_member_id
  ,p_forwarded_by_position_id       => p_forwarded_by_position_id
  ,p_forwarded_by_user_id           => p_forwarded_by_user_id
  ,p_forwarded_by_role_id           => p_forwarded_by_role_id
  ,p_forwarded_to_assignment_id     => p_forwarded_to_assignment_id
  ,p_forwarded_to_member_id         => p_forwarded_to_member_id
  ,p_forwarded_to_position_id       => p_forwarded_to_position_id
  ,p_forwarded_to_user_id           => p_forwarded_to_user_id
  ,p_forwarded_to_role_id           => p_forwarded_to_role_id
  ,p_notification_date              => p_notification_date
  ,p_pos_structure_version_id       => p_pos_structure_version_id
  ,p_routing_category_id            => p_routing_category_id
  ,p_transaction_category_id        => p_transaction_category_id
  ,p_transaction_id                 => p_transaction_id
  ,p_user_action_cd                 => p_user_action_cd
  ,p_object_version_number          => l_object_version_number
  ,p_from_range_name                => p_from_range_name
  ,p_to_range_name                  => p_to_range_name
  ,p_list_range_name                => p_list_range_name
  ,p_effective_date                 => p_effective_date
);
--
--  populate the OUT vairables of create_routing_history_bp

    p_routing_history_id    := l_routing_history_id;
    p_object_version_number := l_object_version_number;
--
--
--     Call the pqh_routing_hist_attrib_api.create_routing_hist_attrib in LOOP
--
--
--

   FOR i in NVL(p_rha_tab.FIRST,0)..NVL(p_rha_tab.LAST,-1)
     LOOP

        hr_utility.set_location(' Inserting Into pqh_routing_hist_attribs: '||l_proc, 5);



           pqh_routing_hist_attrib_api.create_routing_hist_attrib
           (
              p_validate                       => p_validate
             ,p_routing_hist_attrib_id         => l_routing_hist_attrib_id
             ,p_routing_history_id             => l_routing_history_id
             ,p_attribute_id                   => p_rha_tab(i).attribute_id
             ,p_from_char                      => p_rha_tab(i).from_char
             ,p_from_date                      => p_rha_tab(i).from_date
             ,p_from_number                    => p_rha_tab(i).from_number
             ,p_to_char                        => p_rha_tab(i).to_char
             ,p_to_date                        => p_rha_tab(i).to_date
             ,p_to_number                      => p_rha_tab(i).to_number
             ,p_object_version_number          => l_object_version_number
             ,p_range_type_cd                  => p_rha_tab(i).range_type_cd
             ,p_value_date                     => p_rha_tab(i).value_date
             ,p_value_number                   => p_rha_tab(i).value_number
             ,p_value_char                     => p_rha_tab(i).value_char
             ,p_effective_date                 => p_effective_date
            );

        hr_utility.set_location(' Done Inserting Into pqh_routing_hist_attribs: '||l_routing_hist_attrib_id, 7);

     END LOOP;


end create_routing_history_bp;
--
--
--
end pqh_routing_history_api;

/
