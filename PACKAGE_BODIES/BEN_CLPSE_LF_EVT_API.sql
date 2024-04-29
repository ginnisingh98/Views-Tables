--------------------------------------------------------
--  DDL for Package Body BEN_CLPSE_LF_EVT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLPSE_LF_EVT_API" as
/* $Header: beclpapi.pkb 120.0 2005/05/28 01:04:37 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_clpse_lf_evt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_clpse_lf_evt >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_clpse_lf_evt
  (p_validate                       in  boolean   default false
  ,p_clpse_lf_evt_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_seq                            in  number    default null
  ,p_ler1_id                        in  number    default null
  ,p_bool1_cd                       in  varchar2  default null
  ,p_ler2_id                        in  number    default null
  ,p_bool2_cd                       in  varchar2  default null
  ,p_ler3_id                        in  number    default null
  ,p_bool3_cd                       in  varchar2  default null
  ,p_ler4_id                        in  number    default null
  ,p_bool4_cd                       in  varchar2  default null
  ,p_ler5_id                        in  number    default null
  ,p_bool5_cd                       in  varchar2  default null
  ,p_ler6_id                        in  number    default null
  ,p_bool6_cd                       in  varchar2  default null
  ,p_ler7_id                        in  number    default null
  ,p_bool7_cd                       in  varchar2  default null
  ,p_ler8_id                        in  number    default null
  ,p_bool8_cd                       in  varchar2  default null
  ,p_ler9_id                        in  number    default null
  ,p_bool9_cd                       in  varchar2  default null
  ,p_ler10_id                       in  number    default null
  ,p_eval_cd                        in  varchar2  default null
  ,p_eval_rl                        in  number    default null
  ,p_tlrnc_dys_num                  in  number    default null
  ,p_eval_ler_id                    in  number    default null
  ,p_eval_ler_det_cd                in  varchar2  default null
  ,p_eval_ler_det_rl                in  number    default null
  ,p_clp_attribute_category         in  varchar2  default null
  ,p_clp_attribute1                 in  varchar2  default null
  ,p_clp_attribute2                 in  varchar2  default null
  ,p_clp_attribute3                 in  varchar2  default null
  ,p_clp_attribute4                 in  varchar2  default null
  ,p_clp_attribute5                 in  varchar2  default null
  ,p_clp_attribute6                 in  varchar2  default null
  ,p_clp_attribute7                 in  varchar2  default null
  ,p_clp_attribute8                 in  varchar2  default null
  ,p_clp_attribute9                 in  varchar2  default null
  ,p_clp_attribute10                in  varchar2  default null
  ,p_clp_attribute11                in  varchar2  default null
  ,p_clp_attribute12                in  varchar2  default null
  ,p_clp_attribute13                in  varchar2  default null
  ,p_clp_attribute14                in  varchar2  default null
  ,p_clp_attribute15                in  varchar2  default null
  ,p_clp_attribute16                in  varchar2  default null
  ,p_clp_attribute17                in  varchar2  default null
  ,p_clp_attribute18                in  varchar2  default null
  ,p_clp_attribute19                in  varchar2  default null
  ,p_clp_attribute20                in  varchar2  default null
  ,p_clp_attribute21                in  varchar2  default null
  ,p_clp_attribute22                in  varchar2  default null
  ,p_clp_attribute23                in  varchar2  default null
  ,p_clp_attribute24                in  varchar2  default null
  ,p_clp_attribute25                in  varchar2  default null
  ,p_clp_attribute26                in  varchar2  default null
  ,p_clp_attribute27                in  varchar2  default null
  ,p_clp_attribute28                in  varchar2  default null
  ,p_clp_attribute29                in  varchar2  default null
  ,p_clp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_clpse_lf_evt_id ben_clpse_lf_evt_f.clpse_lf_evt_id%TYPE;
  l_effective_start_date ben_clpse_lf_evt_f.effective_start_date%TYPE;
  l_effective_end_date ben_clpse_lf_evt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_clpse_lf_evt';
  l_object_version_number ben_clpse_lf_evt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_clpse_lf_evt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_clpse_lf_evt
    --
    ben_clpse_lf_evt_bk1.create_clpse_lf_evt_b
      (p_business_group_id              =>  p_business_group_id
      ,p_seq                            =>  p_seq
      ,p_ler1_id                        =>  p_ler1_id
      ,p_bool1_cd                       =>  p_bool1_cd
      ,p_ler2_id                        =>  p_ler2_id
      ,p_bool2_cd                       =>  p_bool2_cd
      ,p_ler3_id                        =>  p_ler3_id
      ,p_bool3_cd                       =>  p_bool3_cd
      ,p_ler4_id                        =>  p_ler4_id
      ,p_bool4_cd                       =>  p_bool4_cd
      ,p_ler5_id                        =>  p_ler5_id
      ,p_bool5_cd                       =>  p_bool5_cd
      ,p_ler6_id                        =>  p_ler6_id
      ,p_bool6_cd                       =>  p_bool6_cd
      ,p_ler7_id                        =>  p_ler7_id
      ,p_bool7_cd                       =>  p_bool7_cd
      ,p_ler8_id                        =>  p_ler8_id
      ,p_bool8_cd                       =>  p_bool8_cd
      ,p_ler9_id                        =>  p_ler9_id
      ,p_bool9_cd                       =>  p_bool9_cd
      ,p_ler10_id                       =>  p_ler10_id
      ,p_eval_cd                        =>  p_eval_cd
      ,p_eval_rl                        =>  p_eval_rl
      ,p_tlrnc_dys_num                  =>  p_tlrnc_dys_num
      ,p_eval_ler_id                    =>  p_eval_ler_id
      ,p_eval_ler_det_cd                =>  p_eval_ler_det_cd
      ,p_eval_ler_det_rl                =>  p_eval_ler_det_rl
      ,p_clp_attribute_category         =>  p_clp_attribute_category
      ,p_clp_attribute1                 =>  p_clp_attribute1
      ,p_clp_attribute2                 =>  p_clp_attribute2
      ,p_clp_attribute3                 =>  p_clp_attribute3
      ,p_clp_attribute4                 =>  p_clp_attribute4
      ,p_clp_attribute5                 =>  p_clp_attribute5
      ,p_clp_attribute6                 =>  p_clp_attribute6
      ,p_clp_attribute7                 =>  p_clp_attribute7
      ,p_clp_attribute8                 =>  p_clp_attribute8
      ,p_clp_attribute9                 =>  p_clp_attribute9
      ,p_clp_attribute10                =>  p_clp_attribute10
      ,p_clp_attribute11                =>  p_clp_attribute11
      ,p_clp_attribute12                =>  p_clp_attribute12
      ,p_clp_attribute13                =>  p_clp_attribute13
      ,p_clp_attribute14                =>  p_clp_attribute14
      ,p_clp_attribute15                =>  p_clp_attribute15
      ,p_clp_attribute16                =>  p_clp_attribute16
      ,p_clp_attribute17                =>  p_clp_attribute17
      ,p_clp_attribute18                =>  p_clp_attribute18
      ,p_clp_attribute19                =>  p_clp_attribute19
      ,p_clp_attribute20                =>  p_clp_attribute20
      ,p_clp_attribute21                =>  p_clp_attribute21
      ,p_clp_attribute22                =>  p_clp_attribute22
      ,p_clp_attribute23                =>  p_clp_attribute23
      ,p_clp_attribute24                =>  p_clp_attribute24
      ,p_clp_attribute25                =>  p_clp_attribute25
      ,p_clp_attribute26                =>  p_clp_attribute26
      ,p_clp_attribute27                =>  p_clp_attribute27
      ,p_clp_attribute28                =>  p_clp_attribute28
      ,p_clp_attribute29                =>  p_clp_attribute29
      ,p_clp_attribute30                =>  p_clp_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_clpse_lf_evt'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_clpse_lf_evt
    --
  end;
  --
  ben_clp_ins.ins
    (p_clpse_lf_evt_id               => l_clpse_lf_evt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_seq                           => p_seq
    ,p_ler1_id                       => p_ler1_id
    ,p_bool1_cd                      => p_bool1_cd
    ,p_ler2_id                       => p_ler2_id
    ,p_bool2_cd                      => p_bool2_cd
    ,p_ler3_id                       => p_ler3_id
    ,p_bool3_cd                      => p_bool3_cd
    ,p_ler4_id                       => p_ler4_id
    ,p_bool4_cd                      => p_bool4_cd
    ,p_ler5_id                       => p_ler5_id
    ,p_bool5_cd                      => p_bool5_cd
    ,p_ler6_id                       => p_ler6_id
    ,p_bool6_cd                      => p_bool6_cd
    ,p_ler7_id                       => p_ler7_id
    ,p_bool7_cd                      => p_bool7_cd
    ,p_ler8_id                       => p_ler8_id
    ,p_bool8_cd                      => p_bool8_cd
    ,p_ler9_id                       => p_ler9_id
    ,p_bool9_cd                      => p_bool9_cd
    ,p_ler10_id                      => p_ler10_id
    ,p_eval_cd                       => p_eval_cd
    ,p_eval_rl                       => p_eval_rl
    ,p_tlrnc_dys_num                 => p_tlrnc_dys_num
    ,p_eval_ler_id                   => p_eval_ler_id
    ,p_eval_ler_det_cd               => p_eval_ler_det_cd
    ,p_eval_ler_det_rl               => p_eval_ler_det_rl
    ,p_clp_attribute_category        => p_clp_attribute_category
    ,p_clp_attribute1                => p_clp_attribute1
    ,p_clp_attribute2                => p_clp_attribute2
    ,p_clp_attribute3                => p_clp_attribute3
    ,p_clp_attribute4                => p_clp_attribute4
    ,p_clp_attribute5                => p_clp_attribute5
    ,p_clp_attribute6                => p_clp_attribute6
    ,p_clp_attribute7                => p_clp_attribute7
    ,p_clp_attribute8                => p_clp_attribute8
    ,p_clp_attribute9                => p_clp_attribute9
    ,p_clp_attribute10               => p_clp_attribute10
    ,p_clp_attribute11               => p_clp_attribute11
    ,p_clp_attribute12               => p_clp_attribute12
    ,p_clp_attribute13               => p_clp_attribute13
    ,p_clp_attribute14               => p_clp_attribute14
    ,p_clp_attribute15               => p_clp_attribute15
    ,p_clp_attribute16               => p_clp_attribute16
    ,p_clp_attribute17               => p_clp_attribute17
    ,p_clp_attribute18               => p_clp_attribute18
    ,p_clp_attribute19               => p_clp_attribute19
    ,p_clp_attribute20               => p_clp_attribute20
    ,p_clp_attribute21               => p_clp_attribute21
    ,p_clp_attribute22               => p_clp_attribute22
    ,p_clp_attribute23               => p_clp_attribute23
    ,p_clp_attribute24               => p_clp_attribute24
    ,p_clp_attribute25               => p_clp_attribute25
    ,p_clp_attribute26               => p_clp_attribute26
    ,p_clp_attribute27               => p_clp_attribute27
    ,p_clp_attribute28               => p_clp_attribute28
    ,p_clp_attribute29               => p_clp_attribute29
    ,p_clp_attribute30               => p_clp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
    --
  begin
    --
    -- Start of API User Hook for the after hook of create_clpse_lf_evt
    --
    ben_clpse_lf_evt_bk1.create_clpse_lf_evt_a
      (p_clpse_lf_evt_id                =>  l_clpse_lf_evt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_seq                            =>  p_seq
      ,p_ler1_id                        =>  p_ler1_id
      ,p_bool1_cd                       =>  p_bool1_cd
      ,p_ler2_id                        =>  p_ler2_id
      ,p_bool2_cd                       =>  p_bool2_cd
      ,p_ler3_id                        =>  p_ler3_id
      ,p_bool3_cd                       =>  p_bool3_cd
      ,p_ler4_id                        =>  p_ler4_id
      ,p_bool4_cd                       =>  p_bool4_cd
      ,p_ler5_id                        =>  p_ler5_id
      ,p_bool5_cd                       =>  p_bool5_cd
      ,p_ler6_id                        =>  p_ler6_id
      ,p_bool6_cd                       =>  p_bool6_cd
      ,p_ler7_id                        =>  p_ler7_id
      ,p_bool7_cd                       =>  p_bool7_cd
      ,p_ler8_id                        =>  p_ler8_id
      ,p_bool8_cd                       =>  p_bool8_cd
      ,p_ler9_id                        =>  p_ler9_id
      ,p_bool9_cd                       =>  p_bool9_cd
      ,p_ler10_id                       =>  p_ler10_id
      ,p_eval_cd                        =>  p_eval_cd
      ,p_eval_rl                        =>  p_eval_rl
      ,p_tlrnc_dys_num                  =>  p_tlrnc_dys_num
      ,p_eval_ler_id                    =>  p_eval_ler_id
      ,p_eval_ler_det_cd                =>  p_eval_ler_det_cd
      ,p_eval_ler_det_rl                =>  p_eval_ler_det_rl
      ,p_clp_attribute_category         =>  p_clp_attribute_category
      ,p_clp_attribute1                 =>  p_clp_attribute1
      ,p_clp_attribute2                 =>  p_clp_attribute2
      ,p_clp_attribute3                 =>  p_clp_attribute3
      ,p_clp_attribute4                 =>  p_clp_attribute4
      ,p_clp_attribute5                 =>  p_clp_attribute5
      ,p_clp_attribute6                 =>  p_clp_attribute6
      ,p_clp_attribute7                 =>  p_clp_attribute7
      ,p_clp_attribute8                 =>  p_clp_attribute8
      ,p_clp_attribute9                 =>  p_clp_attribute9
      ,p_clp_attribute10                =>  p_clp_attribute10
      ,p_clp_attribute11                =>  p_clp_attribute11
      ,p_clp_attribute12                =>  p_clp_attribute12
      ,p_clp_attribute13                =>  p_clp_attribute13
      ,p_clp_attribute14                =>  p_clp_attribute14
      ,p_clp_attribute15                =>  p_clp_attribute15
      ,p_clp_attribute16                =>  p_clp_attribute16
      ,p_clp_attribute17                =>  p_clp_attribute17
      ,p_clp_attribute18                =>  p_clp_attribute18
      ,p_clp_attribute19                =>  p_clp_attribute19
      ,p_clp_attribute20                =>  p_clp_attribute20
      ,p_clp_attribute21                =>  p_clp_attribute21
      ,p_clp_attribute22                =>  p_clp_attribute22
      ,p_clp_attribute23                =>  p_clp_attribute23
      ,p_clp_attribute24                =>  p_clp_attribute24
      ,p_clp_attribute25                =>  p_clp_attribute25
      ,p_clp_attribute26                =>  p_clp_attribute26
      ,p_clp_attribute27                =>  p_clp_attribute27
      ,p_clp_attribute28                =>  p_clp_attribute28
      ,p_clp_attribute29                =>  p_clp_attribute29
      ,p_clp_attribute30                =>  p_clp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_clpse_lf_evt'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_clpse_lf_evt
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
  p_clpse_lf_evt_id := l_clpse_lf_evt_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO create_clpse_lf_evt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_clpse_lf_evt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_clpse_lf_evt;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end create_clpse_lf_evt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_clpse_lf_evt >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_clpse_lf_evt
  (p_validate                       in  boolean   default false
  ,p_clpse_lf_evt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_seq                            in  number    default hr_api.g_number
  ,p_ler1_id                        in  number    default hr_api.g_number
  ,p_bool1_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler2_id                        in  number    default hr_api.g_number
  ,p_bool2_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler3_id                        in  number    default hr_api.g_number
  ,p_bool3_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler4_id                        in  number    default hr_api.g_number
  ,p_bool4_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler5_id                        in  number    default hr_api.g_number
  ,p_bool5_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler6_id                        in  number    default hr_api.g_number
  ,p_bool6_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler7_id                        in  number    default hr_api.g_number
  ,p_bool7_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler8_id                        in  number    default hr_api.g_number
  ,p_bool8_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler9_id                        in  number    default hr_api.g_number
  ,p_bool9_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_ler10_id                       in  number    default hr_api.g_number
  ,p_eval_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_eval_rl                        in  number    default hr_api.g_number
  ,p_tlrnc_dys_num                  in  number    default hr_api.g_number
  ,p_eval_ler_id                    in  number    default hr_api.g_number
  ,p_eval_ler_det_cd                in  varchar2  default hr_api.g_varchar2
  ,p_eval_ler_det_rl                in  number    default hr_api.g_number
  ,p_clp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_clp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_clpse_lf_evt';
  l_object_version_number ben_clpse_lf_evt_f.object_version_number%TYPE;
  l_effective_start_date ben_clpse_lf_evt_f.effective_start_date%TYPE;
  l_effective_end_date ben_clpse_lf_evt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_clpse_lf_evt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_clpse_lf_evt
    --
    ben_clpse_lf_evt_bk2.update_clpse_lf_evt_b
      (p_clpse_lf_evt_id                =>  p_clpse_lf_evt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_seq                            =>  p_seq
      ,p_ler1_id                        =>  p_ler1_id
      ,p_bool1_cd                       =>  p_bool1_cd
      ,p_ler2_id                        =>  p_ler2_id
      ,p_bool2_cd                       =>  p_bool2_cd
      ,p_ler3_id                        =>  p_ler3_id
      ,p_bool3_cd                       =>  p_bool3_cd
      ,p_ler4_id                        =>  p_ler4_id
      ,p_bool4_cd                       =>  p_bool4_cd
      ,p_ler5_id                        =>  p_ler5_id
      ,p_bool5_cd                       =>  p_bool5_cd
      ,p_ler6_id                        =>  p_ler6_id
      ,p_bool6_cd                       =>  p_bool6_cd
      ,p_ler7_id                        =>  p_ler7_id
      ,p_bool7_cd                       =>  p_bool7_cd
      ,p_ler8_id                        =>  p_ler8_id
      ,p_bool8_cd                       =>  p_bool8_cd
      ,p_ler9_id                        =>  p_ler9_id
      ,p_bool9_cd                       =>  p_bool9_cd
      ,p_ler10_id                       =>  p_ler10_id
      ,p_eval_cd                        =>  p_eval_cd
      ,p_eval_rl                        =>  p_eval_rl
      ,p_tlrnc_dys_num                  =>  p_tlrnc_dys_num
      ,p_eval_ler_id                    =>  p_eval_ler_id
      ,p_eval_ler_det_cd                =>  p_eval_ler_det_cd
      ,p_eval_ler_det_rl                =>  p_eval_ler_det_rl
      ,p_clp_attribute_category         =>  p_clp_attribute_category
      ,p_clp_attribute1                 =>  p_clp_attribute1
      ,p_clp_attribute2                 =>  p_clp_attribute2
      ,p_clp_attribute3                 =>  p_clp_attribute3
      ,p_clp_attribute4                 =>  p_clp_attribute4
      ,p_clp_attribute5                 =>  p_clp_attribute5
      ,p_clp_attribute6                 =>  p_clp_attribute6
      ,p_clp_attribute7                 =>  p_clp_attribute7
      ,p_clp_attribute8                 =>  p_clp_attribute8
      ,p_clp_attribute9                 =>  p_clp_attribute9
      ,p_clp_attribute10                =>  p_clp_attribute10
      ,p_clp_attribute11                =>  p_clp_attribute11
      ,p_clp_attribute12                =>  p_clp_attribute12
      ,p_clp_attribute13                =>  p_clp_attribute13
      ,p_clp_attribute14                =>  p_clp_attribute14
      ,p_clp_attribute15                =>  p_clp_attribute15
      ,p_clp_attribute16                =>  p_clp_attribute16
      ,p_clp_attribute17                =>  p_clp_attribute17
      ,p_clp_attribute18                =>  p_clp_attribute18
      ,p_clp_attribute19                =>  p_clp_attribute19
      ,p_clp_attribute20                =>  p_clp_attribute20
      ,p_clp_attribute21                =>  p_clp_attribute21
      ,p_clp_attribute22                =>  p_clp_attribute22
      ,p_clp_attribute23                =>  p_clp_attribute23
      ,p_clp_attribute24                =>  p_clp_attribute24
      ,p_clp_attribute25                =>  p_clp_attribute25
      ,p_clp_attribute26                =>  p_clp_attribute26
      ,p_clp_attribute27                =>  p_clp_attribute27
      ,p_clp_attribute28                =>  p_clp_attribute28
      ,p_clp_attribute29                =>  p_clp_attribute29
      ,p_clp_attribute30                =>  p_clp_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_clpse_lf_evt'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_clpse_lf_evt
    --
  end;
  --
  ben_clp_upd.upd
    (p_clpse_lf_evt_id               => p_clpse_lf_evt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_seq                           => p_seq
    ,p_ler1_id                       => p_ler1_id
    ,p_bool1_cd                      => p_bool1_cd
    ,p_ler2_id                       => p_ler2_id
    ,p_bool2_cd                      => p_bool2_cd
    ,p_ler3_id                       => p_ler3_id
    ,p_bool3_cd                      => p_bool3_cd
    ,p_ler4_id                       => p_ler4_id
    ,p_bool4_cd                      => p_bool4_cd
    ,p_ler5_id                       => p_ler5_id
    ,p_bool5_cd                      => p_bool5_cd
    ,p_ler6_id                       => p_ler6_id
    ,p_bool6_cd                      => p_bool6_cd
    ,p_ler7_id                       => p_ler7_id
    ,p_bool7_cd                      => p_bool7_cd
    ,p_ler8_id                       => p_ler8_id
    ,p_bool8_cd                      => p_bool8_cd
    ,p_ler9_id                       => p_ler9_id
    ,p_bool9_cd                      => p_bool9_cd
    ,p_ler10_id                      => p_ler10_id
    ,p_eval_cd                       => p_eval_cd
    ,p_eval_rl                       => p_eval_rl
    ,p_tlrnc_dys_num                 => p_tlrnc_dys_num
    ,p_eval_ler_id                   => p_eval_ler_id
    ,p_eval_ler_det_cd               => p_eval_ler_det_cd
    ,p_eval_ler_det_rl               => p_eval_ler_det_rl
    ,p_clp_attribute_category        => p_clp_attribute_category
    ,p_clp_attribute1                => p_clp_attribute1
    ,p_clp_attribute2                => p_clp_attribute2
    ,p_clp_attribute3                => p_clp_attribute3
    ,p_clp_attribute4                => p_clp_attribute4
    ,p_clp_attribute5                => p_clp_attribute5
    ,p_clp_attribute6                => p_clp_attribute6
    ,p_clp_attribute7                => p_clp_attribute7
    ,p_clp_attribute8                => p_clp_attribute8
    ,p_clp_attribute9                => p_clp_attribute9
    ,p_clp_attribute10               => p_clp_attribute10
    ,p_clp_attribute11               => p_clp_attribute11
    ,p_clp_attribute12               => p_clp_attribute12
    ,p_clp_attribute13               => p_clp_attribute13
    ,p_clp_attribute14               => p_clp_attribute14
    ,p_clp_attribute15               => p_clp_attribute15
    ,p_clp_attribute16               => p_clp_attribute16
    ,p_clp_attribute17               => p_clp_attribute17
    ,p_clp_attribute18               => p_clp_attribute18
    ,p_clp_attribute19               => p_clp_attribute19
    ,p_clp_attribute20               => p_clp_attribute20
    ,p_clp_attribute21               => p_clp_attribute21
    ,p_clp_attribute22               => p_clp_attribute22
    ,p_clp_attribute23               => p_clp_attribute23
    ,p_clp_attribute24               => p_clp_attribute24
    ,p_clp_attribute25               => p_clp_attribute25
    ,p_clp_attribute26               => p_clp_attribute26
    ,p_clp_attribute27               => p_clp_attribute27
    ,p_clp_attribute28               => p_clp_attribute28
    ,p_clp_attribute29               => p_clp_attribute29
    ,p_clp_attribute30               => p_clp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_clpse_lf_evt
    --
    ben_clpse_lf_evt_bk2.update_clpse_lf_evt_a
      (p_clpse_lf_evt_id                =>  p_clpse_lf_evt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_seq                            =>  p_seq
      ,p_ler1_id                        =>  p_ler1_id
      ,p_bool1_cd                       =>  p_bool1_cd
      ,p_ler2_id                        =>  p_ler2_id
      ,p_bool2_cd                       =>  p_bool2_cd
      ,p_ler3_id                        =>  p_ler3_id
      ,p_bool3_cd                       =>  p_bool3_cd
      ,p_ler4_id                        =>  p_ler4_id
      ,p_bool4_cd                       =>  p_bool4_cd
      ,p_ler5_id                        =>  p_ler5_id
      ,p_bool5_cd                       =>  p_bool5_cd
      ,p_ler6_id                        =>  p_ler6_id
      ,p_bool6_cd                       =>  p_bool6_cd
      ,p_ler7_id                        =>  p_ler7_id
      ,p_bool7_cd                       =>  p_bool7_cd
      ,p_ler8_id                        =>  p_ler8_id
      ,p_bool8_cd                       =>  p_bool8_cd
      ,p_ler9_id                        =>  p_ler9_id
      ,p_bool9_cd                       =>  p_bool9_cd
      ,p_ler10_id                       =>  p_ler10_id
      ,p_eval_cd                        =>  p_eval_cd
      ,p_eval_rl                        =>  p_eval_rl
      ,p_tlrnc_dys_num                  =>  p_tlrnc_dys_num
      ,p_eval_ler_id                    =>  p_eval_ler_id
      ,p_eval_ler_det_cd                =>  p_eval_ler_det_cd
      ,p_eval_ler_det_rl                =>  p_eval_ler_det_rl
      ,p_clp_attribute_category         =>  p_clp_attribute_category
      ,p_clp_attribute1                 =>  p_clp_attribute1
      ,p_clp_attribute2                 =>  p_clp_attribute2
      ,p_clp_attribute3                 =>  p_clp_attribute3
      ,p_clp_attribute4                 =>  p_clp_attribute4
      ,p_clp_attribute5                 =>  p_clp_attribute5
      ,p_clp_attribute6                 =>  p_clp_attribute6
      ,p_clp_attribute7                 =>  p_clp_attribute7
      ,p_clp_attribute8                 =>  p_clp_attribute8
      ,p_clp_attribute9                 =>  p_clp_attribute9
      ,p_clp_attribute10                =>  p_clp_attribute10
      ,p_clp_attribute11                =>  p_clp_attribute11
      ,p_clp_attribute12                =>  p_clp_attribute12
      ,p_clp_attribute13                =>  p_clp_attribute13
      ,p_clp_attribute14                =>  p_clp_attribute14
      ,p_clp_attribute15                =>  p_clp_attribute15
      ,p_clp_attribute16                =>  p_clp_attribute16
      ,p_clp_attribute17                =>  p_clp_attribute17
      ,p_clp_attribute18                =>  p_clp_attribute18
      ,p_clp_attribute19                =>  p_clp_attribute19
      ,p_clp_attribute20                =>  p_clp_attribute20
      ,p_clp_attribute21                =>  p_clp_attribute21
      ,p_clp_attribute22                =>  p_clp_attribute22
      ,p_clp_attribute23                =>  p_clp_attribute23
      ,p_clp_attribute24                =>  p_clp_attribute24
      ,p_clp_attribute25                =>  p_clp_attribute25
      ,p_clp_attribute26                =>  p_clp_attribute26
      ,p_clp_attribute27                =>  p_clp_attribute27
      ,p_clp_attribute28                =>  p_clp_attribute28
      ,p_clp_attribute29                =>  p_clp_attribute29
      ,p_clp_attribute30                =>  p_clp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_clpse_lf_evt'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_clpse_lf_evt
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
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO update_clpse_lf_evt;
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
    ROLLBACK TO update_clpse_lf_evt;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_clpse_lf_evt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_clpse_lf_evt >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_clpse_lf_evt
  (p_validate                       in  boolean  default false
  ,p_clpse_lf_evt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_clpse_lf_evt';
  l_object_version_number ben_clpse_lf_evt_f.object_version_number%TYPE;
  l_effective_start_date ben_clpse_lf_evt_f.effective_start_date%TYPE;
  l_effective_end_date ben_clpse_lf_evt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_clpse_lf_evt;
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
    -- Start of API User Hook for the before hook of delete_clpse_lf_evt
    --
    ben_clpse_lf_evt_bk3.delete_clpse_lf_evt_b
      (p_clpse_lf_evt_id                =>  p_clpse_lf_evt_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_clpse_lf_evt'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_clpse_lf_evt
    --
  end;
  --
  ben_clp_del.del
    (p_clpse_lf_evt_id               => p_clpse_lf_evt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_clpse_lf_evt
    --
    ben_clpse_lf_evt_bk3.delete_clpse_lf_evt_a
      (p_clpse_lf_evt_id                =>  p_clpse_lf_evt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_clpse_lf_evt'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_clpse_lf_evt
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
    ROLLBACK TO delete_clpse_lf_evt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_clpse_lf_evt;
      /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
     p_effective_end_date := null;
    raise;
    --
end delete_clpse_lf_evt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_clpse_lf_evt_id                in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_clp_shd.lck
    (p_clpse_lf_evt_id            => p_clpse_lf_evt_id
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date
    ,p_object_version_number      => p_object_version_number
    ,p_effective_date             => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_clpse_lf_evt_api;

/
