--------------------------------------------------------
--  DDL for Package Body BEN_CWB_MATRIX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_MATRIX_API" as
/* $Header: bebcmapi.pkb 115.2 2003/03/10 14:38:58 ssrayapu noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_cwb_matrix_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cwb_matrix >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_matrix
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_name                          in     varchar2
  ,p_plan_id                       in     number   default null
  ,p_matrix_typ_cd                 in     varchar2 default null
  ,p_person_id                     in     number   default null
  ,p_row_crit_cd                   in     varchar2
  ,p_col_crit_cd                   in     varchar2 default null
  ,p_alct_by_cd                    in     varchar2 default 'PCT'
  ,p_cwb_matrix_id                 out nocopy    number
  ,p_object_version_number         out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cwb_matrix_id                  ben_cwb_matrix.cwb_matrix_id%TYPE;
  l_object_version_number          ben_cwb_matrix.object_version_number%TYPE;
  l_proc                           varchar2(72) := g_package||'create_cwb_matrix';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_cwb_matrix;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_matrix_bk1.create_cwb_matrix_b
      (p_effective_date                =>   p_effective_date
      ,p_business_group_id             =>   p_business_group_id
      ,p_name                          =>   p_name
      ,p_plan_id                       =>   p_plan_id
      ,p_matrix_typ_cd                 =>   p_matrix_typ_cd
      ,p_person_id                     =>   p_person_id
      ,p_row_crit_cd                   =>   p_row_crit_cd
      ,p_col_crit_cd                   =>   p_col_crit_cd
      ,p_alct_by_cd                    =>   p_alct_by_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwb_matrix'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ben_bcm_ins.ins
    (p_effective_date                 =>   p_effective_date
    ,p_name                           =>   p_name
    ,p_row_crit_cd                    =>   p_row_crit_cd
    ,p_business_group_id              =>   p_business_group_id
    ,p_date_saved                     =>   p_effective_date
    ,p_plan_id                        =>   p_plan_id
    ,p_matrix_typ_cd                  =>   p_matrix_typ_cd
    ,p_person_id                      =>   p_person_id
    ,p_col_crit_cd                    =>   p_col_crit_cd
    ,p_alct_by_cd                     =>   p_alct_by_cd
    ,p_cwb_matrix_id                  =>   l_cwb_matrix_id
    ,p_object_version_number          =>   l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_matrix_bk1.create_cwb_matrix_a
      (p_effective_date                =>   p_effective_date
      ,p_business_group_id             =>   p_business_group_id
      ,p_name                          =>   p_name
      ,p_plan_id                       =>   p_plan_id
      ,p_matrix_typ_cd                 =>   p_matrix_typ_cd
      ,p_person_id                     =>   p_person_id
      ,p_row_crit_cd                   =>   p_row_crit_cd
      ,p_col_crit_cd                   =>   p_col_crit_cd
      ,p_alct_by_cd                    =>   p_alct_by_cd
      ,p_cwb_matrix_id                 =>   l_cwb_matrix_id
      ,p_object_version_number         =>   l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwb_matrix'
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
  p_cwb_matrix_id          := l_cwb_matrix_id;
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
    rollback to create_cwb_matrix;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cwb_matrix_id          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_cwb_matrix;

    p_cwb_matrix_id          := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cwb_matrix;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cwb_matrix >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwb_matrix
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_id                 in     number
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_plan_id                       in     number   default hr_api.g_number
  ,p_matrix_typ_cd                 in     varchar2 default hr_api.g_varchar2
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_row_crit_cd                   in     varchar2 default hr_api.g_varchar2
  ,p_col_crit_cd                   in     varchar2 default hr_api.g_varchar2
  ,p_alct_by_cd                    in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number          ben_cwb_matrix.object_version_number%TYPE;
  l_proc                           varchar2(72) := g_package||'update_cwb_matrix';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_cwb_matrix;
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
    ben_cwb_matrix_bk2.update_cwb_matrix_b
      (p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_effective_date              =>   p_effective_date
      ,p_business_group_id           =>   p_business_group_id
      ,p_name                        =>   p_name
      ,p_plan_id                     =>   p_plan_id
      ,p_matrix_typ_cd               =>   p_matrix_typ_cd
      ,p_person_id                   =>   p_person_id
      ,p_row_crit_cd                 =>   p_row_crit_cd
      ,p_col_crit_cd                 =>   p_col_crit_cd
      ,p_alct_by_cd                  =>   p_alct_by_cd
      ,p_object_version_number       =>   p_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cwb_matrix'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ben_bcm_upd.upd
    (p_effective_date               =>   p_effective_date
    ,p_cwb_matrix_id                =>   p_cwb_matrix_id
    ,p_object_version_number        =>   l_object_version_number
    ,p_name                         =>   p_name
    ,p_row_crit_cd                  =>   p_row_crit_cd
    ,p_business_group_id            =>   p_business_group_id
    ,p_date_saved                   =>   p_effective_date
    ,p_plan_id                      =>   p_plan_id
    ,p_matrix_typ_cd                =>   p_matrix_typ_cd
    ,p_person_id                    =>   p_person_id
    ,p_col_crit_cd                  =>   p_col_crit_cd
    ,p_alct_by_cd                   =>   p_alct_by_cd
  );
  --
  -- Call After Process User Hook
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_cwb_matrix
    --
    ben_cwb_matrix_bk2.update_cwb_matrix_a
      (p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_name                        =>   p_name
      ,p_effective_date              =>   p_effective_date
      ,p_plan_id                     =>   p_plan_id
      ,p_matrix_typ_cd               =>   p_matrix_typ_cd
      ,p_person_id                   =>   p_person_id
      ,p_row_crit_cd                 =>   p_row_crit_cd
      ,p_col_crit_cd                 =>   p_col_crit_cd
      ,p_alct_by_cd                  =>   p_alct_by_cd
      ,p_business_group_id           =>   p_business_group_id
      ,p_object_version_number       =>   l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_cwb_matrix'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_cwb_matrix
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
    rollback to update_cwb_matrix;
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
    rollback to update_cwb_matrix;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_cwb_matrix;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cwb_matrix >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_matrix
  (p_validate                      in     boolean  default false
  ,p_cwb_matrix_id                 in     number
  ,p_effective_date                in     date
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number          ben_cwb_matrix.object_version_number%TYPE;
  l_proc                           varchar2(72) := g_package||'delete_cwb_matrix';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_cwb_matrix;
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
    ben_cwb_matrix_bk3.delete_cwb_matrix_b
      (p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_effective_date              =>   p_effective_date
      ,p_object_version_number       =>   p_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_cwb_matrix'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  ben_bcm_del.del
    (p_cwb_matrix_id                 =>   p_cwb_matrix_id
    ,p_object_version_number         =>   l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_cwb_matrix
    --
    ben_cwb_matrix_bk3.delete_cwb_matrix_a
      (p_cwb_matrix_id               =>   p_cwb_matrix_id
      ,p_effective_date              =>   p_effective_date
      ,p_object_version_number       =>   l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_cwb_matrix'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cwb_matrix
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
    rollback to delete_cwb_matrix;
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
    rollback to delete_cwb_matrix;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_cwb_matrix;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_cwb_matrix_id                 in     number
  ,p_effective_date                in     date
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
  ben_bcm_shd.lck
    (p_cwb_matrix_id               =>  p_cwb_matrix_id
    ,p_object_version_number       =>  p_object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_cwb_matrix_api;

/
