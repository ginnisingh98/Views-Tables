--------------------------------------------------------
--  DDL for Package Body BEN_COMP_COMM_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_COMM_TYPES_API" as
/* $Header: becctapi.pkb 120.0 2005/05/28 00:58:35 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_comp_comm_types_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_comp_comm_types >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_comp_comm_types
  (p_validate                       in  boolean   default false
  ,p_cm_typ_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_desc_txt                       in  varchar2  default null
  ,p_cm_typ_rl                      in  number    default null
  ,p_cm_usg_cd                      in  varchar2  default null
  ,p_whnvr_trgrd_flag               in  varchar2  default null
  ,p_shrt_name                      in  varchar2  default null
  ,p_pc_kit_cd                      in  varchar2  default null
  ,p_trk_mlg_flag                   in  varchar2  default null
  ,p_mx_num_avlbl_val               in  number    default null
  ,p_to_be_sent_dt_cd               in  varchar2  default null
  ,p_to_be_sent_dt_rl               in  number    default null
  ,p_inspn_rqd_flag                 in  varchar2  default null
  ,p_inspn_rqd_rl                   in  number    default null
  ,p_rcpent_cd                      in  varchar2  default null
  ,p_parnt_cm_typ_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cct_attribute_category         in  varchar2  default null
  ,p_cct_attribute1                 in  varchar2  default null
  ,p_cct_attribute10                in  varchar2  default null
  ,p_cct_attribute11                in  varchar2  default null
  ,p_cct_attribute12                in  varchar2  default null
  ,p_cct_attribute13                in  varchar2  default null
  ,p_cct_attribute14                in  varchar2  default null
  ,p_cct_attribute15                in  varchar2  default null
  ,p_cct_attribute16                in  varchar2  default null
  ,p_cct_attribute17                in  varchar2  default null
  ,p_cct_attribute18                in  varchar2  default null
  ,p_cct_attribute19                in  varchar2  default null
  ,p_cct_attribute2                 in  varchar2  default null
  ,p_cct_attribute20                in  varchar2  default null
  ,p_cct_attribute21                in  varchar2  default null
  ,p_cct_attribute22                in  varchar2  default null
  ,p_cct_attribute23                in  varchar2  default null
  ,p_cct_attribute24                in  varchar2  default null
  ,p_cct_attribute25                in  varchar2  default null
  ,p_cct_attribute26                in  varchar2  default null
  ,p_cct_attribute27                in  varchar2  default null
  ,p_cct_attribute28                in  varchar2  default null
  ,p_cct_attribute29                in  varchar2  default null
  ,p_cct_attribute3                 in  varchar2  default null
  ,p_cct_attribute30                in  varchar2  default null
  ,p_cct_attribute4                 in  varchar2  default null
  ,p_cct_attribute5                 in  varchar2  default null
  ,p_cct_attribute6                 in  varchar2  default null
  ,p_cct_attribute7                 in  varchar2  default null
  ,p_cct_attribute8                 in  varchar2  default null
  ,p_cct_attribute9                 in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_cm_typ_id ben_cm_typ_f.cm_typ_id%TYPE;
  l_effective_start_date ben_cm_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_cm_typ_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_comp_comm_types';
  l_object_version_number ben_cm_typ_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_comp_comm_types;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_comp_comm_types
    --
    ben_comp_comm_types_bk1.create_comp_comm_types_b
      (p_name                           =>  p_name
      ,p_desc_txt                       =>  p_desc_txt
      ,p_cm_typ_rl                      =>  p_cm_typ_rl
      ,p_cm_usg_cd                      =>  p_cm_usg_cd
      ,p_whnvr_trgrd_flag               =>  p_whnvr_trgrd_flag
      ,p_shrt_name                      =>  p_shrt_name
      ,p_pc_kit_cd                      =>  p_pc_kit_cd
      ,p_trk_mlg_flag                   =>  p_trk_mlg_flag
      ,p_mx_num_avlbl_val               =>  p_mx_num_avlbl_val
      ,p_to_be_sent_dt_cd               =>  p_to_be_sent_dt_cd
      ,p_to_be_sent_dt_rl               =>  p_to_be_sent_dt_rl
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_inspn_rqd_rl                   =>  p_inspn_rqd_rl
      ,p_rcpent_cd                      =>  p_rcpent_cd
      ,p_parnt_cm_typ_id                =>  p_parnt_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cct_attribute_category         =>  p_cct_attribute_category
      ,p_cct_attribute1                 =>  p_cct_attribute1
      ,p_cct_attribute10                =>  p_cct_attribute10
      ,p_cct_attribute11                =>  p_cct_attribute11
      ,p_cct_attribute12                =>  p_cct_attribute12
      ,p_cct_attribute13                =>  p_cct_attribute13
      ,p_cct_attribute14                =>  p_cct_attribute14
      ,p_cct_attribute15                =>  p_cct_attribute15
      ,p_cct_attribute16                =>  p_cct_attribute16
      ,p_cct_attribute17                =>  p_cct_attribute17
      ,p_cct_attribute18                =>  p_cct_attribute18
      ,p_cct_attribute19                =>  p_cct_attribute19
      ,p_cct_attribute2                 =>  p_cct_attribute2
      ,p_cct_attribute20                =>  p_cct_attribute20
      ,p_cct_attribute21                =>  p_cct_attribute21
      ,p_cct_attribute22                =>  p_cct_attribute22
      ,p_cct_attribute23                =>  p_cct_attribute23
      ,p_cct_attribute24                =>  p_cct_attribute24
      ,p_cct_attribute25                =>  p_cct_attribute25
      ,p_cct_attribute26                =>  p_cct_attribute26
      ,p_cct_attribute27                =>  p_cct_attribute27
      ,p_cct_attribute28                =>  p_cct_attribute28
      ,p_cct_attribute29                =>  p_cct_attribute29
      ,p_cct_attribute3                 =>  p_cct_attribute3
      ,p_cct_attribute30                =>  p_cct_attribute30
      ,p_cct_attribute4                 =>  p_cct_attribute4
      ,p_cct_attribute5                 =>  p_cct_attribute5
      ,p_cct_attribute6                 =>  p_cct_attribute6
      ,p_cct_attribute7                 =>  p_cct_attribute7
      ,p_cct_attribute8                 =>  p_cct_attribute8
      ,p_cct_attribute9                 =>  p_cct_attribute9
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_comp_comm_types'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_comp_comm_types
    --
  end;
  --
  ben_cct_ins.ins
    (p_cm_typ_id                     => l_cm_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_desc_txt                      => p_desc_txt
    ,p_cm_typ_rl                     => p_cm_typ_rl
    ,p_cm_usg_cd                     => p_cm_usg_cd
    ,p_whnvr_trgrd_flag              => p_whnvr_trgrd_flag
    ,p_shrt_name                     => p_shrt_name
    ,p_pc_kit_cd                     => p_pc_kit_cd
    ,p_trk_mlg_flag                  => p_trk_mlg_flag
    ,p_mx_num_avlbl_val              => p_mx_num_avlbl_val
    ,p_to_be_sent_dt_cd              => p_to_be_sent_dt_cd
    ,p_to_be_sent_dt_rl              => p_to_be_sent_dt_rl
    ,p_inspn_rqd_flag                => p_inspn_rqd_flag
    ,p_inspn_rqd_rl                  => p_inspn_rqd_rl
    ,p_rcpent_cd                     => p_rcpent_cd
    ,p_parnt_cm_typ_id               => p_parnt_cm_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_cct_attribute_category        => p_cct_attribute_category
    ,p_cct_attribute1                => p_cct_attribute1
    ,p_cct_attribute10               => p_cct_attribute10
    ,p_cct_attribute11               => p_cct_attribute11
    ,p_cct_attribute12               => p_cct_attribute12
    ,p_cct_attribute13               => p_cct_attribute13
    ,p_cct_attribute14               => p_cct_attribute14
    ,p_cct_attribute15               => p_cct_attribute15
    ,p_cct_attribute16               => p_cct_attribute16
    ,p_cct_attribute17               => p_cct_attribute17
    ,p_cct_attribute18               => p_cct_attribute18
    ,p_cct_attribute19               => p_cct_attribute19
    ,p_cct_attribute2                => p_cct_attribute2
    ,p_cct_attribute20               => p_cct_attribute20
    ,p_cct_attribute21               => p_cct_attribute21
    ,p_cct_attribute22               => p_cct_attribute22
    ,p_cct_attribute23               => p_cct_attribute23
    ,p_cct_attribute24               => p_cct_attribute24
    ,p_cct_attribute25               => p_cct_attribute25
    ,p_cct_attribute26               => p_cct_attribute26
    ,p_cct_attribute27               => p_cct_attribute27
    ,p_cct_attribute28               => p_cct_attribute28
    ,p_cct_attribute29               => p_cct_attribute29
    ,p_cct_attribute3                => p_cct_attribute3
    ,p_cct_attribute30               => p_cct_attribute30
    ,p_cct_attribute4                => p_cct_attribute4
    ,p_cct_attribute5                => p_cct_attribute5
    ,p_cct_attribute6                => p_cct_attribute6
    ,p_cct_attribute7                => p_cct_attribute7
    ,p_cct_attribute8                => p_cct_attribute8
    ,p_cct_attribute9                => p_cct_attribute9
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_comp_comm_types
    --
    ben_comp_comm_types_bk1.create_comp_comm_types_a
      (p_cm_typ_id                      =>  l_cm_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_desc_txt                       =>  p_desc_txt
      ,p_cm_typ_rl                      =>  p_cm_typ_rl
      ,p_cm_usg_cd                      =>  p_cm_usg_cd
      ,p_whnvr_trgrd_flag               =>  p_whnvr_trgrd_flag
      ,p_shrt_name                      =>  p_shrt_name
      ,p_pc_kit_cd                      =>  p_pc_kit_cd
      ,p_trk_mlg_flag                   =>  p_trk_mlg_flag
      ,p_mx_num_avlbl_val               =>  p_mx_num_avlbl_val
      ,p_to_be_sent_dt_cd               =>  p_to_be_sent_dt_cd
      ,p_to_be_sent_dt_rl               =>  p_to_be_sent_dt_rl
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_inspn_rqd_rl                   =>  p_inspn_rqd_rl
      ,p_rcpent_cd                      =>  p_rcpent_cd
      ,p_parnt_cm_typ_id                =>  p_parnt_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cct_attribute_category         =>  p_cct_attribute_category
      ,p_cct_attribute1                 =>  p_cct_attribute1
      ,p_cct_attribute10                =>  p_cct_attribute10
      ,p_cct_attribute11                =>  p_cct_attribute11
      ,p_cct_attribute12                =>  p_cct_attribute12
      ,p_cct_attribute13                =>  p_cct_attribute13
      ,p_cct_attribute14                =>  p_cct_attribute14
      ,p_cct_attribute15                =>  p_cct_attribute15
      ,p_cct_attribute16                =>  p_cct_attribute16
      ,p_cct_attribute17                =>  p_cct_attribute17
      ,p_cct_attribute18                =>  p_cct_attribute18
      ,p_cct_attribute19                =>  p_cct_attribute19
      ,p_cct_attribute2                 =>  p_cct_attribute2
      ,p_cct_attribute20                =>  p_cct_attribute20
      ,p_cct_attribute21                =>  p_cct_attribute21
      ,p_cct_attribute22                =>  p_cct_attribute22
      ,p_cct_attribute23                =>  p_cct_attribute23
      ,p_cct_attribute24                =>  p_cct_attribute24
      ,p_cct_attribute25                =>  p_cct_attribute25
      ,p_cct_attribute26                =>  p_cct_attribute26
      ,p_cct_attribute27                =>  p_cct_attribute27
      ,p_cct_attribute28                =>  p_cct_attribute28
      ,p_cct_attribute29                =>  p_cct_attribute29
      ,p_cct_attribute3                 =>  p_cct_attribute3
      ,p_cct_attribute30                =>  p_cct_attribute30
      ,p_cct_attribute4                 =>  p_cct_attribute4
      ,p_cct_attribute5                 =>  p_cct_attribute5
      ,p_cct_attribute6                 =>  p_cct_attribute6
      ,p_cct_attribute7                 =>  p_cct_attribute7
      ,p_cct_attribute8                 =>  p_cct_attribute8
      ,p_cct_attribute9                 =>  p_cct_attribute9
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_comp_comm_types'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_comp_comm_types
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
  p_cm_typ_id := l_cm_typ_id;
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
    ROLLBACK TO create_comp_comm_types;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cm_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_comp_comm_types;
    raise;
    --
end create_comp_comm_types;
-- ----------------------------------------------------------------------------
-- |------------------------< update_comp_comm_types >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_comp_comm_types
  (p_validate                       in  boolean   default false
  ,p_cm_typ_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_desc_txt                       in  varchar2  default hr_api.g_varchar2
  ,p_cm_typ_rl                      in  number    default hr_api.g_number
  ,p_cm_usg_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_whnvr_trgrd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_shrt_name                      in  varchar2  default hr_api.g_varchar2
  ,p_pc_kit_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_trk_mlg_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_mx_num_avlbl_val               in  number    default hr_api.g_number
  ,p_to_be_sent_dt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_to_be_sent_dt_rl               in  number    default hr_api.g_number
  ,p_inspn_rqd_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_inspn_rqd_rl                   in  number    default hr_api.g_number
  ,p_rcpent_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_parnt_cm_typ_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cct_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cct_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_comp_comm_types';
  l_object_version_number ben_cm_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_cm_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_cm_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_comp_comm_types;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_comp_comm_types
    --
    ben_comp_comm_types_bk2.update_comp_comm_types_b
      (p_cm_typ_id                      =>  p_cm_typ_id
      ,p_name                           =>  p_name
      ,p_desc_txt                       =>  p_desc_txt
      ,p_cm_typ_rl                      =>  p_cm_typ_rl
      ,p_cm_usg_cd                      =>  p_cm_usg_cd
      ,p_whnvr_trgrd_flag               =>  p_whnvr_trgrd_flag
      ,p_shrt_name                      =>  p_shrt_name
      ,p_pc_kit_cd                      =>  p_pc_kit_cd
      ,p_trk_mlg_flag                   =>  p_trk_mlg_flag
      ,p_mx_num_avlbl_val               =>  p_mx_num_avlbl_val
      ,p_to_be_sent_dt_cd               =>  p_to_be_sent_dt_cd
      ,p_to_be_sent_dt_rl               =>  p_to_be_sent_dt_rl
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_inspn_rqd_rl                   =>  p_inspn_rqd_rl
      ,p_rcpent_cd                      =>  p_rcpent_cd
      ,p_parnt_cm_typ_id                =>  p_parnt_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cct_attribute_category         =>  p_cct_attribute_category
      ,p_cct_attribute1                 =>  p_cct_attribute1
      ,p_cct_attribute10                =>  p_cct_attribute10
      ,p_cct_attribute11                =>  p_cct_attribute11
      ,p_cct_attribute12                =>  p_cct_attribute12
      ,p_cct_attribute13                =>  p_cct_attribute13
      ,p_cct_attribute14                =>  p_cct_attribute14
      ,p_cct_attribute15                =>  p_cct_attribute15
      ,p_cct_attribute16                =>  p_cct_attribute16
      ,p_cct_attribute17                =>  p_cct_attribute17
      ,p_cct_attribute18                =>  p_cct_attribute18
      ,p_cct_attribute19                =>  p_cct_attribute19
      ,p_cct_attribute2                 =>  p_cct_attribute2
      ,p_cct_attribute20                =>  p_cct_attribute20
      ,p_cct_attribute21                =>  p_cct_attribute21
      ,p_cct_attribute22                =>  p_cct_attribute22
      ,p_cct_attribute23                =>  p_cct_attribute23
      ,p_cct_attribute24                =>  p_cct_attribute24
      ,p_cct_attribute25                =>  p_cct_attribute25
      ,p_cct_attribute26                =>  p_cct_attribute26
      ,p_cct_attribute27                =>  p_cct_attribute27
      ,p_cct_attribute28                =>  p_cct_attribute28
      ,p_cct_attribute29                =>  p_cct_attribute29
      ,p_cct_attribute3                 =>  p_cct_attribute3
      ,p_cct_attribute30                =>  p_cct_attribute30
      ,p_cct_attribute4                 =>  p_cct_attribute4
      ,p_cct_attribute5                 =>  p_cct_attribute5
      ,p_cct_attribute6                 =>  p_cct_attribute6
      ,p_cct_attribute7                 =>  p_cct_attribute7
      ,p_cct_attribute8                 =>  p_cct_attribute8
      ,p_cct_attribute9                 =>  p_cct_attribute9
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_comp_comm_types'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_comp_comm_types
    --
  end;
  --
  ben_cct_upd.upd
    (p_cm_typ_id                     => p_cm_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_desc_txt                      => p_desc_txt
    ,p_cm_typ_rl                     => p_cm_typ_rl
    ,p_cm_usg_cd                     => p_cm_usg_cd
    ,p_whnvr_trgrd_flag              => p_whnvr_trgrd_flag
    ,p_shrt_name                     => p_shrt_name
    ,p_pc_kit_cd                     => p_pc_kit_cd
    ,p_trk_mlg_flag                  => p_trk_mlg_flag
    ,p_mx_num_avlbl_val              => p_mx_num_avlbl_val
    ,p_to_be_sent_dt_cd              => p_to_be_sent_dt_cd
    ,p_to_be_sent_dt_rl              => p_to_be_sent_dt_rl
    ,p_inspn_rqd_flag                => p_inspn_rqd_flag
    ,p_inspn_rqd_rl                  => p_inspn_rqd_rl
    ,p_rcpent_cd                     => p_rcpent_cd
    ,p_parnt_cm_typ_id               => p_parnt_cm_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_cct_attribute_category        => p_cct_attribute_category
    ,p_cct_attribute1                => p_cct_attribute1
    ,p_cct_attribute10               => p_cct_attribute10
    ,p_cct_attribute11               => p_cct_attribute11
    ,p_cct_attribute12               => p_cct_attribute12
    ,p_cct_attribute13               => p_cct_attribute13
    ,p_cct_attribute14               => p_cct_attribute14
    ,p_cct_attribute15               => p_cct_attribute15
    ,p_cct_attribute16               => p_cct_attribute16
    ,p_cct_attribute17               => p_cct_attribute17
    ,p_cct_attribute18               => p_cct_attribute18
    ,p_cct_attribute19               => p_cct_attribute19
    ,p_cct_attribute2                => p_cct_attribute2
    ,p_cct_attribute20               => p_cct_attribute20
    ,p_cct_attribute21               => p_cct_attribute21
    ,p_cct_attribute22               => p_cct_attribute22
    ,p_cct_attribute23               => p_cct_attribute23
    ,p_cct_attribute24               => p_cct_attribute24
    ,p_cct_attribute25               => p_cct_attribute25
    ,p_cct_attribute26               => p_cct_attribute26
    ,p_cct_attribute27               => p_cct_attribute27
    ,p_cct_attribute28               => p_cct_attribute28
    ,p_cct_attribute29               => p_cct_attribute29
    ,p_cct_attribute3                => p_cct_attribute3
    ,p_cct_attribute30               => p_cct_attribute30
    ,p_cct_attribute4                => p_cct_attribute4
    ,p_cct_attribute5                => p_cct_attribute5
    ,p_cct_attribute6                => p_cct_attribute6
    ,p_cct_attribute7                => p_cct_attribute7
    ,p_cct_attribute8                => p_cct_attribute8
    ,p_cct_attribute9                => p_cct_attribute9
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_comp_comm_types
    --
    ben_comp_comm_types_bk2.update_comp_comm_types_a
      (p_cm_typ_id                      =>  p_cm_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_desc_txt                       =>  p_desc_txt
      ,p_cm_typ_rl                      =>  p_cm_typ_rl
      ,p_cm_usg_cd                      =>  p_cm_usg_cd
      ,p_whnvr_trgrd_flag               =>  p_whnvr_trgrd_flag
      ,p_shrt_name                      =>  p_shrt_name
      ,p_pc_kit_cd                      =>  p_pc_kit_cd
      ,p_trk_mlg_flag                   =>  p_trk_mlg_flag
      ,p_mx_num_avlbl_val               =>  p_mx_num_avlbl_val
      ,p_to_be_sent_dt_cd               =>  p_to_be_sent_dt_cd
      ,p_to_be_sent_dt_rl               =>  p_to_be_sent_dt_rl
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_inspn_rqd_rl                   =>  p_inspn_rqd_rl
      ,p_rcpent_cd                      =>  p_rcpent_cd
      ,p_parnt_cm_typ_id                =>  p_parnt_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cct_attribute_category         =>  p_cct_attribute_category
      ,p_cct_attribute1                 =>  p_cct_attribute1
      ,p_cct_attribute10                =>  p_cct_attribute10
      ,p_cct_attribute11                =>  p_cct_attribute11
      ,p_cct_attribute12                =>  p_cct_attribute12
      ,p_cct_attribute13                =>  p_cct_attribute13
      ,p_cct_attribute14                =>  p_cct_attribute14
      ,p_cct_attribute15                =>  p_cct_attribute15
      ,p_cct_attribute16                =>  p_cct_attribute16
      ,p_cct_attribute17                =>  p_cct_attribute17
      ,p_cct_attribute18                =>  p_cct_attribute18
      ,p_cct_attribute19                =>  p_cct_attribute19
      ,p_cct_attribute2                 =>  p_cct_attribute2
      ,p_cct_attribute20                =>  p_cct_attribute20
      ,p_cct_attribute21                =>  p_cct_attribute21
      ,p_cct_attribute22                =>  p_cct_attribute22
      ,p_cct_attribute23                =>  p_cct_attribute23
      ,p_cct_attribute24                =>  p_cct_attribute24
      ,p_cct_attribute25                =>  p_cct_attribute25
      ,p_cct_attribute26                =>  p_cct_attribute26
      ,p_cct_attribute27                =>  p_cct_attribute27
      ,p_cct_attribute28                =>  p_cct_attribute28
      ,p_cct_attribute29                =>  p_cct_attribute29
      ,p_cct_attribute3                 =>  p_cct_attribute3
      ,p_cct_attribute30                =>  p_cct_attribute30
      ,p_cct_attribute4                 =>  p_cct_attribute4
      ,p_cct_attribute5                 =>  p_cct_attribute5
      ,p_cct_attribute6                 =>  p_cct_attribute6
      ,p_cct_attribute7                 =>  p_cct_attribute7
      ,p_cct_attribute8                 =>  p_cct_attribute8
      ,p_cct_attribute9                 =>  p_cct_attribute9
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_comp_comm_types'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_comp_comm_types
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
    ROLLBACK TO update_comp_comm_types;
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
    ROLLBACK TO update_comp_comm_types;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end update_comp_comm_types;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_comp_comm_types >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comp_comm_types
  (p_validate                       in  boolean  default false
  ,p_cm_typ_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_comp_comm_types';
  l_object_version_number ben_cm_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_cm_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_cm_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_comp_comm_types;
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
    -- Start of API User Hook for the before hook of delete_comp_comm_types
    --
    ben_comp_comm_types_bk3.delete_comp_comm_types_b
      (p_cm_typ_id                      =>  p_cm_typ_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_comp_comm_types'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_comp_comm_types
    --
  end;
  --
  ben_cct_del.del
    (p_cm_typ_id                     => p_cm_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_comp_comm_types
    --
    ben_comp_comm_types_bk3.delete_comp_comm_types_a
      (p_cm_typ_id                      =>  p_cm_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_comp_comm_types'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_comp_comm_types
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
    ROLLBACK TO delete_comp_comm_types;
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
    ROLLBACK TO delete_comp_comm_types;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_comp_comm_types;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_cm_typ_id                      in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date) is
  --
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
  ben_cct_shd.lck
    (p_cm_typ_id                 => p_cm_typ_id
    ,p_validation_start_date     => l_validation_start_date
    ,p_validation_end_date       => l_validation_end_date
    ,p_object_version_number     => p_object_version_number
    ,p_effective_date            => p_effective_date
    ,p_datetrack_mode            => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_comp_comm_types_api;

/
