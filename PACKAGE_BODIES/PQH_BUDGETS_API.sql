--------------------------------------------------------
--  DDL for Package Body PQH_BUDGETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGETS_API" as
/* $Header: pqbgtapi.pkb 120.1 2005/11/18 11:06:21 srajakum noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_budgets_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_budget
  (p_validate                       in  boolean   default false
  ,p_budget_id                      out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_start_organization_id          in  number    default null
  ,p_org_structure_version_id       in  number    default null
  ,p_budgeted_entity_cd             in  varchar2  default null
  ,p_budget_style_cd                in  varchar2  default null
  ,p_budget_name                    in  varchar2  default null
  ,p_period_set_name                in  varchar2  default null
  ,p_budget_start_date              in  date      default null
  ,p_budget_end_date                in  date      default null
  ,p_gl_budget_name                 in  varchar2  default null
  ,p_psb_budget_flag                in  varchar2  default 'N'
  ,p_transfer_to_gl_flag            in  varchar2  default null
  ,p_transfer_to_grants_flag        in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_id                in  number    default null
  ,p_budget_unit2_id                in  number    default null
  ,p_budget_unit3_id                in  number    default null
  ,p_gl_set_of_books_id             in  number    default null
  ,p_budget_unit1_aggregate         in varchar2   default null
  ,p_budget_unit2_aggregate         in varchar2   default null
  ,p_budget_unit3_aggregate         in varchar2   default null
  ,p_position_control_flag          in varchar2   default null
  ,p_valid_grade_reqd_flag          in varchar2   default null
  ,p_currency_code                  in varchar2   default null
  ,p_dflt_budget_set_id             in number     default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_budget_id pqh_budgets.budget_id%TYPE;
  l_proc varchar2(72) := g_package||'create_budget';
  l_object_version_number pqh_budgets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_budget;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_budget
    --
    pqh_budgets_bk1.create_budget_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_start_organization_id          =>  p_start_organization_id
      ,p_org_structure_version_id       =>  p_org_structure_version_id
      ,p_budgeted_entity_cd             =>  p_budgeted_entity_cd
      ,p_budget_style_cd                =>  p_budget_style_cd
      ,p_budget_name                    =>  p_budget_name
      ,p_period_set_name                =>  p_period_set_name
      ,p_budget_start_date              =>  p_budget_start_date
      ,p_budget_end_date                =>  p_budget_end_date
      ,p_gl_budget_name                 =>  p_gl_budget_name
      ,p_psb_budget_flag                =>  p_psb_budget_flag
      ,p_transfer_to_gl_flag            =>  p_transfer_to_gl_flag
      ,p_transfer_to_grants_flag        =>  p_transfer_to_grants_flag
      ,p_status                         =>  p_status
      ,p_budget_unit1_id                =>  p_budget_unit1_id
      ,p_budget_unit2_id                =>  p_budget_unit2_id
      ,p_budget_unit3_id                =>  p_budget_unit3_id
      ,p_gl_set_of_books_id             =>  p_gl_set_of_books_id
      ,p_budget_unit1_aggregate         =>  p_budget_unit1_aggregate
      ,p_budget_unit2_aggregate         =>  p_budget_unit2_aggregate
      ,p_budget_unit3_aggregate         =>  p_budget_unit3_aggregate
      ,p_position_control_flag          =>  p_position_control_flag
      ,p_valid_grade_reqd_flag          =>  p_valid_grade_reqd_flag
      ,p_currency_code                  =>  p_currency_code
      ,p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_budget'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_budget
    --
  end;
  --
  PQH_BGT_ins.ins
    (
     p_budget_id                     => l_budget_id
    ,p_business_group_id             => p_business_group_id
    ,p_start_organization_id         => p_start_organization_id
    ,p_org_structure_version_id      => p_org_structure_version_id
    ,p_budgeted_entity_cd            => p_budgeted_entity_cd
    ,p_budget_style_cd               => p_budget_style_cd
    ,p_budget_name                   => p_budget_name
    ,p_period_set_name               => p_period_set_name
    ,p_budget_start_date             => p_budget_start_date
    ,p_budget_end_date               => p_budget_end_date
    ,p_gl_budget_name                => p_gl_budget_name
    ,p_psb_budget_flag                =>  p_psb_budget_flag
    ,p_transfer_to_gl_flag           => p_transfer_to_gl_flag
    ,p_transfer_to_grants_flag       => p_transfer_to_grants_flag
    ,p_status                        => p_status
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_id               => p_budget_unit1_id
    ,p_budget_unit2_id               => p_budget_unit2_id
    ,p_budget_unit3_id               => p_budget_unit3_id
    ,p_gl_set_of_books_id            => p_gl_set_of_books_id
    ,p_budget_unit1_aggregate        => p_budget_unit1_aggregate
    ,p_budget_unit2_aggregate        => p_budget_unit2_aggregate
    ,p_budget_unit3_aggregate        => p_budget_unit3_aggregate
    ,p_position_control_flag         => p_position_control_flag
    ,p_valid_grade_reqd_flag         => p_valid_grade_reqd_flag
    ,p_currency_code                 => p_currency_code
    ,p_dflt_budget_set_id            => p_dflt_budget_set_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_budget
    --
    pqh_budgets_bk1.create_budget_a
      (
       p_budget_id                      =>  l_budget_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_start_organization_id          =>  p_start_organization_id
      ,p_org_structure_version_id       =>  p_org_structure_version_id
      ,p_budgeted_entity_cd             =>  p_budgeted_entity_cd
      ,p_budget_style_cd                =>  p_budget_style_cd
      ,p_budget_name                    =>  p_budget_name
      ,p_period_set_name                =>  p_period_set_name
      ,p_budget_start_date              =>  p_budget_start_date
      ,p_budget_end_date                =>  p_budget_end_date
      ,p_gl_budget_name                 =>  p_gl_budget_name
      ,p_psb_budget_flag                =>  p_psb_budget_flag
      ,p_transfer_to_gl_flag            =>  p_transfer_to_gl_flag
      ,p_transfer_to_grants_flag        =>  p_transfer_to_grants_flag
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_id                =>  p_budget_unit1_id
      ,p_budget_unit2_id                =>  p_budget_unit2_id
      ,p_budget_unit3_id                =>  p_budget_unit3_id
      ,p_gl_set_of_books_id             =>  p_gl_set_of_books_id
      ,p_budget_unit1_aggregate         =>  p_budget_unit1_aggregate
      ,p_budget_unit2_aggregate         =>  p_budget_unit2_aggregate
      ,p_budget_unit3_aggregate         =>  p_budget_unit3_aggregate
      ,p_position_control_flag          =>  p_position_control_flag
      ,p_valid_grade_reqd_flag          =>  p_valid_grade_reqd_flag
      ,p_currency_code                  =>  p_currency_code
      ,p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_budget'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_budget
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
  p_budget_id := l_budget_id;
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
    ROLLBACK TO create_budget;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_budget_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_budget_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_budget;
    raise;
    --
end create_budget;
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget
  (p_validate                       in  boolean   default false
  ,p_budget_id                      in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_start_organization_id          in  number    default hr_api.g_number
  ,p_org_structure_version_id       in  number    default hr_api.g_number
  ,p_budgeted_entity_cd             in  varchar2  default hr_api.g_varchar2
  ,p_budget_style_cd                in  varchar2  default hr_api.g_varchar2
  ,p_budget_name                    in  varchar2  default hr_api.g_varchar2
  ,p_period_set_name                in  varchar2  default hr_api.g_varchar2
  ,p_budget_start_date              in  date      default hr_api.g_date
  ,p_budget_end_date                in  date      default hr_api.g_date
  ,p_gl_budget_name                 in  varchar2  default hr_api.g_varchar2
  ,p_psb_budget_flag                in  varchar2  default hr_api.g_varchar2
  ,p_transfer_to_gl_flag            in  varchar2  default hr_api.g_varchar2
  ,p_transfer_to_grants_flag        in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_id                in  number    default hr_api.g_number
  ,p_budget_unit2_id                in  number    default hr_api.g_number
  ,p_budget_unit3_id                in  number    default hr_api.g_number
  ,p_gl_set_of_books_id             in  number    default hr_api.g_number
  ,p_budget_unit1_aggregate         in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_aggregate         in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_aggregate         in  varchar2  default hr_api.g_varchar2
  ,p_position_control_flag          in  varchar2  default hr_api.g_varchar2
  ,p_valid_grade_reqd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_currency_code                  in  varchar2  default hr_api.g_varchar2
  ,p_dflt_budget_set_id             in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_budget';
  l_object_version_number pqh_budgets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_budget;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_budget
    --
    pqh_budgets_bk2.update_budget_b
      (
       p_budget_id                      =>  p_budget_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_start_organization_id          =>  p_start_organization_id
      ,p_org_structure_version_id       =>  p_org_structure_version_id
      ,p_budgeted_entity_cd             =>  p_budgeted_entity_cd
      ,p_budget_style_cd                =>  p_budget_style_cd
      ,p_budget_name                    =>  p_budget_name
      ,p_period_set_name                =>  p_period_set_name
      ,p_budget_start_date              =>  p_budget_start_date
      ,p_budget_end_date                =>  p_budget_end_date
      ,p_gl_budget_name                 =>  p_gl_budget_name
      ,p_psb_budget_flag                =>  p_psb_budget_flag
      ,p_transfer_to_gl_flag            =>  p_transfer_to_gl_flag
      ,p_transfer_to_grants_flag        =>  p_transfer_to_grants_flag
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  p_object_version_number
      ,p_budget_unit1_id                =>  p_budget_unit1_id
      ,p_budget_unit2_id                =>  p_budget_unit2_id
      ,p_budget_unit3_id                =>  p_budget_unit3_id
      ,p_gl_set_of_books_id             =>  p_gl_set_of_books_id
      ,p_budget_unit1_aggregate         =>  p_budget_unit1_aggregate
      ,p_budget_unit2_aggregate         =>  p_budget_unit2_aggregate
      ,p_budget_unit3_aggregate         =>  p_budget_unit3_aggregate
      ,p_position_control_flag          =>  p_position_control_flag
      ,p_valid_grade_reqd_flag          =>  p_valid_grade_reqd_flag
      ,p_currency_code                  =>  p_currency_code
      ,p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_budget'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_budget
    --
  end;
  --
  PQH_BGT_upd.upd
    (
     p_budget_id                     => p_budget_id
    ,p_business_group_id             => p_business_group_id
    ,p_start_organization_id         => p_start_organization_id
    ,p_org_structure_version_id      => p_org_structure_version_id
    ,p_budgeted_entity_cd            => p_budgeted_entity_cd
    ,p_budget_style_cd               => p_budget_style_cd
    ,p_budget_name                   => p_budget_name
    ,p_period_set_name               => p_period_set_name
    ,p_budget_start_date             => p_budget_start_date
    ,p_budget_end_date               => p_budget_end_date
    ,p_gl_budget_name                => p_gl_budget_name
    ,p_psb_budget_flag               => p_psb_budget_flag
    ,p_transfer_to_gl_flag           => p_transfer_to_gl_flag
    ,p_transfer_to_grants_flag       => p_transfer_to_grants_flag
    ,p_status                        => p_status
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_id               => p_budget_unit1_id
    ,p_budget_unit2_id               => p_budget_unit2_id
    ,p_budget_unit3_id               => p_budget_unit3_id
    ,p_gl_set_of_books_id            => p_gl_set_of_books_id
    ,p_budget_unit1_aggregate        => p_budget_unit1_aggregate
    ,p_budget_unit2_aggregate        => p_budget_unit2_aggregate
    ,p_budget_unit3_aggregate        => p_budget_unit3_aggregate
    ,p_position_control_flag         => p_position_control_flag
    ,p_valid_grade_reqd_flag         => p_valid_grade_reqd_flag
    ,p_currency_code                 => p_currency_code
    ,p_dflt_budget_set_id            => p_dflt_budget_set_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_budget
    --
    pqh_budgets_bk2.update_budget_a
      (
       p_budget_id                      =>  p_budget_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_start_organization_id          =>  p_start_organization_id
      ,p_org_structure_version_id       =>  p_org_structure_version_id
      ,p_budgeted_entity_cd             =>  p_budgeted_entity_cd
      ,p_budget_style_cd                =>  p_budget_style_cd
      ,p_budget_name                    =>  p_budget_name
      ,p_period_set_name                =>  p_period_set_name
      ,p_budget_start_date              =>  p_budget_start_date
      ,p_budget_end_date                =>  p_budget_end_date
      ,p_gl_budget_name                 =>  p_gl_budget_name
      ,p_psb_budget_flag                =>  p_psb_budget_flag
      ,p_transfer_to_gl_flag            =>  p_transfer_to_gl_flag
      ,p_transfer_to_grants_flag        =>  p_transfer_to_grants_flag
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_id                =>  p_budget_unit1_id
      ,p_budget_unit2_id                =>  p_budget_unit2_id
      ,p_budget_unit3_id                =>  p_budget_unit3_id
      ,p_gl_set_of_books_id             =>  p_gl_set_of_books_id
      ,p_budget_unit1_aggregate         =>  p_budget_unit1_aggregate
      ,p_budget_unit2_aggregate         =>  p_budget_unit2_aggregate
      ,p_budget_unit3_aggregate         =>  p_budget_unit3_aggregate
      ,p_position_control_flag          =>  p_position_control_flag
      ,p_valid_grade_reqd_flag          =>  p_valid_grade_reqd_flag
      ,p_currency_code                  =>  p_currency_code
      ,p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_budget'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_budget
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
    ROLLBACK TO update_budget;
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
    ROLLBACK TO update_budget;
    raise;
    --
end update_budget;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_budget >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget
  (p_validate                       in  boolean  default false
  ,p_budget_id                      in  number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_budget';
  l_object_version_number pqh_budgets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_budget;
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
    -- Start of API User Hook for the before hook of delete_budget
    --
    pqh_budgets_bk3.delete_budget_b
      (
       p_budget_id                      =>  p_budget_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_budget'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_budget
    --
  end;
  --
  PQH_BGT_del.del
    (
     p_budget_id                     => p_budget_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_budget
    --
    pqh_budgets_bk3.delete_budget_a
      (
       p_budget_id                      =>  p_budget_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_budget'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_budget
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
    ROLLBACK TO delete_budget;
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
    ROLLBACK TO delete_budget;
    raise;
    --
end delete_budget;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_budget_id                   in     number
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
  PQH_BGT_shd.lck
    (
      p_budget_id                 => p_budget_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_budgets_api;

/
