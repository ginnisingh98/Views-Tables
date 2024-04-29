--------------------------------------------------------
--  DDL for Package Body PQH_WORKSHEET_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WORKSHEET_DETAILS_API" as
/* $Header: pqwdtapi.pkb 120.1.12000000.1 2007/01/17 00:29:36 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_WORKSHEET_DETAILS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_DETAIL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_DETAIL
  (p_validate                       in  boolean   default false
  ,p_worksheet_detail_id            out nocopy number
  ,p_worksheet_id                   in  number
  ,p_organization_id                in  number    default null
  ,p_job_id                         in  number    default null
  ,p_position_id                    in  number    default null
  ,p_grade_id                       in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_budget_detail_id               in  number    default null
  ,p_parent_worksheet_detail_id     in  number    default null
  ,p_user_id                        in  number    default null
  ,p_action_cd                      in  varchar2  default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_old_unit1_value                in  number    default null
  ,p_old_unit2_value                in  number    default null
  ,p_old_unit3_value                in  number    default null
  ,p_defer_flag                     in  varchar2  default null
  ,p_propagation_method             in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_worksheet_detail_id pqh_worksheet_details.worksheet_detail_id%TYPE;
  l_proc varchar2(72) := g_package||'create_WORKSHEET_DETAIL';
  l_object_version_number pqh_worksheet_details.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_WORKSHEET_DETAIL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_WORKSHEET_DETAIL
    --
    pqh_WORKSHEET_DETAILS_bk1.create_WORKSHEET_DETAIL_b
      (
       p_worksheet_id                   =>  p_worksheet_id
      ,p_organization_id                =>  p_organization_id
      ,p_job_id                         =>  p_job_id
      ,p_position_id                    =>  p_position_id
      ,p_grade_id                       =>  p_grade_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_budget_detail_id               =>  p_budget_detail_id
      ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
      ,p_user_id                        =>  p_user_id
      ,p_action_cd                      =>  p_action_cd
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_status                         =>  p_status
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_old_unit1_value                =>  p_old_unit1_value
      ,p_old_unit2_value                =>  p_old_unit2_value
      ,p_old_unit3_value                =>  p_old_unit3_value
      ,p_defer_flag                     =>  p_defer_flag
      ,p_propagation_method             =>  p_propagation_method
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_WORKSHEET_DETAIL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_WORKSHEET_DETAIL
    --
  end;
  --
  pqh_wdt_ins.ins
    (
     p_worksheet_detail_id           => l_worksheet_detail_id
    ,p_worksheet_id                  => p_worksheet_id
    ,p_organization_id               => p_organization_id
    ,p_job_id                        => p_job_id
    ,p_position_id                   => p_position_id
    ,p_grade_id                      => p_grade_id
    ,p_position_transaction_id       => p_position_transaction_id
    ,p_budget_detail_id              => p_budget_detail_id
    ,p_parent_worksheet_detail_id    => p_parent_worksheet_detail_id
    ,p_user_id                       => p_user_id
    ,p_action_cd                     => p_action_cd
    ,p_budget_unit1_percent          => p_budget_unit1_percent
    ,p_budget_unit1_value            => p_budget_unit1_value
    ,p_budget_unit2_percent          => p_budget_unit2_percent
    ,p_budget_unit2_value            => p_budget_unit2_value
    ,p_budget_unit3_percent          => p_budget_unit3_percent
    ,p_budget_unit3_value            => p_budget_unit3_value
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_value_type_cd    => p_budget_unit1_value_type_cd
    ,p_budget_unit2_value_type_cd    => p_budget_unit2_value_type_cd
    ,p_budget_unit3_value_type_cd    => p_budget_unit3_value_type_cd
    ,p_status                        => p_status
    ,p_budget_unit1_available        => p_budget_unit1_available
    ,p_budget_unit2_available        => p_budget_unit2_available
    ,p_budget_unit3_available        => p_budget_unit3_available
    ,p_old_unit1_value               => p_old_unit1_value
    ,p_old_unit2_value               => p_old_unit2_value
    ,p_old_unit3_value               => p_old_unit3_value
    ,p_defer_flag                    => p_defer_flag
    ,p_propagation_method            => p_propagation_method
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_WORKSHEET_DETAIL
    --
    pqh_WORKSHEET_DETAILS_bk1.create_WORKSHEET_DETAIL_a
      (
       p_worksheet_detail_id            =>  l_worksheet_detail_id
      ,p_worksheet_id                   =>  p_worksheet_id
      ,p_organization_id                =>  p_organization_id
      ,p_job_id                         =>  p_job_id
      ,p_position_id                    =>  p_position_id
      ,p_grade_id                       =>  p_grade_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_budget_detail_id               =>  p_budget_detail_id
      ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
      ,p_user_id                        =>  p_user_id
      ,p_action_cd                      =>  p_action_cd
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_status                         =>  p_status
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_old_unit1_value                =>  p_old_unit1_value
      ,p_old_unit2_value                =>  p_old_unit2_value
      ,p_old_unit3_value                =>  p_old_unit3_value
      ,p_defer_flag                     =>  p_defer_flag
      ,p_propagation_method             =>  p_propagation_method
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WORKSHEET_DETAIL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_WORKSHEET_DETAIL
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
  p_worksheet_detail_id := l_worksheet_detail_id;
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
    ROLLBACK TO create_WORKSHEET_DETAIL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_worksheet_detail_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_worksheet_detail_id := null;
  p_object_version_number := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_WORKSHEET_DETAIL;
    raise;
    --
end create_WORKSHEET_DETAIL;

-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_DETAIL_BP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_DETAIL_BP
  (p_validate                       in  boolean   default false
  ,p_worksheet_detail_id            out nocopy number
  ,p_worksheet_id                   in  number
  ,p_organization_id                in  number    default null
  ,p_job_id                         in  number    default null
  ,p_position_id                    in  number    default null
  ,p_grade_id                       in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_budget_detail_id               in  number    default null
  ,p_parent_worksheet_detail_id     in  number    default null
  ,p_user_id                        in  number    default null
  ,p_action_cd                      in  varchar2  default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_old_unit1_value                in  number    default null
  ,p_old_unit2_value                in  number    default null
  ,p_old_unit3_value                in  number    default null
  ,p_defer_flag                     in  varchar2  default null
  ,p_propagation_method             in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_copy_budget_periods            in varchar2   default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_worksheet_detail_id pqh_worksheet_details.worksheet_detail_id%TYPE;
  l_proc varchar2(72) := g_package||'create_WORKSHEET_DETAIL_BP';
  l_wkd_ovn pqh_worksheet_details.object_version_number%TYPE;
  l_wpr_ovn pqh_worksheet_periods.object_version_number%TYPE;
  l_worksheet_period_id pqh_worksheet_periods.worksheet_period_id%TYPE;
  l_budget_unit1_available number;
  l_budget_unit2_available number;
  l_budget_unit3_available number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if nvl(p_action_cd,'D') = 'B' then
     l_budget_unit1_available := 0;
     l_budget_unit2_available := 0;
     l_budget_unit3_available := 0;
  else
     l_budget_unit1_available := p_budget_unit1_available;
     l_budget_unit2_available := p_budget_unit2_available;
     l_budget_unit3_available := p_budget_unit3_available;
  end if;
  -- call the create worksheet details API
  --
    pqh_WORKSHEET_DETAILS_api.create_WORKSHEET_DETAIL
    (
     p_validate                      => p_validate
    ,p_worksheet_detail_id           => l_worksheet_detail_id
    ,p_worksheet_id                  => p_worksheet_id
    ,p_organization_id               => p_organization_id
    ,p_job_id                        => p_job_id
    ,p_position_id                   => p_position_id
    ,p_grade_id                      => p_grade_id
    ,p_position_transaction_id       => p_position_transaction_id
    ,p_budget_detail_id              => p_budget_detail_id
    ,p_parent_worksheet_detail_id    => p_parent_worksheet_detail_id
    ,p_user_id                       => p_user_id
    ,p_action_cd                     => p_action_cd
    ,p_budget_unit1_percent          => p_budget_unit1_percent
    ,p_budget_unit1_value            => p_budget_unit1_value
    ,p_budget_unit2_percent          => p_budget_unit2_percent
    ,p_budget_unit2_value            => p_budget_unit2_value
    ,p_budget_unit3_percent          => p_budget_unit3_percent
    ,p_budget_unit3_value            => p_budget_unit3_value
    ,p_object_version_number         => l_wkd_ovn
    ,p_budget_unit1_value_type_cd    => p_budget_unit1_value_type_cd
    ,p_budget_unit2_value_type_cd    => p_budget_unit2_value_type_cd
    ,p_budget_unit3_value_type_cd    => p_budget_unit3_value_type_cd
    ,p_status                        => p_status
    ,p_budget_unit1_available        => l_budget_unit1_available
    ,p_budget_unit2_available        => l_budget_unit2_available
    ,p_budget_unit3_available        => l_budget_unit3_available
    ,p_old_unit1_value               => p_old_unit1_value
    ,p_old_unit2_value               => p_old_unit2_value
    ,p_old_unit3_value               => p_old_unit3_value
    ,p_defer_flag                    => p_defer_flag
    ,p_propagation_method            => p_propagation_method
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  --
  hr_utility.set_location('Created WKS Dtl : '|| l_worksheet_detail_id, 100);
  --
  --
  --
  if nvl(p_action_cd,'D') ='B' then
     --
     --  call to insert row into wks periods
     --
     if (p_copy_budget_periods = 'N')
     then
     --
     --  insert default period only when profile HR: Copy period details
     --  for budget is set to Yes at the site level.
     --
     pqh_wks_budget.insert_default_period
     (
      p_worksheet_detail_id             => l_worksheet_detail_id
     ,p_worksheet_unit1_value           => p_budget_unit1_value
     ,p_worksheet_unit2_value           => p_budget_unit2_value
     ,p_worksheet_unit3_value           => p_budget_unit3_value
     ,p_worksheet_period_id             => l_worksheet_period_id
     ,p_wkd_ovn                         => l_wkd_ovn
     ,p_wpr_ovn                         => l_wpr_ovn
     );
     end if;
     --
     hr_utility.set_location('Created WKS Period : '|| l_worksheet_period_id, 200);
     --
  end if;
  p_object_version_number := l_wkd_ovn;
  p_worksheet_detail_id   := l_worksheet_detail_id;
exception
  when OTHERS then
  p_object_version_number := null;
  p_worksheet_detail_id   := null;
   raise;
end create_WORKSHEET_DETAIL_BP;

-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET_DETAIL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET_DETAIL
  (p_validate                       in  boolean   default false
  ,p_worksheet_detail_id            in  number
  ,p_worksheet_id                   in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_job_id                         in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_position_transaction_id        in  number    default hr_api.g_number
  ,p_budget_detail_id               in  number    default hr_api.g_number
  ,p_parent_worksheet_detail_id     in  number    default hr_api.g_number
  ,p_user_id                        in  number    default hr_api.g_number
  ,p_action_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_old_unit1_value                in  number    default hr_api.g_number
  ,p_old_unit2_value                in  number    default hr_api.g_number
  ,p_old_unit3_value                in  number    default hr_api.g_number
  ,p_defer_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_propagation_method             in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WORKSHEET_DETAIL';
  l_object_version_number pqh_worksheet_details.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_WORKSHEET_DETAIL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_WORKSHEET_DETAIL
    --
    pqh_WORKSHEET_DETAILS_bk2.update_WORKSHEET_DETAIL_b
      (
       p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_worksheet_id                   =>  p_worksheet_id
      ,p_organization_id                =>  p_organization_id
      ,p_job_id                         =>  p_job_id
      ,p_position_id                    =>  p_position_id
      ,p_grade_id                       =>  p_grade_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_budget_detail_id               =>  p_budget_detail_id
      ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
      ,p_user_id                        =>  p_user_id
      ,p_action_cd                      =>  p_action_cd
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_object_version_number          =>  p_object_version_number
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_status                         =>  p_status
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_old_unit1_value                =>  p_old_unit1_value
      ,p_old_unit2_value                =>  p_old_unit2_value
      ,p_old_unit3_value                =>  p_old_unit3_value
      ,p_defer_flag                     =>  p_defer_flag
      ,p_propagation_method             =>  p_propagation_method
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET_DETAIL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_WORKSHEET_DETAIL
    --
  end;
  --
  pqh_wdt_upd.upd
    (
     p_worksheet_detail_id           => p_worksheet_detail_id
    ,p_worksheet_id                  => p_worksheet_id
    ,p_organization_id               => p_organization_id
    ,p_job_id                        => p_job_id
    ,p_position_id                   => p_position_id
    ,p_grade_id                      => p_grade_id
    ,p_position_transaction_id       => p_position_transaction_id
    ,p_budget_detail_id              => p_budget_detail_id
    ,p_parent_worksheet_detail_id    => p_parent_worksheet_detail_id
    ,p_user_id                       => p_user_id
    ,p_action_cd                     => p_action_cd
    ,p_budget_unit1_percent          => p_budget_unit1_percent
    ,p_budget_unit1_value            => p_budget_unit1_value
    ,p_budget_unit2_percent          => p_budget_unit2_percent
    ,p_budget_unit2_value            => p_budget_unit2_value
    ,p_budget_unit3_percent          => p_budget_unit3_percent
    ,p_budget_unit3_value            => p_budget_unit3_value
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_value_type_cd    => p_budget_unit1_value_type_cd
    ,p_budget_unit2_value_type_cd    => p_budget_unit2_value_type_cd
    ,p_budget_unit3_value_type_cd    => p_budget_unit3_value_type_cd
    ,p_status                        => p_status
    ,p_budget_unit1_available        => p_budget_unit1_available
    ,p_budget_unit2_available        => p_budget_unit2_available
    ,p_budget_unit3_available        => p_budget_unit3_available
    ,p_old_unit1_value               => p_old_unit1_value
    ,p_old_unit2_value               => p_old_unit2_value
    ,p_old_unit3_value               => p_old_unit3_value
    ,p_defer_flag                    => p_defer_flag
    ,p_propagation_method            => p_propagation_method
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_WORKSHEET_DETAIL
    --
    pqh_WORKSHEET_DETAILS_bk2.update_WORKSHEET_DETAIL_a
      (
       p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_worksheet_id                   =>  p_worksheet_id
      ,p_organization_id                =>  p_organization_id
      ,p_job_id                         =>  p_job_id
      ,p_position_id                    =>  p_position_id
      ,p_grade_id                       =>  p_grade_id
      ,p_position_transaction_id        =>  p_position_transaction_id
      ,p_budget_detail_id               =>  p_budget_detail_id
      ,p_parent_worksheet_detail_id     =>  p_parent_worksheet_detail_id
      ,p_user_id                        =>  p_user_id
      ,p_action_cd                      =>  p_action_cd
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_status                         =>  p_status
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_old_unit1_value                =>  p_old_unit1_value
      ,p_old_unit2_value                =>  p_old_unit2_value
      ,p_old_unit3_value                =>  p_old_unit3_value
      ,p_defer_flag                     =>  p_defer_flag
      ,p_propagation_method             =>  p_propagation_method
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET_DETAIL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_WORKSHEET_DETAIL
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
    ROLLBACK TO update_WORKSHEET_DETAIL;
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
    ROLLBACK TO update_WORKSHEET_DETAIL;
    raise;
    --
end update_WORKSHEET_DETAIL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET_DETAIL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_DETAIL
  (p_validate                       in  boolean  default false
  ,p_worksheet_detail_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_WORKSHEET_DETAIL';
  l_object_version_number pqh_worksheet_details.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_WORKSHEET_DETAIL;
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
    -- Start of API User Hook for the before hook of delete_WORKSHEET_DETAIL
    --
    pqh_WORKSHEET_DETAILS_bk3.delete_WORKSHEET_DETAIL_b
      (
       p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET_DETAIL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_WORKSHEET_DETAIL
    --
  end;
  --
  pqh_wdt_del.del
    (
     p_worksheet_detail_id           => p_worksheet_detail_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_WORKSHEET_DETAIL
    --
    pqh_WORKSHEET_DETAILS_bk3.delete_WORKSHEET_DETAIL_a
      (
       p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET_DETAIL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_WORKSHEET_DETAIL
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
    ROLLBACK TO delete_WORKSHEET_DETAIL;
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
    ROLLBACK TO delete_WORKSHEET_DETAIL;
    raise;
    --
end delete_WORKSHEET_DETAIL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_worksheet_detail_id                   in     number
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
  pqh_wdt_shd.lck
    (
      p_worksheet_detail_id                 => p_worksheet_detail_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_WORKSHEET_DETAILS_api;

/
