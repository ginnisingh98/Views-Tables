--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_ELCTBL_CHC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_ELCTBL_CHC_API" as
/* $Header: bebecapi.pkb 115.3 2002/12/16 17:34:23 glingapp ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_batch_elctbl_chc_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_elctbl_chc >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_elctbl_chc
  (p_validate                       in  boolean   default false
  ,p_batch_elctbl_id                out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_erlst_deenrt_dt                in  date      default null
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_comp_lvl_cd                    in  varchar2  default null
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_batch_elctbl_id ben_batch_elctbl_chc_info.batch_elctbl_id%TYPE;
  l_proc varchar2(72) := g_package||'create_batch_elctbl_chc';
  l_object_version_number ben_batch_elctbl_chc_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_batch_elctbl_chc;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_batch_elctbl_chc
    --
    ben_batch_elctbl_chc_bk1.create_batch_elctbl_chc_b
      (p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_batch_elctbl_chc'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_batch_elctbl_chc
    --
  end;
  --
  ben_bec_ins.ins
    (p_batch_elctbl_id               => l_batch_elctbl_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_person_id                     => p_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
    ,p_enrt_perd_strt_dt             => p_enrt_perd_strt_dt
    ,p_enrt_perd_end_dt              => p_enrt_perd_end_dt
    ,p_erlst_deenrt_dt               => p_erlst_deenrt_dt
    ,p_dflt_enrt_dt                  => p_dflt_enrt_dt
    ,p_enrt_typ_cycl_cd              => p_enrt_typ_cycl_cd
    ,p_comp_lvl_cd                   => p_comp_lvl_cd
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_batch_elctbl_chc
    --
    ben_batch_elctbl_chc_bk1.create_batch_elctbl_chc_a
      (p_batch_elctbl_id                =>  l_batch_elctbl_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_batch_elctbl_chc'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_batch_elctbl_chc
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
  p_batch_elctbl_id := l_batch_elctbl_id;
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
    ROLLBACK TO create_batch_elctbl_chc;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_batch_elctbl_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_batch_elctbl_chc;
    p_batch_elctbl_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_batch_elctbl_chc;
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_elctbl_chc >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_elctbl_chc
  (p_validate                       in  boolean   default false
  ,p_batch_elctbl_id                in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  ,p_erlst_deenrt_dt                in  date      default hr_api.g_date
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_batch_elctbl_chc';
  l_object_version_number ben_batch_elctbl_chc_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_batch_elctbl_chc;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_batch_elctbl_chc
    --
    ben_batch_elctbl_chc_bk2.update_batch_elctbl_chc_b
      (p_batch_elctbl_id                =>  p_batch_elctbl_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_elctbl_chc'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_batch_elctbl_chc
    --
  end;
  --
  ben_bec_upd.upd
    (p_batch_elctbl_id               => p_batch_elctbl_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_person_id                     => p_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
    ,p_enrt_perd_strt_dt             => p_enrt_perd_strt_dt
    ,p_enrt_perd_end_dt              => p_enrt_perd_end_dt
    ,p_erlst_deenrt_dt               => p_erlst_deenrt_dt
    ,p_dflt_enrt_dt                  => p_dflt_enrt_dt
    ,p_enrt_typ_cycl_cd              => p_enrt_typ_cycl_cd
    ,p_comp_lvl_cd                   => p_comp_lvl_cd
    ,p_mndtry_flag                   => p_mndtry_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_batch_elctbl_chc
    --
    ben_batch_elctbl_chc_bk2.update_batch_elctbl_chc_a
      (p_batch_elctbl_id                =>  p_batch_elctbl_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_erlst_deenrt_dt                =>  p_erlst_deenrt_dt
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_comp_lvl_cd                    =>  p_comp_lvl_cd
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_elctbl_chc'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_batch_elctbl_chc
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
    ROLLBACK TO update_batch_elctbl_chc;
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
    ROLLBACK TO update_batch_elctbl_chc;
    raise;
    --
end update_batch_elctbl_chc;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_elctbl_chc >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_elctbl_chc
  (p_validate                       in  boolean  default false
  ,p_batch_elctbl_id                in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_batch_elctbl_chc';
  l_object_version_number ben_batch_elctbl_chc_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_batch_elctbl_chc;
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
    -- Start of API User Hook for the before hook of delete_batch_elctbl_chc
    --
    ben_batch_elctbl_chc_bk3.delete_batch_elctbl_chc_b
      (p_batch_elctbl_id                =>  p_batch_elctbl_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_elctbl_chc'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_batch_elctbl_chc
    --
  end;
  --
  ben_bec_del.del
    (p_batch_elctbl_id               => p_batch_elctbl_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_batch_elctbl_chc
    --
    ben_batch_elctbl_chc_bk3.delete_batch_elctbl_chc_a
      (p_batch_elctbl_id                =>  p_batch_elctbl_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_elctbl_chc'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_batch_elctbl_chc
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
    ROLLBACK TO delete_batch_elctbl_chc;
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
    ROLLBACK TO delete_batch_elctbl_chc;
    raise;
    --
end delete_batch_elctbl_chc;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_batch_elctbl_id                in     number
  ,p_object_version_number          in     number) is
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
  ben_bec_shd.lck
    (p_batch_elctbl_id            => p_batch_elctbl_id
    ,p_object_version_number      => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_batch_elctbl_chc_api;

/
