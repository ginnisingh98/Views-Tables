--------------------------------------------------------
--  DDL for Package Body BEN_CWB_MATRIX_DTL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_MATRIX_DTL_API" as
/* $Header: bebcdapi.pkb 120.0 2005/05/28 00:34:22 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_cwb_matrix_dtl_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cwb_matrix_dtl >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_matrix_dtl
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_cwb_matrix_id                 in     number
  ,p_row_crit_val                  in     varchar2
  ,p_col_crit_val                  in     varchar2 default null
  ,p_pct_emp_cndr                  in     number   default null
  ,p_pct_val                       in     number   default null
  ,p_emp_amt                       in     number   default null
  ,p_cwb_matrix_dtl_id             out nocopy    number
  ,p_object_version_number         out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cwb_matrix_dtl_id              ben_cwb_matrix_dtl.cwb_matrix_dtl_id%TYPE;
  l_object_version_number          ben_cwb_matrix_dtl.object_version_number%TYPE;
  l_proc                           varchar2(72) := g_package||'create_cwb_matrix_dtl';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_cwb_matrix_dtl;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_matrix_dtl_bk1.create_cwb_matrix_dtl_b
      (p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_business_group_id           =>   p_business_group_id
      ,p_row_crit_val                =>   p_row_crit_val
      ,p_col_crit_val                =>   p_col_crit_val
      ,p_pct_emp_cndr                =>   p_pct_emp_cndr
      ,p_pct_val                     =>   p_pct_val
      ,p_emp_amt                     =>   p_emp_amt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwb_matrix_dtl'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ben_bcd_ins.ins
    (p_cwb_matrix_dtl_id           =>   l_cwb_matrix_dtl_id
    ,p_cwb_matrix_id               =>   p_cwb_matrix_id
    ,p_business_group_id           =>   p_business_group_id
    ,p_row_crit_val                =>   p_row_crit_val
    ,p_col_crit_val                =>   p_col_crit_val
    ,p_pct_emp_cndr                =>   p_pct_emp_cndr
    ,p_pct_val                     =>   p_pct_val
    ,p_emp_amt                     =>   p_emp_amt
    ,p_object_version_number       =>   l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_matrix_dtl_bk1.create_cwb_matrix_dtl_a
      (p_cwb_matrix_dtl_id           =>   l_cwb_matrix_dtl_id
      ,p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_business_group_id           =>   p_business_group_id
      ,p_row_crit_val                =>   p_row_crit_val
      ,p_col_crit_val                =>   p_col_crit_val
      ,p_pct_emp_cndr                =>   p_pct_emp_cndr
      ,p_pct_val                     =>   p_pct_val
      ,p_emp_amt                     =>   p_emp_amt
      ,p_object_version_number       =>   l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwb_matrix_dtl'
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
  p_cwb_matrix_dtl_id      := l_cwb_matrix_dtl_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_cwb_matrix_dtl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cwb_matrix_dtl_id      := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_cwb_matrix_dtl;
    p_cwb_matrix_dtl_id      := null; --nocopy changes
    p_object_version_number  := null; --nocopy changes

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cwb_matrix_dtl;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cwb_matrix_dtl >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwb_matrix_dtl
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_dtl_id             in     number
  ,p_cwb_matrix_id                 in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_row_crit_val                  in     varchar2 default hr_api.g_varchar2
  ,p_col_crit_val                  in     varchar2 default hr_api.g_varchar2
  ,p_pct_emp_cndr                  in     number   default hr_api.g_number
  ,p_pct_val                       in     number   default hr_api.g_number
  ,p_emp_amt                       in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number          ben_cwb_matrix_dtl.object_version_number%TYPE;
  l_proc                           varchar2(72) := g_package||'update_cwb_matrix_dtl';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_cwb_matrix_dtl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_matrix_dtl_bk2.update_cwb_matrix_dtl_b
      (p_cwb_matrix_dtl_id           =>   p_cwb_matrix_dtl_id
      ,p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_business_group_id           =>   p_business_group_id
      ,p_row_crit_val                =>   p_row_crit_val
      ,p_col_crit_val                =>   p_col_crit_val
      ,p_pct_emp_cndr                =>   p_pct_emp_cndr
      ,p_pct_val                     =>   p_pct_val
      ,p_emp_amt                     =>   p_emp_amt
      ,p_object_version_number       =>   p_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cwb_matrix_dtl'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ben_bcd_upd.upd
    (p_cwb_matrix_dtl_id           =>   p_cwb_matrix_dtl_id
    ,p_cwb_matrix_id               =>   p_cwb_matrix_id
    ,p_row_crit_val                =>   p_row_crit_val
    ,p_col_crit_val                =>   p_col_crit_val
    ,p_business_group_id           =>   p_business_group_id
    ,p_pct_emp_cndr                =>   p_pct_emp_cndr
    ,p_pct_val                     =>   p_pct_val
    ,p_emp_amt                     =>   p_emp_amt
    ,p_object_version_number       =>   l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_cwb_matrix_dtl
    --
    ben_cwb_matrix_dtl_bk2.update_cwb_matrix_dtl_a
      (p_cwb_matrix_dtl_id           =>   p_cwb_matrix_dtl_id
      ,p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_business_group_id           =>   p_business_group_id
      ,p_row_crit_val                =>   p_row_crit_val
      ,p_col_crit_val                =>   p_col_crit_val
      ,p_pct_emp_cndr                =>   p_pct_emp_cndr
      ,p_pct_val                     =>   p_pct_val
      ,p_emp_amt                     =>   p_emp_amt
      ,p_object_version_number       =>   l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cwb_matrix_dtl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_cwb_matrix_dtl
    --
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_cwb_matrix_dtl;
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
    rollback to update_cwb_matrix_dtl;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cwb_matrix_dtl;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cwb_matrix_dtl >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_matrix_dtl
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_dtl_id             in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number          ben_cwb_matrix_dtl.object_version_number%TYPE;
  l_proc                           varchar2(72) := g_package||'delete_cwb_matrix_dtl';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_cwb_matrix_dtl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_matrix_dtl_bk3.delete_cwb_matrix_dtl_b
      (p_cwb_matrix_dtl_id           =>   p_cwb_matrix_dtl_id
      ,p_object_version_number       =>   p_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_cwb_matrix_dtl'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ben_bcd_del.del
    (p_cwb_matrix_dtl_id           =>   p_cwb_matrix_dtl_id
    ,p_object_version_number       =>   l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_cwb_matrix_dtl
    --
    ben_cwb_matrix_dtl_bk3.delete_cwb_matrix_dtl_a
      (p_cwb_matrix_dtl_id           =>   p_cwb_matrix_dtl_id
      ,p_object_version_number       =>   l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_cwb_matrix_dtl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cwb_matrix_dtl
    --
  end;
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
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_cwb_matrix_dtl;
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
    rollback to delete_cwb_matrix_dtl;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_cwb_matrix_dtl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_cwb_matrix_dtl_id             in     number
  ,p_object_version_number         in     number
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
  ben_bcd_shd.lck
    (p_cwb_matrix_dtl_id           =>  p_cwb_matrix_dtl_id
    ,p_object_version_number       =>  p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_cwb_matrix_dtl_api;

/
