--------------------------------------------------------
--  DDL for Package Body BEN_LIFE_EVENT_ENROLL_RSN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LIFE_EVENT_ENROLL_RSN_API" as
/* $Header: belenapi.pkb 120.0.12000000.2 2007/05/13 22:56:52 rtagarra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Life_Event_Enroll_Rsn_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Life_Event_Enroll_Rsn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Life_Event_Enroll_Rsn
  (p_validate                       in  boolean   default false
  ,p_lee_rsn_id                     out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_popl_enrt_typ_cycl_id          in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_dys_aftr_end_to_dflt_num       in  number    default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_enrt_perd_strt_dt_cd           in  varchar2  default null
  ,p_enrt_perd_strt_dt_rl           in  number    default null
  ,p_enrt_perd_end_dt_cd            in  varchar2  default null
  ,p_enrt_perd_end_dt_rl            in  number    default null
  ,p_addl_procg_dys_num             in  number    default null
  ,p_dys_no_enrl_not_elig_num       in  number    default null
  ,p_dys_no_enrl_cant_enrl_num      in  number    default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_len_attribute_category         in  varchar2  default null
  ,p_len_attribute1                 in  varchar2  default null
  ,p_len_attribute2                 in  varchar2  default null
  ,p_len_attribute3                 in  varchar2  default null
  ,p_len_attribute4                 in  varchar2  default null
  ,p_len_attribute5                 in  varchar2  default null
  ,p_len_attribute6                 in  varchar2  default null
  ,p_len_attribute7                 in  varchar2  default null
  ,p_len_attribute8                 in  varchar2  default null
  ,p_len_attribute9                 in  varchar2  default null
  ,p_len_attribute10                in  varchar2  default null
  ,p_len_attribute11                in  varchar2  default null
  ,p_len_attribute12                in  varchar2  default null
  ,p_len_attribute13                in  varchar2  default null
  ,p_len_attribute14                in  varchar2  default null
  ,p_len_attribute15                in  varchar2  default null
  ,p_len_attribute16                in  varchar2  default null
  ,p_len_attribute17                in  varchar2  default null
  ,p_len_attribute18                in  varchar2  default null
  ,p_len_attribute19                in  varchar2  default null
  ,p_len_attribute20                in  varchar2  default null
  ,p_len_attribute21                in  varchar2  default null
  ,p_len_attribute22                in  varchar2  default null
  ,p_len_attribute23                in  varchar2  default null
  ,p_len_attribute24                in  varchar2  default null
  ,p_len_attribute25                in  varchar2  default null
  ,p_len_attribute26                in  varchar2  default null
  ,p_len_attribute27                in  varchar2  default null
  ,p_len_attribute28                in  varchar2  default null
  ,p_len_attribute29                in  varchar2  default null
  ,p_len_attribute30                in  varchar2  default null
  ,p_enrt_perd_det_ovrlp_bckdt_cd                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_reinstate_cd			in varchar2 default null
  ,p_reinstate_ovrdn_cd		in varchar2 default null
  ,p_ENRT_PERD_STRT_DAYS	in number   default null
  ,p_ENRT_PERD_END_DAYS	        in number   default null
  ,p_defer_deenrol_flag         in varchar2       default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_lee_rsn_id ben_lee_rsn_f.lee_rsn_id%TYPE;
  l_effective_start_date ben_lee_rsn_f.effective_start_date%TYPE;
  l_effective_end_date ben_lee_rsn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Life_Event_Enroll_Rsn';
  l_object_version_number ben_lee_rsn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Life_Event_Enroll_Rsn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Life_Event_Enroll_Rsn
    --
    ben_Life_Event_Enroll_Rsn_bk1.create_Life_Event_Enroll_Rsn_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dys_aftr_end_to_dflt_num       =>  p_dys_aftr_end_to_dflt_num
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_perd_strt_dt_cd           =>  p_enrt_perd_strt_dt_cd
      ,p_enrt_perd_strt_dt_rl           =>  p_enrt_perd_strt_dt_rl
      ,p_enrt_perd_end_dt_cd            =>  p_enrt_perd_end_dt_cd
      ,p_enrt_perd_end_dt_rl            =>  p_enrt_perd_end_dt_rl
      ,p_addl_procg_dys_num             =>  p_addl_procg_dys_num
      ,p_dys_no_enrl_not_elig_num       =>  p_dys_no_enrl_not_elig_num
      ,p_dys_no_enrl_cant_enrl_num      =>  p_dys_no_enrl_cant_enrl_num
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_len_attribute_category         =>  p_len_attribute_category
      ,p_len_attribute1                 =>  p_len_attribute1
      ,p_len_attribute2                 =>  p_len_attribute2
      ,p_len_attribute3                 =>  p_len_attribute3
      ,p_len_attribute4                 =>  p_len_attribute4
      ,p_len_attribute5                 =>  p_len_attribute5
      ,p_len_attribute6                 =>  p_len_attribute6
      ,p_len_attribute7                 =>  p_len_attribute7
      ,p_len_attribute8                 =>  p_len_attribute8
      ,p_len_attribute9                 =>  p_len_attribute9
      ,p_len_attribute10                =>  p_len_attribute10
      ,p_len_attribute11                =>  p_len_attribute11
      ,p_len_attribute12                =>  p_len_attribute12
      ,p_len_attribute13                =>  p_len_attribute13
      ,p_len_attribute14                =>  p_len_attribute14
      ,p_len_attribute15                =>  p_len_attribute15
      ,p_len_attribute16                =>  p_len_attribute16
      ,p_len_attribute17                =>  p_len_attribute17
      ,p_len_attribute18                =>  p_len_attribute18
      ,p_len_attribute19                =>  p_len_attribute19
      ,p_len_attribute20                =>  p_len_attribute20
      ,p_len_attribute21                =>  p_len_attribute21
      ,p_len_attribute22                =>  p_len_attribute22
      ,p_len_attribute23                =>  p_len_attribute23
      ,p_len_attribute24                =>  p_len_attribute24
      ,p_len_attribute25                =>  p_len_attribute25
      ,p_len_attribute26                =>  p_len_attribute26
      ,p_len_attribute27                =>  p_len_attribute27
      ,p_len_attribute28                =>  p_len_attribute28
      ,p_len_attribute29                =>  p_len_attribute29
      ,p_len_attribute30                =>  p_len_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd                =>  p_enrt_perd_det_ovrlp_bckdt_cd
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_reinstate_cd				=>p_reinstate_cd
      ,p_reinstate_ovrdn_cd		=> p_reinstate_ovrdn_cd
      ,p_ENRT_PERD_STRT_DAYS		=> p_ENRT_PERD_STRT_DAYS
      ,p_ENRT_PERD_END_DAYS		=> p_ENRT_PERD_END_DAYS
      ,p_defer_deenrol_flag             => p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Life_Event_Enroll_Rsn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Life_Event_Enroll_Rsn
    --
  end;
  --
  ben_len_ins.ins
    (
     p_lee_rsn_id                    => l_lee_rsn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_ler_id                        => p_ler_id
    ,p_cls_enrt_dt_to_use_cd         => p_cls_enrt_dt_to_use_cd
    ,p_dys_aftr_end_to_dflt_num      => p_dys_aftr_end_to_dflt_num
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_perd_strt_dt_cd          => p_enrt_perd_strt_dt_cd
    ,p_enrt_perd_strt_dt_rl          => p_enrt_perd_strt_dt_rl
    ,p_enrt_perd_end_dt_cd           => p_enrt_perd_end_dt_cd
    ,p_enrt_perd_end_dt_rl           => p_enrt_perd_end_dt_rl
    ,p_addl_procg_dys_num            => p_addl_procg_dys_num
    ,p_dys_no_enrl_not_elig_num      => p_dys_no_enrl_not_elig_num
    ,p_dys_no_enrl_cant_enrl_num     => p_dys_no_enrl_cant_enrl_num
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_len_attribute_category        => p_len_attribute_category
    ,p_len_attribute1                => p_len_attribute1
    ,p_len_attribute2                => p_len_attribute2
    ,p_len_attribute3                => p_len_attribute3
    ,p_len_attribute4                => p_len_attribute4
    ,p_len_attribute5                => p_len_attribute5
    ,p_len_attribute6                => p_len_attribute6
    ,p_len_attribute7                => p_len_attribute7
    ,p_len_attribute8                => p_len_attribute8
    ,p_len_attribute9                => p_len_attribute9
    ,p_len_attribute10               => p_len_attribute10
    ,p_len_attribute11               => p_len_attribute11
    ,p_len_attribute12               => p_len_attribute12
    ,p_len_attribute13               => p_len_attribute13
    ,p_len_attribute14               => p_len_attribute14
    ,p_len_attribute15               => p_len_attribute15
    ,p_len_attribute16               => p_len_attribute16
    ,p_len_attribute17               => p_len_attribute17
    ,p_len_attribute18               => p_len_attribute18
    ,p_len_attribute19               => p_len_attribute19
    ,p_len_attribute20               => p_len_attribute20
    ,p_len_attribute21               => p_len_attribute21
    ,p_len_attribute22               => p_len_attribute22
    ,p_len_attribute23               => p_len_attribute23
    ,p_len_attribute24               => p_len_attribute24
    ,p_len_attribute25               => p_len_attribute25
    ,p_len_attribute26               => p_len_attribute26
    ,p_len_attribute27               => p_len_attribute27
    ,p_len_attribute28               => p_len_attribute28
    ,p_len_attribute29               => p_len_attribute29
    ,p_len_attribute30               => p_len_attribute30
    ,p_enrt_perd_det_ovrlp_bckdt_cd               => p_enrt_perd_det_ovrlp_bckdt_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_reinstate_cd				=>p_reinstate_cd
    ,p_reinstate_ovrdn_cd		=> p_reinstate_ovrdn_cd
    ,p_ENRT_PERD_STRT_DAYS		=> p_ENRT_PERD_STRT_DAYS
    ,p_ENRT_PERD_END_DAYS		=> p_ENRT_PERD_END_DAYS
    ,p_defer_deenrol_flag             => p_defer_deenrol_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Life_Event_Enroll_Rsn
    --
    ben_Life_Event_Enroll_Rsn_bk1.create_Life_Event_Enroll_Rsn_a
      (
       p_lee_rsn_id                     =>  l_lee_rsn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dys_aftr_end_to_dflt_num       =>  p_dys_aftr_end_to_dflt_num
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_perd_strt_dt_cd           =>  p_enrt_perd_strt_dt_cd
      ,p_enrt_perd_strt_dt_rl           =>  p_enrt_perd_strt_dt_rl
      ,p_enrt_perd_end_dt_cd            =>  p_enrt_perd_end_dt_cd
      ,p_enrt_perd_end_dt_rl            =>  p_enrt_perd_end_dt_rl
      ,p_addl_procg_dys_num             =>  p_addl_procg_dys_num
      ,p_dys_no_enrl_not_elig_num       =>  p_dys_no_enrl_not_elig_num
      ,p_dys_no_enrl_cant_enrl_num      =>  p_dys_no_enrl_cant_enrl_num
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_len_attribute_category         =>  p_len_attribute_category
      ,p_len_attribute1                 =>  p_len_attribute1
      ,p_len_attribute2                 =>  p_len_attribute2
      ,p_len_attribute3                 =>  p_len_attribute3
      ,p_len_attribute4                 =>  p_len_attribute4
      ,p_len_attribute5                 =>  p_len_attribute5
      ,p_len_attribute6                 =>  p_len_attribute6
      ,p_len_attribute7                 =>  p_len_attribute7
      ,p_len_attribute8                 =>  p_len_attribute8
      ,p_len_attribute9                 =>  p_len_attribute9
      ,p_len_attribute10                =>  p_len_attribute10
      ,p_len_attribute11                =>  p_len_attribute11
      ,p_len_attribute12                =>  p_len_attribute12
      ,p_len_attribute13                =>  p_len_attribute13
      ,p_len_attribute14                =>  p_len_attribute14
      ,p_len_attribute15                =>  p_len_attribute15
      ,p_len_attribute16                =>  p_len_attribute16
      ,p_len_attribute17                =>  p_len_attribute17
      ,p_len_attribute18                =>  p_len_attribute18
      ,p_len_attribute19                =>  p_len_attribute19
      ,p_len_attribute20                =>  p_len_attribute20
      ,p_len_attribute21                =>  p_len_attribute21
      ,p_len_attribute22                =>  p_len_attribute22
      ,p_len_attribute23                =>  p_len_attribute23
      ,p_len_attribute24                =>  p_len_attribute24
      ,p_len_attribute25                =>  p_len_attribute25
      ,p_len_attribute26                =>  p_len_attribute26
      ,p_len_attribute27                =>  p_len_attribute27
      ,p_len_attribute28                =>  p_len_attribute28
      ,p_len_attribute29                =>  p_len_attribute29
      ,p_len_attribute30                =>  p_len_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd                =>  p_enrt_perd_det_ovrlp_bckdt_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_reinstate_cd				=>p_reinstate_cd
      ,p_reinstate_ovrdn_cd		=> p_reinstate_ovrdn_cd
      ,p_ENRT_PERD_STRT_DAYS		=> p_ENRT_PERD_STRT_DAYS
      ,p_ENRT_PERD_END_DAYS		=> p_ENRT_PERD_END_DAYS
      ,p_defer_deenrol_flag             => p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Life_Event_Enroll_Rsn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Life_Event_Enroll_Rsn
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
  p_lee_rsn_id := l_lee_rsn_id;
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
    ROLLBACK TO create_Life_Event_Enroll_Rsn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_lee_rsn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Life_Event_Enroll_Rsn;
    raise;
    --
end create_Life_Event_Enroll_Rsn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Life_Event_Enroll_Rsn >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Life_Event_Enroll_Rsn
  (p_validate                       in  boolean   default false
  ,p_lee_rsn_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_popl_enrt_typ_cycl_id          in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_dys_aftr_end_to_dflt_num       in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_strt_dt_cd           in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_strt_dt_rl           in  number    default hr_api.g_number
  ,p_enrt_perd_end_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt_rl            in  number    default hr_api.g_number
  ,p_addl_procg_dys_num             in  number    default hr_api.g_number
  ,p_dys_no_enrl_not_elig_num       in  number    default hr_api.g_number
  ,p_dys_no_enrl_cant_enrl_num      in  number    default hr_api.g_number
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_len_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_len_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_det_ovrlp_bckdt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_reinstate_cd			in  varchar2  default hr_api.g_varchar2
  ,p_reinstate_ovrdn_cd		in  varchar2  default hr_api.g_varchar2
  ,p_ENRT_PERD_STRT_DAYS	in  number  default hr_api.g_number
  ,p_ENRT_PERD_END_DAYS	        in  number  default hr_api.g_number
  ,p_defer_deenrol_flag         in varchar2       default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Life_Event_Enroll_Rsn';
  l_object_version_number ben_lee_rsn_f.object_version_number%TYPE;
  l_effective_start_date ben_lee_rsn_f.effective_start_date%TYPE;
  l_effective_end_date ben_lee_rsn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Life_Event_Enroll_Rsn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Life_Event_Enroll_Rsn
    --
    ben_Life_Event_Enroll_Rsn_bk2.update_Life_Event_Enroll_Rsn_b
      (
       p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dys_aftr_end_to_dflt_num       =>  p_dys_aftr_end_to_dflt_num
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_perd_strt_dt_cd           =>  p_enrt_perd_strt_dt_cd
      ,p_enrt_perd_strt_dt_rl           =>  p_enrt_perd_strt_dt_rl
      ,p_enrt_perd_end_dt_cd            =>  p_enrt_perd_end_dt_cd
      ,p_enrt_perd_end_dt_rl            =>  p_enrt_perd_end_dt_rl
      ,p_addl_procg_dys_num             =>  p_addl_procg_dys_num
      ,p_dys_no_enrl_not_elig_num       =>  p_dys_no_enrl_not_elig_num
      ,p_dys_no_enrl_cant_enrl_num      =>  p_dys_no_enrl_cant_enrl_num
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_len_attribute_category         =>  p_len_attribute_category
      ,p_len_attribute1                 =>  p_len_attribute1
      ,p_len_attribute2                 =>  p_len_attribute2
      ,p_len_attribute3                 =>  p_len_attribute3
      ,p_len_attribute4                 =>  p_len_attribute4
      ,p_len_attribute5                 =>  p_len_attribute5
      ,p_len_attribute6                 =>  p_len_attribute6
      ,p_len_attribute7                 =>  p_len_attribute7
      ,p_len_attribute8                 =>  p_len_attribute8
      ,p_len_attribute9                 =>  p_len_attribute9
      ,p_len_attribute10                =>  p_len_attribute10
      ,p_len_attribute11                =>  p_len_attribute11
      ,p_len_attribute12                =>  p_len_attribute12
      ,p_len_attribute13                =>  p_len_attribute13
      ,p_len_attribute14                =>  p_len_attribute14
      ,p_len_attribute15                =>  p_len_attribute15
      ,p_len_attribute16                =>  p_len_attribute16
      ,p_len_attribute17                =>  p_len_attribute17
      ,p_len_attribute18                =>  p_len_attribute18
      ,p_len_attribute19                =>  p_len_attribute19
      ,p_len_attribute20                =>  p_len_attribute20
      ,p_len_attribute21                =>  p_len_attribute21
      ,p_len_attribute22                =>  p_len_attribute22
      ,p_len_attribute23                =>  p_len_attribute23
      ,p_len_attribute24                =>  p_len_attribute24
      ,p_len_attribute25                =>  p_len_attribute25
      ,p_len_attribute26                =>  p_len_attribute26
      ,p_len_attribute27                =>  p_len_attribute27
      ,p_len_attribute28                =>  p_len_attribute28
      ,p_len_attribute29                =>  p_len_attribute29
      ,p_len_attribute30                =>  p_len_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd                =>  p_enrt_perd_det_ovrlp_bckdt_cd
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
    ,p_reinstate_cd			=> p_reinstate_cd
    ,p_reinstate_ovrdn_cd		=> p_reinstate_ovrdn_cd
    ,p_ENRT_PERD_STRT_DAYS		=> p_ENRT_PERD_STRT_DAYS
    ,p_ENRT_PERD_END_DAYS		=> p_ENRT_PERD_END_DAYS
    ,p_defer_deenrol_flag               => p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Life_Event_Enroll_Rsn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Life_Event_Enroll_Rsn
    --
  end;
  --
  ben_len_upd.upd
    (
     p_lee_rsn_id                    => p_lee_rsn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_ler_id                        => p_ler_id
    ,p_cls_enrt_dt_to_use_cd         => p_cls_enrt_dt_to_use_cd
    ,p_dys_aftr_end_to_dflt_num      => p_dys_aftr_end_to_dflt_num
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_enrt_perd_strt_dt_cd          => p_enrt_perd_strt_dt_cd
    ,p_enrt_perd_strt_dt_rl          => p_enrt_perd_strt_dt_rl
    ,p_enrt_perd_end_dt_cd           => p_enrt_perd_end_dt_cd
    ,p_enrt_perd_end_dt_rl           => p_enrt_perd_end_dt_rl
    ,p_addl_procg_dys_num            => p_addl_procg_dys_num
    ,p_dys_no_enrl_not_elig_num      => p_dys_no_enrl_not_elig_num
    ,p_dys_no_enrl_cant_enrl_num     => p_dys_no_enrl_cant_enrl_num
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_len_attribute_category        => p_len_attribute_category
    ,p_len_attribute1                => p_len_attribute1
    ,p_len_attribute2                => p_len_attribute2
    ,p_len_attribute3                => p_len_attribute3
    ,p_len_attribute4                => p_len_attribute4
    ,p_len_attribute5                => p_len_attribute5
    ,p_len_attribute6                => p_len_attribute6
    ,p_len_attribute7                => p_len_attribute7
    ,p_len_attribute8                => p_len_attribute8
    ,p_len_attribute9                => p_len_attribute9
    ,p_len_attribute10               => p_len_attribute10
    ,p_len_attribute11               => p_len_attribute11
    ,p_len_attribute12               => p_len_attribute12
    ,p_len_attribute13               => p_len_attribute13
    ,p_len_attribute14               => p_len_attribute14
    ,p_len_attribute15               => p_len_attribute15
    ,p_len_attribute16               => p_len_attribute16
    ,p_len_attribute17               => p_len_attribute17
    ,p_len_attribute18               => p_len_attribute18
    ,p_len_attribute19               => p_len_attribute19
    ,p_len_attribute20               => p_len_attribute20
    ,p_len_attribute21               => p_len_attribute21
    ,p_len_attribute22               => p_len_attribute22
    ,p_len_attribute23               => p_len_attribute23
    ,p_len_attribute24               => p_len_attribute24
    ,p_len_attribute25               => p_len_attribute25
    ,p_len_attribute26               => p_len_attribute26
    ,p_len_attribute27               => p_len_attribute27
    ,p_len_attribute28               => p_len_attribute28
    ,p_len_attribute29               => p_len_attribute29
    ,p_len_attribute30               => p_len_attribute30
    ,p_enrt_perd_det_ovrlp_bckdt_cd               => p_enrt_perd_det_ovrlp_bckdt_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
     ,p_reinstate_cd			=> p_reinstate_cd
   ,p_reinstate_ovrdn_cd		=> p_reinstate_ovrdn_cd
   ,p_ENRT_PERD_STRT_DAYS		=> p_ENRT_PERD_STRT_DAYS
   ,p_ENRT_PERD_END_DAYS		=> p_ENRT_PERD_END_DAYS
   ,p_defer_deenrol_flag                => p_defer_deenrol_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Life_Event_Enroll_Rsn
    --
    ben_Life_Event_Enroll_Rsn_bk2.update_Life_Event_Enroll_Rsn_a
      (
       p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_ler_id                         =>  p_ler_id
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dys_aftr_end_to_dflt_num       =>  p_dys_aftr_end_to_dflt_num
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_enrt_perd_strt_dt_cd           =>  p_enrt_perd_strt_dt_cd
      ,p_enrt_perd_strt_dt_rl           =>  p_enrt_perd_strt_dt_rl
      ,p_enrt_perd_end_dt_cd            =>  p_enrt_perd_end_dt_cd
      ,p_enrt_perd_end_dt_rl            =>  p_enrt_perd_end_dt_rl
      ,p_addl_procg_dys_num             =>  p_addl_procg_dys_num
      ,p_dys_no_enrl_not_elig_num       =>  p_dys_no_enrl_not_elig_num
      ,p_dys_no_enrl_cant_enrl_num      =>  p_dys_no_enrl_cant_enrl_num
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_len_attribute_category         =>  p_len_attribute_category
      ,p_len_attribute1                 =>  p_len_attribute1
      ,p_len_attribute2                 =>  p_len_attribute2
      ,p_len_attribute3                 =>  p_len_attribute3
      ,p_len_attribute4                 =>  p_len_attribute4
      ,p_len_attribute5                 =>  p_len_attribute5
      ,p_len_attribute6                 =>  p_len_attribute6
      ,p_len_attribute7                 =>  p_len_attribute7
      ,p_len_attribute8                 =>  p_len_attribute8
      ,p_len_attribute9                 =>  p_len_attribute9
      ,p_len_attribute10                =>  p_len_attribute10
      ,p_len_attribute11                =>  p_len_attribute11
      ,p_len_attribute12                =>  p_len_attribute12
      ,p_len_attribute13                =>  p_len_attribute13
      ,p_len_attribute14                =>  p_len_attribute14
      ,p_len_attribute15                =>  p_len_attribute15
      ,p_len_attribute16                =>  p_len_attribute16
      ,p_len_attribute17                =>  p_len_attribute17
      ,p_len_attribute18                =>  p_len_attribute18
      ,p_len_attribute19                =>  p_len_attribute19
      ,p_len_attribute20                =>  p_len_attribute20
      ,p_len_attribute21                =>  p_len_attribute21
      ,p_len_attribute22                =>  p_len_attribute22
      ,p_len_attribute23                =>  p_len_attribute23
      ,p_len_attribute24                =>  p_len_attribute24
      ,p_len_attribute25                =>  p_len_attribute25
      ,p_len_attribute26                =>  p_len_attribute26
      ,p_len_attribute27                =>  p_len_attribute27
      ,p_len_attribute28                =>  p_len_attribute28
      ,p_len_attribute29                =>  p_len_attribute29
      ,p_len_attribute30                =>  p_len_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd                =>  p_enrt_perd_det_ovrlp_bckdt_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_reinstate_cd			=> p_reinstate_cd
      ,p_reinstate_ovrdn_cd		=> p_reinstate_ovrdn_cd
      ,p_ENRT_PERD_STRT_DAYS		=> p_ENRT_PERD_STRT_DAYS
      ,p_ENRT_PERD_END_DAYS		=> p_ENRT_PERD_END_DAYS
      ,p_defer_deenrol_flag             => p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Life_Event_Enroll_Rsn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Life_Event_Enroll_Rsn
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
    ROLLBACK TO update_Life_Event_Enroll_Rsn;
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
    ROLLBACK TO update_Life_Event_Enroll_Rsn;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_Life_Event_Enroll_Rsn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Life_Event_Enroll_Rsn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Life_Event_Enroll_Rsn
  (p_validate                       in  boolean  default false
  ,p_lee_rsn_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Life_Event_Enroll_Rsn';
  l_object_version_number ben_lee_rsn_f.object_version_number%TYPE;
  l_effective_start_date ben_lee_rsn_f.effective_start_date%TYPE;
  l_effective_end_date ben_lee_rsn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Life_Event_Enroll_Rsn;
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
    -- Start of API User Hook for the before hook of delete_Life_Event_Enroll_Rsn
    --
    ben_Life_Event_Enroll_Rsn_bk3.delete_Life_Event_Enroll_Rsn_b
      (
       p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Life_Event_Enroll_Rsn'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Life_Event_Enroll_Rsn
    --
  end;
  --
  ben_len_del.del
    (
     p_lee_rsn_id                    => p_lee_rsn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Life_Event_Enroll_Rsn
    --
    ben_Life_Event_Enroll_Rsn_bk3.delete_Life_Event_Enroll_Rsn_a
      (
       p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Life_Event_Enroll_Rsn'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Life_Event_Enroll_Rsn
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
    ROLLBACK TO delete_Life_Event_Enroll_Rsn;
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
    ROLLBACK TO delete_Life_Event_Enroll_Rsn;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_Life_Event_Enroll_Rsn;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_lee_rsn_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
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
  ben_len_shd.lck
    (
      p_lee_rsn_id                 => p_lee_rsn_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Life_Event_Enroll_Rsn_api;

/
