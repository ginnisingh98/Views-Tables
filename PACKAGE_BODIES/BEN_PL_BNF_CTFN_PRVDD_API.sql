--------------------------------------------------------
--  DDL for Package Body BEN_PL_BNF_CTFN_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PL_BNF_CTFN_PRVDD_API" as
/* $Header: bepbcapi.pkb 120.1.12010000.2 2008/08/05 15:03:15 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PL_BNF_CTFN_PRVDD_api.';
--
procedure check_bnf_ctfn
       (p_prtt_enrt_actn_id      in number,
        p_datetrack_mode         in varchar2,
        p_business_group_id      in number,
        p_effective_date         in date) is
  --
  l_all_prvdd boolean := FALSE;
  --
  cursor bnf_c is
  select pen.prtt_enrt_rslt_id,
         plb.bnf_person_id,
	 plb.organization_id,                   -- Bug 5156111
         plb.pl_bnf_id,
         pea.prtt_enrt_actn_id,
         pea.actn_typ_id,
         pea.cmpltd_dt,
         pen.object_version_number rslt_ovn,
         pea.object_version_number
    from ben_prtt_enrt_rslt_f pen,
         ben_prtt_enrt_actn_f pea,
         ben_pl_bnf_f plb
   where pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and pea.pl_bnf_id         = plb.pl_bnf_id
     and plb.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and pea.business_group_id  = p_business_group_id
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
     and plb.business_group_id  = p_business_group_id
     and p_effective_date between plb.effective_start_date
                              and plb.effective_end_date
     and pen.business_group_id  = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date;
  --
  l_bnf      bnf_c%rowtype;
  --
  l_proc       varchar2(80) := g_package||'check_bnf_ctfn';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  open bnf_c;
  fetch bnf_c into l_bnf;
  close bnf_c;
  --
  if l_bnf.prtt_enrt_rslt_id is not null and
     (l_bnf.bnf_person_id is not null or l_bnf.organization_id is not null) then   -- Bug 5156111
    --
    --
    l_all_prvdd := ben_enrollment_action_items.check_bnf_ctfn
                       (p_prtt_enrt_actn_id => l_bnf.prtt_enrt_actn_id
                       ,p_pl_bnf_id         => l_bnf.pl_bnf_id
                       ,p_effective_date    => p_effective_date);
    --
    ben_enrollment_action_items.process_action_item
          (p_prtt_enrt_actn_id         => l_bnf.prtt_enrt_actn_id
          ,p_actn_typ_id               => l_bnf.actn_typ_id
          ,p_cmpltd_dt                 => l_bnf.cmpltd_dt
          ,p_object_version_number     => l_bnf.object_version_number
          ,p_effective_date            => p_effective_date
          ,p_rqd_data_found            => l_all_prvdd
          ,p_prtt_enrt_rslt_id         => l_bnf.prtt_enrt_rslt_id
          ,p_pl_bnf_id                 => l_bnf.pl_bnf_id
          ,p_rqd_flag                  => 'Y'
          ,p_post_rslt_flag            => 'N'
          ,p_business_group_id         => p_business_group_id
          ,p_datetrack_mode            => p_datetrack_mode
          ,p_rslt_object_version_number=> l_bnf.rslt_ovn);
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
  --
end check_bnf_ctfn;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PL_BNF_CTFN_PRVDD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PL_BNF_CTFN_PRVDD
  (p_validate                       in  boolean   default false
  ,p_pl_bnf_ctfn_prvdd_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_bnf_ctfn_typ_cd                in  varchar2  default null
  ,p_bnf_ctfn_recd_dt               in  date      default null
  ,p_bnf_ctfn_rqd_flag              in  varchar2  default 'N'
  ,p_pl_bnf_id                      in  number    default null
  ,p_prtt_enrt_actn_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pbc_attribute_category         in  varchar2  default null
  ,p_pbc_attribute1                 in  varchar2  default null
  ,p_pbc_attribute2                 in  varchar2  default null
  ,p_pbc_attribute3                 in  varchar2  default null
  ,p_pbc_attribute4                 in  varchar2  default null
  ,p_pbc_attribute5                 in  varchar2  default null
  ,p_pbc_attribute6                 in  varchar2  default null
  ,p_pbc_attribute7                 in  varchar2  default null
  ,p_pbc_attribute8                 in  varchar2  default null
  ,p_pbc_attribute9                 in  varchar2  default null
  ,p_pbc_attribute10                in  varchar2  default null
  ,p_pbc_attribute11                in  varchar2  default null
  ,p_pbc_attribute12                in  varchar2  default null
  ,p_pbc_attribute13                in  varchar2  default null
  ,p_pbc_attribute14                in  varchar2  default null
  ,p_pbc_attribute15                in  varchar2  default null
  ,p_pbc_attribute16                in  varchar2  default null
  ,p_pbc_attribute17                in  varchar2  default null
  ,p_pbc_attribute18                in  varchar2  default null
  ,p_pbc_attribute19                in  varchar2  default null
  ,p_pbc_attribute20                in  varchar2  default null
  ,p_pbc_attribute21                in  varchar2  default null
  ,p_pbc_attribute22                in  varchar2  default null
  ,p_pbc_attribute23                in  varchar2  default null
  ,p_pbc_attribute24                in  varchar2  default null
  ,p_pbc_attribute25                in  varchar2  default null
  ,p_pbc_attribute26                in  varchar2  default null
  ,p_pbc_attribute27                in  varchar2  default null
  ,p_pbc_attribute28                in  varchar2  default null
  ,p_pbc_attribute29                in  varchar2  default null
  ,p_pbc_attribute30                in  varchar2  default null
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
  l_pl_bnf_ctfn_prvdd_id ben_pl_bnf_ctfn_prvdd_f.pl_bnf_ctfn_prvdd_id%TYPE;
  l_effective_start_date ben_pl_bnf_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_bnf_ctfn_prvdd_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PL_BNF_CTFN_PRVDD';
  l_object_version_number ben_pl_bnf_ctfn_prvdd_f.object_version_number%TYPE;
  l_prtt_enrt_actn_id  ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type;
  l_prtt_enrt_rslt_id  ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%type;
  l_actn_typ_cd        varchar2(30);
  --
  cursor c_pbn is
     select pbn.prtt_enrt_rslt_id
     from   ben_pl_bnf_f pbn
     where  pbn.pl_bnf_id = p_pl_bnf_id
     and    pbn.business_group_id = p_business_group_id
     and    p_effective_date between
            pbn.effective_start_date and pbn.effective_end_date;
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
  savepoint create_PL_BNF_CTFN_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if p_prtt_enrt_actn_id is null then
     --
     open  c_pbn;
     fetch c_pbn into l_prtt_enrt_rslt_id;
     close c_pbn;
     --
     if p_bnf_ctfn_typ_cd = 'NSC' then
        --
        l_actn_typ_cd := 'BNFSCCTFN';
        --
     else
        --
        l_actn_typ_cd := 'BNFCTFN';
        --
     end if;
     --
     ben_enrollment_action_items.process_new_ctfn_action
          (p_prtt_enrt_rslt_id   => l_prtt_enrt_rslt_id
          ,p_pl_bnf_id           => p_pl_bnf_id
          ,p_actn_typ_cd         => l_actn_typ_cd
          ,p_ctfn_rqd_flag       => p_bnf_ctfn_rqd_flag
          ,p_ctfn_recd_dt        => p_bnf_ctfn_recd_dt
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
    -- Start of API User Hook for the before hook of create_PL_BNF_CTFN_PRVDD
    --
    ben_PL_BNF_CTFN_PRVDD_bk1.create_PL_BNF_CTFN_PRVDD_b
      (
       p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_bnf_ctfn_recd_dt               =>  p_bnf_ctfn_recd_dt
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbc_attribute_category         =>  p_pbc_attribute_category
      ,p_pbc_attribute1                 =>  p_pbc_attribute1
      ,p_pbc_attribute2                 =>  p_pbc_attribute2
      ,p_pbc_attribute3                 =>  p_pbc_attribute3
      ,p_pbc_attribute4                 =>  p_pbc_attribute4
      ,p_pbc_attribute5                 =>  p_pbc_attribute5
      ,p_pbc_attribute6                 =>  p_pbc_attribute6
      ,p_pbc_attribute7                 =>  p_pbc_attribute7
      ,p_pbc_attribute8                 =>  p_pbc_attribute8
      ,p_pbc_attribute9                 =>  p_pbc_attribute9
      ,p_pbc_attribute10                =>  p_pbc_attribute10
      ,p_pbc_attribute11                =>  p_pbc_attribute11
      ,p_pbc_attribute12                =>  p_pbc_attribute12
      ,p_pbc_attribute13                =>  p_pbc_attribute13
      ,p_pbc_attribute14                =>  p_pbc_attribute14
      ,p_pbc_attribute15                =>  p_pbc_attribute15
      ,p_pbc_attribute16                =>  p_pbc_attribute16
      ,p_pbc_attribute17                =>  p_pbc_attribute17
      ,p_pbc_attribute18                =>  p_pbc_attribute18
      ,p_pbc_attribute19                =>  p_pbc_attribute19
      ,p_pbc_attribute20                =>  p_pbc_attribute20
      ,p_pbc_attribute21                =>  p_pbc_attribute21
      ,p_pbc_attribute22                =>  p_pbc_attribute22
      ,p_pbc_attribute23                =>  p_pbc_attribute23
      ,p_pbc_attribute24                =>  p_pbc_attribute24
      ,p_pbc_attribute25                =>  p_pbc_attribute25
      ,p_pbc_attribute26                =>  p_pbc_attribute26
      ,p_pbc_attribute27                =>  p_pbc_attribute27
      ,p_pbc_attribute28                =>  p_pbc_attribute28
      ,p_pbc_attribute29                =>  p_pbc_attribute29
      ,p_pbc_attribute30                =>  p_pbc_attribute30
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
         p_module_name => 'CREATE_PL_BNF_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PL_BNF_CTFN_PRVDD
    --
  end;
  --
  ben_pbc_ins.ins
    (
     p_pl_bnf_ctfn_prvdd_id          => l_pl_bnf_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_bnf_ctfn_typ_cd               => p_bnf_ctfn_typ_cd
    ,p_bnf_ctfn_recd_dt              => p_bnf_ctfn_recd_dt
    ,p_bnf_ctfn_rqd_flag             => p_bnf_ctfn_rqd_flag
    ,p_pl_bnf_id                     => p_pl_bnf_id
    ,p_prtt_enrt_actn_id             => l_prtt_enrt_actn_id
    ,p_business_group_id             => p_business_group_id
    ,p_pbc_attribute_category        => p_pbc_attribute_category
    ,p_pbc_attribute1                => p_pbc_attribute1
    ,p_pbc_attribute2                => p_pbc_attribute2
    ,p_pbc_attribute3                => p_pbc_attribute3
    ,p_pbc_attribute4                => p_pbc_attribute4
    ,p_pbc_attribute5                => p_pbc_attribute5
    ,p_pbc_attribute6                => p_pbc_attribute6
    ,p_pbc_attribute7                => p_pbc_attribute7
    ,p_pbc_attribute8                => p_pbc_attribute8
    ,p_pbc_attribute9                => p_pbc_attribute9
    ,p_pbc_attribute10               => p_pbc_attribute10
    ,p_pbc_attribute11               => p_pbc_attribute11
    ,p_pbc_attribute12               => p_pbc_attribute12
    ,p_pbc_attribute13               => p_pbc_attribute13
    ,p_pbc_attribute14               => p_pbc_attribute14
    ,p_pbc_attribute15               => p_pbc_attribute15
    ,p_pbc_attribute16               => p_pbc_attribute16
    ,p_pbc_attribute17               => p_pbc_attribute17
    ,p_pbc_attribute18               => p_pbc_attribute18
    ,p_pbc_attribute19               => p_pbc_attribute19
    ,p_pbc_attribute20               => p_pbc_attribute20
    ,p_pbc_attribute21               => p_pbc_attribute21
    ,p_pbc_attribute22               => p_pbc_attribute22
    ,p_pbc_attribute23               => p_pbc_attribute23
    ,p_pbc_attribute24               => p_pbc_attribute24
    ,p_pbc_attribute25               => p_pbc_attribute25
    ,p_pbc_attribute26               => p_pbc_attribute26
    ,p_pbc_attribute27               => p_pbc_attribute27
    ,p_pbc_attribute28               => p_pbc_attribute28
    ,p_pbc_attribute29               => p_pbc_attribute29
    ,p_pbc_attribute30               => p_pbc_attribute30
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
    -- Start of API User Hook for the after hook of create_PL_BNF_CTFN_PRVDD
    --
    ben_PL_BNF_CTFN_PRVDD_bk1.create_PL_BNF_CTFN_PRVDD_a
      (
       p_pl_bnf_ctfn_prvdd_id           =>  l_pl_bnf_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_bnf_ctfn_recd_dt               =>  p_bnf_ctfn_recd_dt
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbc_attribute_category         =>  p_pbc_attribute_category
      ,p_pbc_attribute1                 =>  p_pbc_attribute1
      ,p_pbc_attribute2                 =>  p_pbc_attribute2
      ,p_pbc_attribute3                 =>  p_pbc_attribute3
      ,p_pbc_attribute4                 =>  p_pbc_attribute4
      ,p_pbc_attribute5                 =>  p_pbc_attribute5
      ,p_pbc_attribute6                 =>  p_pbc_attribute6
      ,p_pbc_attribute7                 =>  p_pbc_attribute7
      ,p_pbc_attribute8                 =>  p_pbc_attribute8
      ,p_pbc_attribute9                 =>  p_pbc_attribute9
      ,p_pbc_attribute10                =>  p_pbc_attribute10
      ,p_pbc_attribute11                =>  p_pbc_attribute11
      ,p_pbc_attribute12                =>  p_pbc_attribute12
      ,p_pbc_attribute13                =>  p_pbc_attribute13
      ,p_pbc_attribute14                =>  p_pbc_attribute14
      ,p_pbc_attribute15                =>  p_pbc_attribute15
      ,p_pbc_attribute16                =>  p_pbc_attribute16
      ,p_pbc_attribute17                =>  p_pbc_attribute17
      ,p_pbc_attribute18                =>  p_pbc_attribute18
      ,p_pbc_attribute19                =>  p_pbc_attribute19
      ,p_pbc_attribute20                =>  p_pbc_attribute20
      ,p_pbc_attribute21                =>  p_pbc_attribute21
      ,p_pbc_attribute22                =>  p_pbc_attribute22
      ,p_pbc_attribute23                =>  p_pbc_attribute23
      ,p_pbc_attribute24                =>  p_pbc_attribute24
      ,p_pbc_attribute25                =>  p_pbc_attribute25
      ,p_pbc_attribute26                =>  p_pbc_attribute26
      ,p_pbc_attribute27                =>  p_pbc_attribute27
      ,p_pbc_attribute28                =>  p_pbc_attribute28
      ,p_pbc_attribute29                =>  p_pbc_attribute29
      ,p_pbc_attribute30                =>  p_pbc_attribute30
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
        (p_module_name => 'CREATE_PL_BNF_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PL_BNF_CTFN_PRVDD
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
  p_pl_bnf_ctfn_prvdd_id := l_pl_bnf_ctfn_prvdd_id;
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
    ROLLBACK TO create_PL_BNF_CTFN_PRVDD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_bnf_ctfn_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PL_BNF_CTFN_PRVDD;
    p_pl_bnf_ctfn_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_PL_BNF_CTFN_PRVDD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PL_BNF_CTFN_PRVDD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PL_BNF_CTFN_PRVDD
  (p_validate                       in  boolean   default false
  ,p_pl_bnf_ctfn_prvdd_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_bnf_ctfn_typ_cd                in  varchar2  default hr_api.g_varchar2
  ,p_bnf_ctfn_recd_dt               in  date      default hr_api.g_date
  ,p_bnf_ctfn_rqd_flag              in  varchar2  default hr_api.g_varchar2
  ,p_pl_bnf_id                      in  number    default hr_api.g_number
  ,p_prtt_enrt_actn_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pbc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pbc_attribute30                in  varchar2  default hr_api.g_varchar2
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
  l_proc varchar2(72) := g_package||'update_PL_BNF_CTFN_PRVDD';
  l_object_version_number ben_pl_bnf_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_bnf_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_bnf_ctfn_prvdd_f.effective_end_date%TYPE;
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
  savepoint update_PL_BNF_CTFN_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PL_BNF_CTFN_PRVDD
    --
    ben_PL_BNF_CTFN_PRVDD_bk2.update_PL_BNF_CTFN_PRVDD_b
      (
       p_pl_bnf_ctfn_prvdd_id           =>  p_pl_bnf_ctfn_prvdd_id
      ,p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_bnf_ctfn_recd_dt               =>  p_bnf_ctfn_recd_dt
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbc_attribute_category         =>  p_pbc_attribute_category
      ,p_pbc_attribute1                 =>  p_pbc_attribute1
      ,p_pbc_attribute2                 =>  p_pbc_attribute2
      ,p_pbc_attribute3                 =>  p_pbc_attribute3
      ,p_pbc_attribute4                 =>  p_pbc_attribute4
      ,p_pbc_attribute5                 =>  p_pbc_attribute5
      ,p_pbc_attribute6                 =>  p_pbc_attribute6
      ,p_pbc_attribute7                 =>  p_pbc_attribute7
      ,p_pbc_attribute8                 =>  p_pbc_attribute8
      ,p_pbc_attribute9                 =>  p_pbc_attribute9
      ,p_pbc_attribute10                =>  p_pbc_attribute10
      ,p_pbc_attribute11                =>  p_pbc_attribute11
      ,p_pbc_attribute12                =>  p_pbc_attribute12
      ,p_pbc_attribute13                =>  p_pbc_attribute13
      ,p_pbc_attribute14                =>  p_pbc_attribute14
      ,p_pbc_attribute15                =>  p_pbc_attribute15
      ,p_pbc_attribute16                =>  p_pbc_attribute16
      ,p_pbc_attribute17                =>  p_pbc_attribute17
      ,p_pbc_attribute18                =>  p_pbc_attribute18
      ,p_pbc_attribute19                =>  p_pbc_attribute19
      ,p_pbc_attribute20                =>  p_pbc_attribute20
      ,p_pbc_attribute21                =>  p_pbc_attribute21
      ,p_pbc_attribute22                =>  p_pbc_attribute22
      ,p_pbc_attribute23                =>  p_pbc_attribute23
      ,p_pbc_attribute24                =>  p_pbc_attribute24
      ,p_pbc_attribute25                =>  p_pbc_attribute25
      ,p_pbc_attribute26                =>  p_pbc_attribute26
      ,p_pbc_attribute27                =>  p_pbc_attribute27
      ,p_pbc_attribute28                =>  p_pbc_attribute28
      ,p_pbc_attribute29                =>  p_pbc_attribute29
      ,p_pbc_attribute30                =>  p_pbc_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PL_BNF_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PL_BNF_CTFN_PRVDD
    --
  end;
  --
  ben_pbc_upd.upd
    (
     p_pl_bnf_ctfn_prvdd_id          => p_pl_bnf_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_bnf_ctfn_typ_cd               => p_bnf_ctfn_typ_cd
    ,p_bnf_ctfn_recd_dt              => p_bnf_ctfn_recd_dt
    ,p_bnf_ctfn_rqd_flag             => p_bnf_ctfn_rqd_flag
    ,p_pl_bnf_id                     => p_pl_bnf_id
    ,p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_business_group_id             => p_business_group_id
    ,p_pbc_attribute_category        => p_pbc_attribute_category
    ,p_pbc_attribute1                => p_pbc_attribute1
    ,p_pbc_attribute2                => p_pbc_attribute2
    ,p_pbc_attribute3                => p_pbc_attribute3
    ,p_pbc_attribute4                => p_pbc_attribute4
    ,p_pbc_attribute5                => p_pbc_attribute5
    ,p_pbc_attribute6                => p_pbc_attribute6
    ,p_pbc_attribute7                => p_pbc_attribute7
    ,p_pbc_attribute8                => p_pbc_attribute8
    ,p_pbc_attribute9                => p_pbc_attribute9
    ,p_pbc_attribute10               => p_pbc_attribute10
    ,p_pbc_attribute11               => p_pbc_attribute11
    ,p_pbc_attribute12               => p_pbc_attribute12
    ,p_pbc_attribute13               => p_pbc_attribute13
    ,p_pbc_attribute14               => p_pbc_attribute14
    ,p_pbc_attribute15               => p_pbc_attribute15
    ,p_pbc_attribute16               => p_pbc_attribute16
    ,p_pbc_attribute17               => p_pbc_attribute17
    ,p_pbc_attribute18               => p_pbc_attribute18
    ,p_pbc_attribute19               => p_pbc_attribute19
    ,p_pbc_attribute20               => p_pbc_attribute20
    ,p_pbc_attribute21               => p_pbc_attribute21
    ,p_pbc_attribute22               => p_pbc_attribute22
    ,p_pbc_attribute23               => p_pbc_attribute23
    ,p_pbc_attribute24               => p_pbc_attribute24
    ,p_pbc_attribute25               => p_pbc_attribute25
    ,p_pbc_attribute26               => p_pbc_attribute26
    ,p_pbc_attribute27               => p_pbc_attribute27
    ,p_pbc_attribute28               => p_pbc_attribute28
    ,p_pbc_attribute29               => p_pbc_attribute29
    ,p_pbc_attribute30               => p_pbc_attribute30
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
  --
  check_bnf_ctfn
        (p_prtt_enrt_actn_id      => p_prtt_enrt_actn_id,
         p_datetrack_mode         => p_datetrack_mode,
         p_business_group_id      => p_business_group_id,
         p_effective_date         => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PL_BNF_CTFN_PRVDD
    --
    ben_PL_BNF_CTFN_PRVDD_bk2.update_PL_BNF_CTFN_PRVDD_a
      (
       p_pl_bnf_ctfn_prvdd_id           =>  p_pl_bnf_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_bnf_ctfn_typ_cd                =>  p_bnf_ctfn_typ_cd
      ,p_bnf_ctfn_recd_dt               =>  p_bnf_ctfn_recd_dt
      ,p_bnf_ctfn_rqd_flag              =>  p_bnf_ctfn_rqd_flag
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbc_attribute_category         =>  p_pbc_attribute_category
      ,p_pbc_attribute1                 =>  p_pbc_attribute1
      ,p_pbc_attribute2                 =>  p_pbc_attribute2
      ,p_pbc_attribute3                 =>  p_pbc_attribute3
      ,p_pbc_attribute4                 =>  p_pbc_attribute4
      ,p_pbc_attribute5                 =>  p_pbc_attribute5
      ,p_pbc_attribute6                 =>  p_pbc_attribute6
      ,p_pbc_attribute7                 =>  p_pbc_attribute7
      ,p_pbc_attribute8                 =>  p_pbc_attribute8
      ,p_pbc_attribute9                 =>  p_pbc_attribute9
      ,p_pbc_attribute10                =>  p_pbc_attribute10
      ,p_pbc_attribute11                =>  p_pbc_attribute11
      ,p_pbc_attribute12                =>  p_pbc_attribute12
      ,p_pbc_attribute13                =>  p_pbc_attribute13
      ,p_pbc_attribute14                =>  p_pbc_attribute14
      ,p_pbc_attribute15                =>  p_pbc_attribute15
      ,p_pbc_attribute16                =>  p_pbc_attribute16
      ,p_pbc_attribute17                =>  p_pbc_attribute17
      ,p_pbc_attribute18                =>  p_pbc_attribute18
      ,p_pbc_attribute19                =>  p_pbc_attribute19
      ,p_pbc_attribute20                =>  p_pbc_attribute20
      ,p_pbc_attribute21                =>  p_pbc_attribute21
      ,p_pbc_attribute22                =>  p_pbc_attribute22
      ,p_pbc_attribute23                =>  p_pbc_attribute23
      ,p_pbc_attribute24                =>  p_pbc_attribute24
      ,p_pbc_attribute25                =>  p_pbc_attribute25
      ,p_pbc_attribute26                =>  p_pbc_attribute26
      ,p_pbc_attribute27                =>  p_pbc_attribute27
      ,p_pbc_attribute28                =>  p_pbc_attribute28
      ,p_pbc_attribute29                =>  p_pbc_attribute29
      ,p_pbc_attribute30                =>  p_pbc_attribute30
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
        (p_module_name => 'UPDATE_PL_BNF_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PL_BNF_CTFN_PRVDD
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
    ROLLBACK TO update_PL_BNF_CTFN_PRVDD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_PL_BNF_CTFN_PRVDD;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_PL_BNF_CTFN_PRVDD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PL_BNF_CTFN_PRVDD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PL_BNF_CTFN_PRVDD
  (p_validate                       in  boolean  default false
  ,p_pl_bnf_ctfn_prvdd_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_check_actions                  in varchar2 default 'Y'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_PL_BNF_CTFN_PRVDD';
  l_object_version_number ben_pl_bnf_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_bnf_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_bnf_ctfn_prvdd_f.effective_end_date%TYPE;
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
        from ben_pl_bnf_ctfn_prvdd_f
      where pl_bnf_ctfn_prvdd_id = p_pl_bnf_ctfn_prvdd_id
       and business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
  --
  cursor more_ctfn_c is
     select 'Y'
       from ben_pl_bnf_ctfn_prvdd_f
     where prtt_enrt_actn_id = l_prtt_enrt_actn_id
       and business_group_id = p_business_group_id
       and p_effective_date between effective_start_date
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
  savepoint delete_PL_BNF_CTFN_PRVDD;
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
    -- Start of API User Hook for the before hook of delete_PL_BNF_CTFN_PRVDD
    --
    ben_PL_BNF_CTFN_PRVDD_bk3.delete_PL_BNF_CTFN_PRVDD_b
      (
       p_pl_bnf_ctfn_prvdd_id           =>  p_pl_bnf_ctfn_prvdd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PL_BNF_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PL_BNF_CTFN_PRVDD
    --
  end;
  --
  -- Get action item id
  --
  open get_actn_c;
  fetch get_actn_c into l_prtt_enrt_actn_id;
  close get_actn_c;
  --
  ben_pbc_del.del
    (
     p_pl_bnf_ctfn_prvdd_id          => p_pl_bnf_ctfn_prvdd_id
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
      open  actn_info_c;
      fetch actn_info_c into l1_object_version_number,
                             l_prtt_enrt_rslt_id,
                             l_rslt_object_version_number;
      if actn_info_c%FOUND then
        --
        ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
          (p_validate              => p_validate,
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
           p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id);
        --
      end if;
      --
      close actn_info_c;
      --
    else
      --
      -- Other Ctfn exist. Check whether action item can be closed.
      --
      check_bnf_ctfn
        (p_prtt_enrt_actn_id      => l_prtt_enrt_actn_id,
         p_datetrack_mode         => p_datetrack_mode,
         p_business_group_id      => p_business_group_id,
         p_effective_date         => p_effective_date);
      --
    end if; -- l_exist
    --
  end if;  -- check_actions
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PL_BNF_CTFN_PRVDD
    --
    ben_PL_BNF_CTFN_PRVDD_bk3.delete_PL_BNF_CTFN_PRVDD_a
      (
       p_pl_bnf_ctfn_prvdd_id           =>  p_pl_bnf_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PL_BNF_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PL_BNF_CTFN_PRVDD
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
    ROLLBACK TO delete_PL_BNF_CTFN_PRVDD;
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
    ROLLBACK TO delete_PL_BNF_CTFN_PRVDD;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_PL_BNF_CTFN_PRVDD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_bnf_ctfn_prvdd_id                   in     number
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
  ben_pbc_shd.lck
    (
      p_pl_bnf_ctfn_prvdd_id                 => p_pl_bnf_ctfn_prvdd_id
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
end ben_PL_BNF_CTFN_PRVDD_api;

/
