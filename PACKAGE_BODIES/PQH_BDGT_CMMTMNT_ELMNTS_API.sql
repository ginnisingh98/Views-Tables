--------------------------------------------------------
--  DDL for Package Body PQH_BDGT_CMMTMNT_ELMNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT_CMMTMNT_ELMNTS_API" as
/* $Header: pqbceapi.pkb 115.5 2004/04/28 17:26:35 rthiagar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_bdgt_cmmtmnt_elmnts_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_bdgt_cmmtmnt_elmnt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bdgt_cmmtmnt_elmnt
  (p_validate                       in  boolean   default false
  ,p_bdgt_cmmtmnt_elmnt_id          out nocopy number
  ,p_budget_id                      in  number    default null
  ,p_actual_commitment_type         in  varchar2  default null
  ,p_element_type_id                in  number    default null
  ,p_salary_basis_flag              in  varchar2  default 'N'
  ,p_element_input_value_id         in  number    default null
  ,p_balance_type_id                in  number    default null
  ,p_frequency_input_value_id       in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_dflt_elmnt_frequency           in  varchar2  default null
  ,p_overhead_percentage            in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_bdgt_cmmtmnt_elmnt_id pqh_bdgt_cmmtmnt_elmnts.bdgt_cmmtmnt_elmnt_id%TYPE;
  l_proc varchar2(72) := g_package||'create_bdgt_cmmtmnt_elmnt';
  l_object_version_number pqh_bdgt_cmmtmnt_elmnts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_bdgt_cmmtmnt_elmnt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_bdgt_cmmtmnt_elmnt
    --
    pqh_bdgt_cmmtmnt_elmnts_bk1.create_bdgt_cmmtmnt_elmnt_b
      (
       p_budget_id                      =>  p_budget_id
      ,p_actual_commitment_type         =>  p_actual_commitment_type
      ,p_element_type_id                =>  p_element_type_id
      ,p_salary_basis_flag              =>  p_salary_basis_flag
      ,p_element_input_value_id         =>  p_element_input_value_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_frequency_input_value_id       =>  p_frequency_input_value_id
      ,p_formula_id                     =>  p_formula_id
      ,p_dflt_elmnt_frequency           =>  p_dflt_elmnt_frequency
      ,p_overhead_percentage            =>  p_overhead_percentage
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_bdgt_cmmtmnt_elmnt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_bdgt_cmmtmnt_elmnt
    --
  end;
  --
  pqh_bce_ins.ins
    (
     p_bdgt_cmmtmnt_elmnt_id         => l_bdgt_cmmtmnt_elmnt_id
    ,p_budget_id                     => p_budget_id
    ,p_actual_commitment_type        => p_actual_commitment_type
    ,p_element_type_id               => p_element_type_id
    ,p_salary_basis_flag             => p_salary_basis_flag
    ,p_element_input_value_id        => p_element_input_value_id
    ,p_balance_type_id               => p_balance_type_id
    ,p_frequency_input_value_id      => p_frequency_input_value_id
    ,p_formula_id                    => p_formula_id
    ,p_dflt_elmnt_frequency          => p_dflt_elmnt_frequency
    ,p_overhead_percentage           => p_overhead_percentage
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_bdgt_cmmtmnt_elmnt
    --
    pqh_bdgt_cmmtmnt_elmnts_bk1.create_bdgt_cmmtmnt_elmnt_a
      (
       p_bdgt_cmmtmnt_elmnt_id          =>  l_bdgt_cmmtmnt_elmnt_id
      ,p_budget_id                      =>  p_budget_id
      ,p_actual_commitment_type         =>  p_actual_commitment_type
      ,p_element_type_id                =>  p_element_type_id
      ,p_salary_basis_flag              =>  p_salary_basis_flag
      ,p_element_input_value_id         =>  p_element_input_value_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_frequency_input_value_id       =>  p_frequency_input_value_id
      ,p_formula_id                     =>  p_formula_id
      ,p_dflt_elmnt_frequency           =>  p_dflt_elmnt_frequency
      ,p_overhead_percentage            =>  p_overhead_percentage
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_bdgt_cmmtmnt_elmnt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_bdgt_cmmtmnt_elmnt
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
  p_bdgt_cmmtmnt_elmnt_id := l_bdgt_cmmtmnt_elmnt_id;
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
    ROLLBACK TO create_bdgt_cmmtmnt_elmnt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bdgt_cmmtmnt_elmnt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_bdgt_cmmtmnt_elmnt_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_bdgt_cmmtmnt_elmnt;
    raise;
    --
end create_bdgt_cmmtmnt_elmnt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_bdgt_cmmtmnt_elmnt >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_bdgt_cmmtmnt_elmnt
  (p_validate                       in  boolean   default false
  ,p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_actual_commitment_type         in  varchar2  default hr_api.g_varchar2
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_salary_basis_flag              in  varchar2  default hr_api.g_varchar2
  ,p_element_input_value_id         in  number    default hr_api.g_number
  ,p_balance_type_id                in  number    default hr_api.g_number
  ,p_frequency_input_value_id       in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_dflt_elmnt_frequency           in  varchar2  default hr_api.g_varchar2
  ,p_overhead_percentage            in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_bdgt_cmmtmnt_elmnt';
  l_object_version_number pqh_bdgt_cmmtmnt_elmnts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_bdgt_cmmtmnt_elmnt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_bdgt_cmmtmnt_elmnt
    --
    pqh_bdgt_cmmtmnt_elmnts_bk2.update_bdgt_cmmtmnt_elmnt_b
      (
       p_bdgt_cmmtmnt_elmnt_id          =>  p_bdgt_cmmtmnt_elmnt_id
      ,p_budget_id                      =>  p_budget_id
      ,p_actual_commitment_type         =>  p_actual_commitment_type
      ,p_element_type_id                =>  p_element_type_id
      ,p_salary_basis_flag              =>  p_salary_basis_flag
      ,p_element_input_value_id         =>  p_element_input_value_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_frequency_input_value_id       =>  p_frequency_input_value_id
      ,p_formula_id                     =>  p_formula_id
      ,p_dflt_elmnt_frequency           =>  p_dflt_elmnt_frequency
      ,p_overhead_percentage            =>  p_overhead_percentage
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_bdgt_cmmtmnt_elmnt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_bdgt_cmmtmnt_elmnt
    --
  end;
  --
  pqh_bce_upd.upd
    (
     p_bdgt_cmmtmnt_elmnt_id         => p_bdgt_cmmtmnt_elmnt_id
    ,p_budget_id                     => p_budget_id
    ,p_actual_commitment_type        => p_actual_commitment_type
    ,p_element_type_id               => p_element_type_id
    ,p_salary_basis_flag             => p_salary_basis_flag
    ,p_element_input_value_id        => p_element_input_value_id
    ,p_balance_type_id               => p_balance_type_id
    ,p_frequency_input_value_id      => p_frequency_input_value_id
    ,p_formula_id                    => p_formula_id
    ,p_dflt_elmnt_frequency          => p_dflt_elmnt_frequency
    ,p_overhead_percentage           => p_overhead_percentage
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_bdgt_cmmtmnt_elmnt
    --
    pqh_bdgt_cmmtmnt_elmnts_bk2.update_bdgt_cmmtmnt_elmnt_a
      (
       p_bdgt_cmmtmnt_elmnt_id          =>  p_bdgt_cmmtmnt_elmnt_id
      ,p_budget_id                      =>  p_budget_id
      ,p_actual_commitment_type         =>  p_actual_commitment_type
      ,p_element_type_id                =>  p_element_type_id
      ,p_salary_basis_flag              =>  p_salary_basis_flag
      ,p_element_input_value_id         =>  p_element_input_value_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_frequency_input_value_id       =>  p_frequency_input_value_id
      ,p_formula_id                     =>  p_formula_id
      ,p_dflt_elmnt_frequency           =>  p_dflt_elmnt_frequency
      ,p_overhead_percentage            =>  p_overhead_percentage
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_bdgt_cmmtmnt_elmnt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_bdgt_cmmtmnt_elmnt
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
    ROLLBACK TO update_bdgt_cmmtmnt_elmnt;
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
    ROLLBACK TO update_bdgt_cmmtmnt_elmnt;
    raise;
    --
end update_bdgt_cmmtmnt_elmnt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_bdgt_cmmtmnt_elmnt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bdgt_cmmtmnt_elmnt
  (p_validate                       in  boolean  default false
  ,p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_bdgt_cmmtmnt_elmnt';
  l_object_version_number pqh_bdgt_cmmtmnt_elmnts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_bdgt_cmmtmnt_elmnt;
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
    -- Start of API User Hook for the before hook of delete_bdgt_cmmtmnt_elmnt
    --
    pqh_bdgt_cmmtmnt_elmnts_bk3.delete_bdgt_cmmtmnt_elmnt_b
      (
       p_bdgt_cmmtmnt_elmnt_id          =>  p_bdgt_cmmtmnt_elmnt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_bdgt_cmmtmnt_elmnt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_bdgt_cmmtmnt_elmnt
    --
  end;
  --
  pqh_bce_del.del
    (
     p_bdgt_cmmtmnt_elmnt_id         => p_bdgt_cmmtmnt_elmnt_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_bdgt_cmmtmnt_elmnt
    --
    pqh_bdgt_cmmtmnt_elmnts_bk3.delete_bdgt_cmmtmnt_elmnt_a
      (
       p_bdgt_cmmtmnt_elmnt_id          =>  p_bdgt_cmmtmnt_elmnt_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_bdgt_cmmtmnt_elmnt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_bdgt_cmmtmnt_elmnt
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
    ROLLBACK TO delete_bdgt_cmmtmnt_elmnt;
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
    ROLLBACK TO delete_bdgt_cmmtmnt_elmnt;
    raise;
    --
end delete_bdgt_cmmtmnt_elmnt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bdgt_cmmtmnt_elmnt_id                   in     number
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
  pqh_bce_shd.lck
    (
      p_bdgt_cmmtmnt_elmnt_id                 => p_bdgt_cmmtmnt_elmnt_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_bdgt_cmmtmnt_elmnts_api;

/
