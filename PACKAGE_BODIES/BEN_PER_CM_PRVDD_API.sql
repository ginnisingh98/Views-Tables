--------------------------------------------------------
--  DDL for Package Body BEN_PER_CM_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PER_CM_PRVDD_API" as
/* $Header: bepcdapi.pkb 115.6 2003/01/16 14:34:59 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PER_CM_PRVDD_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM_PRVDD >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_PRVDD
  (p_validate                       in  boolean   default false
  ,p_per_cm_prvdd_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqstd_flag                     in  varchar2  default 'N'
  ,p_per_cm_prvdd_stat_cd           in  varchar2  default null
  ,p_cm_dlvry_med_cd                in  varchar2  default null
  ,p_cm_dlvry_mthd_cd               in  varchar2  default null
  ,p_sent_dt                        in  date      default null
  ,p_instnc_num                     in  number    default null
  ,p_to_be_sent_dt                  in  date      default null
  ,p_dlvry_instn_txt                in  varchar2  default null
  ,p_inspn_rqd_flag                 in  varchar2  default 'N'
  ,p_resnd_rsn_cd                   in  varchar2  default null
  ,p_resnd_cmnt_txt                 in  varchar2  default null
  ,p_per_cm_id                      in  number    default null
  ,p_address_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcd_attribute_category         in  varchar2  default null
  ,p_pcd_attribute1                 in  varchar2  default null
  ,p_pcd_attribute2                 in  varchar2  default null
  ,p_pcd_attribute3                 in  varchar2  default null
  ,p_pcd_attribute4                 in  varchar2  default null
  ,p_pcd_attribute5                 in  varchar2  default null
  ,p_pcd_attribute6                 in  varchar2  default null
  ,p_pcd_attribute7                 in  varchar2  default null
  ,p_pcd_attribute8                 in  varchar2  default null
  ,p_pcd_attribute9                 in  varchar2  default null
  ,p_pcd_attribute10                in  varchar2  default null
  ,p_pcd_attribute11                in  varchar2  default null
  ,p_pcd_attribute12                in  varchar2  default null
  ,p_pcd_attribute13                in  varchar2  default null
  ,p_pcd_attribute14                in  varchar2  default null
  ,p_pcd_attribute15                in  varchar2  default null
  ,p_pcd_attribute16                in  varchar2  default null
  ,p_pcd_attribute17                in  varchar2  default null
  ,p_pcd_attribute18                in  varchar2  default null
  ,p_pcd_attribute19                in  varchar2  default null
  ,p_pcd_attribute20                in  varchar2  default null
  ,p_pcd_attribute21                in  varchar2  default null
  ,p_pcd_attribute22                in  varchar2  default null
  ,p_pcd_attribute23                in  varchar2  default null
  ,p_pcd_attribute24                in  varchar2  default null
  ,p_pcd_attribute25                in  varchar2  default null
  ,p_pcd_attribute26                in  varchar2  default null
  ,p_pcd_attribute27                in  varchar2  default null
  ,p_pcd_attribute28                in  varchar2  default null
  ,p_pcd_attribute29                in  varchar2  default null
  ,p_pcd_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_per_cm_prvdd_id ben_per_cm_prvdd_f.per_cm_prvdd_id%TYPE;
  l_effective_start_date ben_per_cm_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_prvdd_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PER_CM_PRVDD';
  l_object_version_number ben_per_cm_prvdd_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PER_CM_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk1.create_PER_CM_PRVDD_b
      (p_rqstd_flag                     =>  p_rqstd_flag
      ,p_per_cm_prvdd_stat_cd           =>  p_per_cm_prvdd_stat_cd
      ,p_cm_dlvry_med_cd                =>  p_cm_dlvry_med_cd
      ,p_cm_dlvry_mthd_cd               =>  p_cm_dlvry_mthd_cd
      ,p_sent_dt                        =>  p_sent_dt
      ,p_instnc_num                     =>  p_instnc_num
      ,p_to_be_sent_dt                  =>  p_to_be_sent_dt
      ,p_dlvry_instn_txt                =>  p_dlvry_instn_txt
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_resnd_rsn_cd                   =>  p_resnd_rsn_cd
      ,p_resnd_cmnt_txt                 =>  p_resnd_cmnt_txt
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_address_id                     =>  p_address_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcd_attribute_category         =>  p_pcd_attribute_category
      ,p_pcd_attribute1                 =>  p_pcd_attribute1
      ,p_pcd_attribute2                 =>  p_pcd_attribute2
      ,p_pcd_attribute3                 =>  p_pcd_attribute3
      ,p_pcd_attribute4                 =>  p_pcd_attribute4
      ,p_pcd_attribute5                 =>  p_pcd_attribute5
      ,p_pcd_attribute6                 =>  p_pcd_attribute6
      ,p_pcd_attribute7                 =>  p_pcd_attribute7
      ,p_pcd_attribute8                 =>  p_pcd_attribute8
      ,p_pcd_attribute9                 =>  p_pcd_attribute9
      ,p_pcd_attribute10                =>  p_pcd_attribute10
      ,p_pcd_attribute11                =>  p_pcd_attribute11
      ,p_pcd_attribute12                =>  p_pcd_attribute12
      ,p_pcd_attribute13                =>  p_pcd_attribute13
      ,p_pcd_attribute14                =>  p_pcd_attribute14
      ,p_pcd_attribute15                =>  p_pcd_attribute15
      ,p_pcd_attribute16                =>  p_pcd_attribute16
      ,p_pcd_attribute17                =>  p_pcd_attribute17
      ,p_pcd_attribute18                =>  p_pcd_attribute18
      ,p_pcd_attribute19                =>  p_pcd_attribute19
      ,p_pcd_attribute20                =>  p_pcd_attribute20
      ,p_pcd_attribute21                =>  p_pcd_attribute21
      ,p_pcd_attribute22                =>  p_pcd_attribute22
      ,p_pcd_attribute23                =>  p_pcd_attribute23
      ,p_pcd_attribute24                =>  p_pcd_attribute24
      ,p_pcd_attribute25                =>  p_pcd_attribute25
      ,p_pcd_attribute26                =>  p_pcd_attribute26
      ,p_pcd_attribute27                =>  p_pcd_attribute27
      ,p_pcd_attribute28                =>  p_pcd_attribute28
      ,p_pcd_attribute29                =>  p_pcd_attribute29
      ,p_pcd_attribute30                =>  p_pcd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_PRVDD'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_PER_CM_PRVDD
    --
  end;
  --
  ben_pcd_ins.ins
    (p_per_cm_prvdd_id               => l_per_cm_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_rqstd_flag                    => p_rqstd_flag
    ,p_per_cm_prvdd_stat_cd          => p_per_cm_prvdd_stat_cd
    ,p_cm_dlvry_med_cd               => p_cm_dlvry_med_cd
    ,p_cm_dlvry_mthd_cd              => p_cm_dlvry_mthd_cd
    ,p_sent_dt                       => p_sent_dt
    ,p_instnc_num                    => p_instnc_num
    ,p_to_be_sent_dt                 => p_to_be_sent_dt
    ,p_dlvry_instn_txt               => p_dlvry_instn_txt
    ,p_inspn_rqd_flag                => p_inspn_rqd_flag
    ,p_resnd_rsn_cd                  => p_resnd_rsn_cd
    ,p_resnd_cmnt_txt                => p_resnd_cmnt_txt
    ,p_per_cm_id                     => p_per_cm_id
    ,p_address_id                    => p_address_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcd_attribute_category        => p_pcd_attribute_category
    ,p_pcd_attribute1                => p_pcd_attribute1
    ,p_pcd_attribute2                => p_pcd_attribute2
    ,p_pcd_attribute3                => p_pcd_attribute3
    ,p_pcd_attribute4                => p_pcd_attribute4
    ,p_pcd_attribute5                => p_pcd_attribute5
    ,p_pcd_attribute6                => p_pcd_attribute6
    ,p_pcd_attribute7                => p_pcd_attribute7
    ,p_pcd_attribute8                => p_pcd_attribute8
    ,p_pcd_attribute9                => p_pcd_attribute9
    ,p_pcd_attribute10               => p_pcd_attribute10
    ,p_pcd_attribute11               => p_pcd_attribute11
    ,p_pcd_attribute12               => p_pcd_attribute12
    ,p_pcd_attribute13               => p_pcd_attribute13
    ,p_pcd_attribute14               => p_pcd_attribute14
    ,p_pcd_attribute15               => p_pcd_attribute15
    ,p_pcd_attribute16               => p_pcd_attribute16
    ,p_pcd_attribute17               => p_pcd_attribute17
    ,p_pcd_attribute18               => p_pcd_attribute18
    ,p_pcd_attribute19               => p_pcd_attribute19
    ,p_pcd_attribute20               => p_pcd_attribute20
    ,p_pcd_attribute21               => p_pcd_attribute21
    ,p_pcd_attribute22               => p_pcd_attribute22
    ,p_pcd_attribute23               => p_pcd_attribute23
    ,p_pcd_attribute24               => p_pcd_attribute24
    ,p_pcd_attribute25               => p_pcd_attribute25
    ,p_pcd_attribute26               => p_pcd_attribute26
    ,p_pcd_attribute27               => p_pcd_attribute27
    ,p_pcd_attribute28               => p_pcd_attribute28
    ,p_pcd_attribute29               => p_pcd_attribute29
    ,p_pcd_attribute30               => p_pcd_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk1.create_PER_CM_PRVDD_a
      (p_per_cm_prvdd_id                =>  l_per_cm_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_rqstd_flag                     =>  p_rqstd_flag
      ,p_per_cm_prvdd_stat_cd           =>  p_per_cm_prvdd_stat_cd
      ,p_cm_dlvry_med_cd                =>  p_cm_dlvry_med_cd
      ,p_cm_dlvry_mthd_cd               =>  p_cm_dlvry_mthd_cd
      ,p_sent_dt                        =>  p_sent_dt
      ,p_instnc_num                     =>  p_instnc_num
      ,p_to_be_sent_dt                  =>  p_to_be_sent_dt
      ,p_dlvry_instn_txt                =>  p_dlvry_instn_txt
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_resnd_rsn_cd                   =>  p_resnd_rsn_cd
      ,p_resnd_cmnt_txt                 =>  p_resnd_cmnt_txt
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_address_id                     =>  p_address_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcd_attribute_category         =>  p_pcd_attribute_category
      ,p_pcd_attribute1                 =>  p_pcd_attribute1
      ,p_pcd_attribute2                 =>  p_pcd_attribute2
      ,p_pcd_attribute3                 =>  p_pcd_attribute3
      ,p_pcd_attribute4                 =>  p_pcd_attribute4
      ,p_pcd_attribute5                 =>  p_pcd_attribute5
      ,p_pcd_attribute6                 =>  p_pcd_attribute6
      ,p_pcd_attribute7                 =>  p_pcd_attribute7
      ,p_pcd_attribute8                 =>  p_pcd_attribute8
      ,p_pcd_attribute9                 =>  p_pcd_attribute9
      ,p_pcd_attribute10                =>  p_pcd_attribute10
      ,p_pcd_attribute11                =>  p_pcd_attribute11
      ,p_pcd_attribute12                =>  p_pcd_attribute12
      ,p_pcd_attribute13                =>  p_pcd_attribute13
      ,p_pcd_attribute14                =>  p_pcd_attribute14
      ,p_pcd_attribute15                =>  p_pcd_attribute15
      ,p_pcd_attribute16                =>  p_pcd_attribute16
      ,p_pcd_attribute17                =>  p_pcd_attribute17
      ,p_pcd_attribute18                =>  p_pcd_attribute18
      ,p_pcd_attribute19                =>  p_pcd_attribute19
      ,p_pcd_attribute20                =>  p_pcd_attribute20
      ,p_pcd_attribute21                =>  p_pcd_attribute21
      ,p_pcd_attribute22                =>  p_pcd_attribute22
      ,p_pcd_attribute23                =>  p_pcd_attribute23
      ,p_pcd_attribute24                =>  p_pcd_attribute24
      ,p_pcd_attribute25                =>  p_pcd_attribute25
      ,p_pcd_attribute26                =>  p_pcd_attribute26
      ,p_pcd_attribute27                =>  p_pcd_attribute27
      ,p_pcd_attribute28                =>  p_pcd_attribute28
      ,p_pcd_attribute29                =>  p_pcd_attribute29
      ,p_pcd_attribute30                =>  p_pcd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_PRVDD'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_PER_CM_PRVDD
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
  p_per_cm_prvdd_id := l_per_cm_prvdd_id;
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
    ROLLBACK TO create_PER_CM_PRVDD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_cm_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PER_CM_PRVDD;
    p_per_cm_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_PER_CM_PRVDD;
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM_PRVDD_perf >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_PRVDD_perf
  (p_validate                       in  boolean   default false
  ,p_per_cm_prvdd_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqstd_flag                     in  varchar2  default 'N'
  ,p_per_cm_prvdd_stat_cd           in  varchar2  default null
  ,p_cm_dlvry_med_cd                in  varchar2  default null
  ,p_cm_dlvry_mthd_cd               in  varchar2  default null
  ,p_sent_dt                        in  date      default null
  ,p_instnc_num                     in  number    default null
  ,p_to_be_sent_dt                  in  date      default null
  ,p_dlvry_instn_txt                in  varchar2  default null
  ,p_inspn_rqd_flag                 in  varchar2  default 'N'
  ,p_resnd_rsn_cd                   in  varchar2  default null
  ,p_resnd_cmnt_txt                 in  varchar2  default null
  ,p_per_cm_id                      in  number    default null
  ,p_address_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcd_attribute_category         in  varchar2  default null
  ,p_pcd_attribute1                 in  varchar2  default null
  ,p_pcd_attribute2                 in  varchar2  default null
  ,p_pcd_attribute3                 in  varchar2  default null
  ,p_pcd_attribute4                 in  varchar2  default null
  ,p_pcd_attribute5                 in  varchar2  default null
  ,p_pcd_attribute6                 in  varchar2  default null
  ,p_pcd_attribute7                 in  varchar2  default null
  ,p_pcd_attribute8                 in  varchar2  default null
  ,p_pcd_attribute9                 in  varchar2  default null
  ,p_pcd_attribute10                in  varchar2  default null
  ,p_pcd_attribute11                in  varchar2  default null
  ,p_pcd_attribute12                in  varchar2  default null
  ,p_pcd_attribute13                in  varchar2  default null
  ,p_pcd_attribute14                in  varchar2  default null
  ,p_pcd_attribute15                in  varchar2  default null
  ,p_pcd_attribute16                in  varchar2  default null
  ,p_pcd_attribute17                in  varchar2  default null
  ,p_pcd_attribute18                in  varchar2  default null
  ,p_pcd_attribute19                in  varchar2  default null
  ,p_pcd_attribute20                in  varchar2  default null
  ,p_pcd_attribute21                in  varchar2  default null
  ,p_pcd_attribute22                in  varchar2  default null
  ,p_pcd_attribute23                in  varchar2  default null
  ,p_pcd_attribute24                in  varchar2  default null
  ,p_pcd_attribute25                in  varchar2  default null
  ,p_pcd_attribute26                in  varchar2  default null
  ,p_pcd_attribute27                in  varchar2  default null
  ,p_pcd_attribute28                in  varchar2  default null
  ,p_pcd_attribute29                in  varchar2  default null
  ,p_pcd_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_per_cm_prvdd_id ben_per_cm_prvdd_f.per_cm_prvdd_id%TYPE;
  l_effective_start_date ben_per_cm_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_prvdd_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PER_CM_PRVDD';
  l_object_version_number ben_per_cm_prvdd_f.object_version_number%TYPE;
  --
  cursor c_seq is
    select ben_per_cm_prvdd_f_s.nextval
    from   sys.dual;
  --
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PER_CM_PRVDD;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk1.create_PER_CM_PRVDD_b
      (p_rqstd_flag                     =>  p_rqstd_flag
      ,p_per_cm_prvdd_stat_cd           =>  p_per_cm_prvdd_stat_cd
      ,p_cm_dlvry_med_cd                =>  p_cm_dlvry_med_cd
      ,p_cm_dlvry_mthd_cd               =>  p_cm_dlvry_mthd_cd
      ,p_sent_dt                        =>  p_sent_dt
      ,p_instnc_num                     =>  p_instnc_num
      ,p_to_be_sent_dt                  =>  p_to_be_sent_dt
      ,p_dlvry_instn_txt                =>  p_dlvry_instn_txt
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_resnd_rsn_cd                   =>  p_resnd_rsn_cd
      ,p_resnd_cmnt_txt                 =>  p_resnd_cmnt_txt
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_address_id                     =>  p_address_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcd_attribute_category         =>  p_pcd_attribute_category
      ,p_pcd_attribute1                 =>  p_pcd_attribute1
      ,p_pcd_attribute2                 =>  p_pcd_attribute2
      ,p_pcd_attribute3                 =>  p_pcd_attribute3
      ,p_pcd_attribute4                 =>  p_pcd_attribute4
      ,p_pcd_attribute5                 =>  p_pcd_attribute5
      ,p_pcd_attribute6                 =>  p_pcd_attribute6
      ,p_pcd_attribute7                 =>  p_pcd_attribute7
      ,p_pcd_attribute8                 =>  p_pcd_attribute8
      ,p_pcd_attribute9                 =>  p_pcd_attribute9
      ,p_pcd_attribute10                =>  p_pcd_attribute10
      ,p_pcd_attribute11                =>  p_pcd_attribute11
      ,p_pcd_attribute12                =>  p_pcd_attribute12
      ,p_pcd_attribute13                =>  p_pcd_attribute13
      ,p_pcd_attribute14                =>  p_pcd_attribute14
      ,p_pcd_attribute15                =>  p_pcd_attribute15
      ,p_pcd_attribute16                =>  p_pcd_attribute16
      ,p_pcd_attribute17                =>  p_pcd_attribute17
      ,p_pcd_attribute18                =>  p_pcd_attribute18
      ,p_pcd_attribute19                =>  p_pcd_attribute19
      ,p_pcd_attribute20                =>  p_pcd_attribute20
      ,p_pcd_attribute21                =>  p_pcd_attribute21
      ,p_pcd_attribute22                =>  p_pcd_attribute22
      ,p_pcd_attribute23                =>  p_pcd_attribute23
      ,p_pcd_attribute24                =>  p_pcd_attribute24
      ,p_pcd_attribute25                =>  p_pcd_attribute25
      ,p_pcd_attribute26                =>  p_pcd_attribute26
      ,p_pcd_attribute27                =>  p_pcd_attribute27
      ,p_pcd_attribute28                =>  p_pcd_attribute28
      ,p_pcd_attribute29                =>  p_pcd_attribute29
      ,p_pcd_attribute30                =>  p_pcd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_PRVDD'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_PER_CM_PRVDD
    --
  end;
  --
  -- Set sequence
  --
  open c_seq;
    --
    fetch c_seq into l_per_cm_prvdd_id;
    --
  close c_seq;
  --
  -- Post insert row handler hook
  --
  dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date,
     p_datetrack_mode          => 'INSERT',
     p_base_table_name         => 'ben_per_cm_prvdd_f',
     p_base_key_column         => 'per_cm_prvdd_id',
     p_base_key_value          => p_per_cm_prvdd_id,
     p_parent_table_name1      => 'ben_per_cm_f',
     p_parent_key_column1      => 'per_cm_id',
     p_parent_key_value1       => p_per_cm_id,
     p_enforce_foreign_locking => false,
     p_validation_start_date   => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  l_effective_start_date := l_validation_start_date;
  l_effective_end_date := l_validation_end_date;
  l_object_version_number := 1;
  --
  insert into ben_per_cm_prvdd_f
    (per_cm_prvdd_id
    ,effective_start_date
    ,effective_end_date
    ,rqstd_flag
    ,per_cm_prvdd_stat_cd
    ,cm_dlvry_med_cd
    ,cm_dlvry_mthd_cd
    ,sent_dt
    ,instnc_num
    ,to_be_sent_dt
    ,dlvry_instn_txt
    ,inspn_rqd_flag
    ,resnd_rsn_cd
    ,resnd_cmnt_txt
    ,per_cm_id
    ,address_id
    ,business_group_id
    ,pcd_attribute_category
    ,pcd_attribute1
    ,pcd_attribute2
    ,pcd_attribute3
    ,pcd_attribute4
    ,pcd_attribute5
    ,pcd_attribute6
    ,pcd_attribute7
    ,pcd_attribute8
    ,pcd_attribute9
    ,pcd_attribute10
    ,pcd_attribute11
    ,pcd_attribute12
    ,pcd_attribute13
    ,pcd_attribute14
    ,pcd_attribute15
    ,pcd_attribute16
    ,pcd_attribute17
    ,pcd_attribute18
    ,pcd_attribute19
    ,pcd_attribute20
    ,pcd_attribute21
    ,pcd_attribute22
    ,pcd_attribute23
    ,pcd_attribute24
    ,pcd_attribute25
    ,pcd_attribute26
    ,pcd_attribute27
    ,pcd_attribute28
    ,pcd_attribute29
    ,pcd_attribute30
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,object_version_number)
  values
    (l_per_cm_prvdd_id
    ,l_effective_start_date
    ,l_effective_end_date
    ,p_rqstd_flag
    ,p_per_cm_prvdd_stat_cd
    ,p_cm_dlvry_med_cd
    ,p_cm_dlvry_mthd_cd
    ,p_sent_dt
    ,p_instnc_num
    ,p_to_be_sent_dt
    ,p_dlvry_instn_txt
    ,p_inspn_rqd_flag
    ,p_resnd_rsn_cd
    ,p_resnd_cmnt_txt
    ,p_per_cm_id
    ,p_address_id
    ,p_business_group_id
    ,p_pcd_attribute_category
    ,p_pcd_attribute1
    ,p_pcd_attribute2
    ,p_pcd_attribute3
    ,p_pcd_attribute4
    ,p_pcd_attribute5
    ,p_pcd_attribute6
    ,p_pcd_attribute7
    ,p_pcd_attribute8
    ,p_pcd_attribute9
    ,p_pcd_attribute10
    ,p_pcd_attribute11
    ,p_pcd_attribute12
    ,p_pcd_attribute13
    ,p_pcd_attribute14
    ,p_pcd_attribute15
    ,p_pcd_attribute16
    ,p_pcd_attribute17
    ,p_pcd_attribute18
    ,p_pcd_attribute19
    ,p_pcd_attribute20
    ,p_pcd_attribute21
    ,p_pcd_attribute22
    ,p_pcd_attribute23
    ,p_pcd_attribute24
    ,p_pcd_attribute25
    ,p_pcd_attribute26
    ,p_pcd_attribute27
    ,p_pcd_attribute28
    ,p_pcd_attribute29
    ,p_pcd_attribute30
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,l_object_version_number);
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_pcd_rki.after_insert
      (p_per_cm_prvdd_id               =>l_per_cm_prvdd_id
      ,p_effective_start_date          =>l_effective_start_date
      ,p_effective_end_date            =>l_effective_end_date
      ,p_rqstd_flag                    =>p_rqstd_flag
      ,p_inspn_rqd_flag                =>p_inspn_rqd_flag
      ,p_resnd_rsn_cd                  =>p_resnd_rsn_cd
      ,p_resnd_cmnt_txt                =>p_resnd_cmnt_txt
      ,p_per_cm_prvdd_stat_cd          =>p_per_cm_prvdd_stat_cd
      ,p_cm_dlvry_med_cd               =>p_cm_dlvry_med_cd
      ,p_cm_dlvry_mthd_cd              =>p_cm_dlvry_mthd_cd
      ,p_sent_dt                       =>p_sent_dt
      ,p_instnc_num                    =>p_instnc_num
      ,p_to_be_sent_dt                 =>p_to_be_sent_dt
      ,p_dlvry_instn_txt               =>p_dlvry_instn_txt
      ,p_per_cm_id                     =>p_per_cm_id
      ,p_address_id                    =>p_address_id
      ,p_business_group_id             =>p_business_group_id
      ,p_pcd_attribute_category        =>p_pcd_attribute_category
      ,p_pcd_attribute1                =>p_pcd_attribute1
      ,p_pcd_attribute2                =>p_pcd_attribute2
      ,p_pcd_attribute3                =>p_pcd_attribute3
      ,p_pcd_attribute4                =>p_pcd_attribute4
      ,p_pcd_attribute5                =>p_pcd_attribute5
      ,p_pcd_attribute6                =>p_pcd_attribute6
      ,p_pcd_attribute7                =>p_pcd_attribute7
      ,p_pcd_attribute8                =>p_pcd_attribute8
      ,p_pcd_attribute9                =>p_pcd_attribute9
      ,p_pcd_attribute10               =>p_pcd_attribute10
      ,p_pcd_attribute11               =>p_pcd_attribute11
      ,p_pcd_attribute12               =>p_pcd_attribute12
      ,p_pcd_attribute13               =>p_pcd_attribute13
      ,p_pcd_attribute14               =>p_pcd_attribute14
      ,p_pcd_attribute15               =>p_pcd_attribute15
      ,p_pcd_attribute16               =>p_pcd_attribute16
      ,p_pcd_attribute17               =>p_pcd_attribute17
      ,p_pcd_attribute18               =>p_pcd_attribute18
      ,p_pcd_attribute19               =>p_pcd_attribute19
      ,p_pcd_attribute20               =>p_pcd_attribute20
      ,p_pcd_attribute21               =>p_pcd_attribute21
      ,p_pcd_attribute22               =>p_pcd_attribute22
      ,p_pcd_attribute23               =>p_pcd_attribute23
      ,p_pcd_attribute24               =>p_pcd_attribute24
      ,p_pcd_attribute25               =>p_pcd_attribute25
      ,p_pcd_attribute26               =>p_pcd_attribute26
      ,p_pcd_attribute27               =>p_pcd_attribute27
      ,p_pcd_attribute28               =>p_pcd_attribute28
      ,p_pcd_attribute29               =>p_pcd_attribute29
      ,p_pcd_attribute30               =>p_pcd_attribute30
      ,p_request_id                    =>p_request_id
      ,p_program_application_id        =>p_program_application_id
      ,p_program_id                    =>p_program_id
      ,p_program_update_date           =>p_program_update_date
      ,p_object_version_number         =>l_object_version_number
      ,p_effective_date                =>p_effective_date
      ,p_validation_start_date         =>l_validation_start_date
      ,p_validation_end_date           =>l_validation_end_date);
    --
  exception
    --
     when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_per_cm_prvdd_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk1.create_PER_CM_PRVDD_a
      (p_per_cm_prvdd_id                =>  l_per_cm_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_rqstd_flag                     =>  p_rqstd_flag
      ,p_per_cm_prvdd_stat_cd           =>  p_per_cm_prvdd_stat_cd
      ,p_cm_dlvry_med_cd                =>  p_cm_dlvry_med_cd
      ,p_cm_dlvry_mthd_cd               =>  p_cm_dlvry_mthd_cd
      ,p_sent_dt                        =>  p_sent_dt
      ,p_instnc_num                     =>  p_instnc_num
      ,p_to_be_sent_dt                  =>  p_to_be_sent_dt
      ,p_dlvry_instn_txt                =>  p_dlvry_instn_txt
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_resnd_rsn_cd                   =>  p_resnd_rsn_cd
      ,p_resnd_cmnt_txt                 =>  p_resnd_cmnt_txt
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_address_id                     =>  p_address_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcd_attribute_category         =>  p_pcd_attribute_category
      ,p_pcd_attribute1                 =>  p_pcd_attribute1
      ,p_pcd_attribute2                 =>  p_pcd_attribute2
      ,p_pcd_attribute3                 =>  p_pcd_attribute3
      ,p_pcd_attribute4                 =>  p_pcd_attribute4
      ,p_pcd_attribute5                 =>  p_pcd_attribute5
      ,p_pcd_attribute6                 =>  p_pcd_attribute6
      ,p_pcd_attribute7                 =>  p_pcd_attribute7
      ,p_pcd_attribute8                 =>  p_pcd_attribute8
      ,p_pcd_attribute9                 =>  p_pcd_attribute9
      ,p_pcd_attribute10                =>  p_pcd_attribute10
      ,p_pcd_attribute11                =>  p_pcd_attribute11
      ,p_pcd_attribute12                =>  p_pcd_attribute12
      ,p_pcd_attribute13                =>  p_pcd_attribute13
      ,p_pcd_attribute14                =>  p_pcd_attribute14
      ,p_pcd_attribute15                =>  p_pcd_attribute15
      ,p_pcd_attribute16                =>  p_pcd_attribute16
      ,p_pcd_attribute17                =>  p_pcd_attribute17
      ,p_pcd_attribute18                =>  p_pcd_attribute18
      ,p_pcd_attribute19                =>  p_pcd_attribute19
      ,p_pcd_attribute20                =>  p_pcd_attribute20
      ,p_pcd_attribute21                =>  p_pcd_attribute21
      ,p_pcd_attribute22                =>  p_pcd_attribute22
      ,p_pcd_attribute23                =>  p_pcd_attribute23
      ,p_pcd_attribute24                =>  p_pcd_attribute24
      ,p_pcd_attribute25                =>  p_pcd_attribute25
      ,p_pcd_attribute26                =>  p_pcd_attribute26
      ,p_pcd_attribute27                =>  p_pcd_attribute27
      ,p_pcd_attribute28                =>  p_pcd_attribute28
      ,p_pcd_attribute29                =>  p_pcd_attribute29
      ,p_pcd_attribute30                =>  p_pcd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_CM_PRVDD'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_PER_CM_PRVDD
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
  p_per_cm_prvdd_id := l_per_cm_prvdd_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PER_CM_PRVDD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_cm_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PER_CM_PRVDD;
    p_per_cm_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_PER_CM_PRVDD_perf;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PER_CM_PRVDD >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PER_CM_PRVDD
  (p_validate                       in  boolean   default false
  ,p_per_cm_prvdd_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_rqstd_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_per_cm_prvdd_stat_cd           in  varchar2  default hr_api.g_varchar2
  ,p_cm_dlvry_med_cd                in  varchar2  default hr_api.g_varchar2
  ,p_cm_dlvry_mthd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_sent_dt                        in  date      default hr_api.g_date
  ,p_instnc_num                     in  number    default hr_api.g_number
  ,p_to_be_sent_dt                  in  date      default hr_api.g_date
  ,p_dlvry_instn_txt                in  varchar2  default hr_api.g_varchar2
  ,p_inspn_rqd_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_resnd_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_resnd_cmnt_txt                 in  varchar2  default hr_api.g_varchar2
  ,p_per_cm_id                      in  number    default hr_api.g_number
  ,p_address_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PER_CM_PRVDD';
  l_object_version_number ben_per_cm_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_per_cm_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_prvdd_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PER_CM_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk2.update_PER_CM_PRVDD_b
      (p_per_cm_prvdd_id                =>  p_per_cm_prvdd_id
      ,p_rqstd_flag                     =>  p_rqstd_flag
      ,p_per_cm_prvdd_stat_cd           =>  p_per_cm_prvdd_stat_cd
      ,p_cm_dlvry_med_cd                =>  p_cm_dlvry_med_cd
      ,p_cm_dlvry_mthd_cd               =>  p_cm_dlvry_mthd_cd
      ,p_sent_dt                        =>  p_sent_dt
      ,p_instnc_num                     =>  p_instnc_num
      ,p_to_be_sent_dt                  =>  p_to_be_sent_dt
      ,p_dlvry_instn_txt                =>  p_dlvry_instn_txt
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_resnd_rsn_cd                   =>  p_resnd_rsn_cd
      ,p_resnd_cmnt_txt                 =>  p_resnd_cmnt_txt
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_address_id                     =>  p_address_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcd_attribute_category         =>  p_pcd_attribute_category
      ,p_pcd_attribute1                 =>  p_pcd_attribute1
      ,p_pcd_attribute2                 =>  p_pcd_attribute2
      ,p_pcd_attribute3                 =>  p_pcd_attribute3
      ,p_pcd_attribute4                 =>  p_pcd_attribute4
      ,p_pcd_attribute5                 =>  p_pcd_attribute5
      ,p_pcd_attribute6                 =>  p_pcd_attribute6
      ,p_pcd_attribute7                 =>  p_pcd_attribute7
      ,p_pcd_attribute8                 =>  p_pcd_attribute8
      ,p_pcd_attribute9                 =>  p_pcd_attribute9
      ,p_pcd_attribute10                =>  p_pcd_attribute10
      ,p_pcd_attribute11                =>  p_pcd_attribute11
      ,p_pcd_attribute12                =>  p_pcd_attribute12
      ,p_pcd_attribute13                =>  p_pcd_attribute13
      ,p_pcd_attribute14                =>  p_pcd_attribute14
      ,p_pcd_attribute15                =>  p_pcd_attribute15
      ,p_pcd_attribute16                =>  p_pcd_attribute16
      ,p_pcd_attribute17                =>  p_pcd_attribute17
      ,p_pcd_attribute18                =>  p_pcd_attribute18
      ,p_pcd_attribute19                =>  p_pcd_attribute19
      ,p_pcd_attribute20                =>  p_pcd_attribute20
      ,p_pcd_attribute21                =>  p_pcd_attribute21
      ,p_pcd_attribute22                =>  p_pcd_attribute22
      ,p_pcd_attribute23                =>  p_pcd_attribute23
      ,p_pcd_attribute24                =>  p_pcd_attribute24
      ,p_pcd_attribute25                =>  p_pcd_attribute25
      ,p_pcd_attribute26                =>  p_pcd_attribute26
      ,p_pcd_attribute27                =>  p_pcd_attribute27
      ,p_pcd_attribute28                =>  p_pcd_attribute28
      ,p_pcd_attribute29                =>  p_pcd_attribute29
      ,p_pcd_attribute30                =>  p_pcd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PER_CM_PRVDD'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_PER_CM_PRVDD
    --
  end;
  --
  ben_pcd_upd.upd
    (p_per_cm_prvdd_id               => p_per_cm_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_rqstd_flag                    => p_rqstd_flag
    ,p_per_cm_prvdd_stat_cd          => p_per_cm_prvdd_stat_cd
    ,p_cm_dlvry_med_cd               => p_cm_dlvry_med_cd
    ,p_cm_dlvry_mthd_cd              => p_cm_dlvry_mthd_cd
    ,p_sent_dt                       => p_sent_dt
    ,p_instnc_num                    => p_instnc_num
    ,p_to_be_sent_dt                 => p_to_be_sent_dt
    ,p_dlvry_instn_txt               => p_dlvry_instn_txt
    ,p_inspn_rqd_flag                => p_inspn_rqd_flag
    ,p_resnd_rsn_cd                  => p_resnd_rsn_cd
    ,p_resnd_cmnt_txt                => p_resnd_cmnt_txt
    ,p_per_cm_id                     => p_per_cm_id
    ,p_address_id                    => p_address_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcd_attribute_category        => p_pcd_attribute_category
    ,p_pcd_attribute1                => p_pcd_attribute1
    ,p_pcd_attribute2                => p_pcd_attribute2
    ,p_pcd_attribute3                => p_pcd_attribute3
    ,p_pcd_attribute4                => p_pcd_attribute4
    ,p_pcd_attribute5                => p_pcd_attribute5
    ,p_pcd_attribute6                => p_pcd_attribute6
    ,p_pcd_attribute7                => p_pcd_attribute7
    ,p_pcd_attribute8                => p_pcd_attribute8
    ,p_pcd_attribute9                => p_pcd_attribute9
    ,p_pcd_attribute10               => p_pcd_attribute10
    ,p_pcd_attribute11               => p_pcd_attribute11
    ,p_pcd_attribute12               => p_pcd_attribute12
    ,p_pcd_attribute13               => p_pcd_attribute13
    ,p_pcd_attribute14               => p_pcd_attribute14
    ,p_pcd_attribute15               => p_pcd_attribute15
    ,p_pcd_attribute16               => p_pcd_attribute16
    ,p_pcd_attribute17               => p_pcd_attribute17
    ,p_pcd_attribute18               => p_pcd_attribute18
    ,p_pcd_attribute19               => p_pcd_attribute19
    ,p_pcd_attribute20               => p_pcd_attribute20
    ,p_pcd_attribute21               => p_pcd_attribute21
    ,p_pcd_attribute22               => p_pcd_attribute22
    ,p_pcd_attribute23               => p_pcd_attribute23
    ,p_pcd_attribute24               => p_pcd_attribute24
    ,p_pcd_attribute25               => p_pcd_attribute25
    ,p_pcd_attribute26               => p_pcd_attribute26
    ,p_pcd_attribute27               => p_pcd_attribute27
    ,p_pcd_attribute28               => p_pcd_attribute28
    ,p_pcd_attribute29               => p_pcd_attribute29
    ,p_pcd_attribute30               => p_pcd_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk2.update_PER_CM_PRVDD_a
      (p_per_cm_prvdd_id                =>  p_per_cm_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_rqstd_flag                     =>  p_rqstd_flag
      ,p_per_cm_prvdd_stat_cd           =>  p_per_cm_prvdd_stat_cd
      ,p_cm_dlvry_med_cd                =>  p_cm_dlvry_med_cd
      ,p_cm_dlvry_mthd_cd               =>  p_cm_dlvry_mthd_cd
      ,p_sent_dt                        =>  p_sent_dt
      ,p_instnc_num                     =>  p_instnc_num
      ,p_to_be_sent_dt                  =>  p_to_be_sent_dt
      ,p_dlvry_instn_txt                =>  p_dlvry_instn_txt
      ,p_inspn_rqd_flag                 =>  p_inspn_rqd_flag
      ,p_resnd_rsn_cd                   =>  p_resnd_rsn_cd
      ,p_resnd_cmnt_txt                 =>  p_resnd_cmnt_txt
      ,p_per_cm_id                      =>  p_per_cm_id
      ,p_address_id                     =>  p_address_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcd_attribute_category         =>  p_pcd_attribute_category
      ,p_pcd_attribute1                 =>  p_pcd_attribute1
      ,p_pcd_attribute2                 =>  p_pcd_attribute2
      ,p_pcd_attribute3                 =>  p_pcd_attribute3
      ,p_pcd_attribute4                 =>  p_pcd_attribute4
      ,p_pcd_attribute5                 =>  p_pcd_attribute5
      ,p_pcd_attribute6                 =>  p_pcd_attribute6
      ,p_pcd_attribute7                 =>  p_pcd_attribute7
      ,p_pcd_attribute8                 =>  p_pcd_attribute8
      ,p_pcd_attribute9                 =>  p_pcd_attribute9
      ,p_pcd_attribute10                =>  p_pcd_attribute10
      ,p_pcd_attribute11                =>  p_pcd_attribute11
      ,p_pcd_attribute12                =>  p_pcd_attribute12
      ,p_pcd_attribute13                =>  p_pcd_attribute13
      ,p_pcd_attribute14                =>  p_pcd_attribute14
      ,p_pcd_attribute15                =>  p_pcd_attribute15
      ,p_pcd_attribute16                =>  p_pcd_attribute16
      ,p_pcd_attribute17                =>  p_pcd_attribute17
      ,p_pcd_attribute18                =>  p_pcd_attribute18
      ,p_pcd_attribute19                =>  p_pcd_attribute19
      ,p_pcd_attribute20                =>  p_pcd_attribute20
      ,p_pcd_attribute21                =>  p_pcd_attribute21
      ,p_pcd_attribute22                =>  p_pcd_attribute22
      ,p_pcd_attribute23                =>  p_pcd_attribute23
      ,p_pcd_attribute24                =>  p_pcd_attribute24
      ,p_pcd_attribute25                =>  p_pcd_attribute25
      ,p_pcd_attribute26                =>  p_pcd_attribute26
      ,p_pcd_attribute27                =>  p_pcd_attribute27
      ,p_pcd_attribute28                =>  p_pcd_attribute28
      ,p_pcd_attribute29                =>  p_pcd_attribute29
      ,p_pcd_attribute30                =>  p_pcd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PER_CM_PRVDD'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_PER_CM_PRVDD
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
    ROLLBACK TO update_PER_CM_PRVDD;
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
    ROLLBACK TO update_PER_CM_PRVDD;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_PER_CM_PRVDD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PER_CM_PRVDD >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PER_CM_PRVDD
  (p_validate                       in  boolean  default false
  ,p_per_cm_prvdd_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PER_CM_PRVDD';
  l_object_version_number ben_per_cm_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_per_cm_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_prvdd_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PER_CM_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk3.delete_PER_CM_PRVDD_b
      (p_per_cm_prvdd_id                =>  p_per_cm_prvdd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PER_CM_PRVDD'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_PER_CM_PRVDD
    --
  end;
  --
  ben_pcd_del.del
    (p_per_cm_prvdd_id               => p_per_cm_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PER_CM_PRVDD
    --
    ben_PER_CM_PRVDD_bk3.delete_PER_CM_PRVDD_a
      (p_per_cm_prvdd_id                =>  p_per_cm_prvdd_id
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
        (p_module_name => 'DELETE_PER_CM_PRVDD'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_PER_CM_PRVDD
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
    ROLLBACK TO delete_PER_CM_PRVDD;
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
    ROLLBACK TO delete_PER_CM_PRVDD;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_PER_CM_PRVDD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_per_cm_prvdd_id                in     number
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
  ben_pcd_shd.lck
    (p_per_cm_prvdd_id            => p_per_cm_prvdd_id
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
end ben_PER_CM_PRVDD_api;

/
