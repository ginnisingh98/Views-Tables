--------------------------------------------------------
--  DDL for Package Body BEN_PRV_CTFN_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRV_CTFN_PRVDD_API" as
/* $Header: bervcapi.pkb 115.4 2004/01/22 09:53:37 mmudigon noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_prv_ctfn_prvdd_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_prv_ctfn_prvdd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_prv_ctfn_prvdd
  (p_validate                       in  boolean   default false
  ,p_prtt_rt_val_ctfn_prvdd_id        out nocopy number
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default 'N'
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_enrt_ctfn_recd_dt              in  date      default null
  ,p_enrt_ctfn_dnd_dt               in  date      default null
  ,p_prtt_rt_val_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_rvc_attribute_category         in  varchar2  default null
  ,p_rvc_attribute1                 in  varchar2  default null
  ,p_rvc_attribute2                 in  varchar2  default null
  ,p_rvc_attribute3                 in  varchar2  default null
  ,p_rvc_attribute4                 in  varchar2  default null
  ,p_rvc_attribute5                 in  varchar2  default null
  ,p_rvc_attribute6                 in  varchar2  default null
  ,p_rvc_attribute7                 in  varchar2  default null
  ,p_rvc_attribute8                 in  varchar2  default null
  ,p_rvc_attribute9                 in  varchar2  default null
  ,p_rvc_attribute10                in  varchar2  default null
  ,p_rvc_attribute11                in  varchar2  default null
  ,p_rvc_attribute12                in  varchar2  default null
  ,p_rvc_attribute13                in  varchar2  default null
  ,p_rvc_attribute14                in  varchar2  default null
  ,p_rvc_attribute15                in  varchar2  default null
  ,p_rvc_attribute16                in  varchar2  default null
  ,p_rvc_attribute17                in  varchar2  default null
  ,p_rvc_attribute18                in  varchar2  default null
  ,p_rvc_attribute19                in  varchar2  default null
  ,p_rvc_attribute20                in  varchar2  default null
  ,p_rvc_attribute21                in  varchar2  default null
  ,p_rvc_attribute22                in  varchar2  default null
  ,p_rvc_attribute23                in  varchar2  default null
  ,p_rvc_attribute24                in  varchar2  default null
  ,p_rvc_attribute25                in  varchar2  default null
  ,p_rvc_attribute26                in  varchar2  default null
  ,p_rvc_attribute27                in  varchar2  default null
  ,p_rvc_attribute28                in  varchar2  default null
  ,p_rvc_attribute29                in  varchar2  default null
  ,p_rvc_attribute30                in  varchar2  default null
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
  l_prtt_rt_val_ctfn_prvdd_id ben_prtt_rt_val_ctfn_prvdd.prtt_rt_val_ctfn_prvdd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_prv_ctfn_prvdd';
  l_object_version_number ben_prtt_rt_val_ctfn_prvdd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialize environment
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init
      (p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_thread_id         => null,
       p_chunk_size        => null,
       p_threads           => null,
       p_max_errors        => null,
       p_benefit_action_id => null);
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_prv_ctfn_prvdd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_prv_ctfn_prvdd
    --
    ben_prv_ctfn_prvdd_bk1.create_prv_ctfn_prvdd_b
      (
       p_prtt_rt_val_ctfn_prvdd_id      => l_prtt_rt_val_ctfn_prvdd_id
      ,p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_prtt_rt_val_id                 =>  p_prtt_rt_val_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rvc_attribute_category         =>  p_rvc_attribute_category
      ,p_rvc_attribute1                 =>  p_rvc_attribute1
      ,p_rvc_attribute2                 =>  p_rvc_attribute2
      ,p_rvc_attribute3                 =>  p_rvc_attribute3
      ,p_rvc_attribute4                 =>  p_rvc_attribute4
      ,p_rvc_attribute5                 =>  p_rvc_attribute5
      ,p_rvc_attribute6                 =>  p_rvc_attribute6
      ,p_rvc_attribute7                 =>  p_rvc_attribute7
      ,p_rvc_attribute8                 =>  p_rvc_attribute8
      ,p_rvc_attribute9                 =>  p_rvc_attribute9
      ,p_rvc_attribute10                =>  p_rvc_attribute10
      ,p_rvc_attribute11                =>  p_rvc_attribute11
      ,p_rvc_attribute12                =>  p_rvc_attribute12
      ,p_rvc_attribute13                =>  p_rvc_attribute13
      ,p_rvc_attribute14                =>  p_rvc_attribute14
      ,p_rvc_attribute15                =>  p_rvc_attribute15
      ,p_rvc_attribute16                =>  p_rvc_attribute16
      ,p_rvc_attribute17                =>  p_rvc_attribute17
      ,p_rvc_attribute18                =>  p_rvc_attribute18
      ,p_rvc_attribute19                =>  p_rvc_attribute19
      ,p_rvc_attribute20                =>  p_rvc_attribute20
      ,p_rvc_attribute21                =>  p_rvc_attribute21
      ,p_rvc_attribute22                =>  p_rvc_attribute22
      ,p_rvc_attribute23                =>  p_rvc_attribute23
      ,p_rvc_attribute24                =>  p_rvc_attribute24
      ,p_rvc_attribute25                =>  p_rvc_attribute25
      ,p_rvc_attribute26                =>  p_rvc_attribute26
      ,p_rvc_attribute27                =>  p_rvc_attribute27
      ,p_rvc_attribute28                =>  p_rvc_attribute28
      ,p_rvc_attribute29                =>  p_rvc_attribute29
      ,p_rvc_attribute30                =>  p_rvc_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_prv_ctfn_prvdd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_prv_ctfn_prvdd
    --
  end;
  --
  ben_rvc_ins.ins
    (
     p_prtt_rt_val_ctfn_prvdd_id       => l_prtt_rt_val_ctfn_prvdd_id
    ,p_enrt_ctfn_rqd_flag            => p_enrt_ctfn_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_enrt_ctfn_recd_dt             => p_enrt_ctfn_recd_dt
    ,p_enrt_ctfn_dnd_dt              => p_enrt_ctfn_dnd_dt
    ,p_prtt_rt_val_id             => p_prtt_rt_val_id
    ,p_business_group_id             => p_business_group_id
    ,p_rvc_attribute_category        => p_rvc_attribute_category
    ,p_rvc_attribute1                => p_rvc_attribute1
    ,p_rvc_attribute2                => p_rvc_attribute2
    ,p_rvc_attribute3                => p_rvc_attribute3
    ,p_rvc_attribute4                => p_rvc_attribute4
    ,p_rvc_attribute5                => p_rvc_attribute5
    ,p_rvc_attribute6                => p_rvc_attribute6
    ,p_rvc_attribute7                => p_rvc_attribute7
    ,p_rvc_attribute8                => p_rvc_attribute8
    ,p_rvc_attribute9                => p_rvc_attribute9
    ,p_rvc_attribute10               => p_rvc_attribute10
    ,p_rvc_attribute11               => p_rvc_attribute11
    ,p_rvc_attribute12               => p_rvc_attribute12
    ,p_rvc_attribute13               => p_rvc_attribute13
    ,p_rvc_attribute14               => p_rvc_attribute14
    ,p_rvc_attribute15               => p_rvc_attribute15
    ,p_rvc_attribute16               => p_rvc_attribute16
    ,p_rvc_attribute17               => p_rvc_attribute17
    ,p_rvc_attribute18               => p_rvc_attribute18
    ,p_rvc_attribute19               => p_rvc_attribute19
    ,p_rvc_attribute20               => p_rvc_attribute20
    ,p_rvc_attribute21               => p_rvc_attribute21
    ,p_rvc_attribute22               => p_rvc_attribute22
    ,p_rvc_attribute23               => p_rvc_attribute23
    ,p_rvc_attribute24               => p_rvc_attribute24
    ,p_rvc_attribute25               => p_rvc_attribute25
    ,p_rvc_attribute26               => p_rvc_attribute26
    ,p_rvc_attribute27               => p_rvc_attribute27
    ,p_rvc_attribute28               => p_rvc_attribute28
    ,p_rvc_attribute29               => p_rvc_attribute29
    ,p_rvc_attribute30               => p_rvc_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_prv_ctfn_prvdd
    --
    ben_prv_ctfn_prvdd_bk1.create_prv_ctfn_prvdd_a
      (
       p_prtt_rt_val_ctfn_prvdd_id        =>  l_prtt_rt_val_ctfn_prvdd_id
      ,p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_prtt_rt_val_id              =>  p_prtt_rt_val_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rvc_attribute_category         =>  p_rvc_attribute_category
      ,p_rvc_attribute1                 =>  p_rvc_attribute1
      ,p_rvc_attribute2                 =>  p_rvc_attribute2
      ,p_rvc_attribute3                 =>  p_rvc_attribute3
      ,p_rvc_attribute4                 =>  p_rvc_attribute4
      ,p_rvc_attribute5                 =>  p_rvc_attribute5
      ,p_rvc_attribute6                 =>  p_rvc_attribute6
      ,p_rvc_attribute7                 =>  p_rvc_attribute7
      ,p_rvc_attribute8                 =>  p_rvc_attribute8
      ,p_rvc_attribute9                 =>  p_rvc_attribute9
      ,p_rvc_attribute10                =>  p_rvc_attribute10
      ,p_rvc_attribute11                =>  p_rvc_attribute11
      ,p_rvc_attribute12                =>  p_rvc_attribute12
      ,p_rvc_attribute13                =>  p_rvc_attribute13
      ,p_rvc_attribute14                =>  p_rvc_attribute14
      ,p_rvc_attribute15                =>  p_rvc_attribute15
      ,p_rvc_attribute16                =>  p_rvc_attribute16
      ,p_rvc_attribute17                =>  p_rvc_attribute17
      ,p_rvc_attribute18                =>  p_rvc_attribute18
      ,p_rvc_attribute19                =>  p_rvc_attribute19
      ,p_rvc_attribute20                =>  p_rvc_attribute20
      ,p_rvc_attribute21                =>  p_rvc_attribute21
      ,p_rvc_attribute22                =>  p_rvc_attribute22
      ,p_rvc_attribute23                =>  p_rvc_attribute23
      ,p_rvc_attribute24                =>  p_rvc_attribute24
      ,p_rvc_attribute25                =>  p_rvc_attribute25
      ,p_rvc_attribute26                =>  p_rvc_attribute26
      ,p_rvc_attribute27                =>  p_rvc_attribute27
      ,p_rvc_attribute28                =>  p_rvc_attribute28
      ,p_rvc_attribute29                =>  p_rvc_attribute29
      ,p_rvc_attribute30                =>  p_rvc_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_prv_ctfn_prvdd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_prv_ctfn_prvdd
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
  p_prtt_rt_val_ctfn_prvdd_id := l_prtt_rt_val_ctfn_prvdd_id;
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
    ROLLBACK TO create_prv_ctfn_prvdd;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_rt_val_ctfn_prvdd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_prv_ctfn_prvdd;
    p_prtt_rt_val_ctfn_prvdd_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_prv_ctfn_prvdd;
-- ----------------------------------------------------------------------------
-- |---------------------< update_prv_ctfn_prvdd >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_prv_ctfn_prvdd
  (p_validate                       in  boolean   default false
  ,p_prtt_rt_val_ctfn_prvdd_id        in  number
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_recd_dt              in  date      default hr_api.g_date
  ,p_enrt_ctfn_dnd_dt               in  date      default hr_api.g_date
  ,p_prtt_rt_val_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rvc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_rvc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_prv_ctfn_prvdd';
  l_object_version_number ben_prtt_rt_val_ctfn_prvdd.object_version_number%TYPE;
  --
  cursor c_prv is
   select prv.*, pil.person_id, abr.input_value_id, abr.element_type_id
   from ben_prtt_rt_val prv,
        ben_per_in_ler  pil,
        ben_acty_base_rt_f abr
   where prv.prtt_rt_val_id = p_prtt_rt_val_id
     and prv.business_group_id = p_business_group_id
     and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
     and pil.per_in_ler_id = prv.per_in_ler_id
     and abr.acty_base_rt_id = prv.acty_base_rt_id
     and p_effective_date between abr.effective_start_date and
                                  abr.effective_end_date;
  --
  l_prv_rec      c_prv%rowtype;
  l_ovn          number;
  l_dummy_number number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialize environment
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init
      (p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_thread_id         => null,
       p_chunk_size        => null,
       p_threads           => null,
       p_max_errors        => null,
       p_benefit_action_id => null);
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_prv_ctfn_prvdd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_prv_ctfn_prvdd
    --
    ben_prv_ctfn_prvdd_bk2.update_prv_ctfn_prvdd_b
      (
       p_prtt_rt_val_ctfn_prvdd_id        =>  p_prtt_rt_val_ctfn_prvdd_id
      ,p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_prtt_rt_val_id              =>  p_prtt_rt_val_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rvc_attribute_category         =>  p_rvc_attribute_category
      ,p_rvc_attribute1                 =>  p_rvc_attribute1
      ,p_rvc_attribute2                 =>  p_rvc_attribute2
      ,p_rvc_attribute3                 =>  p_rvc_attribute3
      ,p_rvc_attribute4                 =>  p_rvc_attribute4
      ,p_rvc_attribute5                 =>  p_rvc_attribute5
      ,p_rvc_attribute6                 =>  p_rvc_attribute6
      ,p_rvc_attribute7                 =>  p_rvc_attribute7
      ,p_rvc_attribute8                 =>  p_rvc_attribute8
      ,p_rvc_attribute9                 =>  p_rvc_attribute9
      ,p_rvc_attribute10                =>  p_rvc_attribute10
      ,p_rvc_attribute11                =>  p_rvc_attribute11
      ,p_rvc_attribute12                =>  p_rvc_attribute12
      ,p_rvc_attribute13                =>  p_rvc_attribute13
      ,p_rvc_attribute14                =>  p_rvc_attribute14
      ,p_rvc_attribute15                =>  p_rvc_attribute15
      ,p_rvc_attribute16                =>  p_rvc_attribute16
      ,p_rvc_attribute17                =>  p_rvc_attribute17
      ,p_rvc_attribute18                =>  p_rvc_attribute18
      ,p_rvc_attribute19                =>  p_rvc_attribute19
      ,p_rvc_attribute20                =>  p_rvc_attribute20
      ,p_rvc_attribute21                =>  p_rvc_attribute21
      ,p_rvc_attribute22                =>  p_rvc_attribute22
      ,p_rvc_attribute23                =>  p_rvc_attribute23
      ,p_rvc_attribute24                =>  p_rvc_attribute24
      ,p_rvc_attribute25                =>  p_rvc_attribute25
      ,p_rvc_attribute26                =>  p_rvc_attribute26
      ,p_rvc_attribute27                =>  p_rvc_attribute27
      ,p_rvc_attribute28                =>  p_rvc_attribute28
      ,p_rvc_attribute29                =>  p_rvc_attribute29
      ,p_rvc_attribute30                =>  p_rvc_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_prv_ctfn_prvdd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_prv_ctfn_prvdd
    --
  end;
  --
  ben_rvc_upd.upd
    (
     p_prtt_rt_val_ctfn_prvdd_id       => p_prtt_rt_val_ctfn_prvdd_id
    ,p_enrt_ctfn_rqd_flag            => p_enrt_ctfn_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_enrt_ctfn_recd_dt             => p_enrt_ctfn_recd_dt
    ,p_enrt_ctfn_dnd_dt              => p_enrt_ctfn_dnd_dt
    ,p_prtt_rt_val_id             => p_prtt_rt_val_id
    ,p_business_group_id             => p_business_group_id
    ,p_rvc_attribute_category        => p_rvc_attribute_category
    ,p_rvc_attribute1                => p_rvc_attribute1
    ,p_rvc_attribute2                => p_rvc_attribute2
    ,p_rvc_attribute3                => p_rvc_attribute3
    ,p_rvc_attribute4                => p_rvc_attribute4
    ,p_rvc_attribute5                => p_rvc_attribute5
    ,p_rvc_attribute6                => p_rvc_attribute6
    ,p_rvc_attribute7                => p_rvc_attribute7
    ,p_rvc_attribute8                => p_rvc_attribute8
    ,p_rvc_attribute9                => p_rvc_attribute9
    ,p_rvc_attribute10               => p_rvc_attribute10
    ,p_rvc_attribute11               => p_rvc_attribute11
    ,p_rvc_attribute12               => p_rvc_attribute12
    ,p_rvc_attribute13               => p_rvc_attribute13
    ,p_rvc_attribute14               => p_rvc_attribute14
    ,p_rvc_attribute15               => p_rvc_attribute15
    ,p_rvc_attribute16               => p_rvc_attribute16
    ,p_rvc_attribute17               => p_rvc_attribute17
    ,p_rvc_attribute18               => p_rvc_attribute18
    ,p_rvc_attribute19               => p_rvc_attribute19
    ,p_rvc_attribute20               => p_rvc_attribute20
    ,p_rvc_attribute21               => p_rvc_attribute21
    ,p_rvc_attribute22               => p_rvc_attribute22
    ,p_rvc_attribute23               => p_rvc_attribute23
    ,p_rvc_attribute24               => p_rvc_attribute24
    ,p_rvc_attribute25               => p_rvc_attribute25
    ,p_rvc_attribute26               => p_rvc_attribute26
    ,p_rvc_attribute27               => p_rvc_attribute27
    ,p_rvc_attribute28               => p_rvc_attribute28
    ,p_rvc_attribute29               => p_rvc_attribute29
    ,p_rvc_attribute30               => p_rvc_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_prv_ctfn_prvdd
    --
    ben_prv_ctfn_prvdd_bk2.update_prv_ctfn_prvdd_a
      (
       p_prtt_rt_val_ctfn_prvdd_id        =>  p_prtt_rt_val_ctfn_prvdd_id
      ,p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_prtt_rt_val_id              =>  p_prtt_rt_val_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rvc_attribute_category         =>  p_rvc_attribute_category
      ,p_rvc_attribute1                 =>  p_rvc_attribute1
      ,p_rvc_attribute2                 =>  p_rvc_attribute2
      ,p_rvc_attribute3                 =>  p_rvc_attribute3
      ,p_rvc_attribute4                 =>  p_rvc_attribute4
      ,p_rvc_attribute5                 =>  p_rvc_attribute5
      ,p_rvc_attribute6                 =>  p_rvc_attribute6
      ,p_rvc_attribute7                 =>  p_rvc_attribute7
      ,p_rvc_attribute8                 =>  p_rvc_attribute8
      ,p_rvc_attribute9                 =>  p_rvc_attribute9
      ,p_rvc_attribute10                =>  p_rvc_attribute10
      ,p_rvc_attribute11                =>  p_rvc_attribute11
      ,p_rvc_attribute12                =>  p_rvc_attribute12
      ,p_rvc_attribute13                =>  p_rvc_attribute13
      ,p_rvc_attribute14                =>  p_rvc_attribute14
      ,p_rvc_attribute15                =>  p_rvc_attribute15
      ,p_rvc_attribute16                =>  p_rvc_attribute16
      ,p_rvc_attribute17                =>  p_rvc_attribute17
      ,p_rvc_attribute18                =>  p_rvc_attribute18
      ,p_rvc_attribute19                =>  p_rvc_attribute19
      ,p_rvc_attribute20                =>  p_rvc_attribute20
      ,p_rvc_attribute21                =>  p_rvc_attribute21
      ,p_rvc_attribute22                =>  p_rvc_attribute22
      ,p_rvc_attribute23                =>  p_rvc_attribute23
      ,p_rvc_attribute24                =>  p_rvc_attribute24
      ,p_rvc_attribute25                =>  p_rvc_attribute25
      ,p_rvc_attribute26                =>  p_rvc_attribute26
      ,p_rvc_attribute27                =>  p_rvc_attribute27
      ,p_rvc_attribute28                =>  p_rvc_attribute28
      ,p_rvc_attribute29                =>  p_rvc_attribute29
      ,p_rvc_attribute30                =>  p_rvc_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_prv_ctfn_prvdd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_prv_ctfn_prvdd
    --
  end;
  --
  -- LGE : if certification recieved then create element entry.
  --
  if nvl(p_enrt_ctfn_recd_dt, hr_api.g_date) <> hr_api.g_date and
     nvl(p_enrt_ctfn_dnd_dt, hr_api.g_date) =  hr_api.g_date
  then
    --
    -- Create element entry.
    --
    open c_prv;
    fetch c_prv into l_prv_rec;
    close c_prv;
    --
    /*
    if result_is_suspended(
       p_prtt_enrt_rslt_id => l_prv_rec.prtt_enrt_rslt_id,
       p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date)
     ='N' then
    */
     --
     ben_element_entry.create_enrollment_element
      (p_business_group_id        => p_business_group_id
      ,p_prtt_rt_val_id           => p_prtt_rt_val_id
      ,p_person_id                => l_prv_rec.person_id
      ,p_acty_ref_perd            => l_prv_rec.acty_ref_perd_cd
      ,p_acty_base_rt_id          => l_prv_rec.acty_base_rt_id
      ,p_enrt_rslt_id             => l_prv_rec.prtt_enrt_rslt_id
      ,p_rt_start_date            => l_prv_rec.rt_strt_dt
      ,p_rt                       => l_prv_rec.rt_val
      ,p_cmncd_rt                 => l_prv_rec.cmcd_rt_val
      ,p_ann_rt                   => l_prv_rec.ann_rt_val
      ,p_input_value_id           => l_prv_rec.input_value_id
      ,p_element_type_id          => l_prv_rec.element_type_id
      ,p_prv_object_version_number=> l_prv_rec.object_version_number
      ,p_effective_date           => p_effective_date
      ,p_eev_screen_entry_value   => l_dummy_number
      ,p_element_entry_value_id   => l_dummy_number
      );
     --
    -- end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 64);
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
    ROLLBACK TO update_prv_ctfn_prvdd;
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
    ROLLBACK TO update_prv_ctfn_prvdd;
    raise;
    --
end update_prv_ctfn_prvdd;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_prv_ctfn_prvdd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_prv_ctfn_prvdd
  (p_validate                       in  boolean  default false
  ,p_prtt_rt_val_ctfn_prvdd_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_check_actions                  in varchar2 default 'Y'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_prv_ctfn_prvdd';
  l_object_version_number ben_prtt_rt_val_ctfn_prvdd.object_version_number%TYPE;
  --
  l_prtt_rt_val_id      number(15);
  l_rslt_object_version_number number(15);
  l_business_group_id      number(15);
  l_exist                  varchar2(1) := 'N';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Get action item id and the business group id.
  --
  -- Initialize environment
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init
      (p_business_group_id => l_business_group_id,
       p_effective_date    => p_effective_date,
       p_thread_id         => null,
       p_chunk_size        => null,
       p_threads           => null,
       p_max_errors        => null,
       p_benefit_action_id => null);
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_prv_ctfn_prvdd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_prv_ctfn_prvdd
    --
    ben_prv_ctfn_prvdd_bk3.delete_prv_ctfn_prvdd_b
      (p_prtt_rt_val_ctfn_prvdd_id        =>  p_prtt_rt_val_ctfn_prvdd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date) );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_prv_ctfn_prvdd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_prv_ctfn_prvdd
    --
  end;
  --
  ben_rvc_del.del
    (
     p_prtt_rt_val_ctfn_prvdd_id       => p_prtt_rt_val_ctfn_prvdd_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_prv_ctfn_prvdd
    --
    ben_prv_ctfn_prvdd_bk3.delete_prv_ctfn_prvdd_a
      (
       p_prtt_rt_val_ctfn_prvdd_id        =>  p_prtt_rt_val_ctfn_prvdd_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_prv_ctfn_prvdd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_prv_ctfn_prvdd
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
    ROLLBACK TO delete_prv_ctfn_prvdd;
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
    ROLLBACK TO delete_prv_ctfn_prvdd;
    raise;
    --
end delete_prv_ctfn_prvdd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_rt_val_ctfn_prvdd_id      in     number
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
  ben_rvc_shd.lck
    (
      p_prtt_rt_val_ctfn_prvdd_id    => p_prtt_rt_val_ctfn_prvdd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_prv_ctfn_prvdd_api;

/
