--------------------------------------------------------
--  DDL for Package Body BEN_PER_CM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PER_CM_API" as
/* $Header: bepcmapi.pkb 120.1 2005/06/16 10:23:04 vborkar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PER_CM_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM
  (p_validate                       in  boolean   default false
  ,p_per_cm_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_rqstbl_untl_dt                 in  date      default null
  ,p_ler_id                         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_prtt_enrt_actn_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_bnf_person_id                  in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_cm_typ_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcm_attribute_category         in  varchar2  default null
  ,p_pcm_attribute1                 in  varchar2  default null
  ,p_pcm_attribute2                 in  varchar2  default null
  ,p_pcm_attribute3                 in  varchar2  default null
  ,p_pcm_attribute4                 in  varchar2  default null
  ,p_pcm_attribute5                 in  varchar2  default null
  ,p_pcm_attribute6                 in  varchar2  default null
  ,p_pcm_attribute7                 in  varchar2  default null
  ,p_pcm_attribute8                 in  varchar2  default null
  ,p_pcm_attribute9                 in  varchar2  default null
  ,p_pcm_attribute10                in  varchar2  default null
  ,p_pcm_attribute11                in  varchar2  default null
  ,p_pcm_attribute12                in  varchar2  default null
  ,p_pcm_attribute13                in  varchar2  default null
  ,p_pcm_attribute14                in  varchar2  default null
  ,p_pcm_attribute15                in  varchar2  default null
  ,p_pcm_attribute16                in  varchar2  default null
  ,p_pcm_attribute17                in  varchar2  default null
  ,p_pcm_attribute18                in  varchar2  default null
  ,p_pcm_attribute19                in  varchar2  default null
  ,p_pcm_attribute20                in  varchar2  default null
  ,p_pcm_attribute21                in  varchar2  default null
  ,p_pcm_attribute22                in  varchar2  default null
  ,p_pcm_attribute23                in  varchar2  default null
  ,p_pcm_attribute24                in  varchar2  default null
  ,p_pcm_attribute25                in  varchar2  default null
  ,p_pcm_attribute26                in  varchar2  default null
  ,p_pcm_attribute27                in  varchar2  default null
  ,p_pcm_attribute28                in  varchar2  default null
  ,p_pcm_attribute29                in  varchar2  default null
  ,p_pcm_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_per_cm_id ben_per_cm_f.per_cm_id%TYPE;
  l_effective_start_date ben_per_cm_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PER_CM';
  l_object_version_number ben_per_cm_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PER_CM;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PER_CM
    --
    ben_PER_CM_bk1.create_PER_CM_b
      (p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_rqstbl_untl_dt                 =>  p_rqstbl_untl_dt
      ,p_ler_id                         =>  p_ler_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_person_id                      =>  p_person_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcm_attribute_category         =>  p_pcm_attribute_category
      ,p_pcm_attribute1                 =>  p_pcm_attribute1
      ,p_pcm_attribute2                 =>  p_pcm_attribute2
      ,p_pcm_attribute3                 =>  p_pcm_attribute3
      ,p_pcm_attribute4                 =>  p_pcm_attribute4
      ,p_pcm_attribute5                 =>  p_pcm_attribute5
      ,p_pcm_attribute6                 =>  p_pcm_attribute6
      ,p_pcm_attribute7                 =>  p_pcm_attribute7
      ,p_pcm_attribute8                 =>  p_pcm_attribute8
      ,p_pcm_attribute9                 =>  p_pcm_attribute9
      ,p_pcm_attribute10                =>  p_pcm_attribute10
      ,p_pcm_attribute11                =>  p_pcm_attribute11
      ,p_pcm_attribute12                =>  p_pcm_attribute12
      ,p_pcm_attribute13                =>  p_pcm_attribute13
      ,p_pcm_attribute14                =>  p_pcm_attribute14
      ,p_pcm_attribute15                =>  p_pcm_attribute15
      ,p_pcm_attribute16                =>  p_pcm_attribute16
      ,p_pcm_attribute17                =>  p_pcm_attribute17
      ,p_pcm_attribute18                =>  p_pcm_attribute18
      ,p_pcm_attribute19                =>  p_pcm_attribute19
      ,p_pcm_attribute20                =>  p_pcm_attribute20
      ,p_pcm_attribute21                =>  p_pcm_attribute21
      ,p_pcm_attribute22                =>  p_pcm_attribute22
      ,p_pcm_attribute23                =>  p_pcm_attribute23
      ,p_pcm_attribute24                =>  p_pcm_attribute24
      ,p_pcm_attribute25                =>  p_pcm_attribute25
      ,p_pcm_attribute26                =>  p_pcm_attribute26
      ,p_pcm_attribute27                =>  p_pcm_attribute27
      ,p_pcm_attribute28                =>  p_pcm_attribute28
      ,p_pcm_attribute29                =>  p_pcm_attribute29
      ,p_pcm_attribute30                =>  p_pcm_attribute30
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
        (p_module_name => 'CREATE_PER_CM'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_PER_CM
    --
  end;
  --
  ben_pcm_ins.ins
    (p_per_cm_id                     => l_per_cm_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_lf_evt_ocrd_dt                => p_lf_evt_ocrd_dt
    ,p_rqstbl_untl_dt                => p_rqstbl_untl_dt
    ,p_ler_id                        => p_ler_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_person_id                     => p_person_id
    ,p_bnf_person_id                 => p_bnf_person_id
    ,p_dpnt_person_id                => p_dpnt_person_id
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcm_attribute_category        => p_pcm_attribute_category
    ,p_pcm_attribute1                => p_pcm_attribute1
    ,p_pcm_attribute2                => p_pcm_attribute2
    ,p_pcm_attribute3                => p_pcm_attribute3
    ,p_pcm_attribute4                => p_pcm_attribute4
    ,p_pcm_attribute5                => p_pcm_attribute5
    ,p_pcm_attribute6                => p_pcm_attribute6
    ,p_pcm_attribute7                => p_pcm_attribute7
    ,p_pcm_attribute8                => p_pcm_attribute8
    ,p_pcm_attribute9                => p_pcm_attribute9
    ,p_pcm_attribute10               => p_pcm_attribute10
    ,p_pcm_attribute11               => p_pcm_attribute11
    ,p_pcm_attribute12               => p_pcm_attribute12
    ,p_pcm_attribute13               => p_pcm_attribute13
    ,p_pcm_attribute14               => p_pcm_attribute14
    ,p_pcm_attribute15               => p_pcm_attribute15
    ,p_pcm_attribute16               => p_pcm_attribute16
    ,p_pcm_attribute17               => p_pcm_attribute17
    ,p_pcm_attribute18               => p_pcm_attribute18
    ,p_pcm_attribute19               => p_pcm_attribute19
    ,p_pcm_attribute20               => p_pcm_attribute20
    ,p_pcm_attribute21               => p_pcm_attribute21
    ,p_pcm_attribute22               => p_pcm_attribute22
    ,p_pcm_attribute23               => p_pcm_attribute23
    ,p_pcm_attribute24               => p_pcm_attribute24
    ,p_pcm_attribute25               => p_pcm_attribute25
    ,p_pcm_attribute26               => p_pcm_attribute26
    ,p_pcm_attribute27               => p_pcm_attribute27
    ,p_pcm_attribute28               => p_pcm_attribute28
    ,p_pcm_attribute29               => p_pcm_attribute29
    ,p_pcm_attribute30               => p_pcm_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PER_CM
    --
    ben_PER_CM_bk1.create_PER_CM_a
      (p_per_cm_id                      =>  l_per_cm_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_rqstbl_untl_dt                 =>  p_rqstbl_untl_dt
      ,p_ler_id                         =>  p_ler_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_person_id                      =>  p_person_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcm_attribute_category         =>  p_pcm_attribute_category
      ,p_pcm_attribute1                 =>  p_pcm_attribute1
      ,p_pcm_attribute2                 =>  p_pcm_attribute2
      ,p_pcm_attribute3                 =>  p_pcm_attribute3
      ,p_pcm_attribute4                 =>  p_pcm_attribute4
      ,p_pcm_attribute5                 =>  p_pcm_attribute5
      ,p_pcm_attribute6                 =>  p_pcm_attribute6
      ,p_pcm_attribute7                 =>  p_pcm_attribute7
      ,p_pcm_attribute8                 =>  p_pcm_attribute8
      ,p_pcm_attribute9                 =>  p_pcm_attribute9
      ,p_pcm_attribute10                =>  p_pcm_attribute10
      ,p_pcm_attribute11                =>  p_pcm_attribute11
      ,p_pcm_attribute12                =>  p_pcm_attribute12
      ,p_pcm_attribute13                =>  p_pcm_attribute13
      ,p_pcm_attribute14                =>  p_pcm_attribute14
      ,p_pcm_attribute15                =>  p_pcm_attribute15
      ,p_pcm_attribute16                =>  p_pcm_attribute16
      ,p_pcm_attribute17                =>  p_pcm_attribute17
      ,p_pcm_attribute18                =>  p_pcm_attribute18
      ,p_pcm_attribute19                =>  p_pcm_attribute19
      ,p_pcm_attribute20                =>  p_pcm_attribute20
      ,p_pcm_attribute21                =>  p_pcm_attribute21
      ,p_pcm_attribute22                =>  p_pcm_attribute22
      ,p_pcm_attribute23                =>  p_pcm_attribute23
      ,p_pcm_attribute24                =>  p_pcm_attribute24
      ,p_pcm_attribute25                =>  p_pcm_attribute25
      ,p_pcm_attribute26                =>  p_pcm_attribute26
      ,p_pcm_attribute27                =>  p_pcm_attribute27
      ,p_pcm_attribute28                =>  p_pcm_attribute28
      ,p_pcm_attribute29                =>  p_pcm_attribute29
      ,p_pcm_attribute30                =>  p_pcm_attribute30
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
        (p_module_name => 'CREATE_PER_CM'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_PER_CM
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
  p_per_cm_id := l_per_cm_id;
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
    ROLLBACK TO create_PER_CM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_cm_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PER_CM;
    p_per_cm_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_PER_CM;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PER_CM_perf >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_perf
  (p_validate                       in  boolean   default false
  ,p_per_cm_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_rqstbl_untl_dt                 in  date      default null
  ,p_ler_id                         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_prtt_enrt_actn_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_bnf_person_id                  in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_cm_typ_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcm_attribute_category         in  varchar2  default null
  ,p_pcm_attribute1                 in  varchar2  default null
  ,p_pcm_attribute2                 in  varchar2  default null
  ,p_pcm_attribute3                 in  varchar2  default null
  ,p_pcm_attribute4                 in  varchar2  default null
  ,p_pcm_attribute5                 in  varchar2  default null
  ,p_pcm_attribute6                 in  varchar2  default null
  ,p_pcm_attribute7                 in  varchar2  default null
  ,p_pcm_attribute8                 in  varchar2  default null
  ,p_pcm_attribute9                 in  varchar2  default null
  ,p_pcm_attribute10                in  varchar2  default null
  ,p_pcm_attribute11                in  varchar2  default null
  ,p_pcm_attribute12                in  varchar2  default null
  ,p_pcm_attribute13                in  varchar2  default null
  ,p_pcm_attribute14                in  varchar2  default null
  ,p_pcm_attribute15                in  varchar2  default null
  ,p_pcm_attribute16                in  varchar2  default null
  ,p_pcm_attribute17                in  varchar2  default null
  ,p_pcm_attribute18                in  varchar2  default null
  ,p_pcm_attribute19                in  varchar2  default null
  ,p_pcm_attribute20                in  varchar2  default null
  ,p_pcm_attribute21                in  varchar2  default null
  ,p_pcm_attribute22                in  varchar2  default null
  ,p_pcm_attribute23                in  varchar2  default null
  ,p_pcm_attribute24                in  varchar2  default null
  ,p_pcm_attribute25                in  varchar2  default null
  ,p_pcm_attribute26                in  varchar2  default null
  ,p_pcm_attribute27                in  varchar2  default null
  ,p_pcm_attribute28                in  varchar2  default null
  ,p_pcm_attribute29                in  varchar2  default null
  ,p_pcm_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_per_cm_id ben_per_cm_f.per_cm_id%TYPE;
  l_effective_start_date ben_per_cm_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PER_CM';
  l_object_version_number ben_per_cm_f.object_version_number%TYPE;
  --
  cursor c_seq is
    select ben_per_cm_f_s.nextval
    from   sys.dual;
  --
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PER_CM;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PER_CM
    --
    ben_PER_CM_bk1.create_PER_CM_b
      (p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_rqstbl_untl_dt                 =>  p_rqstbl_untl_dt
      ,p_ler_id                         =>  p_ler_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_person_id                      =>  p_person_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcm_attribute_category         =>  p_pcm_attribute_category
      ,p_pcm_attribute1                 =>  p_pcm_attribute1
      ,p_pcm_attribute2                 =>  p_pcm_attribute2
      ,p_pcm_attribute3                 =>  p_pcm_attribute3
      ,p_pcm_attribute4                 =>  p_pcm_attribute4
      ,p_pcm_attribute5                 =>  p_pcm_attribute5
      ,p_pcm_attribute6                 =>  p_pcm_attribute6
      ,p_pcm_attribute7                 =>  p_pcm_attribute7
      ,p_pcm_attribute8                 =>  p_pcm_attribute8
      ,p_pcm_attribute9                 =>  p_pcm_attribute9
      ,p_pcm_attribute10                =>  p_pcm_attribute10
      ,p_pcm_attribute11                =>  p_pcm_attribute11
      ,p_pcm_attribute12                =>  p_pcm_attribute12
      ,p_pcm_attribute13                =>  p_pcm_attribute13
      ,p_pcm_attribute14                =>  p_pcm_attribute14
      ,p_pcm_attribute15                =>  p_pcm_attribute15
      ,p_pcm_attribute16                =>  p_pcm_attribute16
      ,p_pcm_attribute17                =>  p_pcm_attribute17
      ,p_pcm_attribute18                =>  p_pcm_attribute18
      ,p_pcm_attribute19                =>  p_pcm_attribute19
      ,p_pcm_attribute20                =>  p_pcm_attribute20
      ,p_pcm_attribute21                =>  p_pcm_attribute21
      ,p_pcm_attribute22                =>  p_pcm_attribute22
      ,p_pcm_attribute23                =>  p_pcm_attribute23
      ,p_pcm_attribute24                =>  p_pcm_attribute24
      ,p_pcm_attribute25                =>  p_pcm_attribute25
      ,p_pcm_attribute26                =>  p_pcm_attribute26
      ,p_pcm_attribute27                =>  p_pcm_attribute27
      ,p_pcm_attribute28                =>  p_pcm_attribute28
      ,p_pcm_attribute29                =>  p_pcm_attribute29
      ,p_pcm_attribute30                =>  p_pcm_attribute30
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
        (p_module_name => 'CREATE_PER_CM'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_PER_CM
    --
  end;
  --
  --
  -- Set sequence
  --
  open c_seq;
    --
    fetch c_seq into l_per_cm_id;
    --
  close c_seq;
  --
  -- Post insert row handler hook
  --
  dt_api.validate_dt_mode
    (p_effective_date          => trunc(p_effective_date),
     p_datetrack_mode          => 'INSERT',
     p_base_table_name         => 'ben_per_cm_f',
     p_base_key_column         => 'per_cm_id',
     p_base_key_value          => p_per_cm_id,
     p_parent_table_name1      => 'ben_cm_typ_f',
     p_parent_key_column1      => 'cm_typ_id',
     p_parent_key_value1       => p_cm_typ_id,
     p_parent_table_name2      => 'ben_prtt_enrt_actn_f',
     p_parent_key_column2      => 'prtt_enrt_actn_id',
     p_parent_key_value2       => p_prtt_enrt_actn_id,
     p_enforce_foreign_locking => false,
     p_validation_start_date   => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  l_effective_start_date := l_validation_start_date;
  l_effective_end_date := l_validation_end_date;
  l_object_version_number := 1;
  --
  insert into ben_per_cm_f
    (per_cm_id
    ,effective_start_date
    ,effective_end_date
    ,lf_evt_ocrd_dt
    ,rqstbl_untl_dt
    ,ler_id
    ,per_in_ler_id
    ,prtt_enrt_actn_id
    ,person_id
    ,bnf_person_id
    ,dpnt_person_id
    ,cm_typ_id
    ,business_group_id
    ,pcm_attribute_category
    ,pcm_attribute1
    ,pcm_attribute2
    ,pcm_attribute3
    ,pcm_attribute4
    ,pcm_attribute5
    ,pcm_attribute6
    ,pcm_attribute7
    ,pcm_attribute8
    ,pcm_attribute9
    ,pcm_attribute10
    ,pcm_attribute11
    ,pcm_attribute12
    ,pcm_attribute13
    ,pcm_attribute14
    ,pcm_attribute15
    ,pcm_attribute16
    ,pcm_attribute17
    ,pcm_attribute18
    ,pcm_attribute19
    ,pcm_attribute20
    ,pcm_attribute21
    ,pcm_attribute22
    ,pcm_attribute23
    ,pcm_attribute24
    ,pcm_attribute25
    ,pcm_attribute26
    ,pcm_attribute27
    ,pcm_attribute28
    ,pcm_attribute29
    ,pcm_attribute30
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,object_version_number)
  values
    (l_per_cm_id
    ,l_effective_start_date
    ,l_effective_end_date
    ,p_lf_evt_ocrd_dt
    ,p_rqstbl_untl_dt
    ,p_ler_id
    ,p_per_in_ler_id
    ,p_prtt_enrt_actn_id
    ,p_person_id
    ,p_bnf_person_id
    ,p_dpnt_person_id
    ,p_cm_typ_id
    ,p_business_group_id
    ,p_pcm_attribute_category
    ,p_pcm_attribute1
    ,p_pcm_attribute2
    ,p_pcm_attribute3
    ,p_pcm_attribute4
    ,p_pcm_attribute5
    ,p_pcm_attribute6
    ,p_pcm_attribute7
    ,p_pcm_attribute8
    ,p_pcm_attribute9
    ,p_pcm_attribute10
    ,p_pcm_attribute11
    ,p_pcm_attribute12
    ,p_pcm_attribute13
    ,p_pcm_attribute14
    ,p_pcm_attribute15
    ,p_pcm_attribute16
    ,p_pcm_attribute17
    ,p_pcm_attribute18
    ,p_pcm_attribute19
    ,p_pcm_attribute20
    ,p_pcm_attribute21
    ,p_pcm_attribute22
    ,p_pcm_attribute23
    ,p_pcm_attribute24
    ,p_pcm_attribute25
    ,p_pcm_attribute26
    ,p_pcm_attribute27
    ,p_pcm_attribute28
    ,p_pcm_attribute29
    ,p_pcm_attribute30
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
    ben_pcm_rki.after_insert
      (p_per_cm_id                     =>l_per_cm_id
      ,p_effective_start_date          =>l_effective_start_date
      ,p_effective_end_date            =>l_effective_end_date
      ,p_lf_evt_ocrd_dt                =>p_lf_evt_ocrd_dt
      ,p_rqstbl_untl_dt                =>p_rqstbl_untl_dt
      ,p_ler_id                        =>p_ler_id
      ,p_per_in_ler_id                 =>p_per_in_ler_id
      ,p_prtt_enrt_actn_id             =>p_prtt_enrt_actn_id
      ,p_person_id                     =>p_person_id
      ,p_bnf_person_id                 =>p_bnf_person_id
      ,p_dpnt_person_id                =>p_dpnt_person_id
      ,p_cm_typ_id                     =>p_cm_typ_id
      ,p_business_group_id             =>p_business_group_id
      ,p_pcm_attribute_category        =>p_pcm_attribute_category
      ,p_pcm_attribute1                =>p_pcm_attribute1
      ,p_pcm_attribute2                =>p_pcm_attribute2
      ,p_pcm_attribute3                =>p_pcm_attribute3
      ,p_pcm_attribute4                =>p_pcm_attribute4
      ,p_pcm_attribute5                =>p_pcm_attribute5
      ,p_pcm_attribute6                =>p_pcm_attribute6
      ,p_pcm_attribute7                =>p_pcm_attribute7
      ,p_pcm_attribute8                =>p_pcm_attribute8
      ,p_pcm_attribute9                =>p_pcm_attribute9
      ,p_pcm_attribute10               =>p_pcm_attribute10
      ,p_pcm_attribute11               =>p_pcm_attribute11
      ,p_pcm_attribute12               =>p_pcm_attribute12
      ,p_pcm_attribute13               =>p_pcm_attribute13
      ,p_pcm_attribute14               =>p_pcm_attribute14
      ,p_pcm_attribute15               =>p_pcm_attribute15
      ,p_pcm_attribute16               =>p_pcm_attribute16
      ,p_pcm_attribute17               =>p_pcm_attribute17
      ,p_pcm_attribute18               =>p_pcm_attribute18
      ,p_pcm_attribute19               =>p_pcm_attribute19
      ,p_pcm_attribute20               =>p_pcm_attribute20
      ,p_pcm_attribute21               =>p_pcm_attribute21
      ,p_pcm_attribute22               =>p_pcm_attribute22
      ,p_pcm_attribute23               =>p_pcm_attribute23
      ,p_pcm_attribute24               =>p_pcm_attribute24
      ,p_pcm_attribute25               =>p_pcm_attribute25
      ,p_pcm_attribute26               =>p_pcm_attribute26
      ,p_pcm_attribute27               =>p_pcm_attribute27
      ,p_pcm_attribute28               =>p_pcm_attribute28
      ,p_pcm_attribute29               =>p_pcm_attribute29
      ,p_pcm_attribute30               =>p_pcm_attribute30
      ,p_request_id                    =>p_request_id
      ,p_program_application_id        =>p_program_application_id
      ,p_program_id                    =>p_program_id
      ,p_program_update_date           =>p_program_update_date
      ,p_object_version_number         =>l_object_version_number
      ,p_effective_date                =>trunc(p_effective_date)
      ,p_validation_start_date         =>l_validation_start_date
      ,p_validation_end_date           =>l_validation_end_date);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_per_cm_f'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PER_CM
    --
    ben_PER_CM_bk1.create_PER_CM_a
      (p_per_cm_id                      =>  l_per_cm_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_rqstbl_untl_dt                 =>  p_rqstbl_untl_dt
      ,p_ler_id                         =>  p_ler_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_person_id                      =>  p_person_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcm_attribute_category         =>  p_pcm_attribute_category
      ,p_pcm_attribute1                 =>  p_pcm_attribute1
      ,p_pcm_attribute2                 =>  p_pcm_attribute2
      ,p_pcm_attribute3                 =>  p_pcm_attribute3
      ,p_pcm_attribute4                 =>  p_pcm_attribute4
      ,p_pcm_attribute5                 =>  p_pcm_attribute5
      ,p_pcm_attribute6                 =>  p_pcm_attribute6
      ,p_pcm_attribute7                 =>  p_pcm_attribute7
      ,p_pcm_attribute8                 =>  p_pcm_attribute8
      ,p_pcm_attribute9                 =>  p_pcm_attribute9
      ,p_pcm_attribute10                =>  p_pcm_attribute10
      ,p_pcm_attribute11                =>  p_pcm_attribute11
      ,p_pcm_attribute12                =>  p_pcm_attribute12
      ,p_pcm_attribute13                =>  p_pcm_attribute13
      ,p_pcm_attribute14                =>  p_pcm_attribute14
      ,p_pcm_attribute15                =>  p_pcm_attribute15
      ,p_pcm_attribute16                =>  p_pcm_attribute16
      ,p_pcm_attribute17                =>  p_pcm_attribute17
      ,p_pcm_attribute18                =>  p_pcm_attribute18
      ,p_pcm_attribute19                =>  p_pcm_attribute19
      ,p_pcm_attribute20                =>  p_pcm_attribute20
      ,p_pcm_attribute21                =>  p_pcm_attribute21
      ,p_pcm_attribute22                =>  p_pcm_attribute22
      ,p_pcm_attribute23                =>  p_pcm_attribute23
      ,p_pcm_attribute24                =>  p_pcm_attribute24
      ,p_pcm_attribute25                =>  p_pcm_attribute25
      ,p_pcm_attribute26                =>  p_pcm_attribute26
      ,p_pcm_attribute27                =>  p_pcm_attribute27
      ,p_pcm_attribute28                =>  p_pcm_attribute28
      ,p_pcm_attribute29                =>  p_pcm_attribute29
      ,p_pcm_attribute30                =>  p_pcm_attribute30
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
        (p_module_name => 'CREATE_PER_CM'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_PER_CM
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
  p_per_cm_id := l_per_cm_id;
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
    ROLLBACK TO create_PER_CM;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_cm_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PER_CM;
    p_per_cm_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_PER_CM_perf;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PER_CM >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PER_CM
  (p_validate                       in  boolean   default false
  ,p_per_cm_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_rqstbl_untl_dt                 in  date      default hr_api.g_date
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_prtt_enrt_actn_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_bnf_person_id                  in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_cm_typ_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcm_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcm_attribute30                in  varchar2  default hr_api.g_varchar2
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
  l_proc varchar2(72) := g_package||'update_PER_CM';
  l_object_version_number ben_per_cm_f.object_version_number%TYPE;
  l_effective_start_date ben_per_cm_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PER_CM;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PER_CM
    --
    ben_PER_CM_bk2.update_PER_CM_b
      (p_per_cm_id                      =>  p_per_cm_id
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_rqstbl_untl_dt                 =>  p_rqstbl_untl_dt
      ,p_ler_id                         =>  p_ler_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_person_id                      =>  p_person_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcm_attribute_category         =>  p_pcm_attribute_category
      ,p_pcm_attribute1                 =>  p_pcm_attribute1
      ,p_pcm_attribute2                 =>  p_pcm_attribute2
      ,p_pcm_attribute3                 =>  p_pcm_attribute3
      ,p_pcm_attribute4                 =>  p_pcm_attribute4
      ,p_pcm_attribute5                 =>  p_pcm_attribute5
      ,p_pcm_attribute6                 =>  p_pcm_attribute6
      ,p_pcm_attribute7                 =>  p_pcm_attribute7
      ,p_pcm_attribute8                 =>  p_pcm_attribute8
      ,p_pcm_attribute9                 =>  p_pcm_attribute9
      ,p_pcm_attribute10                =>  p_pcm_attribute10
      ,p_pcm_attribute11                =>  p_pcm_attribute11
      ,p_pcm_attribute12                =>  p_pcm_attribute12
      ,p_pcm_attribute13                =>  p_pcm_attribute13
      ,p_pcm_attribute14                =>  p_pcm_attribute14
      ,p_pcm_attribute15                =>  p_pcm_attribute15
      ,p_pcm_attribute16                =>  p_pcm_attribute16
      ,p_pcm_attribute17                =>  p_pcm_attribute17
      ,p_pcm_attribute18                =>  p_pcm_attribute18
      ,p_pcm_attribute19                =>  p_pcm_attribute19
      ,p_pcm_attribute20                =>  p_pcm_attribute20
      ,p_pcm_attribute21                =>  p_pcm_attribute21
      ,p_pcm_attribute22                =>  p_pcm_attribute22
      ,p_pcm_attribute23                =>  p_pcm_attribute23
      ,p_pcm_attribute24                =>  p_pcm_attribute24
      ,p_pcm_attribute25                =>  p_pcm_attribute25
      ,p_pcm_attribute26                =>  p_pcm_attribute26
      ,p_pcm_attribute27                =>  p_pcm_attribute27
      ,p_pcm_attribute28                =>  p_pcm_attribute28
      ,p_pcm_attribute29                =>  p_pcm_attribute29
      ,p_pcm_attribute30                =>  p_pcm_attribute30
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
        (p_module_name => 'UPDATE_PER_CM'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_PER_CM
    --
  end;
  --
  ben_pcm_upd.upd
    (p_per_cm_id                     => p_per_cm_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_lf_evt_ocrd_dt                => p_lf_evt_ocrd_dt
    ,p_rqstbl_untl_dt                => p_rqstbl_untl_dt
    ,p_ler_id                        => p_ler_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_person_id                     => p_person_id
    ,p_bnf_person_id                 => p_bnf_person_id
    ,p_dpnt_person_id                => p_dpnt_person_id
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcm_attribute_category        => p_pcm_attribute_category
    ,p_pcm_attribute1                => p_pcm_attribute1
    ,p_pcm_attribute2                => p_pcm_attribute2
    ,p_pcm_attribute3                => p_pcm_attribute3
    ,p_pcm_attribute4                => p_pcm_attribute4
    ,p_pcm_attribute5                => p_pcm_attribute5
    ,p_pcm_attribute6                => p_pcm_attribute6
    ,p_pcm_attribute7                => p_pcm_attribute7
    ,p_pcm_attribute8                => p_pcm_attribute8
    ,p_pcm_attribute9                => p_pcm_attribute9
    ,p_pcm_attribute10               => p_pcm_attribute10
    ,p_pcm_attribute11               => p_pcm_attribute11
    ,p_pcm_attribute12               => p_pcm_attribute12
    ,p_pcm_attribute13               => p_pcm_attribute13
    ,p_pcm_attribute14               => p_pcm_attribute14
    ,p_pcm_attribute15               => p_pcm_attribute15
    ,p_pcm_attribute16               => p_pcm_attribute16
    ,p_pcm_attribute17               => p_pcm_attribute17
    ,p_pcm_attribute18               => p_pcm_attribute18
    ,p_pcm_attribute19               => p_pcm_attribute19
    ,p_pcm_attribute20               => p_pcm_attribute20
    ,p_pcm_attribute21               => p_pcm_attribute21
    ,p_pcm_attribute22               => p_pcm_attribute22
    ,p_pcm_attribute23               => p_pcm_attribute23
    ,p_pcm_attribute24               => p_pcm_attribute24
    ,p_pcm_attribute25               => p_pcm_attribute25
    ,p_pcm_attribute26               => p_pcm_attribute26
    ,p_pcm_attribute27               => p_pcm_attribute27
    ,p_pcm_attribute28               => p_pcm_attribute28
    ,p_pcm_attribute29               => p_pcm_attribute29
    ,p_pcm_attribute30               => p_pcm_attribute30
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
    -- Start of API User Hook for the after hook of update_PER_CM
    --
    ben_PER_CM_bk2.update_PER_CM_a
      (p_per_cm_id                      =>  p_per_cm_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_rqstbl_untl_dt                 =>  p_rqstbl_untl_dt
      ,p_ler_id                         =>  p_ler_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_person_id                      =>  p_person_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcm_attribute_category         =>  p_pcm_attribute_category
      ,p_pcm_attribute1                 =>  p_pcm_attribute1
      ,p_pcm_attribute2                 =>  p_pcm_attribute2
      ,p_pcm_attribute3                 =>  p_pcm_attribute3
      ,p_pcm_attribute4                 =>  p_pcm_attribute4
      ,p_pcm_attribute5                 =>  p_pcm_attribute5
      ,p_pcm_attribute6                 =>  p_pcm_attribute6
      ,p_pcm_attribute7                 =>  p_pcm_attribute7
      ,p_pcm_attribute8                 =>  p_pcm_attribute8
      ,p_pcm_attribute9                 =>  p_pcm_attribute9
      ,p_pcm_attribute10                =>  p_pcm_attribute10
      ,p_pcm_attribute11                =>  p_pcm_attribute11
      ,p_pcm_attribute12                =>  p_pcm_attribute12
      ,p_pcm_attribute13                =>  p_pcm_attribute13
      ,p_pcm_attribute14                =>  p_pcm_attribute14
      ,p_pcm_attribute15                =>  p_pcm_attribute15
      ,p_pcm_attribute16                =>  p_pcm_attribute16
      ,p_pcm_attribute17                =>  p_pcm_attribute17
      ,p_pcm_attribute18                =>  p_pcm_attribute18
      ,p_pcm_attribute19                =>  p_pcm_attribute19
      ,p_pcm_attribute20                =>  p_pcm_attribute20
      ,p_pcm_attribute21                =>  p_pcm_attribute21
      ,p_pcm_attribute22                =>  p_pcm_attribute22
      ,p_pcm_attribute23                =>  p_pcm_attribute23
      ,p_pcm_attribute24                =>  p_pcm_attribute24
      ,p_pcm_attribute25                =>  p_pcm_attribute25
      ,p_pcm_attribute26                =>  p_pcm_attribute26
      ,p_pcm_attribute27                =>  p_pcm_attribute27
      ,p_pcm_attribute28                =>  p_pcm_attribute28
      ,p_pcm_attribute29                =>  p_pcm_attribute29
      ,p_pcm_attribute30                =>  p_pcm_attribute30
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
        (p_module_name => 'UPDATE_PER_CM'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_PER_CM
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
    ROLLBACK TO update_PER_CM;
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
    ROLLBACK TO update_PER_CM;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_PER_CM;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PER_CM >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PER_CM
  (p_validate                       in  boolean  default false
  ,p_per_cm_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to find rows from ben_per_cm_trgr
  --
  cursor c_per_cm_trgr is
    select per_cm_trgr_id,
           object_version_number,
           effective_start_date,
           effective_end_date
    from   ben_per_cm_trgr_f
    where  per_cm_id = p_per_cm_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  -- Cursor to find rows from ben_per_cm_usg
  --
  cursor c_per_cm_usg is
    select per_cm_usg_id,
           object_version_number,
           effective_start_date,
           effective_end_date
    from   ben_per_cm_usg_f
    where  per_cm_id = p_per_cm_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  -- Cursor to find rows from ben_per_cm_trgr_prvdd
  --
  cursor c_per_cm_prvdd is
    select per_cm_prvdd_id,
           object_version_number,
           effective_start_date,
           effective_end_date
    from   ben_per_cm_prvdd_f
    where  per_cm_id = p_per_cm_id
    and    p_effective_date
           between effective_start_date
           and     effective_end_date;
  --
  l_proc varchar2(72) := g_package||'update_PER_CM';
  l_object_version_number ben_per_cm_f.object_version_number%TYPE;
  l_effective_start_date ben_per_cm_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_cm_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PER_CM;
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
    -- Start of API User Hook for the before hook of delete_PER_CM
    --
    ben_PER_CM_bk3.delete_PER_CM_b
      (p_per_cm_id                      => p_per_cm_id
      ,p_object_version_number          => p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PER_CM'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_PER_CM
    --
  end;
  --
  -- Before deleting the row, delete the child rows in per_cm_trgr, per_cm_usg
  -- and per_cm_prvdd.
  --
  -- Delete from per_cm_trgr.
  --
  for l_rec in c_per_cm_trgr loop
    --
    ben_per_cm_trgr_api.delete_per_cm_trgr
      (p_validate              => FALSE
      ,p_per_cm_trgr_id        => l_rec.per_cm_trgr_id
      ,p_effective_start_date  => l_rec.effective_start_date
      ,p_effective_end_date    => l_rec.effective_end_date
      ,p_object_version_number => l_rec.object_version_number
      ,p_effective_date        => p_effective_date
      ,p_datetrack_mode        => p_datetrack_mode);
    --
  end loop;
  --
  -- Delete from per_cm_trgr_usg.
  --
  for l_rec in c_per_cm_usg loop
    --
    ben_per_cm_usg_api.delete_per_cm_usg
      (p_validate              => FALSE
      ,p_per_cm_usg_id         => l_rec.per_cm_usg_id
      ,p_effective_start_date  => l_rec.effective_start_date
      ,p_effective_end_date    => l_rec.effective_end_date
      ,p_object_version_number => l_rec.object_version_number
      ,p_effective_date        => p_effective_date
      ,p_datetrack_mode        => p_datetrack_mode);
    --
  end loop;
  --
  -- Delete from per_cm_prvdd.
  --
  for l_rec in c_per_cm_prvdd loop
    --
    ben_per_cm_prvdd_api.delete_per_cm_prvdd
      (p_validate              => FALSE
      ,p_per_cm_prvdd_id       => l_rec.per_cm_prvdd_id
      ,p_effective_start_date  => l_rec.effective_start_date
      ,p_effective_end_date    => l_rec.effective_end_date
      ,p_object_version_number => l_rec.object_version_number
      ,p_effective_date        => p_effective_date
      ,p_datetrack_mode        => p_datetrack_mode);
    --
  end loop;
  --
  -- Call the pcm rowhandler to delete the row.
  --
  ben_pcm_del.del
    (p_per_cm_id                     => p_per_cm_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PER_CM
    --
    ben_PER_CM_bk3.delete_PER_CM_a
      (p_per_cm_id                      =>  p_per_cm_id
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
        (p_module_name => 'DELETE_PER_CM'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_PER_CM
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
    ROLLBACK TO delete_PER_CM;
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
    ROLLBACK TO delete_PER_CM;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_PER_CM;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_per_cm_id                      in     number
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
  ben_pcm_shd.lck
     (p_per_cm_id                  => p_per_cm_id
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
procedure create_PER_CM_W
  (p_per_cm_id                      out nocopy number
  ,p_effective_start_date           out nocopy varchar --- change
  ,p_effective_end_date             out nocopy varchar --- change
  ,p_lf_evt_ocrd_dt                 in  varchar   default null  --- change
  ,p_ler_id                         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_person_id                      in  number    default null
  ,p_cm_typ_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  varchar
  ,p_return_status                  out nocopy varchar) is  --- change

  l_per_cm_id                  number;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_object_version_number      number;
  l_lf_evt_ocrd_dt             date;
  l_validate                   boolean := false;
  l_effective_date             date;
begin
  fnd_msg_pub.initialize;
  p_return_status := 'S';

  l_effective_date := to_date(p_effective_date, 'rrrr/mm/dd');
  l_lf_evt_ocrd_dt  := to_date(p_lf_evt_ocrd_dt, 'rrrr/mm/dd');


  create_PER_CM
    (p_validate                       =>  l_validate
    ,p_per_cm_id                      =>  l_per_cm_id
    ,p_effective_start_date           =>  l_effective_start_date
    ,p_effective_end_date             =>  l_effective_end_date
    ,p_lf_evt_ocrd_dt                 =>  l_lf_evt_ocrd_dt
    ,p_rqstbl_untl_dt                 =>  null
    ,p_ler_id                         =>  p_ler_id
    ,p_per_in_ler_id                  =>  p_per_in_ler_id
    ,p_prtt_enrt_actn_id              =>  null
    ,p_person_id                      =>  p_person_id
    ,p_bnf_person_id                  =>  null
    ,p_dpnt_person_id                 =>  null
    ,p_cm_typ_id                      =>  p_cm_typ_id
    ,p_business_group_id              =>  p_business_group_id
    ,p_pcm_attribute_category         =>  null
    ,p_pcm_attribute1                 =>  null
    ,p_pcm_attribute2                 =>  null
    ,p_pcm_attribute3                 =>  null
    ,p_pcm_attribute4                 =>  null
    ,p_pcm_attribute5                 =>  null
    ,p_pcm_attribute6                 =>  null
    ,p_pcm_attribute7                 =>  null
    ,p_pcm_attribute8                 =>  null
    ,p_pcm_attribute9                 =>  null
    ,p_pcm_attribute10                =>  null
    ,p_pcm_attribute11                =>  null
    ,p_pcm_attribute12                =>  null
    ,p_pcm_attribute13                =>  null
    ,p_pcm_attribute14                =>  null
    ,p_pcm_attribute15                =>  null
    ,p_pcm_attribute16                =>  null
    ,p_pcm_attribute17                =>  null
    ,p_pcm_attribute18                =>  null
    ,p_pcm_attribute19                =>  null
    ,p_pcm_attribute20                =>  null
    ,p_pcm_attribute21                =>  null
    ,p_pcm_attribute22                =>  null
    ,p_pcm_attribute23                =>  null
    ,p_pcm_attribute24                =>  null
    ,p_pcm_attribute25                =>  null
    ,p_pcm_attribute26                =>  null
    ,p_pcm_attribute27                =>  null
    ,p_pcm_attribute28                =>  null
    ,p_pcm_attribute29                =>  null
    ,p_pcm_attribute30                =>  null
    ,p_request_id                     =>  null
    ,p_program_application_id         =>  null
    ,p_program_id                     =>  null
    ,p_program_update_date            =>  null
    ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 =>  l_effective_date
    );

  p_effective_start_date := to_char(l_effective_start_date , 'rrrr/mm/dd');
  p_effective_end_date := to_char(l_effective_end_date , 'rrrr/mm/dd');
/*exception
  --
  when others then
    p_return_status := 'E';
    fnd_msg_pub.initialize;
    fnd_msg_pub.add;
*/
  --
end create_per_cm_w;

end ben_PER_CM_api;

/
