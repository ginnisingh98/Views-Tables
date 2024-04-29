--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_ENRT_ACTN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_ENRT_ACTN_API" as
/* $Header: bepeaapi.pkb 120.4.12010000.3 2009/03/20 06:59:23 sallumwa ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PRTT_ENRT_ACTN_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< suspend_rslt  >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure suspend_rslt
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_post_rslt_flag             in     varchar2
  ,p_business_group_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_validate                   in     boolean  default false
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction)
is
  --
  -- check if a suspend action done already. If not suspend enrollment now.
  --
  l_package     varchar2(80) := g_package||'.suspend_rslt';
  --
  cursor c_suspend_enrl
  is
  select sspndd_flag
    from ben_prtt_enrt_rslt_f perslt
   where perslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and perslt.prtt_enrt_rslt_stat_cd is null
     and perslt.business_group_id = p_business_group_id
     and p_effective_date between perslt.effective_start_date
                              and perslt.effective_end_date;
  --
  l_suspend_enrl c_suspend_enrl%rowtype;
--
begin
--
  hr_utility.set_location ('Entering '||l_package,10);
  --
  -- Check if the enrollment result is already suspended.
  --
  open c_suspend_enrl;
  fetch c_suspend_enrl into l_suspend_enrl;
  close c_suspend_enrl;
  --
  -- Bug#2151619 bypass suspend enrollment in backout process
  if -- l_suspend_enrl.sspndd_flag <> 'Y' and --CFW
     ben_back_out_life_event.g_backout_flag is null then
    --
    -- Not already suspended... so suspend enrt rslt.
    --
    ben_sspndd_enrollment.suspend_enrollment
      (p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
      ,p_effective_date        => p_effective_date
      ,p_post_rslt_flag        => p_post_rslt_flag
      ,p_business_group_id     => p_business_group_id
      ,p_object_version_number => p_rslt_object_version_number
      ,p_datetrack_mode        => p_datetrack_mode);
    --
  end if;
  --
  hr_utility.set_location ('Leaving ' ||l_package,10);
--
end suspend_rslt;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< unsuspend_rslt  >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure unsuspend_rslt
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_post_rslt_flag             in     varchar2
  ,p_business_group_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_validate                   in     boolean  default false
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_cmpltd_dt                  in     date default null )
is
  --
  -- check if possible to unsuspend action items for this participant.
  -- ie. there should be no open action items with a rqd_flag = 'Y'.
  --
  l_package     varchar2(80) := g_package||'.unsuspend_rslt';
  --
  cursor c_suspend_enrl
  is
  select sspndd_flag
    from ben_prtt_enrt_rslt_f perslt
   where perslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and perslt.prtt_enrt_rslt_stat_cd is null
     and perslt.business_group_id = p_business_group_id
     and p_effective_date between perslt.effective_start_date
                              and perslt.effective_end_date;
  --
  l_suspend_enrl c_suspend_enrl%rowtype;
  --
  --bug#5621152
  cursor c_cmpltd_actn
  is
  select 'X'
    from ben_prtt_enrt_actn_f act,
         ben_per_in_ler pil
   where act.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and act.per_in_ler_id = pil.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
     and act.rqd_flag = 'Y'
     and act.cmpltd_dt IS NULL
     and act.business_group_id = p_business_group_id
     and p_effective_date between act.effective_start_date
                              and act.effective_end_date;
  --
  l_cmpltd_actn c_cmpltd_actn%rowtype;
--
begin
--
  hr_utility.set_location ('Entering '||l_package,10);
  --
  open c_suspend_enrl;
  fetch c_suspend_enrl into l_suspend_enrl;
  close c_suspend_enrl;
  --
  if l_suspend_enrl.sspndd_flag = 'Y' then
    --
    -- enrollment suspended, now check for the existance of any required
    -- action items that are not yet complete
    --
    open c_cmpltd_actn;
    fetch c_cmpltd_actn into l_cmpltd_actn;
    --
    if c_cmpltd_actn%notfound then
      -- No open required action items exist. Ok to unsuspend enrollment.
      close c_cmpltd_actn;
      --
      ben_sspndd_enrollment.unsuspend_enrollment
        (p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
        ,p_effective_date        => p_effective_date
        ,p_post_rslt_flag        => p_post_rslt_flag
        ,p_business_group_id     => p_business_group_id
        ,p_object_version_number => p_rslt_object_version_number
        ,p_datetrack_mode        => p_datetrack_mode
        ,p_cmpltd_dt             => p_cmpltd_dt );
      --
    else
      --
      -- Open required action items exist. Cannot unsuspend enrollment result.
      --
      close c_cmpltd_actn;
      --
    end if;
    --
  else
    NULL; -- Enrollment already unsuspended.
  end if;
  --
  hr_utility.set_location ('Leaving ' ||l_package,10);
  --
end unsuspend_rslt;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_PRTT_ENRT_ACTN >-----------------------|
-- ----------------------------------------------------------------------------
--
-- THIS PROCEDURE WAS DUPLICATED.  ONE HAS PER-IN-LER-ID THE OTHER DOESN'T.
-- CHANGE BOTH PROCEDURES IF MAKING A CHANGE.
--
procedure create_PRTT_ENRT_ACTN
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_post_rslt_flag                 in     varchar2  default 'N'
  ,p_cmpltd_dt                      in     date      default null
  ,p_due_dt                         in     date      default null
  ,p_rqd_flag                       in     varchar2  default 'Y'
  ,p_prtt_enrt_rslt_id              in     number    default null
  ,p_per_in_ler_id              in     number
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in     number    default null
  ,p_elig_cvrd_dpnt_id              in     number    default null
  ,p_pl_bnf_id                      in     number    default null
  ,p_business_group_id              in     number    default null
  ,p_pea_attribute_category         in     varchar2  default null
  ,p_pea_attribute1                 in     varchar2  default null
  ,p_pea_attribute2                 in     varchar2  default null
  ,p_pea_attribute3                 in     varchar2  default null
  ,p_pea_attribute4                 in     varchar2  default null
  ,p_pea_attribute5                 in     varchar2  default null
  ,p_pea_attribute6                 in     varchar2  default null
  ,p_pea_attribute7                 in     varchar2  default null
  ,p_pea_attribute8                 in     varchar2  default null
  ,p_pea_attribute9                 in     varchar2  default null
  ,p_pea_attribute10                in     varchar2  default null
  ,p_pea_attribute11                in     varchar2  default null
  ,p_pea_attribute12                in     varchar2  default null
  ,p_pea_attribute13                in     varchar2  default null
  ,p_pea_attribute14                in     varchar2  default null
  ,p_pea_attribute15                in     varchar2  default null
  ,p_pea_attribute16                in     varchar2  default null
  ,p_pea_attribute17                in     varchar2  default null
  ,p_pea_attribute18                in     varchar2  default null
  ,p_pea_attribute19                in     varchar2  default null
  ,p_pea_attribute20                in     varchar2  default null
  ,p_pea_attribute21                in     varchar2  default null
  ,p_pea_attribute22                in     varchar2  default null
  ,p_pea_attribute23                in     varchar2  default null
  ,p_pea_attribute24                in     varchar2  default null
  ,p_pea_attribute25                in     varchar2  default null
  ,p_pea_attribute26                in     varchar2  default null
  ,p_pea_attribute27                in     varchar2  default null
  ,p_pea_attribute28                in     varchar2  default null
  ,p_pea_attribute29                in     varchar2  default null
  ,p_pea_attribute30                in     varchar2  default null
  ,p_gnrt_cm                        in     boolean   default true
  ,p_object_version_number             out nocopy number
  ,p_prtt_enrt_actn_id                 out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  )
is
  --
  -- Declare cursors and local variables
  --
  cursor c_prtt_enrt_rslt is
    select person_id
          ,ler_id
          ,pgm_id
          ,pl_id
          ,pl_typ_id
    from ben_prtt_enrt_rslt_f
    where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   prtt_enrt_rslt_stat_cd is null
    and p_effective_date between
    effective_start_date and effective_end_date;
  --
  l_person_id     ben_prtt_enrt_rslt_f.person_id%TYPE;
  l_ler_id        ben_prtt_enrt_rslt_f.ler_id%TYPE;
  l_pl_id         ben_prtt_enrt_rslt_f.pl_id%TYPE;
  l_pl_typ_id     ben_prtt_enrt_rslt_f.pl_typ_id%TYPE;
  l_pgm_id        ben_prtt_enrt_rslt_f.pgm_id%TYPE;
  l_prtt_enrt_actn_id ben_prtt_enrt_actn_f.prtt_enrt_actn_id%TYPE;
  l_effective_start_date ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTT_ENRT_ACTN';
  l_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTT_ENRT_ACTN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk1.create_PRTT_ENRT_ACTN_b
      (p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  p_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTT_ENRT_ACTN
    --
  end;
  --
  ben_pea_ins.ins
    (
     p_prtt_enrt_actn_id             => l_prtt_enrt_actn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cmpltd_dt                     => p_cmpltd_dt
    ,p_due_dt                        => p_due_dt
    ,p_rqd_flag                      => p_rqd_flag
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id             => p_per_in_ler_id
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_pl_bnf_id                     => p_pl_bnf_id
    ,p_business_group_id             => p_business_group_id
    ,p_pea_attribute_category        => p_pea_attribute_category
    ,p_pea_attribute1                => p_pea_attribute1
    ,p_pea_attribute2                => p_pea_attribute2
    ,p_pea_attribute3                => p_pea_attribute3
    ,p_pea_attribute4                => p_pea_attribute4
    ,p_pea_attribute5                => p_pea_attribute5
    ,p_pea_attribute6                => p_pea_attribute6
    ,p_pea_attribute7                => p_pea_attribute7
    ,p_pea_attribute8                => p_pea_attribute8
    ,p_pea_attribute9                => p_pea_attribute9
    ,p_pea_attribute10               => p_pea_attribute10
    ,p_pea_attribute11               => p_pea_attribute11
    ,p_pea_attribute12               => p_pea_attribute12
    ,p_pea_attribute13               => p_pea_attribute13
    ,p_pea_attribute14               => p_pea_attribute14
    ,p_pea_attribute15               => p_pea_attribute15
    ,p_pea_attribute16               => p_pea_attribute16
    ,p_pea_attribute17               => p_pea_attribute17
    ,p_pea_attribute18               => p_pea_attribute18
    ,p_pea_attribute19               => p_pea_attribute19
    ,p_pea_attribute20               => p_pea_attribute20
    ,p_pea_attribute21               => p_pea_attribute21
    ,p_pea_attribute22               => p_pea_attribute22
    ,p_pea_attribute23               => p_pea_attribute23
    ,p_pea_attribute24               => p_pea_attribute24
    ,p_pea_attribute25               => p_pea_attribute25
    ,p_pea_attribute26               => p_pea_attribute26
    ,p_pea_attribute27               => p_pea_attribute27
    ,p_pea_attribute28               => p_pea_attribute28
    ,p_pea_attribute29               => p_pea_attribute29
    ,p_pea_attribute30               => p_pea_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk1.create_PRTT_ENRT_ACTN_a
      (
       p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  p_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTT_ENRT_ACTN
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  p_prtt_enrt_actn_id := l_prtt_enrt_actn_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  -- if action item is required, suspend the enrollment
  -- if setting cmpltd_dt to NULL try to unsuspend if
  -- cmpltd_dt is getting a value
  --
  if p_rqd_flag = 'Y' then
    if p_cmpltd_dt is NULL then
      suspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => hr_api.g_correction);
      --
    else
      --
      unsuspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => hr_api.g_correction
        ,p_cmpltd_dt                  => p_cmpltd_dt );
    --
    end if;
  end if;
  --
  if p_gnrt_cm then
    open c_prtt_enrt_rslt;
    fetch c_prtt_enrt_rslt into l_person_id
                               ,l_ler_id
                               ,l_pgm_id
                               ,l_pl_id
                               ,l_pl_typ_id;
    if c_prtt_enrt_rslt%notfound then
      close c_prtt_enrt_rslt;
      fnd_message.set_name('BEN','BEN_91916_ENRT_TABLE_NOT_FOUND');
      fnd_message.set_token('TABLE','BEN_PRTT_ENRT_RSLT_F');
      fnd_message.raise_error;
    end if;
    close c_prtt_enrt_rslt;
    --
    --  Generate Communications
    --
    ben_generate_communications.main
      (p_person_id             => l_person_id
      ,p_ler_id                => l_ler_id
      -- CWB Changes.
      ,p_per_in_ler_id         => p_per_in_ler_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_pgm_id                => l_pgm_id
      ,p_pl_id                 => l_pl_id
      ,p_pl_typ_id             => l_pl_typ_id
      ,p_actn_typ_id           => p_actn_typ_id
      ,p_business_group_id     => p_business_group_id
      ,p_proc_cd1              => 'ACTNCREATED'
      ,p_effective_date        => p_effective_date);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled
  then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PRTT_ENRT_ACTN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_enrt_actn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTT_ENRT_ACTN;
    raise;
    --
end create_PRTT_ENRT_ACTN;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_PRTT_ENRT_ACTN >-----------------------|
-- ----------------------------------------------------------------------------
--
--
-- THIS PROCEDURE WAS DUPLICATED.  ONE HAS PER-IN-LER-ID THE OTHER DOESN'T.
-- CHANGE BOTH PROCEDURES IF MAKING A CHANGE.
--
procedure create_PRTT_ENRT_ACTN
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_post_rslt_flag                 in     varchar2  default 'N'
  ,p_cmpltd_dt                      in     date      default null
  ,p_due_dt                         in     date      default null
  ,p_rqd_flag                       in     varchar2  default 'Y'
  ,p_prtt_enrt_rslt_id              in     number    default null
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in     number    default null
  ,p_elig_cvrd_dpnt_id              in     number    default null
  ,p_pl_bnf_id                      in     number    default null
  ,p_business_group_id              in     number    default null
  ,p_pea_attribute_category         in     varchar2  default null
  ,p_pea_attribute1                 in     varchar2  default null
  ,p_pea_attribute2                 in     varchar2  default null
  ,p_pea_attribute3                 in     varchar2  default null
  ,p_pea_attribute4                 in     varchar2  default null
  ,p_pea_attribute5                 in     varchar2  default null
  ,p_pea_attribute6                 in     varchar2  default null
  ,p_pea_attribute7                 in     varchar2  default null
  ,p_pea_attribute8                 in     varchar2  default null
  ,p_pea_attribute9                 in     varchar2  default null
  ,p_pea_attribute10                in     varchar2  default null
  ,p_pea_attribute11                in     varchar2  default null
  ,p_pea_attribute12                in     varchar2  default null
  ,p_pea_attribute13                in     varchar2  default null
  ,p_pea_attribute14                in     varchar2  default null
  ,p_pea_attribute15                in     varchar2  default null
  ,p_pea_attribute16                in     varchar2  default null
  ,p_pea_attribute17                in     varchar2  default null
  ,p_pea_attribute18                in     varchar2  default null
  ,p_pea_attribute19                in     varchar2  default null
  ,p_pea_attribute20                in     varchar2  default null
  ,p_pea_attribute21                in     varchar2  default null
  ,p_pea_attribute22                in     varchar2  default null
  ,p_pea_attribute23                in     varchar2  default null
  ,p_pea_attribute24                in     varchar2  default null
  ,p_pea_attribute25                in     varchar2  default null
  ,p_pea_attribute26                in     varchar2  default null
  ,p_pea_attribute27                in     varchar2  default null
  ,p_pea_attribute28                in     varchar2  default null
  ,p_pea_attribute29                in     varchar2  default null
  ,p_pea_attribute30                in     varchar2  default null
  ,p_gnrt_cm                        in     boolean   default true
  ,p_object_version_number             out nocopy number
  ,p_prtt_enrt_actn_id                 out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  )
is
  --
  -- Declare cursors and local variables
  --
  cursor c_prtt_enrt_rslt is
    select person_id
          ,ler_id
          ,pgm_id
          ,pl_id
          ,pl_typ_id
          ,per_in_ler_id
    from ben_prtt_enrt_rslt_f
    where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   prtt_enrt_rslt_stat_cd is null
    and p_effective_date between
    effective_start_date and effective_end_date;
  --
  l_person_id     ben_prtt_enrt_rslt_f.person_id%TYPE;
  l_ler_id        ben_prtt_enrt_rslt_f.ler_id%TYPE;
  l_pl_id         ben_prtt_enrt_rslt_f.pl_id%TYPE;
  l_pl_typ_id     ben_prtt_enrt_rslt_f.pl_typ_id%TYPE;
  l_pgm_id        ben_prtt_enrt_rslt_f.pgm_id%TYPE;
  l_prtt_enrt_actn_id ben_prtt_enrt_actn_f.prtt_enrt_actn_id%TYPE;
  l_effective_start_date ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTT_ENRT_ACTN';
  l_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l_per_in_ler_id number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTT_ENRT_ACTN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    open c_prtt_enrt_rslt;
    fetch c_prtt_enrt_rslt into l_person_id
                               ,l_ler_id
                               ,l_pgm_id
                               ,l_pl_id
                               ,l_pl_typ_id
                               ,l_per_in_ler_id;
    if c_prtt_enrt_rslt%notfound then
      close c_prtt_enrt_rslt;
      fnd_message.set_name('BEN','BEN_91916_ENRT_TABLE_NOT_FOUND');
      fnd_message.set_token('TABLE','BEN_PRTT_ENRT_RSLT_F');
      fnd_message.raise_error;
    end if;
    close c_prtt_enrt_rslt;
    --
    -- Start of API User Hook for the before hook of create_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk1.create_PRTT_ENRT_ACTN_b
      (p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTT_ENRT_ACTN
    --
  end;
  --
  ben_pea_ins.ins
    (
     p_prtt_enrt_actn_id             => l_prtt_enrt_actn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cmpltd_dt                     => p_cmpltd_dt
    ,p_due_dt                        => p_due_dt
    ,p_rqd_flag                      => p_rqd_flag
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id             => l_per_in_ler_id
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_pl_bnf_id                     => p_pl_bnf_id
    ,p_business_group_id             => p_business_group_id
    ,p_pea_attribute_category        => p_pea_attribute_category
    ,p_pea_attribute1                => p_pea_attribute1
    ,p_pea_attribute2                => p_pea_attribute2
    ,p_pea_attribute3                => p_pea_attribute3
    ,p_pea_attribute4                => p_pea_attribute4
    ,p_pea_attribute5                => p_pea_attribute5
    ,p_pea_attribute6                => p_pea_attribute6
    ,p_pea_attribute7                => p_pea_attribute7
    ,p_pea_attribute8                => p_pea_attribute8
    ,p_pea_attribute9                => p_pea_attribute9
    ,p_pea_attribute10               => p_pea_attribute10
    ,p_pea_attribute11               => p_pea_attribute11
    ,p_pea_attribute12               => p_pea_attribute12
    ,p_pea_attribute13               => p_pea_attribute13
    ,p_pea_attribute14               => p_pea_attribute14
    ,p_pea_attribute15               => p_pea_attribute15
    ,p_pea_attribute16               => p_pea_attribute16
    ,p_pea_attribute17               => p_pea_attribute17
    ,p_pea_attribute18               => p_pea_attribute18
    ,p_pea_attribute19               => p_pea_attribute19
    ,p_pea_attribute20               => p_pea_attribute20
    ,p_pea_attribute21               => p_pea_attribute21
    ,p_pea_attribute22               => p_pea_attribute22
    ,p_pea_attribute23               => p_pea_attribute23
    ,p_pea_attribute24               => p_pea_attribute24
    ,p_pea_attribute25               => p_pea_attribute25
    ,p_pea_attribute26               => p_pea_attribute26
    ,p_pea_attribute27               => p_pea_attribute27
    ,p_pea_attribute28               => p_pea_attribute28
    ,p_pea_attribute29               => p_pea_attribute29
    ,p_pea_attribute30               => p_pea_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk1.create_PRTT_ENRT_ACTN_a
      (
       p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTT_ENRT_ACTN
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  p_prtt_enrt_actn_id := l_prtt_enrt_actn_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  -- if action item is required, suspend the enrollment
  -- if setting cmpltd_dt to NULL try to unsuspend if
  -- cmpltd_dt is getting a value
  --
  if p_rqd_flag = 'Y' then
    if p_cmpltd_dt is NULL then
      suspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => hr_api.g_correction);
      --
    else
      --
      unsuspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => hr_api.g_correction
        ,p_cmpltd_dt                  => p_cmpltd_dt);
    --
    end if;
  end if;
  --
  if p_gnrt_cm then
    --
    --  Generate Communications
    --
    ben_generate_communications.main
      (p_person_id             => l_person_id
      ,p_ler_id                => l_ler_id
      -- CWB Changes.
      ,p_per_in_ler_id         => l_per_in_ler_id
      ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
      ,p_pgm_id                => l_pgm_id
      ,p_pl_id                 => l_pl_id
      ,p_pl_typ_id             => l_pl_typ_id
      ,p_actn_typ_id           => p_actn_typ_id
      ,p_business_group_id     => p_business_group_id
      ,p_proc_cd1              => 'ACTNCREATED'
      ,p_effective_date        => p_effective_date);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled
  then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PRTT_ENRT_ACTN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_enrt_actn_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTT_ENRT_ACTN;
    raise;
    --
end create_PRTT_ENRT_ACTN;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_PRTT_ENRT_ACTN >-----------------------|
-- ----------------------------------------------------------------------------
--
--
-- THIS PROCEDURE WAS DUPLICATED.  ONE HAS PER-IN-LER-ID THE OTHER DOESN'T.
-- CHANGE BOTH PROCEDURES IF MAKING A CHANGE.
--
procedure update_PRTT_ENRT_ACTN
  (p_validate                       in  boolean   default false
  ,p_post_rslt_flag                 in  varchar2  default 'N'
  ,p_prtt_enrt_actn_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cmpltd_dt                      in  date      default hr_api.g_date
  ,p_due_dt                         in  date      default hr_api.g_date
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_pl_bnf_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pea_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_gnrt_cm                        in  boolean   default true
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor c_pea is
     select pea.effective_start_date,
            pea.cmpltd_dt
     from   ben_prtt_enrt_actn_f pea
     where  pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and    pea.business_group_id = p_business_group_id
     and    p_effective_date between
            pea.effective_start_date and pea.effective_end_date;
  --
  l_pea          c_pea%rowtype;
  --
  cursor c_pcm is
     select pcm.per_cm_id,
            pcm.object_version_number
     from   ben_per_cm_f pcm
     where  pcm.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and    pcm.business_group_id = p_business_group_id
     and    p_effective_date between
            pcm.effective_start_date and pcm.effective_end_date;
  --
  cursor c_prtt_enrt_rslt is
    select person_id
          ,ler_id
          ,pgm_id
          ,pl_id
          ,pl_typ_id
    from ben_prtt_enrt_rslt_f
    where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   prtt_enrt_rslt_stat_cd is null
    and p_effective_date between
    effective_start_date and effective_end_date;
  --
  l_person_id     ben_prtt_enrt_rslt_f.person_id%TYPE;
  l_ler_id        ben_prtt_enrt_rslt_f.ler_id%TYPE;
  l_pl_id         ben_prtt_enrt_rslt_f.pl_id%TYPE;
  l_pl_typ_id     ben_prtt_enrt_rslt_f.pl_typ_id%TYPE;
  l_pgm_id        ben_prtt_enrt_rslt_f.pgm_id%TYPE;
  --
  l_proc varchar2(72) := g_package||'update_PRTT_ENRT_ACTN';
  l_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  l_pcm_effective_start_date date;
  l_pcm_effective_end_date   date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_ENRT_ACTN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Get the completed date and effective start date before the update.
  --
  open  c_pea;
  fetch c_pea into l_pea;
  close c_pea;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk2.update_PRTT_ENRT_ACTN_b
      (
       p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_ENRT_ACTN
    --
  end;
  --
  ben_pea_upd.upd
    (
     p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cmpltd_dt                     => p_cmpltd_dt
    ,p_due_dt                        => p_due_dt
    ,p_rqd_flag                      => p_rqd_flag
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_pl_bnf_id                     => p_pl_bnf_id
    ,p_business_group_id             => p_business_group_id
    ,p_pea_attribute_category        => p_pea_attribute_category
    ,p_pea_attribute1                => p_pea_attribute1
    ,p_pea_attribute2                => p_pea_attribute2
    ,p_pea_attribute3                => p_pea_attribute3
    ,p_pea_attribute4                => p_pea_attribute4
    ,p_pea_attribute5                => p_pea_attribute5
    ,p_pea_attribute6                => p_pea_attribute6
    ,p_pea_attribute7                => p_pea_attribute7
    ,p_pea_attribute8                => p_pea_attribute8
    ,p_pea_attribute9                => p_pea_attribute9
    ,p_pea_attribute10               => p_pea_attribute10
    ,p_pea_attribute11               => p_pea_attribute11
    ,p_pea_attribute12               => p_pea_attribute12
    ,p_pea_attribute13               => p_pea_attribute13
    ,p_pea_attribute14               => p_pea_attribute14
    ,p_pea_attribute15               => p_pea_attribute15
    ,p_pea_attribute16               => p_pea_attribute16
    ,p_pea_attribute17               => p_pea_attribute17
    ,p_pea_attribute18               => p_pea_attribute18
    ,p_pea_attribute19               => p_pea_attribute19
    ,p_pea_attribute20               => p_pea_attribute20
    ,p_pea_attribute21               => p_pea_attribute21
    ,p_pea_attribute22               => p_pea_attribute22
    ,p_pea_attribute23               => p_pea_attribute23
    ,p_pea_attribute24               => p_pea_attribute24
    ,p_pea_attribute25               => p_pea_attribute25
    ,p_pea_attribute26               => p_pea_attribute26
    ,p_pea_attribute27               => p_pea_attribute27
    ,p_pea_attribute28               => p_pea_attribute28
    ,p_pea_attribute29               => p_pea_attribute29
    ,p_pea_attribute30               => p_pea_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk2.update_PRTT_ENRT_ACTN_a
      (
       p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_ENRT_ACTN
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  -- suspend the enrollment if setting cmpltd_dt to NULL
  -- do not suspend if cmpltd_dt is getting a value
  -- instead if cmpltd_dt not null check if all others are also
  -- completed and if allcmpltd_dt for this participant are not null
  -- then unsuspend the enrollment
  --
  if p_rqd_flag = 'Y' then
    if p_cmpltd_dt is NULL then
    --
      suspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => p_datetrack_mode);
    --
    else
    --
      unsuspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_cmpltd_dt                  => p_cmpltd_dt );
    --
    end if;
   end if;
  --
  if p_gnrt_cm then
    if p_cmpltd_dt is not null then
      --
      if l_pea.cmpltd_dt is null and
         l_pea.effective_start_date = p_effective_date then
         --
         -- Action Item completed and started on the same day.
         --
         -- Delete communications for the action item as the action item just
         -- started and ended. The communications got generated due to the
         -- way we handle action items.
         --
         for l_pcm in c_pcm loop
            --
            ben_per_cm_api.delete_per_cm
                 (p_per_cm_id             => l_pcm.per_cm_id,
                  p_effective_start_date  => l_pcm_effective_start_date,
                  p_effective_end_date    => l_pcm_effective_end_date,
                  p_object_version_number => l_pcm.object_version_number,
                  p_effective_date        => p_effective_date,
                  p_datetrack_mode        => hr_api.g_zap);
            --
         end loop;
         --
      else
         --
         open c_prtt_enrt_rslt;
         fetch c_prtt_enrt_rslt into l_person_id
                                    ,l_ler_id
                                    ,l_pgm_id
                                    ,l_pl_id
                                    ,l_pl_typ_id;
         if c_prtt_enrt_rslt%notfound then
           close c_prtt_enrt_rslt;
           fnd_message.set_name('BEN','BEN_91916_ENRT_TABLE_NOT_FOUND');
           fnd_message.set_token('TABLE','BEN_PRTT_ENRT_RSLT_F');
           fnd_message.raise_error;
         end if;
         close c_prtt_enrt_rslt;
         --
         --  Generate Communications
         --
         ben_generate_communications.main
           (p_person_id             => l_person_id
           ,p_ler_id                => l_ler_id
           -- CWB Changes
           ,p_per_in_ler_id         => p_per_in_ler_id
           ,p_prtt_enrt_actn_id     => p_prtt_enrt_actn_id
           ,p_pgm_id                => l_pgm_id
           ,p_pl_id                 => l_pl_id
           ,p_pl_typ_id             => l_pl_typ_id
           ,p_actn_typ_id           => p_actn_typ_id
           ,p_business_group_id     => p_business_group_id
           ,p_proc_cd1              => 'ACTNCMPL'
           ,p_effective_date        => p_effective_date);
         --
      end if;
      --
    end if;
    --
  end if;
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
    ROLLBACK TO update_PRTT_ENRT_ACTN;
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
    ROLLBACK TO update_PRTT_ENRT_ACTN;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end update_PRTT_ENRT_ACTN;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_PRTT_ENRT_ACTN >-----------------------|
-- ----------------------------------------------------------------------------
--
--
-- THIS PROCEDURE WAS DUPLICATED.  ONE HAS PER-IN-LER-ID THE OTHER DOESN'T.
-- CHANGE BOTH PROCEDURES IF MAKING A CHANGE.
--
procedure update_PRTT_ENRT_ACTN
  (p_validate                       in  boolean   default false
  ,p_post_rslt_flag                 in  varchar2  default 'N'
  ,p_prtt_enrt_actn_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cmpltd_dt                      in  date      default hr_api.g_date
  ,p_due_dt                         in  date      default hr_api.g_date
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_rslt_object_version_number     in out nocopy number
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_pl_bnf_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pea_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pea_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_gnrt_cm                        in  boolean   default true
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor c_pea is
     select pea.effective_start_date,
            pea.cmpltd_dt
     from   ben_prtt_enrt_actn_f pea
     where  pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and    pea.business_group_id = p_business_group_id
     and    p_effective_date between
            pea.effective_start_date and pea.effective_end_date;
  --
  l_pea          c_pea%rowtype;
  --
  cursor c_pcm is
     select pcm.per_cm_id,
            pcm.object_version_number
     from   ben_per_cm_f pcm
     where  pcm.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and    pcm.business_group_id = p_business_group_id
     and    p_effective_date between
            pcm.effective_start_date and pcm.effective_end_date;
  --
  cursor c_prtt_enrt_rslt is
    select person_id
          ,ler_id
          ,pgm_id
          ,pl_id
          ,pl_typ_id
          ,per_in_ler_id
    from ben_prtt_enrt_rslt_f
    where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and   prtt_enrt_rslt_stat_cd is null
    and p_effective_date between
    effective_start_date and effective_end_date;
  --
  l_person_id     ben_prtt_enrt_rslt_f.person_id%TYPE;
  l_ler_id        ben_prtt_enrt_rslt_f.ler_id%TYPE;
  l_pl_id         ben_prtt_enrt_rslt_f.pl_id%TYPE;
  l_pl_typ_id     ben_prtt_enrt_rslt_f.pl_typ_id%TYPE;
  l_pgm_id        ben_prtt_enrt_rslt_f.pgm_id%TYPE;
  l_per_in_ler_id ben_prtt_enrt_rslt_f.per_in_ler_id%TYPE;
  --
  l_proc varchar2(72) := g_package||'update_PRTT_ENRT_ACTN';
  l_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  l_pcm_effective_start_date date;
  l_pcm_effective_end_date   date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_ENRT_ACTN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Get the completed date and effective start date before the update.
  --
  open  c_pea;
  fetch c_pea into l_pea;
  close c_pea;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    open c_prtt_enrt_rslt;
    fetch c_prtt_enrt_rslt into l_person_id
                               ,l_ler_id
                               ,l_pgm_id
                               ,l_pl_id
                               ,l_pl_typ_id
                               ,l_per_in_ler_id;
    if c_prtt_enrt_rslt%notfound then
      close c_prtt_enrt_rslt;
      fnd_message.set_name('BEN','BEN_91916_ENRT_TABLE_NOT_FOUND');
      fnd_message.set_token('TABLE','BEN_PRTT_ENRT_RSLT_F');
      fnd_message.raise_error;
    end if;
    close c_prtt_enrt_rslt;
    --
    -- Start of API User Hook for the before hook of update_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk2.update_PRTT_ENRT_ACTN_b
      (
       p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_ENRT_ACTN
    --
  end;
  --
  ben_pea_upd.upd
    (
     p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cmpltd_dt                     => p_cmpltd_dt
    ,p_due_dt                        => p_due_dt
    ,p_rqd_flag                      => p_rqd_flag
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_per_in_ler_id             => l_per_in_ler_id
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_pl_bnf_id                     => p_pl_bnf_id
    ,p_business_group_id             => p_business_group_id
    ,p_pea_attribute_category        => p_pea_attribute_category
    ,p_pea_attribute1                => p_pea_attribute1
    ,p_pea_attribute2                => p_pea_attribute2
    ,p_pea_attribute3                => p_pea_attribute3
    ,p_pea_attribute4                => p_pea_attribute4
    ,p_pea_attribute5                => p_pea_attribute5
    ,p_pea_attribute6                => p_pea_attribute6
    ,p_pea_attribute7                => p_pea_attribute7
    ,p_pea_attribute8                => p_pea_attribute8
    ,p_pea_attribute9                => p_pea_attribute9
    ,p_pea_attribute10               => p_pea_attribute10
    ,p_pea_attribute11               => p_pea_attribute11
    ,p_pea_attribute12               => p_pea_attribute12
    ,p_pea_attribute13               => p_pea_attribute13
    ,p_pea_attribute14               => p_pea_attribute14
    ,p_pea_attribute15               => p_pea_attribute15
    ,p_pea_attribute16               => p_pea_attribute16
    ,p_pea_attribute17               => p_pea_attribute17
    ,p_pea_attribute18               => p_pea_attribute18
    ,p_pea_attribute19               => p_pea_attribute19
    ,p_pea_attribute20               => p_pea_attribute20
    ,p_pea_attribute21               => p_pea_attribute21
    ,p_pea_attribute22               => p_pea_attribute22
    ,p_pea_attribute23               => p_pea_attribute23
    ,p_pea_attribute24               => p_pea_attribute24
    ,p_pea_attribute25               => p_pea_attribute25
    ,p_pea_attribute26               => p_pea_attribute26
    ,p_pea_attribute27               => p_pea_attribute27
    ,p_pea_attribute28               => p_pea_attribute28
    ,p_pea_attribute29               => p_pea_attribute29
    ,p_pea_attribute30               => p_pea_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk2.update_PRTT_ENRT_ACTN_a
      (
       p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cmpltd_dt                      =>  p_cmpltd_dt
      ,p_due_dt                         =>  p_due_dt
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_per_in_ler_id              =>  l_per_in_ler_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pea_attribute_category         =>  p_pea_attribute_category
      ,p_pea_attribute1                 =>  p_pea_attribute1
      ,p_pea_attribute2                 =>  p_pea_attribute2
      ,p_pea_attribute3                 =>  p_pea_attribute3
      ,p_pea_attribute4                 =>  p_pea_attribute4
      ,p_pea_attribute5                 =>  p_pea_attribute5
      ,p_pea_attribute6                 =>  p_pea_attribute6
      ,p_pea_attribute7                 =>  p_pea_attribute7
      ,p_pea_attribute8                 =>  p_pea_attribute8
      ,p_pea_attribute9                 =>  p_pea_attribute9
      ,p_pea_attribute10                =>  p_pea_attribute10
      ,p_pea_attribute11                =>  p_pea_attribute11
      ,p_pea_attribute12                =>  p_pea_attribute12
      ,p_pea_attribute13                =>  p_pea_attribute13
      ,p_pea_attribute14                =>  p_pea_attribute14
      ,p_pea_attribute15                =>  p_pea_attribute15
      ,p_pea_attribute16                =>  p_pea_attribute16
      ,p_pea_attribute17                =>  p_pea_attribute17
      ,p_pea_attribute18                =>  p_pea_attribute18
      ,p_pea_attribute19                =>  p_pea_attribute19
      ,p_pea_attribute20                =>  p_pea_attribute20
      ,p_pea_attribute21                =>  p_pea_attribute21
      ,p_pea_attribute22                =>  p_pea_attribute22
      ,p_pea_attribute23                =>  p_pea_attribute23
      ,p_pea_attribute24                =>  p_pea_attribute24
      ,p_pea_attribute25                =>  p_pea_attribute25
      ,p_pea_attribute26                =>  p_pea_attribute26
      ,p_pea_attribute27                =>  p_pea_attribute27
      ,p_pea_attribute28                =>  p_pea_attribute28
      ,p_pea_attribute29                =>  p_pea_attribute29
      ,p_pea_attribute30                =>  p_pea_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_ENRT_ACTN
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  -- suspend the enrollment if setting cmpltd_dt to NULL
  -- do not suspend if cmpltd_dt is getting a value
  -- instead if cmpltd_dt not null check if all others are also
  -- completed and if allcmpltd_dt for this participant are not null
  -- then unsuspend the enrollment
  --
  if p_rqd_flag = 'Y' then
    if p_cmpltd_dt is NULL then
    --
      suspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => p_datetrack_mode);
    --
    else
    --
      unsuspend_rslt
        (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
        ,p_post_rslt_flag             => p_post_rslt_flag
        ,p_effective_date             => p_effective_date
        ,p_business_group_id          => p_business_group_id
        ,p_rslt_object_version_number => p_rslt_object_version_number
        ,p_validate                   => p_validate
        ,p_datetrack_mode             => p_datetrack_mode
        ,p_cmpltd_dt                  => p_cmpltd_dt );
    --
    end if;
   end if;
  --
  if p_gnrt_cm then
    if p_cmpltd_dt is not null then
      --
      if l_pea.cmpltd_dt is null and
         l_pea.effective_start_date = p_effective_date then
         --
         -- Action Item completed and started on the same day.
         --
         -- Delete communications for the action item as the action item just
         -- started and ended. The communications got generated due to the
         -- way we handle action items.
         --
         for l_pcm in c_pcm loop
            --
            ben_per_cm_api.delete_per_cm
                 (p_per_cm_id             => l_pcm.per_cm_id,
                  p_effective_start_date  => l_pcm_effective_start_date,
                  p_effective_end_date    => l_pcm_effective_end_date,
                  p_object_version_number => l_pcm.object_version_number,
                  p_effective_date        => p_effective_date,
                  p_datetrack_mode        => hr_api.g_zap);
            --
         end loop;
         --
      else
         --
         --  Generate Communications
         --
         ben_generate_communications.main
           (p_person_id             => l_person_id
           ,p_ler_id                => l_ler_id
           -- CWB Changes
           ,p_per_in_ler_id         => l_per_in_ler_id
           ,p_prtt_enrt_actn_id     => p_prtt_enrt_actn_id
           ,p_pgm_id                => l_pgm_id
           ,p_pl_id                 => l_pl_id
           ,p_pl_typ_id             => l_pl_typ_id
           ,p_actn_typ_id           => p_actn_typ_id
           ,p_business_group_id     => p_business_group_id
           ,p_proc_cd1              => 'ACTNCMPL'
           ,p_effective_date        => p_effective_date);
         --
      end if;
      --
    end if;
    --
  end if;
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
    ROLLBACK TO update_PRTT_ENRT_ACTN;
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
    ROLLBACK TO update_PRTT_ENRT_ACTN;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end update_PRTT_ENRT_ACTN;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_ENRT_ACTN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ENRT_ACTN
  (p_validate                       in     boolean  default false
  ,p_prtt_enrt_actn_id              in     number
  ,p_business_group_id              in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_object_version_number          in out nocopy number
  ,p_prtt_enrt_rslt_id              in     number
  ,p_rslt_object_version_number     in out nocopy number
  ,p_post_rslt_flag                 in     varchar2 default 'N'
  ,p_unsuspend_enrt_flag            in     varchar2 default 'Y'
  ,p_gnrt_cm                        in     boolean default true
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  )
is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to find dpnt ctfns.
  --
  cursor c_dpnt_ctfns
  is
  select cvrd_dpnt_ctfn_prvdd_id,
         object_version_number,
         effective_start_date,
         effective_end_date
    from ben_cvrd_dpnt_ctfn_prvdd_f
   where prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
  --
  -- Cursor to find bnf ctfns.
  --
  cursor c_bnf_ctfns
  is
  select pl_bnf_ctfn_prvdd_id,
         object_version_number,
         effective_start_date,
         effective_end_date
    from ben_pl_bnf_ctfn_prvdd_f
   where prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
  --
  -- Cursor to find enrt ctfns.
  --
  cursor c_enrt_ctfns
  is
  select prtt_enrt_ctfn_prvdd_id,
         object_version_number,
         effective_start_date,
         effective_end_date
    from ben_prtt_enrt_ctfn_prvdd_f
   where prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
  --
  -- Cursor to find person communications.
  --
  cursor c_per_cm
  is
  select per_cm_id,
         object_version_number,
         effective_start_date,
         effective_end_date
    from ben_per_cm_f
   where prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
  --
  --
  l_proc varchar2(72) := g_package||'delete_PRTT_ENRT_ACTN';
  l_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PRTT_ENRT_ACTN;
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
    -- Start of API User Hook for the before hook of delete_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk3.delete_PRTT_ENRT_ACTN_b
      (p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_PRTT_ENRT_ACTN
    --
  end;
  --
  --Bug 5693086
  if p_datetrack_mode = hr_api.g_delete_next_change or p_datetrack_mode = hr_api.g_future_change then
  --
  ben_pea_del.del
    (p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk3.delete_PRTT_ENRT_ACTN_a
      (p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_PRTT_ENRT_ACTN
    --
  end;
   --
  end if;
  --Bug 5693086

  -- First delete all the children of the action item being deleted.
  --
  -- Delete dpnt ctfns.
  --
  for l_rec in c_dpnt_ctfns loop
    --
    -- Do not datetrack delete the row, if it is already end-dated.
    --
    if (p_datetrack_mode = hr_api.g_delete and
        l_rec.effective_end_date > p_effective_date) or
        p_datetrack_mode <> hr_api.g_delete then
      --
      ben_cvrd_dpnt_ctfn_prvdd_api.delete_cvrd_dpnt_ctfn_prvdd
        (p_validate                => FALSE
        ,p_cvrd_dpnt_ctfn_prvdd_id => l_rec.cvrd_dpnt_ctfn_prvdd_id
        ,p_effective_start_date    => l_rec.effective_start_date
        ,p_effective_end_date      => l_rec.effective_end_date
        ,p_object_version_number   => l_rec.object_version_number
        ,p_business_group_id       => p_business_group_id
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => p_datetrack_mode
        ,p_check_actions           => 'N'
        ,p_called_from             => 'bepeaapi' );
      --
    end if;
    --
  end loop;
  --
  -- Delete bnf ctfns.
  --
  for l_rec in c_bnf_ctfns loop
    --
    -- Do not datetrack delete the row, if it is already end-dated.
    --
    if (p_datetrack_mode = hr_api.g_delete and
        l_rec.effective_end_date > p_effective_date) or
        p_datetrack_mode <> hr_api.g_delete then
      --
      ben_pl_bnf_ctfn_prvdd_api.delete_pl_bnf_ctfn_prvdd
        (p_validate                => FALSE
        ,p_pl_bnf_ctfn_prvdd_id    => l_rec.pl_bnf_ctfn_prvdd_id
        ,p_effective_start_date    => l_rec.effective_start_date
        ,p_effective_end_date      => l_rec.effective_end_date
        ,p_object_version_number   => l_rec.object_version_number
        ,p_business_group_id       => p_business_group_id
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => p_datetrack_mode
        ,p_check_actions           => 'N');
      --
    end if;
    --
  end loop;
  --
  -- Delete enrt ctfns.
  --
  for l_rec in c_enrt_ctfns loop
    --
    -- Do not datetrack delete the row, if it is already end-dated.
    --
    if (p_datetrack_mode = hr_api.g_delete and
       /* l_rec.effective_end_date > p_effective_date) or */
          l_rec.effective_end_date >= p_effective_date) or  --Bug 8304294
        p_datetrack_mode <> hr_api.g_delete then
      --
      ben_prtt_enrt_ctfn_prvdd_api.delete_prtt_enrt_ctfn_prvdd
        (p_validate                => FALSE
        ,p_prtt_enrt_ctfn_prvdd_id => l_rec.prtt_enrt_ctfn_prvdd_id
        ,p_effective_start_date    => l_rec.effective_start_date
        ,p_effective_end_date      => l_rec.effective_end_date
        ,p_object_version_number   => l_rec.object_version_number
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => p_datetrack_mode
        ,p_check_actions           => 'N');
      --
    end if;
    --
  end loop;
  --
  -- Delete person communications.
  --
  for l_rec in c_per_cm loop
    --
    -- 5040268 : Do not datetrack delete PER_CM% rows, if already deleted.
    if (p_datetrack_mode = hr_api.g_delete and
        l_rec.effective_end_date > p_effective_date) or
        p_datetrack_mode <> hr_api.g_delete then
        --
        ben_per_cm_api.delete_per_cm
          (p_validate              => FALSE
          ,p_per_cm_id             => l_rec.per_cm_id
          ,p_effective_start_date  => l_rec.effective_start_date
          ,p_effective_end_date    => l_rec.effective_end_date
          ,p_object_version_number => l_rec.object_version_number
          ,p_effective_date        => p_effective_date
          ,p_datetrack_mode        => p_datetrack_mode);
          --
    end if;
    --
  end loop;
  --
  -- Call the action item row handler to delete the row.
  --
  --Bug 5693086
  if p_datetrack_mode <> hr_api.g_delete_next_change and p_datetrack_mode <> hr_api.g_future_change then
  --
  ben_pea_del.del
    (p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTT_ENRT_ACTN
    --
    ben_PRTT_ENRT_ACTN_bk3.delete_PRTT_ENRT_ACTN_a
      (p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_ENRT_ACTN'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_PRTT_ENRT_ACTN
    --
  end;
  --
  end if;
  --
  --Bug 5693086
  hr_utility.set_location(l_proc, 60);
  --
  -- If the calling procedure requests that the enrollment result be unsuspended
  -- then unsuspend the enrollment result.
  --
  if p_unsuspend_enrt_flag = 'Y' then
    --
    unsuspend_rslt
      (p_prtt_enrt_rslt_id          => p_prtt_enrt_rslt_id
      ,p_post_rslt_flag             => p_post_rslt_flag
      ,p_effective_date             => p_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_rslt_object_version_number => p_rslt_object_version_number
      ,p_validate                   => p_validate
      ,p_datetrack_mode             => p_datetrack_mode);
    --
  end if;
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
    ROLLBACK TO delete_PRTT_ENRT_ACTN;
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
    ROLLBACK TO delete_PRTT_ENRT_ACTN;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_PRTT_ENRT_ACTN;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_enrt_actn_id                   in     number
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
  ben_pea_shd.lck
    (
      p_prtt_enrt_actn_id                 => p_prtt_enrt_actn_id
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
end ben_PRTT_ENRT_ACTN_api;

/
