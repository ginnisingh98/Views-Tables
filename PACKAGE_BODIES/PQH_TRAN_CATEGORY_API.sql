--------------------------------------------------------
--  DDL for Package Body PQH_TRAN_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TRAN_CATEGORY_API" as
/* $Header: pqtctapi.pkb 115.11 2004/01/22 16:12:06 nsanghal noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_TRAN_CATEGORY_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_TRAN_CATEGORY >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_TRAN_CATEGORY
  (p_validate                       in  boolean   default false
  ,p_transaction_category_id        out nocopy number
  ,p_custom_wf_process_name         in  varchar2  default null
  ,p_custom_workflow_name           in  varchar2  default null
  ,p_form_name                      in  varchar2
  ,p_freeze_status_cd               in  varchar2  default null
  ,p_future_action_cd               in  varchar2
  ,p_member_cd                      in  varchar2
  ,p_name                           in  varchar2
  ,p_short_name                     in  varchar2
  ,p_post_style_cd                  in  varchar2
  ,p_post_txn_function              in  varchar2
  ,p_route_validated_txn_flag       in  varchar2
  ,p_prevent_approver_skip          in  varchar2  default null
  ,p_workflow_enable_flag           in  varchar2
  ,p_enable_flag           in  varchar2
  ,p_timeout_days                   in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_consolidated_table_route_id    in  number
  ,p_business_group_id              in  number    default null
  ,p_setup_type_cd                  in varchar2   default null
  ,p_master_table_route_id          in  number    default null
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ) is
  --
  -- Declare cursors and local variables
  --
  l_transaction_category_id pqh_transaction_categories.transaction_category_id%TYPE;
  l_proc varchar2(72) := g_package||'create_TRAN_CATEGORY';
  l_object_version_number pqh_transaction_categories.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_TRAN_CATEGORY;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_TRAN_CATEGORY
    --
    pqh_TRAN_CATEGORY_bk1.create_TRAN_CATEGORY_b
      (
       p_custom_wf_process_name         =>  p_custom_wf_process_name
      ,p_custom_workflow_name           =>  p_custom_workflow_name
      ,p_form_name                      =>  p_form_name
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_future_action_cd               =>  p_future_action_cd
      ,p_member_cd                      =>  p_member_cd
      ,p_name                           =>  p_name
      ,p_short_name                           =>  p_short_name
      ,p_post_style_cd                  =>  p_post_style_cd
      ,p_post_txn_function              =>  p_post_txn_function
      ,p_route_validated_txn_flag       =>  p_route_validated_txn_flag
      ,p_prevent_approver_skip          =>  p_prevent_approver_skip
      ,p_workflow_enable_flag       =>  p_workflow_enable_flag
      ,p_enable_flag       =>  p_enable_flag
      ,p_timeout_days                   =>  p_timeout_days
      ,p_consolidated_table_route_id    =>  p_consolidated_table_route_id
  ,p_business_group_id              =>  p_business_group_id
  ,p_setup_type_cd                  =>  p_setup_type_cd
      ,p_master_table_route_id    =>  p_master_table_route_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_TRAN_CATEGORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_TRAN_CATEGORY
    --
  end;
  --
  pqh_tct_ins.ins
    (
     p_transaction_category_id       => l_transaction_category_id
    ,p_custom_wf_process_name        => p_custom_wf_process_name
    ,p_custom_workflow_name          => p_custom_workflow_name
    ,p_form_name                     => p_form_name
    ,p_freeze_status_cd              => p_freeze_status_cd
    ,p_future_action_cd              => p_future_action_cd
    ,p_member_cd                     => p_member_cd
    ,p_name                          => p_name
    ,p_short_name                    => p_short_name
    ,p_post_style_cd                 => p_post_style_cd
    ,p_post_txn_function             => p_post_txn_function
    ,p_route_validated_txn_flag      => p_route_validated_txn_flag
    ,p_prevent_approver_skip         =>  p_prevent_approver_skip
      ,p_workflow_enable_flag       =>  p_workflow_enable_flag
      ,p_enable_flag       =>  p_enable_flag
    ,p_timeout_days                  => p_timeout_days
    ,p_object_version_number         => l_object_version_number
    ,p_consolidated_table_route_id   => p_consolidated_table_route_id
  ,p_business_group_id              =>  p_business_group_id
  ,p_setup_type_cd                  =>  p_setup_type_cd
      ,p_master_table_route_id    =>  p_master_table_route_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  p_transaction_category_id  := l_transaction_category_id ;
  --
  pqh_ctl_ins.ins_tl
       (
       p_language_code             => p_language_code,
       p_transaction_category_id   => l_transaction_category_id ,
       p_name                      => p_name );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_TRAN_CATEGORY
    --
    pqh_TRAN_CATEGORY_bk1.create_TRAN_CATEGORY_a
      (
       p_transaction_category_id        =>  l_transaction_category_id
      ,p_custom_wf_process_name         =>  p_custom_wf_process_name
      ,p_custom_workflow_name           =>  p_custom_workflow_name
      ,p_form_name                      =>  p_form_name
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_future_action_cd               =>  p_future_action_cd
      ,p_member_cd                      =>  p_member_cd
      ,p_name                           =>  p_name
      ,p_short_name                     =>  p_short_name
      ,p_post_style_cd                  =>  p_post_style_cd
      ,p_post_txn_function              =>  p_post_txn_function
      ,p_route_validated_txn_flag       =>  p_route_validated_txn_flag
      ,p_prevent_approver_skip         =>  p_prevent_approver_skip
      ,p_workflow_enable_flag       =>  p_workflow_enable_flag
      ,p_enable_flag       =>  p_enable_flag
      ,p_timeout_days                   =>  p_timeout_days
      ,p_object_version_number          =>  l_object_version_number
      ,p_consolidated_table_route_id    =>  p_consolidated_table_route_id
  ,p_business_group_id              =>  p_business_group_id
  ,p_setup_type_cd                  =>  p_setup_type_cd
      ,p_master_table_route_id    =>  p_master_table_route_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TRAN_CATEGORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_TRAN_CATEGORY
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
  p_transaction_category_id := l_transaction_category_id;
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
    ROLLBACK TO create_TRAN_CATEGORY;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_transaction_category_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
     p_transaction_category_id := null;
  p_object_version_number := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_TRAN_CATEGORY;
    raise;
    --
end create_TRAN_CATEGORY;
-- ----------------------------------------------------------------------------
-- |------------------------< update_TRAN_CATEGORY >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_TRAN_CATEGORY
  (p_validate                       in  boolean   default false
  ,p_transaction_category_id        in  number
  ,p_custom_wf_process_name         in  varchar2  default hr_api.g_varchar2
  ,p_custom_workflow_name           in  varchar2  default hr_api.g_varchar2
  ,p_form_name                      in  varchar2  default hr_api.g_varchar2
  ,p_freeze_status_cd               in  varchar2  default hr_api.g_varchar2
  ,p_future_action_cd               in  varchar2  default hr_api.g_varchar2
  ,p_member_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_post_style_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_post_txn_function              in  varchar2  default hr_api.g_varchar2
  ,p_route_validated_txn_flag       in  varchar2  default hr_api.g_varchar2
  ,p_prevent_approver_skip          in  varchar2  default hr_api.g_varchar2
  ,p_workflow_enable_flag       in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag       in  varchar2  default hr_api.g_varchar2
  ,p_timeout_days                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_consolidated_table_route_id    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_setup_type_cd                  in varchar2   default hr_api.g_varchar2
  ,p_master_table_route_id          in number     default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_TRAN_CATEGORY';
  l_object_version_number pqh_transaction_categories.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_TRAN_CATEGORY;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_TRAN_CATEGORY
    --
    pqh_TRAN_CATEGORY_bk2.update_TRAN_CATEGORY_b
      (
       p_transaction_category_id        =>  p_transaction_category_id
      ,p_custom_wf_process_name         =>  p_custom_wf_process_name
      ,p_custom_workflow_name           =>  p_custom_workflow_name
      ,p_form_name                      =>  p_form_name
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_future_action_cd               =>  p_future_action_cd
      ,p_member_cd                      =>  p_member_cd
      ,p_name                           =>  p_name
      ,p_short_name                     =>  p_short_name
      ,p_post_style_cd                  =>  p_post_style_cd
      ,p_post_txn_function              =>  p_post_txn_function
      ,p_route_validated_txn_flag       =>  p_route_validated_txn_flag
      ,p_prevent_approver_skip          =>  p_prevent_approver_skip
      ,p_workflow_enable_flag       =>  p_workflow_enable_flag
      ,p_enable_flag       =>  p_enable_flag
      ,p_timeout_days                   =>  p_timeout_days
      ,p_object_version_number          =>  p_object_version_number
      ,p_consolidated_table_route_id    =>  p_consolidated_table_route_id
  ,p_business_group_id            =>  p_business_group_id
  ,p_setup_type_cd                =>  p_setup_type_cd
      ,p_master_table_route_id    =>  p_master_table_route_id
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRAN_CATEGORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_TRAN_CATEGORY
    --
  end;
  --
  pqh_tct_upd.upd
    (
     p_transaction_category_id       => p_transaction_category_id
    ,p_custom_wf_process_name        => p_custom_wf_process_name
    ,p_custom_workflow_name          => p_custom_workflow_name
    ,p_form_name                     => p_form_name
    ,p_freeze_status_cd              => p_freeze_status_cd
    ,p_future_action_cd              => p_future_action_cd
    ,p_member_cd                     => p_member_cd
    ,p_name                          => p_name
    ,p_short_name                    =>  p_short_name
    ,p_post_style_cd                 => p_post_style_cd
    ,p_post_txn_function             => p_post_txn_function
    ,p_route_validated_txn_flag      => p_route_validated_txn_flag
    ,p_prevent_approver_skip         =>  p_prevent_approver_skip
      ,p_workflow_enable_flag       =>  p_workflow_enable_flag
      ,p_enable_flag       =>  p_enable_flag
    ,p_timeout_days                  => p_timeout_days
    ,p_object_version_number         => l_object_version_number
    ,p_consolidated_table_route_id   => p_consolidated_table_route_id
  ,p_business_group_id            =>  p_business_group_id
  ,p_setup_type_cd                =>  p_setup_type_cd
      ,p_master_table_route_id    =>  p_master_table_route_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  pqh_ctl_upd.upd_tl
       (
       p_language_code             => p_language_code,
       p_transaction_category_id   => p_transaction_category_id ,
       p_name                      => p_name );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_TRAN_CATEGORY
    --
    pqh_TRAN_CATEGORY_bk2.update_TRAN_CATEGORY_a
      (
       p_transaction_category_id        =>  p_transaction_category_id
      ,p_custom_wf_process_name         =>  p_custom_wf_process_name
      ,p_custom_workflow_name           =>  p_custom_workflow_name
      ,p_form_name                      =>  p_form_name
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_future_action_cd               =>  p_future_action_cd
      ,p_member_cd                      =>  p_member_cd
      ,p_name                           =>  p_name
      ,p_short_name                           =>  p_short_name
      ,p_post_style_cd                  =>  p_post_style_cd
      ,p_post_txn_function              =>  p_post_txn_function
      ,p_route_validated_txn_flag       =>  p_route_validated_txn_flag
      ,p_prevent_approver_skip          =>  p_prevent_approver_skip
      ,p_workflow_enable_flag       =>  p_workflow_enable_flag
      ,p_enable_flag       =>  p_enable_flag
      ,p_timeout_days                   =>  p_timeout_days
      ,p_object_version_number          =>  l_object_version_number
      ,p_consolidated_table_route_id    =>  p_consolidated_table_route_id
  ,p_business_group_id            =>  p_business_group_id
  ,p_setup_type_cd                =>  p_setup_type_cd
      ,p_master_table_route_id    =>  p_master_table_route_id
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRAN_CATEGORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_TRAN_CATEGORY
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
    ROLLBACK TO update_TRAN_CATEGORY;
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
    ROLLBACK TO update_TRAN_CATEGORY;
    raise;
    --
end update_TRAN_CATEGORY;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_TRAN_CATEGORY >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TRAN_CATEGORY
  (p_validate                       in  boolean  default false
  ,p_transaction_category_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_TRAN_CATEGORY';
  l_object_version_number pqh_transaction_categories.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_TRAN_CATEGORY;
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
    -- Start of API User Hook for the before hook of delete_TRAN_CATEGORY
    --
    pqh_TRAN_CATEGORY_bk3.delete_TRAN_CATEGORY_b
      (
       p_transaction_category_id        =>  p_transaction_category_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRAN_CATEGORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_TRAN_CATEGORY
    --
  end;
  --
  pqh_tct_shd.lck
    (
      p_transaction_category_id    => p_transaction_category_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  --
  pqh_ctl_del.del_tl
       (
       p_transaction_category_id   => p_transaction_category_id);

  --
  pqh_tct_del.del
    (
     p_transaction_category_id       => p_transaction_category_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_TRAN_CATEGORY
    --
    pqh_TRAN_CATEGORY_bk3.delete_TRAN_CATEGORY_a
      (
       p_transaction_category_id        =>  p_transaction_category_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRAN_CATEGORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_TRAN_CATEGORY
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
    ROLLBACK TO delete_TRAN_CATEGORY;
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
    ROLLBACK TO delete_TRAN_CATEGORY;
    raise;
    --
end delete_TRAN_CATEGORY;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_transaction_category_id                   in     number
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
  pqh_tct_shd.lck
    (
      p_transaction_category_id                 => p_transaction_category_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
--
end pqh_TRAN_CATEGORY_api;

/
