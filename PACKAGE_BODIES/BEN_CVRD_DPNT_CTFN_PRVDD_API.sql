--------------------------------------------------------
--  DDL for Package Body BEN_CVRD_DPNT_CTFN_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CVRD_DPNT_CTFN_PRVDD_API" as
/* $Header: beccpapi.pkb 120.0.12010000.2 2008/08/05 14:17:22 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_CVRD_DPNT_CTFN_PRVDD_api.';
--
procedure check_dpnt_ctfn
       (p_prtt_enrt_actn_id         in number,
        p_datetrack_mode            in varchar2,
        p_business_group_id         in number,
        p_effective_date            in date) is
  --
  l_all_prvdd boolean := FALSE;
  --
  cursor dpnt_c is
  select pen.prtt_enrt_rslt_id,
         pdp.dpnt_person_id,
         pdp.elig_cvrd_dpnt_id,
         pea.prtt_enrt_actn_id,
         pea.actn_typ_id,
         pea.cmpltd_dt,
         pen.object_version_number rslt_ovn,
         pea.object_version_number
    from ben_prtt_enrt_rslt_f pen,
         ben_prtt_enrt_actn_f pea,
         ben_elig_cvrd_dpnt_f pdp
   where pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and pea.elig_cvrd_dpnt_id = pdp.elig_cvrd_dpnt_id
     and pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and pea.business_group_id  = p_business_group_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
     and pdp.business_group_id  = p_business_group_id
     and p_effective_date between pdp.effective_start_date
                              and pdp.effective_end_date
     and pen.business_group_id  = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date;
  --
  l_dpnt      dpnt_c%rowtype;
  --
  l_proc       varchar2(80) := g_package||'check_dpnt_ctfn';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  open  dpnt_c;
  fetch dpnt_c into l_dpnt;
  close dpnt_c;
  --
  if l_dpnt.prtt_enrt_rslt_id is not null and
     l_dpnt.dpnt_person_id is not null then
    --
    --
    l_all_prvdd := ben_enrollment_action_items.check_dpnt_ctfn
                       (p_prtt_enrt_actn_id => l_dpnt.prtt_enrt_actn_id
                       ,p_elig_cvrd_dpnt_id => l_dpnt.elig_cvrd_dpnt_id
                       ,p_effective_date    => p_effective_date);
    --
    ben_enrollment_action_items.process_action_item
          (p_prtt_enrt_actn_id         => l_dpnt.prtt_enrt_actn_id
          ,p_actn_typ_id               => l_dpnt.actn_typ_id
          ,p_cmpltd_dt                 => l_dpnt.cmpltd_dt
          ,p_object_version_number     => l_dpnt.object_version_number
          ,p_effective_date            => p_effective_date
          ,p_rqd_data_found            => l_all_prvdd
          ,p_prtt_enrt_rslt_id         => l_dpnt.prtt_enrt_rslt_id
          ,p_elig_cvrd_dpnt_id         => l_dpnt.elig_cvrd_dpnt_id
          ,p_rqd_flag                  => 'Y'
          ,p_post_rslt_flag            => 'N'
          ,p_business_group_id         => p_business_group_id
          ,p_datetrack_mode            => p_datetrack_mode
          ,p_rslt_object_version_number => l_dpnt.rslt_ovn);
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
  --
end check_dpnt_ctfn;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_CVRD_DPNT_CTFN_PRVDD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_CVRD_DPNT_CTFN_PRVDD
  (p_validate                       in  boolean   default false
  ,p_cvrd_dpnt_ctfn_prvdd_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dpnt_dsgn_ctfn_typ_cd          in  varchar2  default null
  ,p_dpnt_dsgn_ctfn_rqd_flag        in  varchar2  default 'N'
  ,p_dpnt_dsgn_ctfn_recd_dt         in  date      default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_prtt_enrt_actn_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ccp_attribute_category         in  varchar2  default null
  ,p_ccp_attribute1                 in  varchar2  default null
  ,p_ccp_attribute2                 in  varchar2  default null
  ,p_ccp_attribute3                 in  varchar2  default null
  ,p_ccp_attribute4                 in  varchar2  default null
  ,p_ccp_attribute5                 in  varchar2  default null
  ,p_ccp_attribute6                 in  varchar2  default null
  ,p_ccp_attribute7                 in  varchar2  default null
  ,p_ccp_attribute8                 in  varchar2  default null
  ,p_ccp_attribute9                 in  varchar2  default null
  ,p_ccp_attribute10                in  varchar2  default null
  ,p_ccp_attribute11                in  varchar2  default null
  ,p_ccp_attribute12                in  varchar2  default null
  ,p_ccp_attribute13                in  varchar2  default null
  ,p_ccp_attribute14                in  varchar2  default null
  ,p_ccp_attribute15                in  varchar2  default null
  ,p_ccp_attribute16                in  varchar2  default null
  ,p_ccp_attribute17                in  varchar2  default null
  ,p_ccp_attribute18                in  varchar2  default null
  ,p_ccp_attribute19                in  varchar2  default null
  ,p_ccp_attribute20                in  varchar2  default null
  ,p_ccp_attribute21                in  varchar2  default null
  ,p_ccp_attribute22                in  varchar2  default null
  ,p_ccp_attribute23                in  varchar2  default null
  ,p_ccp_attribute24                in  varchar2  default null
  ,p_ccp_attribute25                in  varchar2  default null
  ,p_ccp_attribute26                in  varchar2  default null
  ,p_ccp_attribute27                in  varchar2  default null
  ,p_ccp_attribute28                in  varchar2  default null
  ,p_ccp_attribute29                in  varchar2  default null
  ,p_ccp_attribute30                in  varchar2  default null
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
  l_cvrd_dpnt_ctfn_prvdd_id ben_cvrd_dpnt_ctfn_prvdd_f.cvrd_dpnt_ctfn_prvdd_id%TYPE;
  l_effective_start_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_CVRD_DPNT_CTFN_PRVDD';
  l_object_version_number ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l_prtt_enrt_actn_id     ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type;
  l_prtt_enrt_rslt_id     ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type;
  --
  cursor c_pdp is
     select pdp.prtt_enrt_rslt_id
     from   ben_elig_cvrd_dpnt_f pdp
     where  pdp.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and    pdp.business_group_id = p_business_group_id
     and    p_effective_date between
            pdp.effective_start_date and pdp.effective_end_date;
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
  savepoint create_CVRD_DPNT_CTFN_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if p_prtt_enrt_actn_id is null then
     --
     open  c_pdp;
     fetch c_pdp into l_prtt_enrt_rslt_id;
     close c_pdp;
     --
     ben_enrollment_action_items.process_new_ctfn_action
          (p_prtt_enrt_rslt_id   => l_prtt_enrt_rslt_id
          ,p_elig_cvrd_dpnt_id   => p_elig_cvrd_dpnt_id
          ,p_actn_typ_cd         => 'DDCTFN'
          ,p_ctfn_rqd_flag       => p_dpnt_dsgn_ctfn_rqd_flag
          ,p_ctfn_recd_dt        => p_dpnt_dsgn_ctfn_recd_dt
          ,p_business_group_id   => p_business_group_id
          ,p_effective_date      => p_effective_date
          ,p_prtt_enrt_actn_id   => l_prtt_enrt_actn_id);
     --
  else
     --
     l_prtt_enrt_actn_id := p_prtt_enrt_actn_id;
     --
  end if;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk1.create_CVRD_DPNT_CTFN_PRVDD_b
      (
       p_dpnt_dsgn_ctfn_typ_cd          =>  p_dpnt_dsgn_ctfn_typ_cd
      ,p_dpnt_dsgn_ctfn_rqd_flag        =>  p_dpnt_dsgn_ctfn_rqd_flag
      ,p_dpnt_dsgn_ctfn_recd_dt         =>  p_dpnt_dsgn_ctfn_recd_dt
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccp_attribute_category         =>  p_ccp_attribute_category
      ,p_ccp_attribute1                 =>  p_ccp_attribute1
      ,p_ccp_attribute2                 =>  p_ccp_attribute2
      ,p_ccp_attribute3                 =>  p_ccp_attribute3
      ,p_ccp_attribute4                 =>  p_ccp_attribute4
      ,p_ccp_attribute5                 =>  p_ccp_attribute5
      ,p_ccp_attribute6                 =>  p_ccp_attribute6
      ,p_ccp_attribute7                 =>  p_ccp_attribute7
      ,p_ccp_attribute8                 =>  p_ccp_attribute8
      ,p_ccp_attribute9                 =>  p_ccp_attribute9
      ,p_ccp_attribute10                =>  p_ccp_attribute10
      ,p_ccp_attribute11                =>  p_ccp_attribute11
      ,p_ccp_attribute12                =>  p_ccp_attribute12
      ,p_ccp_attribute13                =>  p_ccp_attribute13
      ,p_ccp_attribute14                =>  p_ccp_attribute14
      ,p_ccp_attribute15                =>  p_ccp_attribute15
      ,p_ccp_attribute16                =>  p_ccp_attribute16
      ,p_ccp_attribute17                =>  p_ccp_attribute17
      ,p_ccp_attribute18                =>  p_ccp_attribute18
      ,p_ccp_attribute19                =>  p_ccp_attribute19
      ,p_ccp_attribute20                =>  p_ccp_attribute20
      ,p_ccp_attribute21                =>  p_ccp_attribute21
      ,p_ccp_attribute22                =>  p_ccp_attribute22
      ,p_ccp_attribute23                =>  p_ccp_attribute23
      ,p_ccp_attribute24                =>  p_ccp_attribute24
      ,p_ccp_attribute25                =>  p_ccp_attribute25
      ,p_ccp_attribute26                =>  p_ccp_attribute26
      ,p_ccp_attribute27                =>  p_ccp_attribute27
      ,p_ccp_attribute28                =>  p_ccp_attribute28
      ,p_ccp_attribute29                =>  p_ccp_attribute29
      ,p_ccp_attribute30                =>  p_ccp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_CVRD_DPNT_CTFN_PRVDD
    --
  end;
  --
  ben_ccp_ins.ins
    (
     p_cvrd_dpnt_ctfn_prvdd_id       => l_cvrd_dpnt_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_dpnt_dsgn_ctfn_typ_cd         => p_dpnt_dsgn_ctfn_typ_cd
    ,p_dpnt_dsgn_ctfn_rqd_flag       => p_dpnt_dsgn_ctfn_rqd_flag
    ,p_dpnt_dsgn_ctfn_recd_dt        => p_dpnt_dsgn_ctfn_recd_dt
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_prtt_enrt_actn_id             => l_prtt_enrt_actn_id
    ,p_business_group_id             => p_business_group_id
    ,p_ccp_attribute_category        => p_ccp_attribute_category
    ,p_ccp_attribute1                => p_ccp_attribute1
    ,p_ccp_attribute2                => p_ccp_attribute2
    ,p_ccp_attribute3                => p_ccp_attribute3
    ,p_ccp_attribute4                => p_ccp_attribute4
    ,p_ccp_attribute5                => p_ccp_attribute5
    ,p_ccp_attribute6                => p_ccp_attribute6
    ,p_ccp_attribute7                => p_ccp_attribute7
    ,p_ccp_attribute8                => p_ccp_attribute8
    ,p_ccp_attribute9                => p_ccp_attribute9
    ,p_ccp_attribute10               => p_ccp_attribute10
    ,p_ccp_attribute11               => p_ccp_attribute11
    ,p_ccp_attribute12               => p_ccp_attribute12
    ,p_ccp_attribute13               => p_ccp_attribute13
    ,p_ccp_attribute14               => p_ccp_attribute14
    ,p_ccp_attribute15               => p_ccp_attribute15
    ,p_ccp_attribute16               => p_ccp_attribute16
    ,p_ccp_attribute17               => p_ccp_attribute17
    ,p_ccp_attribute18               => p_ccp_attribute18
    ,p_ccp_attribute19               => p_ccp_attribute19
    ,p_ccp_attribute20               => p_ccp_attribute20
    ,p_ccp_attribute21               => p_ccp_attribute21
    ,p_ccp_attribute22               => p_ccp_attribute22
    ,p_ccp_attribute23               => p_ccp_attribute23
    ,p_ccp_attribute24               => p_ccp_attribute24
    ,p_ccp_attribute25               => p_ccp_attribute25
    ,p_ccp_attribute26               => p_ccp_attribute26
    ,p_ccp_attribute27               => p_ccp_attribute27
    ,p_ccp_attribute28               => p_ccp_attribute28
    ,p_ccp_attribute29               => p_ccp_attribute29
    ,p_ccp_attribute30               => p_ccp_attribute30
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
    -- Start of API User Hook for the after hook of create_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk1.create_CVRD_DPNT_CTFN_PRVDD_a
      (
       p_cvrd_dpnt_ctfn_prvdd_id        =>  l_cvrd_dpnt_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_dpnt_dsgn_ctfn_typ_cd          =>  p_dpnt_dsgn_ctfn_typ_cd
      ,p_dpnt_dsgn_ctfn_rqd_flag        =>  p_dpnt_dsgn_ctfn_rqd_flag
      ,p_dpnt_dsgn_ctfn_recd_dt         =>  p_dpnt_dsgn_ctfn_recd_dt
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccp_attribute_category         =>  p_ccp_attribute_category
      ,p_ccp_attribute1                 =>  p_ccp_attribute1
      ,p_ccp_attribute2                 =>  p_ccp_attribute2
      ,p_ccp_attribute3                 =>  p_ccp_attribute3
      ,p_ccp_attribute4                 =>  p_ccp_attribute4
      ,p_ccp_attribute5                 =>  p_ccp_attribute5
      ,p_ccp_attribute6                 =>  p_ccp_attribute6
      ,p_ccp_attribute7                 =>  p_ccp_attribute7
      ,p_ccp_attribute8                 =>  p_ccp_attribute8
      ,p_ccp_attribute9                 =>  p_ccp_attribute9
      ,p_ccp_attribute10                =>  p_ccp_attribute10
      ,p_ccp_attribute11                =>  p_ccp_attribute11
      ,p_ccp_attribute12                =>  p_ccp_attribute12
      ,p_ccp_attribute13                =>  p_ccp_attribute13
      ,p_ccp_attribute14                =>  p_ccp_attribute14
      ,p_ccp_attribute15                =>  p_ccp_attribute15
      ,p_ccp_attribute16                =>  p_ccp_attribute16
      ,p_ccp_attribute17                =>  p_ccp_attribute17
      ,p_ccp_attribute18                =>  p_ccp_attribute18
      ,p_ccp_attribute19                =>  p_ccp_attribute19
      ,p_ccp_attribute20                =>  p_ccp_attribute20
      ,p_ccp_attribute21                =>  p_ccp_attribute21
      ,p_ccp_attribute22                =>  p_ccp_attribute22
      ,p_ccp_attribute23                =>  p_ccp_attribute23
      ,p_ccp_attribute24                =>  p_ccp_attribute24
      ,p_ccp_attribute25                =>  p_ccp_attribute25
      ,p_ccp_attribute26                =>  p_ccp_attribute26
      ,p_ccp_attribute27                =>  p_ccp_attribute27
      ,p_ccp_attribute28                =>  p_ccp_attribute28
      ,p_ccp_attribute29                =>  p_ccp_attribute29
      ,p_ccp_attribute30                =>  p_ccp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_CVRD_DPNT_CTFN_PRVDD
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
  p_cvrd_dpnt_ctfn_prvdd_id := l_cvrd_dpnt_ctfn_prvdd_id;
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
    ROLLBACK TO create_CVRD_DPNT_CTFN_PRVDD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cvrd_dpnt_ctfn_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_CVRD_DPNT_CTFN_PRVDD;
    raise;
    --
end create_CVRD_DPNT_CTFN_PRVDD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_CVRD_DPNT_CTFN_PRVDD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_CVRD_DPNT_CTFN_PRVDD
  (p_validate                       in  boolean   default false
  ,p_cvrd_dpnt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dpnt_dsgn_ctfn_typ_cd          in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_ctfn_rqd_flag        in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_ctfn_recd_dt         in  date      default hr_api.g_date
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_actn_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ccp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ccp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_CVRD_DPNT_CTFN_PRVDD';
  l_object_version_number ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
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
  savepoint update_CVRD_DPNT_CTFN_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk2.update_CVRD_DPNT_CTFN_PRVDD_b
      (
       p_cvrd_dpnt_ctfn_prvdd_id        =>  p_cvrd_dpnt_ctfn_prvdd_id
      ,p_dpnt_dsgn_ctfn_typ_cd          =>  p_dpnt_dsgn_ctfn_typ_cd
      ,p_dpnt_dsgn_ctfn_rqd_flag        =>  p_dpnt_dsgn_ctfn_rqd_flag
      ,p_dpnt_dsgn_ctfn_recd_dt         =>  p_dpnt_dsgn_ctfn_recd_dt
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccp_attribute_category         =>  p_ccp_attribute_category
      ,p_ccp_attribute1                 =>  p_ccp_attribute1
      ,p_ccp_attribute2                 =>  p_ccp_attribute2
      ,p_ccp_attribute3                 =>  p_ccp_attribute3
      ,p_ccp_attribute4                 =>  p_ccp_attribute4
      ,p_ccp_attribute5                 =>  p_ccp_attribute5
      ,p_ccp_attribute6                 =>  p_ccp_attribute6
      ,p_ccp_attribute7                 =>  p_ccp_attribute7
      ,p_ccp_attribute8                 =>  p_ccp_attribute8
      ,p_ccp_attribute9                 =>  p_ccp_attribute9
      ,p_ccp_attribute10                =>  p_ccp_attribute10
      ,p_ccp_attribute11                =>  p_ccp_attribute11
      ,p_ccp_attribute12                =>  p_ccp_attribute12
      ,p_ccp_attribute13                =>  p_ccp_attribute13
      ,p_ccp_attribute14                =>  p_ccp_attribute14
      ,p_ccp_attribute15                =>  p_ccp_attribute15
      ,p_ccp_attribute16                =>  p_ccp_attribute16
      ,p_ccp_attribute17                =>  p_ccp_attribute17
      ,p_ccp_attribute18                =>  p_ccp_attribute18
      ,p_ccp_attribute19                =>  p_ccp_attribute19
      ,p_ccp_attribute20                =>  p_ccp_attribute20
      ,p_ccp_attribute21                =>  p_ccp_attribute21
      ,p_ccp_attribute22                =>  p_ccp_attribute22
      ,p_ccp_attribute23                =>  p_ccp_attribute23
      ,p_ccp_attribute24                =>  p_ccp_attribute24
      ,p_ccp_attribute25                =>  p_ccp_attribute25
      ,p_ccp_attribute26                =>  p_ccp_attribute26
      ,p_ccp_attribute27                =>  p_ccp_attribute27
      ,p_ccp_attribute28                =>  p_ccp_attribute28
      ,p_ccp_attribute29                =>  p_ccp_attribute29
      ,p_ccp_attribute30                =>  p_ccp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_CVRD_DPNT_CTFN_PRVDD
    --
  end;
  --
  ben_ccp_upd.upd
    (
     p_cvrd_dpnt_ctfn_prvdd_id       => p_cvrd_dpnt_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_dpnt_dsgn_ctfn_typ_cd         => p_dpnt_dsgn_ctfn_typ_cd
    ,p_dpnt_dsgn_ctfn_rqd_flag       => p_dpnt_dsgn_ctfn_rqd_flag
    ,p_dpnt_dsgn_ctfn_recd_dt        => p_dpnt_dsgn_ctfn_recd_dt
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_business_group_id             => p_business_group_id
    ,p_ccp_attribute_category        => p_ccp_attribute_category
    ,p_ccp_attribute1                => p_ccp_attribute1
    ,p_ccp_attribute2                => p_ccp_attribute2
    ,p_ccp_attribute3                => p_ccp_attribute3
    ,p_ccp_attribute4                => p_ccp_attribute4
    ,p_ccp_attribute5                => p_ccp_attribute5
    ,p_ccp_attribute6                => p_ccp_attribute6
    ,p_ccp_attribute7                => p_ccp_attribute7
    ,p_ccp_attribute8                => p_ccp_attribute8
    ,p_ccp_attribute9                => p_ccp_attribute9
    ,p_ccp_attribute10               => p_ccp_attribute10
    ,p_ccp_attribute11               => p_ccp_attribute11
    ,p_ccp_attribute12               => p_ccp_attribute12
    ,p_ccp_attribute13               => p_ccp_attribute13
    ,p_ccp_attribute14               => p_ccp_attribute14
    ,p_ccp_attribute15               => p_ccp_attribute15
    ,p_ccp_attribute16               => p_ccp_attribute16
    ,p_ccp_attribute17               => p_ccp_attribute17
    ,p_ccp_attribute18               => p_ccp_attribute18
    ,p_ccp_attribute19               => p_ccp_attribute19
    ,p_ccp_attribute20               => p_ccp_attribute20
    ,p_ccp_attribute21               => p_ccp_attribute21
    ,p_ccp_attribute22               => p_ccp_attribute22
    ,p_ccp_attribute23               => p_ccp_attribute23
    ,p_ccp_attribute24               => p_ccp_attribute24
    ,p_ccp_attribute25               => p_ccp_attribute25
    ,p_ccp_attribute26               => p_ccp_attribute26
    ,p_ccp_attribute27               => p_ccp_attribute27
    ,p_ccp_attribute28               => p_ccp_attribute28
    ,p_ccp_attribute29               => p_ccp_attribute29
    ,p_ccp_attribute30               => p_ccp_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  -- call procedure to close actn items here
  --
  check_dpnt_ctfn
        (p_prtt_enrt_actn_id         => p_prtt_enrt_actn_id,
         p_datetrack_mode            => p_datetrack_mode,
         p_business_group_id         => p_business_group_id,
         p_effective_date            => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk2.update_CVRD_DPNT_CTFN_PRVDD_a
      (
       p_cvrd_dpnt_ctfn_prvdd_id        =>  p_cvrd_dpnt_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_dpnt_dsgn_ctfn_typ_cd          =>  p_dpnt_dsgn_ctfn_typ_cd
      ,p_dpnt_dsgn_ctfn_rqd_flag        =>  p_dpnt_dsgn_ctfn_rqd_flag
      ,p_dpnt_dsgn_ctfn_recd_dt         =>  p_dpnt_dsgn_ctfn_recd_dt
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccp_attribute_category         =>  p_ccp_attribute_category
      ,p_ccp_attribute1                 =>  p_ccp_attribute1
      ,p_ccp_attribute2                 =>  p_ccp_attribute2
      ,p_ccp_attribute3                 =>  p_ccp_attribute3
      ,p_ccp_attribute4                 =>  p_ccp_attribute4
      ,p_ccp_attribute5                 =>  p_ccp_attribute5
      ,p_ccp_attribute6                 =>  p_ccp_attribute6
      ,p_ccp_attribute7                 =>  p_ccp_attribute7
      ,p_ccp_attribute8                 =>  p_ccp_attribute8
      ,p_ccp_attribute9                 =>  p_ccp_attribute9
      ,p_ccp_attribute10                =>  p_ccp_attribute10
      ,p_ccp_attribute11                =>  p_ccp_attribute11
      ,p_ccp_attribute12                =>  p_ccp_attribute12
      ,p_ccp_attribute13                =>  p_ccp_attribute13
      ,p_ccp_attribute14                =>  p_ccp_attribute14
      ,p_ccp_attribute15                =>  p_ccp_attribute15
      ,p_ccp_attribute16                =>  p_ccp_attribute16
      ,p_ccp_attribute17                =>  p_ccp_attribute17
      ,p_ccp_attribute18                =>  p_ccp_attribute18
      ,p_ccp_attribute19                =>  p_ccp_attribute19
      ,p_ccp_attribute20                =>  p_ccp_attribute20
      ,p_ccp_attribute21                =>  p_ccp_attribute21
      ,p_ccp_attribute22                =>  p_ccp_attribute22
      ,p_ccp_attribute23                =>  p_ccp_attribute23
      ,p_ccp_attribute24                =>  p_ccp_attribute24
      ,p_ccp_attribute25                =>  p_ccp_attribute25
      ,p_ccp_attribute26                =>  p_ccp_attribute26
      ,p_ccp_attribute27                =>  p_ccp_attribute27
      ,p_ccp_attribute28                =>  p_ccp_attribute28
      ,p_ccp_attribute29                =>  p_ccp_attribute29
      ,p_ccp_attribute30                =>  p_ccp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_CVRD_DPNT_CTFN_PRVDD
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
    ROLLBACK TO update_CVRD_DPNT_CTFN_PRVDD;
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
    ROLLBACK TO update_CVRD_DPNT_CTFN_PRVDD;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_CVRD_DPNT_CTFN_PRVDD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CVRD_DPNT_CTFN_PRVDD >----------------------|
-- ----------------------------------------------------------------------------
-- !!! THIS IS OVERLOADED. ANY CHANGES MADE HERE NEED TO BE ADDED THERE ALSO !!!
procedure delete_CVRD_DPNT_CTFN_PRVDD
  (p_validate                       in  boolean  default false
  ,p_cvrd_dpnt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_check_actions                  in varchar2 default 'Y'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_CVRD_DPNT_CTFN_PRVDD';
  l_object_version_number ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
  --
  l_prtt_enrt_actn_id    number(15) := null;
  l_prtt_enrt_rslt_id    number(15);
  l_rslt_object_version_number number(15);
  l_exist                varchar2(1) := 'N';
  l1_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l1_effective_start_date  ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l1_effective_end_date    ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  --
  cursor get_actn_c is
      select prtt_enrt_actn_id
        from ben_cvrd_dpnt_ctfn_prvdd_f
      where cvrd_dpnt_ctfn_prvdd_id = p_cvrd_dpnt_ctfn_prvdd_id
        and business_group_id  = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
  --
  cursor more_ctfn_c is
     select 'Y'
       from ben_cvrd_dpnt_ctfn_prvdd_f
     where prtt_enrt_actn_id = l_prtt_enrt_actn_id
       and business_group_id  = p_business_group_id
       and p_effective_date + 1 between effective_start_date
                                   and effective_end_date;
  --
  cursor actn_info_c is
     select pea.object_version_number,
            pea.prtt_enrt_rslt_id,
            pen.object_version_number
       from ben_prtt_enrt_actn_f pea,
            ben_prtt_enrt_rslt_f pen
     where pea.prtt_enrt_actn_id = l_prtt_enrt_actn_id
       and pea.business_group_id = p_business_group_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and p_effective_date between pea.effective_start_date
                                and pea.effective_end_date
       and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
       and p_effective_date between
           pen.effective_start_date and pen.effective_end_date;
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
  savepoint delete_CVRD_DPNT_CTFN_PRVDD;
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
    -- Start of API User Hook for the before hook of delete_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk3.delete_CVRD_DPNT_CTFN_PRVDD_b
      (
       p_cvrd_dpnt_ctfn_prvdd_id        =>  p_cvrd_dpnt_ctfn_prvdd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_CVRD_DPNT_CTFN_PRVDD
    --
  end;
  --
  -- Get action item id
  --
  open get_actn_c;
  fetch get_actn_c into l_prtt_enrt_actn_id;
  close get_actn_c;
  --
  ben_ccp_del.del
    (
     p_cvrd_dpnt_ctfn_prvdd_id       => p_cvrd_dpnt_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  -- If there are no remaining certifications,
  -- delete corresponding action item.
  --
  if p_check_actions = 'Y' then
    --
    open  more_ctfn_c;
    fetch more_ctfn_c into l_exist;
    close more_ctfn_c;
    --
    if l_exist = 'N' then
      --
      open actn_info_c;
      fetch actn_info_c into l1_object_version_number,
                             l_prtt_enrt_rslt_id,
                             l_rslt_object_version_number;
      if actn_info_c%FOUND then
        --
        ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
          (p_validate              => FALSE,
           p_effective_date        => p_effective_date,
           p_business_group_id     => p_business_group_id,
           p_datetrack_mode        => p_datetrack_mode,
           p_object_version_number => l1_object_version_number,
           p_prtt_enrt_rslt_id     => l_prtt_enrt_rslt_id,
           p_rslt_object_version_number => l_rslt_object_version_number,
           p_post_rslt_flag        => 'N',
           p_unsuspend_enrt_flag   => 'Y',
           p_effective_start_date  => l1_effective_start_date,
           p_effective_end_date    => l1_effective_end_date,
           p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
         );
        --
      end if;
      --
      close actn_info_c;
      --
    else
      --
      -- Other Ctfn exist. Check whether action item can be closed.
      --
      check_dpnt_ctfn
        (p_prtt_enrt_actn_id         => l_prtt_enrt_actn_id,
         p_datetrack_mode            => p_datetrack_mode,
         p_business_group_id         => p_business_group_id,
         p_effective_date            => p_effective_date);
      --
    end if; -- l_exist
    --
  end if; -- check_actions
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk3.delete_CVRD_DPNT_CTFN_PRVDD_a
      (
       p_cvrd_dpnt_ctfn_prvdd_id        =>  p_cvrd_dpnt_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_CVRD_DPNT_CTFN_PRVDD
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
    ROLLBACK TO delete_CVRD_DPNT_CTFN_PRVDD;
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
    ROLLBACK TO delete_CVRD_DPNT_CTFN_PRVDD;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_CVRD_DPNT_CTFN_PRVDD;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_CVRD_DPNT_CTFN_PRVDD >----------------------|
-- |!!!!  OVERLOADED PROCEDURE - CHANGES NEED TO BE MADE IN THE OTHER ONE ALSO !!!  |
-- ----------------------------------------------------------------------------
--
procedure delete_CVRD_DPNT_CTFN_PRVDD
  (p_validate                       in  boolean  default false
  ,p_cvrd_dpnt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_check_actions                  in  varchar2 default 'Y'
  ,p_called_from                    in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_CVRD_DPNT_CTFN_PRVDD';
  l_object_version_number ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
  --
  l_prtt_enrt_actn_id    number(15) := null;
  l_prtt_enrt_rslt_id    number(15);
  l_rslt_object_version_number number(15);
  l_exist                varchar2(1) := 'N';
  l1_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l1_effective_start_date  ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l1_effective_end_date    ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  --
  cursor get_actn_c is
      select prtt_enrt_actn_id
        from ben_cvrd_dpnt_ctfn_prvdd_f
      where cvrd_dpnt_ctfn_prvdd_id = p_cvrd_dpnt_ctfn_prvdd_id
        and business_group_id  = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
  --
  cursor more_ctfn_c is
     select 'Y'
       from ben_cvrd_dpnt_ctfn_prvdd_f
     where prtt_enrt_actn_id = l_prtt_enrt_actn_id
       and business_group_id  = p_business_group_id
       and p_effective_date + 1 between effective_start_date
                                   and effective_end_date;
  --
  cursor actn_info_c is
     select pea.object_version_number,
            pea.prtt_enrt_rslt_id,
            pen.object_version_number
       from ben_prtt_enrt_actn_f pea,
            ben_prtt_enrt_rslt_f pen
     where pea.prtt_enrt_actn_id = l_prtt_enrt_actn_id
       and pea.business_group_id = p_business_group_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and p_effective_date between pea.effective_start_date
                                and pea.effective_end_date
       and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
       and p_effective_date between
           pen.effective_start_date and pen.effective_end_date;
  --
  l_unsuspend_enrt_flag        varchar2(30) := 'Y' ;
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
  savepoint delete_CVRD_DPNT_CTFN_PRVDD;
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
    -- Start of API User Hook for the before hook of delete_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk3.delete_CVRD_DPNT_CTFN_PRVDD_b
      (
       p_cvrd_dpnt_ctfn_prvdd_id        =>  p_cvrd_dpnt_ctfn_prvdd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_CVRD_DPNT_CTFN_PRVDD
    --
  end;
  --
  -- Get action item id
  --
  open get_actn_c;
  fetch get_actn_c into l_prtt_enrt_actn_id;
  close get_actn_c;
  --
  ben_ccp_del.del
    (
     p_cvrd_dpnt_ctfn_prvdd_id       => p_cvrd_dpnt_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  -- If there are no remaining certifications,
  -- delete corresponding action item.
  --
  if p_check_actions = 'Y' then
    --
    open  more_ctfn_c;
    fetch more_ctfn_c into l_exist;
    close more_ctfn_c;
    --
    if l_exist = 'N' then
      --
      open actn_info_c;
      fetch actn_info_c into l1_object_version_number,
                             l_prtt_enrt_rslt_id,
                             l_rslt_object_version_number;
      if actn_info_c%FOUND then
        --
        if p_called_from = 'benuneai' then
          l_unsuspend_enrt_flag := 'N' ;
        end if;
        --
        ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
          (p_validate              => FALSE,
           p_effective_date        => p_effective_date,
           p_business_group_id     => p_business_group_id,
           p_datetrack_mode        => p_datetrack_mode,
           p_object_version_number => l1_object_version_number,
           p_prtt_enrt_rslt_id     => l_prtt_enrt_rslt_id,
           p_rslt_object_version_number => l_rslt_object_version_number,
           p_post_rslt_flag        => 'N',
           p_unsuspend_enrt_flag   => l_unsuspend_enrt_flag,
           p_effective_start_date  => l1_effective_start_date,
           p_effective_end_date    => l1_effective_end_date,
           p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
         );
        --
      end if;
      --
      close actn_info_c;
      --
    else
      --
      -- Other Ctfn exist. Check whether action item can be closed.
      --
      check_dpnt_ctfn
        (p_prtt_enrt_actn_id         => l_prtt_enrt_actn_id,
         p_datetrack_mode            => p_datetrack_mode,
         p_business_group_id         => p_business_group_id,
         p_effective_date            => p_effective_date);
      --
    end if; -- l_exist
    --
  end if; -- check_actions
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_CVRD_DPNT_CTFN_PRVDD
    --
    ben_CVRD_DPNT_CTFN_PRVDD_bk3.delete_CVRD_DPNT_CTFN_PRVDD_a
      (
       p_cvrd_dpnt_ctfn_prvdd_id        =>  p_cvrd_dpnt_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CVRD_DPNT_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_CVRD_DPNT_CTFN_PRVDD
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
    ROLLBACK TO delete_CVRD_DPNT_CTFN_PRVDD;
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
    ROLLBACK TO delete_CVRD_DPNT_CTFN_PRVDD;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_CVRD_DPNT_CTFN_PRVDD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cvrd_dpnt_ctfn_prvdd_id                   in     number
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
  ben_ccp_shd.lck
    (
      p_cvrd_dpnt_ctfn_prvdd_id                 => p_cvrd_dpnt_ctfn_prvdd_id
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
end ben_CVRD_DPNT_CTFN_PRVDD_api;

/
