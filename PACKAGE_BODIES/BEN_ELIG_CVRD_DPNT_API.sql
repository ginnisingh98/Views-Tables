--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_CVRD_DPNT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_CVRD_DPNT_API" as
/* $Header: bepdpapi.pkb 120.12.12010000.3 2009/01/15 10:07:16 pvelvano ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIG_CVRD_DPNT_api.';
--
---- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_CVRD_DPNT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_CVRD_DPNT
  (p_validate                       in  boolean   default false
  ,p_elig_cvrd_dpnt_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_cvg_strt_dt                    in  date      default null
  ,p_cvg_thru_dt                    in  date      default null
  ,p_cvg_pndg_flag                  in  varchar2  default 'N'
  ,p_pdp_attribute_category         in  varchar2  default null
  ,p_pdp_attribute1                 in  varchar2  default null
  ,p_pdp_attribute2                 in  varchar2  default null
  ,p_pdp_attribute3                 in  varchar2  default null
  ,p_pdp_attribute4                 in  varchar2  default null
  ,p_pdp_attribute5                 in  varchar2  default null
  ,p_pdp_attribute6                 in  varchar2  default null
  ,p_pdp_attribute7                 in  varchar2  default null
  ,p_pdp_attribute8                 in  varchar2  default null
  ,p_pdp_attribute9                 in  varchar2  default null
  ,p_pdp_attribute10                in  varchar2  default null
  ,p_pdp_attribute11                in  varchar2  default null
  ,p_pdp_attribute12                in  varchar2  default null
  ,p_pdp_attribute13                in  varchar2  default null
  ,p_pdp_attribute14                in  varchar2  default null
  ,p_pdp_attribute15                in  varchar2  default null
  ,p_pdp_attribute16                in  varchar2  default null
  ,p_pdp_attribute17                in  varchar2  default null
  ,p_pdp_attribute18                in  varchar2  default null
  ,p_pdp_attribute19                in  varchar2  default null
  ,p_pdp_attribute20                in  varchar2  default null
  ,p_pdp_attribute21                in  varchar2  default null
  ,p_pdp_attribute22                in  varchar2  default null
  ,p_pdp_attribute23                in  varchar2  default null
  ,p_pdp_attribute24                in  varchar2  default null
  ,p_pdp_attribute25                in  varchar2  default null
  ,p_pdp_attribute26                in  varchar2  default null
  ,p_pdp_attribute27                in  varchar2  default null
  ,p_pdp_attribute28                in  varchar2  default null
  ,p_pdp_attribute29                in  varchar2  default null
  ,p_pdp_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_ovrdn_flag                     in  varchar2  default 'N'
  ,p_per_in_ler_id                  in  number    default null
  ,p_ovrdn_thru_dt                  in  date      default null
  ,p_effective_date                 in  date
  ,p_multi_row_actn                 in  boolean   default TRUE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elig_cvrd_dpnt_id ben_elig_cvrd_dpnt_f.elig_cvrd_dpnt_id%TYPE;
  l_effective_start_date ben_elig_cvrd_dpnt_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_cvrd_dpnt_f.effective_end_date%TYPE;
  l_cvg_thru_dt ben_elig_cvrd_dpnt_f.cvg_thru_dt%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIG_CVRD_DPNT';
  l_object_version_number ben_elig_cvrd_dpnt_f.object_version_number%TYPE;
--
  cursor c_chg_info (p_prtt_enrt_rslt_id  number) is
  SELECT pen.pl_id,
         pen.oipl_id,
         pen.person_id
  FROM   ben_prtt_enrt_rslt_f pen
  WHERE  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  AND    pen.prtt_enrt_rslt_stat_cd is null
  AND  p_effective_date between pen.effective_start_date and pen.effective_end_date;
--
  l_chg_info    c_chg_info%rowtype;
--
 l_env_rec                ben_env_object.g_global_env_rec_type;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.effective_date is null then
      --
      ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
      --
    end if;
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_CVRD_DPNT;
  --
  l_cvg_thru_dt := p_cvg_thru_dt;
  --
  if l_cvg_thru_dt is null then
     --
     l_cvg_thru_dt := hr_api.g_eot;
     --
  end if;
--
--
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk1.create_ELIG_CVRD_DPNT_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cvg_strt_dt                    =>  p_cvg_strt_dt
      ,p_cvg_thru_dt                    =>  l_cvg_thru_dt
      ,p_cvg_pndg_flag                  =>  p_cvg_pndg_flag
      ,p_pdp_attribute_category         =>  p_pdp_attribute_category
      ,p_pdp_attribute1                 =>  p_pdp_attribute1
      ,p_pdp_attribute2                 =>  p_pdp_attribute2
      ,p_pdp_attribute3                 =>  p_pdp_attribute3
      ,p_pdp_attribute4                 =>  p_pdp_attribute4
      ,p_pdp_attribute5                 =>  p_pdp_attribute5
      ,p_pdp_attribute6                 =>  p_pdp_attribute6
      ,p_pdp_attribute7                 =>  p_pdp_attribute7
      ,p_pdp_attribute8                 =>  p_pdp_attribute8
      ,p_pdp_attribute9                 =>  p_pdp_attribute9
      ,p_pdp_attribute10                =>  p_pdp_attribute10
      ,p_pdp_attribute11                =>  p_pdp_attribute11
      ,p_pdp_attribute12                =>  p_pdp_attribute12
      ,p_pdp_attribute13                =>  p_pdp_attribute13
      ,p_pdp_attribute14                =>  p_pdp_attribute14
      ,p_pdp_attribute15                =>  p_pdp_attribute15
      ,p_pdp_attribute16                =>  p_pdp_attribute16
      ,p_pdp_attribute17                =>  p_pdp_attribute17
      ,p_pdp_attribute18                =>  p_pdp_attribute18
      ,p_pdp_attribute19                =>  p_pdp_attribute19
      ,p_pdp_attribute20                =>  p_pdp_attribute20
      ,p_pdp_attribute21                =>  p_pdp_attribute21
      ,p_pdp_attribute22                =>  p_pdp_attribute22
      ,p_pdp_attribute23                =>  p_pdp_attribute23
      ,p_pdp_attribute24                =>  p_pdp_attribute24
      ,p_pdp_attribute25                =>  p_pdp_attribute25
      ,p_pdp_attribute26                =>  p_pdp_attribute26
      ,p_pdp_attribute27                =>  p_pdp_attribute27
      ,p_pdp_attribute28                =>  p_pdp_attribute28
      ,p_pdp_attribute29                =>  p_pdp_attribute29
      ,p_pdp_attribute30                =>  p_pdp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIG_CVRD_DPNT
    --
  end;
  --
  -- dbms_output.put_line('before rhi');
  ben_pdp_ins.ins
    (
     p_elig_cvrd_dpnt_id             => l_elig_cvrd_dpnt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_dpnt_person_id                => p_dpnt_person_id
    ,p_cvg_strt_dt                   => p_cvg_strt_dt
    ,p_cvg_thru_dt                   => l_cvg_thru_dt
    ,p_cvg_pndg_flag                 => p_cvg_pndg_flag
    ,p_pdp_attribute_category        => p_pdp_attribute_category
    ,p_pdp_attribute1                => p_pdp_attribute1
    ,p_pdp_attribute2                => p_pdp_attribute2
    ,p_pdp_attribute3                => p_pdp_attribute3
    ,p_pdp_attribute4                => p_pdp_attribute4
    ,p_pdp_attribute5                => p_pdp_attribute5
    ,p_pdp_attribute6                => p_pdp_attribute6
    ,p_pdp_attribute7                => p_pdp_attribute7
    ,p_pdp_attribute8                => p_pdp_attribute8
    ,p_pdp_attribute9                => p_pdp_attribute9
    ,p_pdp_attribute10               => p_pdp_attribute10
    ,p_pdp_attribute11               => p_pdp_attribute11
    ,p_pdp_attribute12               => p_pdp_attribute12
    ,p_pdp_attribute13               => p_pdp_attribute13
    ,p_pdp_attribute14               => p_pdp_attribute14
    ,p_pdp_attribute15               => p_pdp_attribute15
    ,p_pdp_attribute16               => p_pdp_attribute16
    ,p_pdp_attribute17               => p_pdp_attribute17
    ,p_pdp_attribute18               => p_pdp_attribute18
    ,p_pdp_attribute19               => p_pdp_attribute19
    ,p_pdp_attribute20               => p_pdp_attribute20
    ,p_pdp_attribute21               => p_pdp_attribute21
    ,p_pdp_attribute22               => p_pdp_attribute22
    ,p_pdp_attribute23               => p_pdp_attribute23
    ,p_pdp_attribute24               => p_pdp_attribute24
    ,p_pdp_attribute25               => p_pdp_attribute25
    ,p_pdp_attribute26               => p_pdp_attribute26
    ,p_pdp_attribute27               => p_pdp_attribute27
    ,p_pdp_attribute28               => p_pdp_attribute28
    ,p_pdp_attribute29               => p_pdp_attribute29
    ,p_pdp_attribute30               => p_pdp_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_ovrdn_flag                    => p_ovrdn_flag
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_ovrdn_thru_dt                 => p_ovrdn_thru_dt
    ,p_effective_date                => trunc(p_effective_date)
    );
  -- dbms_output.put_line('after rhi');
  --
  -- create person type usage, if needed
  --
  if p_cvg_strt_dt is not null and l_cvg_thru_dt = hr_api.g_eot then
    --
    add_usage( p_validate              => p_validate
              ,p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id
              ,p_effective_date        => p_effective_date
              ,p_datetrack_mode        => null
             );
    --
  end if;
  --
  --  Call Action item RCO if p_multi_row_actn = TRUE
  --
  if (p_multi_row_actn and
      p_cvg_strt_dt is not null and l_cvg_thru_dt = hr_api.g_eot) then
    --
    dpnt_actn_items(
           p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
          ,p_elig_cvrd_dpnt_id  => l_elig_cvrd_dpnt_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_validate           => p_validate
          ,p_datetrack_mode     => null
          );
    --
  end if;
  --
  --  If processing dependents in the COBRA program.
  --
  ben_cobra_requirements.update_dpnt_cobra_info
    (p_per_in_ler_id     => p_per_in_ler_id
    ,p_person_id         => p_dpnt_person_id
    ,p_business_group_id => p_business_group_id
    ,p_effective_date    => p_effective_date
    ,p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id
    ,p_validate          => p_validate
    );
  --
  -- Added by pxdas for logging change event needed for extract.
  -- p_erson control added to fox 5399

  hr_utility.set_location('pl id '||l_chg_info.pl_id , 5399);
  hr_utility.set_location('oipl id '||l_chg_info.oipl_id , 5399);
  hr_utility.set_location('prt_enrt_rslt id '||p_prtt_enrt_rslt_id , 5399);
  hr_utility.set_location('person id '||l_chg_info.person_id , 5399);
  hr_utility.set_location('dpndnt id '||p_dpnt_person_id , 5399);
  hr_utility.set_location('per_in_ler id '||p_per_in_ler_id , 5399);
  hr_utility.set_location(' idg_cvrd_dpnt_id '||p_elig_cvrd_dpnt_id , 5399);

  if p_dpnt_person_id is not null then
  --
    open c_chg_info (p_prtt_enrt_rslt_id);
    fetch c_chg_info into l_chg_info;
    close c_chg_info;
    --
    if l_chg_info.person_id is not null then
      --
      --
      --  Call the change event logging process.
      --
      ben_ext_chlg.log_dependent_chg
         (p_action               => 'CREATE',
          p_pl_id                => l_chg_info.pl_id,
          p_oipl_id              => l_chg_info.oipl_id,
          p_cvg_strt_dt          => p_cvg_strt_dt,
          p_cvg_end_dt           => l_cvg_thru_dt,
          p_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id,
          p_per_in_ler_id        => p_per_in_ler_id,
          p_elig_cvrd_dpnt_id    => l_elig_cvrd_dpnt_id,
          p_person_id            => l_chg_info.person_id,
          p_dpnt_person_id       => p_dpnt_person_id,
          p_business_group_id    => p_business_group_id,
          p_effective_date       => p_effective_date);
      --
    end if;
    --
  end if;
--
-- End logging change event
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk1.create_ELIG_CVRD_DPNT_a
      (
       p_elig_cvrd_dpnt_id              =>  l_elig_cvrd_dpnt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cvg_strt_dt                    =>  p_cvg_strt_dt
      ,p_cvg_thru_dt                    =>  l_cvg_thru_dt
      ,p_cvg_pndg_flag                  =>  p_cvg_pndg_flag
      ,p_pdp_attribute_category         =>  p_pdp_attribute_category
      ,p_pdp_attribute1                 =>  p_pdp_attribute1
      ,p_pdp_attribute2                 =>  p_pdp_attribute2
      ,p_pdp_attribute3                 =>  p_pdp_attribute3
      ,p_pdp_attribute4                 =>  p_pdp_attribute4
      ,p_pdp_attribute5                 =>  p_pdp_attribute5
      ,p_pdp_attribute6                 =>  p_pdp_attribute6
      ,p_pdp_attribute7                 =>  p_pdp_attribute7
      ,p_pdp_attribute8                 =>  p_pdp_attribute8
      ,p_pdp_attribute9                 =>  p_pdp_attribute9
      ,p_pdp_attribute10                =>  p_pdp_attribute10
      ,p_pdp_attribute11                =>  p_pdp_attribute11
      ,p_pdp_attribute12                =>  p_pdp_attribute12
      ,p_pdp_attribute13                =>  p_pdp_attribute13
      ,p_pdp_attribute14                =>  p_pdp_attribute14
      ,p_pdp_attribute15                =>  p_pdp_attribute15
      ,p_pdp_attribute16                =>  p_pdp_attribute16
      ,p_pdp_attribute17                =>  p_pdp_attribute17
      ,p_pdp_attribute18                =>  p_pdp_attribute18
      ,p_pdp_attribute19                =>  p_pdp_attribute19
      ,p_pdp_attribute20                =>  p_pdp_attribute20
      ,p_pdp_attribute21                =>  p_pdp_attribute21
      ,p_pdp_attribute22                =>  p_pdp_attribute22
      ,p_pdp_attribute23                =>  p_pdp_attribute23
      ,p_pdp_attribute24                =>  p_pdp_attribute24
      ,p_pdp_attribute25                =>  p_pdp_attribute25
      ,p_pdp_attribute26                =>  p_pdp_attribute26
      ,p_pdp_attribute27                =>  p_pdp_attribute27
      ,p_pdp_attribute28                =>  p_pdp_attribute28
      ,p_pdp_attribute29                =>  p_pdp_attribute29
      ,p_pdp_attribute30                =>  p_pdp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIG_CVRD_DPNT
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
  p_elig_cvrd_dpnt_id := l_elig_cvrd_dpnt_id;
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
    ROLLBACK TO create_ELIG_CVRD_DPNT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_cvrd_dpnt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELIG_CVRD_DPNT;
    raise;
    --
end create_ELIG_CVRD_DPNT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_CVRD_DPNT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_CVRD_DPNT
  (p_validate                       in  boolean   default false
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_cvg_strt_dt                    in  date      default hr_api.g_date
  ,p_cvg_thru_dt                    in  date      default hr_api.g_date
  ,p_cvg_pndg_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pdp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_ovrdn_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_ovrdn_thru_dt                  in  date      default hr_api.g_date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_CVRD_DPNT';
  l_object_version_number ben_elig_cvrd_dpnt_f.object_version_number%TYPE;
  l_effective_start_date  ben_elig_cvrd_dpnt_f.effective_start_date%TYPE;
  l_effective_end_date    ben_elig_cvrd_dpnt_f.effective_end_date%TYPE;
  l_prtt_enrt_rslt_id     ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
  --
  l2_object_version_number  ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l2_effective_start_date   ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l2_effective_end_date     ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
  l2_datetrack_mode         varchar2(30);
  --
  cursor dpnt_ctfn_c(x_datetrack_mode varchar2) is
     select bcc.cvrd_dpnt_ctfn_prvdd_id,
            bcc.object_version_number
       from ben_cvrd_dpnt_ctfn_prvdd_f bcc ,
            ben_prtt_enrt_actn_f bpe
       where bcc.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
         and bcc.business_group_id = p_business_group_id
         and bcc.prtt_enrt_actn_id = bpe.prtt_enrt_actn_id
         and bpe.per_in_ler_id     = p_per_in_ler_id
         and bpe.business_group_id = p_business_group_id
         and p_effective_date between bcc.effective_start_date
                                  and bcc.effective_end_date
         and p_effective_date between bpe.effective_start_date
                                  and bpe.effective_end_date
         and (x_datetrack_mode=hr_api.g_delete
              and p_effective_date<>bcc.effective_end_date
              or x_datetrack_mode=hr_api.g_zap)
     ;
--
  cursor c_get_previous_values is
  SELECT pdp.cvg_strt_dt,
         pdp.cvg_thru_dt,
         pdp.prtt_enrt_rslt_id,
         pdp.per_in_ler_id,
         pdp.dpnt_person_id,
         pen.pl_id,
         pen.oipl_id,
         pen.person_id
  FROM   ben_prtt_enrt_rslt_f pen,
         ben_elig_cvrd_dpnt_f pdp
  WHERE  pdp.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
  AND    pen.prtt_enrt_rslt_stat_cd is null
  and    p_effective_date between pdp.effective_start_date and pdp.effective_end_date
  and    pen.prtt_enrt_rslt_id = pdp.prtt_enrt_rslt_id
  AND    p_effective_date between pen.effective_start_date and pen.effective_end_date;
  --
	-- 3574168
	-- Fetch all PCP records on effective date
    Cursor c_pcp (c_elig_cvrd_dpnt_id NUMBER, c_pcp_effective_date DATE)
    is
    select pcp.PRMRY_CARE_PRVDR_ID
        ,pcp.EFFECTIVE_START_DATE
        ,pcp.EFFECTIVE_END_DATE
        ,pcp.PRTT_ENRT_RSLT_ID
        ,pcp.BUSINESS_GROUP_ID
        ,pcp.OBJECT_VERSION_NUMBER
    from ben_prmry_care_prvdr_f pcp
    where business_group_id = p_business_group_id
     and elig_cvrd_dpnt_id = c_elig_cvrd_dpnt_id
     and c_pcp_effective_date between effective_start_date --3631067: Changed p_effective_date to c_pcp_effective_date
                  and effective_end_date
       ;
     --
     -- Fetch all PCP records in future
	  Cursor c_pcp_future (c_elig_cvrd_dpnt_id NUMBER, c_pcp_effective_date DATE)
	  is
	  select pcp.PRMRY_CARE_PRVDR_ID
			,pcp.EFFECTIVE_START_DATE
			,pcp.EFFECTIVE_END_DATE
			,pcp.PRTT_ENRT_RSLT_ID
			,pcp.BUSINESS_GROUP_ID
			,pcp.OBJECT_VERSION_NUMBER
		from ben_prmry_care_prvdr_f pcp
	   where pcp.business_group_id = p_business_group_id
		 and pcp.elig_cvrd_dpnt_id = c_elig_cvrd_dpnt_id
		 and c_pcp_effective_date  < pcp.effective_start_date ----3631067: Changed p_effective_date to c_pcp_effective_date
		 and  NVL(pcp.effective_end_date, hr_api.g_eot) = hr_api.g_eot
       ;
       -- 3574168

--
  l_previous_values     c_get_previous_values%rowtype;
  l_pcp_effective_date DATE;
  l_pcp_effective_start_date DATE;
  --
  l_env_rec                ben_env_object.g_global_env_rec_type;
  --
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('per in ler id '|| p_per_in_ler_id , 9745);
  hr_utility.set_location('elig_dpnt ' || p_elig_cvrd_dpnt_id, 9745);
  hr_utility.set_location(' dt' || p_effective_start_date, 9745);
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.effective_date is null then
      --
      ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
      --
    end if;
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_CVRD_DPNT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
--
-- Added by pxdas for logging change event needed for extract.
--
  open c_get_previous_values;
  fetch c_get_previous_values into l_previous_values;
  close c_get_previous_values;
--
-- Ending Benefit Coverage for Dependent.
--
  if  l_previous_values.cvg_thru_dt = hr_api.g_eot
      and p_cvg_thru_dt <> hr_api.g_date
      and p_cvg_thru_dt <> hr_api.g_eot then
--
--  Call the extract change event logging process.
--
    ben_ext_chlg.log_dependent_chg
       (p_action               => 'DELETE',
        p_pl_id                => l_previous_values.pl_id,
        p_oipl_id              => l_previous_values.oipl_id,
        p_cvg_strt_dt          => l_previous_values.cvg_strt_dt,
        p_cvg_end_dt           => p_cvg_thru_dt,
        p_old_cvg_strt_dt      => l_previous_values.cvg_strt_dt,
        p_old_cvg_end_dt       => l_previous_values.cvg_thru_dt,
        p_prtt_enrt_rslt_id    => l_previous_values.prtt_enrt_rslt_id,
        -- bug 1540458.  line below was just prev per_in_ler_id
        p_per_in_ler_id        => nvl(p_per_in_ler_id,
                                      l_previous_values.per_in_ler_id),
        p_elig_cvrd_dpnt_id    => p_elig_cvrd_dpnt_id,
        p_person_id            => l_previous_values.person_id,
        p_dpnt_person_id       => l_previous_values.dpnt_person_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => p_effective_date);
     --
--
--  Benefit reinstatement for Dependent.
--
  elsif  l_previous_values.cvg_thru_dt <> hr_api.g_eot
      and p_cvg_thru_dt = hr_api.g_eot then
--
--
    ben_ext_chlg.log_dependent_chg
       (p_action               => 'REINSTATE',
        p_pl_id                => l_previous_values.pl_id,
        p_oipl_id              => l_previous_values.oipl_id,
        p_cvg_strt_dt          => l_previous_values.cvg_strt_dt,
        p_cvg_end_dt           => p_cvg_thru_dt,
        p_old_cvg_strt_dt      => l_previous_values.cvg_strt_dt,
        p_old_cvg_end_dt       => l_previous_values.cvg_thru_dt,
        p_prtt_enrt_rslt_id    => l_previous_values.prtt_enrt_rslt_id,
        -- bug 1540458.  line below was just prev per_in_ler_id
        p_per_in_ler_id        => nvl(p_per_in_ler_id,
                                      l_previous_values.per_in_ler_id),
        p_elig_cvrd_dpnt_id    => p_elig_cvrd_dpnt_id,
        p_person_id            => l_previous_values.person_id,
        p_dpnt_person_id       => l_previous_values.dpnt_person_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => p_effective_date);

  end if;
--
-- End logging change event
--
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk2.update_ELIG_CVRD_DPNT_b
      (
       p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cvg_strt_dt                    =>  p_cvg_strt_dt
      ,p_cvg_thru_dt                    =>  p_cvg_thru_dt
      ,p_cvg_pndg_flag                  =>  p_cvg_pndg_flag
      ,p_pdp_attribute_category         =>  p_pdp_attribute_category
      ,p_pdp_attribute1                 =>  p_pdp_attribute1
      ,p_pdp_attribute2                 =>  p_pdp_attribute2
      ,p_pdp_attribute3                 =>  p_pdp_attribute3
      ,p_pdp_attribute4                 =>  p_pdp_attribute4
      ,p_pdp_attribute5                 =>  p_pdp_attribute5
      ,p_pdp_attribute6                 =>  p_pdp_attribute6
      ,p_pdp_attribute7                 =>  p_pdp_attribute7
      ,p_pdp_attribute8                 =>  p_pdp_attribute8
      ,p_pdp_attribute9                 =>  p_pdp_attribute9
      ,p_pdp_attribute10                =>  p_pdp_attribute10
      ,p_pdp_attribute11                =>  p_pdp_attribute11
      ,p_pdp_attribute12                =>  p_pdp_attribute12
      ,p_pdp_attribute13                =>  p_pdp_attribute13
      ,p_pdp_attribute14                =>  p_pdp_attribute14
      ,p_pdp_attribute15                =>  p_pdp_attribute15
      ,p_pdp_attribute16                =>  p_pdp_attribute16
      ,p_pdp_attribute17                =>  p_pdp_attribute17
      ,p_pdp_attribute18                =>  p_pdp_attribute18
      ,p_pdp_attribute19                =>  p_pdp_attribute19
      ,p_pdp_attribute20                =>  p_pdp_attribute20
      ,p_pdp_attribute21                =>  p_pdp_attribute21
      ,p_pdp_attribute22                =>  p_pdp_attribute22
      ,p_pdp_attribute23                =>  p_pdp_attribute23
      ,p_pdp_attribute24                =>  p_pdp_attribute24
      ,p_pdp_attribute25                =>  p_pdp_attribute25
      ,p_pdp_attribute26                =>  p_pdp_attribute26
      ,p_pdp_attribute27                =>  p_pdp_attribute27
      ,p_pdp_attribute28                =>  p_pdp_attribute28
      ,p_pdp_attribute29                =>  p_pdp_attribute29
      ,p_pdp_attribute30                =>  p_pdp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIG_CVRD_DPNT
    --
  end;
  --
  -- If not covered, delete certifications provided.
  --
  if not(p_cvg_strt_dt is not null and p_cvg_thru_dt = hr_api.g_eot) then
    --
    --
    -- delete certifications provided
    if p_datetrack_mode = 'UPDATE' then
      l2_datetrack_mode := 'DELETE';
    else
      l2_datetrack_mode := 'ZAP';
      --
    end if;
    --
    remove_usage( p_validate              => p_validate
                 ,p_elig_cvrd_dpnt_id     => p_elig_cvrd_dpnt_id
                 ,p_cvg_thru_dt           => p_cvg_thru_dt
                 ,p_effective_date        => p_effective_date
                 ,p_datetrack_mode        => l2_datetrack_mode
                 );
    --
    for ctfn_rec in dpnt_ctfn_c(l2_datetrack_mode) loop
      --
      l2_object_version_number := ctfn_rec.object_version_number;
      --
      ben_cvrd_dpnt_ctfn_prvdd_api.delete_cvrd_dpnt_ctfn_prvdd
       (p_validate                => FALSE
       ,p_cvrd_dpnt_ctfn_prvdd_id => ctfn_rec.cvrd_dpnt_ctfn_prvdd_id
       ,p_effective_start_date    => l2_effective_start_date
       ,p_effective_end_date      => l2_effective_end_date
       ,p_object_version_number   => l2_object_version_number
       ,p_business_group_id       => p_business_group_id
       ,p_effective_date          => p_effective_date
       ,p_datetrack_mode          => l2_datetrack_mode
       );
      --
    end loop;
    --
    --
    -- 3574168: Remove PCP records
    -- Set End-date to coverage-end-date.
    --
    l_pcp_effective_date := NVL(p_cvg_thru_dt+1,p_effective_date);
    --
    for l_pcp in c_pcp(p_elig_cvrd_dpnt_id, l_pcp_effective_date) loop
        --
        hr_utility.set_location('DELETE prmry_care_prvdr_id '|| l_pcp.prmry_care_prvdr_id, 15);
        hr_utility.set_location('PCP ESD: EED '|| l_pcp.effective_start_date ||': '||l_pcp.effective_end_date, 15);
        hr_utility.set_location('Effective Date to delete '|| l_pcp_effective_date, 15);
        hr_utility.set_location('DATETRACK_MODE '|| l2_datetrack_mode, 15);
        --
        -- Since, deletion automatically sets end-date to 1 day less than effective-date,
        -- call the delete-api with effective_date = cvg_thru_date+1.
        --
        ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
        (P_VALIDATE               => FALSE
        ,P_PRMRY_CARE_PRVDR_ID    => l_pcp.prmry_care_prvdr_id
        ,P_EFFECTIVE_START_DATE   => l_pcp.effective_start_date
        ,P_EFFECTIVE_END_DATE     => l_pcp.effective_end_date
        ,P_OBJECT_VERSION_NUMBER  => l_pcp.object_version_number
        ,P_EFFECTIVE_DATE         => l_pcp_effective_date --3631067: Changed p_effective_date to l_pcp_effective_date
        ,P_DATETRACK_MODE         => l2_datetrack_mode
        ,p_called_from            => 'delete_enrollment'
        );
        --
    End loop;
    --
    -- Get future PCP records if any and zap - delete all of them.
    --
    for l_pcp_future in c_pcp_future(p_elig_cvrd_dpnt_id, l_pcp_effective_date) loop
        --
        hr_utility.set_location('ZAP prmry_care_prvdr_id '|| l_pcp_future.prmry_care_prvdr_id, 15);
        hr_utility.set_location('PCP ESD: EED '|| l_pcp_future.effective_start_date ||': '||l_pcp_future.effective_end_date, 15);
        hr_utility.set_location('Effective Date to delete '|| l_pcp_effective_start_date, 15);
        --
        l_pcp_effective_start_date := l_pcp_future.effective_start_date;
        --
        ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
        (P_VALIDATE               => FALSE
        ,P_PRMRY_CARE_PRVDR_ID    => l_pcp_future.prmry_care_prvdr_id
        ,P_EFFECTIVE_START_DATE   => l_pcp_future.effective_start_date
        ,P_EFFECTIVE_END_DATE     => l_pcp_future.effective_end_date
        ,P_OBJECT_VERSION_NUMBER  => l_pcp_future.object_version_number
        ,P_EFFECTIVE_DATE         => l_pcp_effective_start_date
        ,P_DATETRACK_MODE         => hr_api.g_zap
        ,p_called_from            => 'delete_enrollment'
        );
    End loop;
    -- 3574168
  end if;
  --
  --
  ben_pdp_upd.upd
    (
     p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_dpnt_person_id                => p_dpnt_person_id
    ,p_cvg_strt_dt                   => p_cvg_strt_dt
    ,p_cvg_thru_dt                   => p_cvg_thru_dt
    ,p_cvg_pndg_flag                 => p_cvg_pndg_flag
    ,p_pdp_attribute_category        => p_pdp_attribute_category
    ,p_pdp_attribute1                => p_pdp_attribute1
    ,p_pdp_attribute2                => p_pdp_attribute2
    ,p_pdp_attribute3                => p_pdp_attribute3
    ,p_pdp_attribute4                => p_pdp_attribute4
    ,p_pdp_attribute5                => p_pdp_attribute5
    ,p_pdp_attribute6                => p_pdp_attribute6
    ,p_pdp_attribute7                => p_pdp_attribute7
    ,p_pdp_attribute8                => p_pdp_attribute8
    ,p_pdp_attribute9                => p_pdp_attribute9
    ,p_pdp_attribute10               => p_pdp_attribute10
    ,p_pdp_attribute11               => p_pdp_attribute11
    ,p_pdp_attribute12               => p_pdp_attribute12
    ,p_pdp_attribute13               => p_pdp_attribute13
    ,p_pdp_attribute14               => p_pdp_attribute14
    ,p_pdp_attribute15               => p_pdp_attribute15
    ,p_pdp_attribute16               => p_pdp_attribute16
    ,p_pdp_attribute17               => p_pdp_attribute17
    ,p_pdp_attribute18               => p_pdp_attribute18
    ,p_pdp_attribute19               => p_pdp_attribute19
    ,p_pdp_attribute20               => p_pdp_attribute20
    ,p_pdp_attribute21               => p_pdp_attribute21
    ,p_pdp_attribute22               => p_pdp_attribute22
    ,p_pdp_attribute23               => p_pdp_attribute23
    ,p_pdp_attribute24               => p_pdp_attribute24
    ,p_pdp_attribute25               => p_pdp_attribute25
    ,p_pdp_attribute26               => p_pdp_attribute26
    ,p_pdp_attribute27               => p_pdp_attribute27
    ,p_pdp_attribute28               => p_pdp_attribute28
    ,p_pdp_attribute29               => p_pdp_attribute29
    ,p_pdp_attribute30               => p_pdp_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
   ,p_ovrdn_flag                    => p_ovrdn_flag
   ,p_per_in_ler_id                 => p_per_in_ler_id
   ,p_ovrdn_thru_dt                 => p_ovrdn_thru_dt
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  if p_prtt_enrt_rslt_id = hr_api.g_number then
    l_prtt_enrt_rslt_id := l_previous_values.prtt_enrt_rslt_id;
  else
    l_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  end if;
    --
  if p_cvg_strt_dt is not null and p_cvg_thru_dt = hr_api.g_eot then
    --
    add_usage( p_validate              => p_validate
              ,p_elig_cvrd_dpnt_id     => p_elig_cvrd_dpnt_id
              ,p_effective_date        => p_effective_date
              ,p_datetrack_mode        => p_datetrack_mode
             );
    --
    ben_cobra_requirements.update_dpnt_cobra_info
      (p_per_in_ler_id     => p_per_in_ler_id
      ,p_person_id         => l_previous_values.dpnt_person_id
      ,p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      ,p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id
      ,p_validate          => p_validate
      );

  end if;
  --
 --  Call Action item RCO if p_multi_row_actn = TRUE
  --
  if p_multi_row_actn then
    --
    dpnt_actn_items(
           p_prtt_enrt_rslt_id  => l_prtt_enrt_rslt_id
          ,p_elig_cvrd_dpnt_id  => p_elig_cvrd_dpnt_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_validate           => p_validate
          ,p_datetrack_mode     => p_datetrack_mode
          );
    --
  end if;
  --
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk2.update_ELIG_CVRD_DPNT_a
      (
       p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_cvg_strt_dt                    =>  p_cvg_strt_dt
      ,p_cvg_thru_dt                    =>  p_cvg_thru_dt
      ,p_cvg_pndg_flag                  =>  p_cvg_pndg_flag
      ,p_pdp_attribute_category         =>  p_pdp_attribute_category
      ,p_pdp_attribute1                 =>  p_pdp_attribute1
      ,p_pdp_attribute2                 =>  p_pdp_attribute2
      ,p_pdp_attribute3                 =>  p_pdp_attribute3
      ,p_pdp_attribute4                 =>  p_pdp_attribute4
      ,p_pdp_attribute5                 =>  p_pdp_attribute5
      ,p_pdp_attribute6                 =>  p_pdp_attribute6
      ,p_pdp_attribute7                 =>  p_pdp_attribute7
      ,p_pdp_attribute8                 =>  p_pdp_attribute8
      ,p_pdp_attribute9                 =>  p_pdp_attribute9
      ,p_pdp_attribute10                =>  p_pdp_attribute10
      ,p_pdp_attribute11                =>  p_pdp_attribute11
      ,p_pdp_attribute12                =>  p_pdp_attribute12
      ,p_pdp_attribute13                =>  p_pdp_attribute13
      ,p_pdp_attribute14                =>  p_pdp_attribute14
      ,p_pdp_attribute15                =>  p_pdp_attribute15
      ,p_pdp_attribute16                =>  p_pdp_attribute16
      ,p_pdp_attribute17                =>  p_pdp_attribute17
      ,p_pdp_attribute18                =>  p_pdp_attribute18
      ,p_pdp_attribute19                =>  p_pdp_attribute19
      ,p_pdp_attribute20                =>  p_pdp_attribute20
      ,p_pdp_attribute21                =>  p_pdp_attribute21
      ,p_pdp_attribute22                =>  p_pdp_attribute22
      ,p_pdp_attribute23                =>  p_pdp_attribute23
      ,p_pdp_attribute24                =>  p_pdp_attribute24
      ,p_pdp_attribute25                =>  p_pdp_attribute25
      ,p_pdp_attribute26                =>  p_pdp_attribute26
      ,p_pdp_attribute27                =>  p_pdp_attribute27
      ,p_pdp_attribute28                =>  p_pdp_attribute28
      ,p_pdp_attribute29                =>  p_pdp_attribute29
      ,p_pdp_attribute30                =>  p_pdp_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIG_CVRD_DPNT
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
    ROLLBACK TO update_ELIG_CVRD_DPNT;
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
    ROLLBACK TO update_ELIG_CVRD_DPNT;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_ELIG_CVRD_DPNT;

-- ----------------------------------------------------------------------------
-- |------------------------< un_end_date_dpnt_ptu >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--  Bug: 1485862. Added new method un_end_date_dpnt_ptu  to un_end_date 'DPNT' person_type_usage for
--  the dependents if the employee's termination event is backed out.
--  Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type
--   p_validate                     No   boolean
--   p_elig_cvrd_dpnt_id            Yes  number
--   p_cvg_thru_dt                  Yes  date
--   p_effective_date               Yes  date
-- 	 p_datetrack_mode				Yes	 varchar2
--
-- Post Success:
--   The Dependent's PTU is un-end-dated.
--
-- Post Failure:
--   The procedure passes the failure to the calling procedure. The calling procedure
--    should handle the failure
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure un_end_date_dpnt_ptu
	(p_validate                       in     boolean  default false
	,p_elig_cvrd_dpnt_id              in     number
	,p_cvg_thru_dt                    in     date
	,p_effective_date                 in     date
	,p_datetrack_mode                 in     varchar2
	) is
--
--
-- Declare cursors and local variables
--
l_proc                    varchar2(72) := g_package||'un_end_date_dpnt_ptu';
l_exist                   varchar2(1);
l_dpnt_person_id          number(15);
l_cvg_strt_dt             date;
l_end_dt                  date;
l_object_version_number   number(9);
l_business_group_id       number(15);
l_datetrack_mode         varchar2(30);
l_effective_end_date	 date;
l_effective_date	 date;
--
--
cursor get_dpnt_info_c is
  select dpnt_person_id,
         cvg_strt_dt,
         business_group_id
    from ben_elig_cvrd_dpnt_f
   where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
--
cursor other_dpnt_c is
     select null
       from ben_elig_cvrd_dpnt_f a,
            ben_per_in_ler pil
         where a.dpnt_person_id = l_dpnt_person_id
           and a.elig_cvrd_dpnt_id <> p_elig_cvrd_dpnt_id
           and a.cvg_strt_dt is not null
           and a.cvg_thru_dt = hr_api.g_eot
           and l_end_dt between a.cvg_strt_dt
                                 and nvl(a.cvg_thru_dt, hr_api.g_date)
           and p_effective_date between a.effective_start_date
                                    and a.effective_end_date
           and   a.per_in_ler_id = pil.per_in_ler_id
           and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
--
cursor usage_c is
   select a.person_id
		,a.person_type_usage_id
		,a.object_version_number
		,a.person_type_id
		,a.effective_start_date
		,a.effective_end_date
     from per_person_type_usages_f a,
          per_person_types         b
    where a.person_id = l_dpnt_person_id
      and a.person_type_id = b.person_type_id
      and b.system_person_type = 'DPNT'
      and b.business_group_id = l_business_group_id
      and l_end_dt between a.effective_start_date
                            and a.effective_end_date;
--
cursor delete_c is
   select a.person_id
		,a.person_type_usage_id
		,a.object_version_number
		,a.person_type_id
		,a.effective_start_date
		,a.effective_end_date
     from per_person_type_usages_f a,
          per_person_types         b
    where a.person_id = l_dpnt_person_id
      and a.person_type_id = b.person_type_id
      and b.system_person_type = 'DPNT'
      and b.business_group_id = l_business_group_id
      and a.effective_start_date > l_end_dt;

begin
--

  hr_utility.set_location(' Entering:'||l_proc, 10);

  open get_dpnt_info_c;
  fetch get_dpnt_info_c into l_dpnt_person_id,
                             l_cvg_strt_dt,
                             l_business_group_id;
  --
  if get_dpnt_info_c%NOTFOUND then
    -- error
    null;
    --
  end if;
  --
  close get_dpnt_info_c;

  hr_utility.set_location('Dependent Person Id : '||l_dpnt_person_id , 20);

  --
  if p_cvg_thru_dt is not null then
     l_end_dt := p_cvg_thru_dt;
  else
     l_end_dt := l_cvg_strt_dt;
  end if;
  --
  --
  open other_dpnt_c;
  fetch other_dpnt_c into l_exist;
  if other_dpnt_c%NOTFOUND then
    --

	-- delete all future ptu's of type 'DPNT', as this one extends to end-of-time

	l_datetrack_mode := hr_api.g_zap ;

	for del_rec in delete_c loop
                --- due to nocopy  the p_effective date is nulifile because
                --- the same variable sent to p_effective_start_date
                --- this is fixed by sending different variabale as p_effective_date

	        l_effective_date := del_rec.effective_start_date ;
                --
		hr_per_type_usage_internal.delete_person_type_usage
		(p_validate               =>  FALSE
		,p_person_type_usage_id   =>  del_rec.person_type_usage_id
		,p_effective_date         =>  l_effective_date -- p_effective_date # 2744060
		,p_datetrack_mode         =>  l_datetrack_mode
		,p_object_version_number  =>  del_rec.object_version_number
		,p_effective_start_date   =>  del_rec.effective_start_date
		,p_effective_end_date     =>  del_rec.effective_end_date
		);
		hr_utility.set_location('Delete Person Type Usage Id : '||del_rec.person_type_usage_id , 30);
	end loop;


		-- set the effective_end_date to end-of-time
		-- update table directly as this is not supported by row handler.
	for cur_rec in usage_c loop
		l_datetrack_mode := hr_api.g_correction;
		l_effective_end_date := hr_api.g_eot;

		update per_person_type_usages_f ptu
		   set effective_end_date = l_effective_end_date
		 where ptu.person_type_usage_id = cur_rec.person_type_usage_id
		   and ptu.effective_start_date = cur_rec.effective_start_date;

		hr_utility.set_location('Un-end-date Person Type Usage Id : '||cur_rec.person_type_usage_id , 30);
    end loop;
  --
  end if;
  --
  close other_dpnt_c;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end un_end_date_dpnt_ptu;

----------------------------------------------------------------------------
-- |------------------------< un_end_date_dpnt_pea >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--  Bug: 5572910. Added new method un_end_date_dpnt_pea to un_end_date PEA records which in
--       turn will un end CCP records if the life event is backed out.
--  Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type
--   p_validate                     No   boolean
--   p_elig_cvrd_dpnt_id            Yes  number
--   p_effective_date               Yes  date
--
-- Post Success:
--   THE PEA and Dependent's CERT is un-end-dated.
--
-- Post Failure:
--   The procedure passes the failure to the calling procedure. The calling procedure
--   should handle the failure
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure un_end_date_dpnt_pea
	(p_validate                       in     boolean  default false
	,p_elig_cvrd_dpnt_id              in     number
	,p_effective_date                 in     date
	) is
--
--
-- Declare cursors and local variables
--
l_proc                    varchar2(72) := g_package||'un_end_date_dpnt_pea';
l_cvg_strt_dt             date;
--
--
cursor c_get_dpnt_info is
  select dpnt_person_id,
         cvg_strt_dt,
         business_group_id,
	 prtt_enrt_rslt_id
    from ben_elig_cvrd_dpnt_f
   where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
--
cursor c_pea(p_prtt_enrt_rslt_id number) is
  --
   select pea.prtt_enrt_actn_id,
	  pea.effective_start_date,
	  pea.effective_end_date,
	  pea.object_version_number,
	  pen.object_version_number rslt_object_version_number
     from ben_prtt_enrt_actn_f pea,
	  ben_prtt_enrt_rslt_f pen
    where pea.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
      and pen.prtt_enrt_rslt_stat_cd is null
      and p_effective_date between pea.effective_start_date
		               and pea.effective_end_date
      and p_effective_date between pen.effective_start_date
			       and pen.effective_end_date;
  --
l_dpnt_person_id          number(15);
l_business_group_id       number(15);
l_prtt_enrt_rslt_id       number;
l_effective_date	  date;
l_effective_start_date    date;
l_effective_end_date	  date;
l_rslt_object_version_number number;
l_datetrack_mode         varchar2(30);
--
begin
--
  hr_utility.set_location(' Entering:'||l_proc, 10);
--
  open c_get_dpnt_info;
  fetch c_get_dpnt_info into l_dpnt_person_id,
                             l_cvg_strt_dt,
                             l_business_group_id,
			     l_prtt_enrt_rslt_id;
  --
  if c_get_dpnt_info%NOTFOUND then
    null;
    --
  end if;
  --
  close c_get_dpnt_info;

  hr_utility.set_location('Dependent Person Id : '||l_dpnt_person_id , 20);
  --
  for l_usage_pea in c_pea(l_prtt_enrt_rslt_id)
    loop
    --
        l_effective_date := l_usage_pea.effective_start_date ;
	if l_usage_pea.effective_end_date <> hr_api.g_eot then
    --
	ben_PRTT_ENRT_ACTN_api.delete_PRTT_ENRT_ACTN
	  (p_validate              => FALSE,
           p_effective_date        => l_effective_date,
           p_business_group_id     => l_business_group_id,
           p_datetrack_mode        => hr_api.g_future_change,
           p_object_version_number => l_usage_pea.object_version_number,
           p_prtt_enrt_rslt_id     => l_prtt_enrt_rslt_id,
           p_rslt_object_version_number => l_usage_pea.rslt_object_version_number,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_prtt_enrt_actn_id     => l_usage_pea.prtt_enrt_actn_id );

	end if;
   --
  end loop;
   --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end un_end_date_dpnt_pea;

-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_CVRD_DPNT >----------------------|
-- ----------------------------------------------------------------------------
-- !!! THIS IS OVERLOADED. CHANGE THE OTHE PROCEDURE ALSO !!!
procedure delete_ELIG_CVRD_DPNT
  (p_validate                       in  boolean  default false
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_ELIG_CVRD_DPNT';
  l_object_version_number     ben_elig_cvrd_dpnt_f.object_version_number%TYPE;
  l_effective_start_date      ben_elig_cvrd_dpnt_f.effective_start_date%TYPE;
  l_effective_end_date        ben_elig_cvrd_dpnt_f.effective_end_date%TYPE;
  l_parent_effective_end_date ben_elig_cvrd_dpnt_f.effective_end_date%TYPE;
  l2_object_version_number    ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l2_effective_start_date     ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l2_effective_end_date       ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
  l3_object_version_number    ben_prmry_care_prvdr_f.object_version_number%TYPE;
  l3_effective_start_date     ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l3_effective_end_date       ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  l2_datetrack_mode           varchar2(30);
  l_child_effective_date      date;
  --
  cursor dpnt_info_c is
    select cvg_strt_dt,
           cvg_thru_dt,
           dpnt_person_id,
           prtt_enrt_rslt_id,
           per_in_ler_id
      from ben_elig_cvrd_dpnt_f
      where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
        and business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
  --
  l_previous_values     dpnt_info_c%rowtype;
  --
 cursor parent_c(cp_prtt_enrt_actn_id number,cp_effective_date date) is
     select effective_end_date
     from   ben_prtt_enrt_actn_f
     where  prtt_enrt_actn_id = cp_prtt_enrt_actn_id
     and    business_group_id + 0 = p_business_group_id
     and    cp_effective_date between effective_start_date and effective_end_date

 ;

  cursor dpnt_ctfn_c is
     select cvrd_dpnt_ctfn_prvdd_id,
            prtt_enrt_actn_id,
            object_version_number,
            effective_start_date,
            effective_end_date
       from ben_cvrd_dpnt_ctfn_prvdd_f
       where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
        and business_group_id = p_business_group_id
         and l_child_effective_date between effective_start_date
                                  and effective_end_date
      order by cvrd_dpnt_ctfn_prvdd_id asc;
  --
  cursor dpnt_pcp_c is
     select prmry_care_prvdr_id,
            object_version_number
       from  ben_prmry_care_prvdr_f
       where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
       and   business_group_id = p_business_group_id
       and   p_effective_date between effective_start_date
                                  and effective_end_date;
  --
  cursor c_chg_info (p_prtt_enrt_rslt_id  number) is
  SELECT pen.pl_id,
         pen.oipl_id,
         pen.person_id
  FROM   ben_prtt_enrt_rslt_f pen
  WHERE  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    pen.prtt_enrt_rslt_stat_cd is null
  and    p_effective_date between pen.effective_start_date and pen.effective_end_date;
  --
  -- Bug 4879122
  --
  l_dpnt_pcp_actn_typ_id   NUMBER (30);
  --
  CURSOR c_dpnt_pcp_actn_item
  IS
     SELECT pea.object_version_number, pea.prtt_enrt_actn_id,
            pea.prtt_enrt_rslt_id, pea.effective_end_date -- 5096675
       FROM ben_prtt_enrt_actn_f pea
      WHERE pea.business_group_id = p_business_group_id
        AND p_effective_date BETWEEN pea.effective_start_date
                                 AND pea.effective_end_date
        AND pea.actn_typ_id = l_dpnt_pcp_actn_typ_id
        AND pea.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id;
  --
  l_chg_info    c_chg_info%rowtype;
  l_env_rec                ben_env_object.g_global_env_rec_type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if ben_back_out_life_event.g_bolfe_effective_date is not null then
    l_child_effective_date:=ben_back_out_life_event.g_bolfe_effective_date;
  else
    l_child_effective_date:=p_effective_date;
  end if;
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.effective_date is null then
      --
      ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
      --
    end if;
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_CVRD_DPNT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  -- Delete certifications
  --
  for ctfn_rec in dpnt_ctfn_c loop
   --
   l2_object_version_number := ctfn_rec.object_version_number;

--   open  parent_c(ctfn_rec.prtt_enrt_actn_id,l_child_effective_date);
--   fetch parent_c into l_parent_effective_end_date;
--   close parent_c;

   if p_datetrack_mode <> hr_api.g_future_change then
--and
--      (ctfn_rec.effective_end_date = hr_api.g_eot or
--       l_parent_effective_end_date = hr_api.g_eot)) then
     ben_cvrd_dpnt_ctfn_prvdd_api.delete_cvrd_dpnt_ctfn_prvdd
       (p_validate                 => FALSE
       ,p_cvrd_dpnt_ctfn_prvdd_id  => ctfn_rec.cvrd_dpnt_ctfn_prvdd_id
       ,p_effective_start_date     => l2_effective_start_date
       ,p_effective_end_date       => l2_effective_end_date
       ,p_object_version_number    => l2_object_version_number
       ,p_business_group_id        => p_business_group_id
       ,p_effective_date           => l_child_effective_date
       ,p_datetrack_mode           => p_datetrack_mode
       );
  end if;

    --
  end loop;
  --
  --
  -- Delete Primary Care Providers.
  --
  for pcp_rec in dpnt_pcp_c loop
     --
     l3_object_version_number := pcp_rec.object_version_number;
     --
     ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
     (p_validate                 => FALSE
     ,p_prmry_care_prvdr_id      => pcp_rec.prmry_care_prvdr_id
     ,p_effective_start_date     => l3_effective_start_date
     ,p_effective_end_date       => l3_effective_end_date
     ,p_object_version_number    => l3_object_version_number
     ,p_effective_date           => p_effective_date
     ,p_datetrack_mode           => p_datetrack_mode
     ,p_called_from            => 'delete_enrollment'
     );
    --
  end loop;
  --
  -- Bug 4879122
  -- Delete Primary Care Providers Action Item.
  --
  l_dpnt_pcp_actn_typ_id := ben_enrollment_action_items.get_actn_typ_id
                                          (p_type_cd                => 'PCPDPNT',
                                           p_business_group_id      => p_business_group_id
                                          );
  --
  hr_utility.set_location('ACE l_dpnt_pcp_actn_typ_id = ' ||l_dpnt_pcp_actn_typ_id, 9999);
  --
  FOR l_dpnt_pcp_actn_item_rec IN c_dpnt_pcp_actn_item
  LOOP
     --
     hr_utility.set_location ('ACE prtt_enrt_actn_id = ' || l_dpnt_pcp_actn_item_rec.prtt_enrt_actn_id, 9999);
     --
     l3_object_version_number := l_dpnt_pcp_actn_item_rec.object_version_number;
     --
     -- 5096675, If Only one record exist in PEA for future change mode, dont call delete api
     if not ( p_datetrack_mode = hr_api.g_future_change and
          l_dpnt_pcp_actn_item_rec.effective_end_date = hr_api.g_eot ) then --5096675 rbingi
      --
       ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
          (p_validate                        => FALSE,
           p_effective_date                  => p_effective_date,
           p_business_group_id               => p_business_group_id,
           p_datetrack_mode                  => p_datetrack_mode,
           p_object_version_number           => l3_object_version_number,
           p_prtt_enrt_rslt_id               => l_dpnt_pcp_actn_item_rec.prtt_enrt_rslt_id,
           p_rslt_object_version_number      => l3_object_version_number,
           p_post_rslt_flag                  => 'N',
           p_unsuspend_enrt_flag             => 'Y',
           p_effective_start_date            => l3_effective_start_date,
           p_effective_end_date              => l3_effective_end_date,
           p_prtt_enrt_actn_id               => l_dpnt_pcp_actn_item_rec.prtt_enrt_actn_id
          );
          --
     end if;
     --
  END LOOP;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk3.delete_ELIG_CVRD_DPNT_b
      (
       p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_CVRD_DPNT
    --
  end;
  --
  open dpnt_info_c;
  fetch dpnt_info_c into l_previous_values;
  close dpnt_info_c;
  --
  if l_previous_values.cvg_strt_dt is not null and l_previous_values.cvg_thru_dt = hr_api.g_eot then
--
-- Added by pxdas for logging change event needed for extract.
--
    open c_chg_info(l_previous_values.prtt_enrt_rslt_id);
    fetch c_chg_info into l_chg_info;
    close c_chg_info;
    --
--  Call the extract change event logging process.
--
    ben_ext_chlg.log_dependent_chg
       (p_action               => 'DELETE',
        p_pl_id                => l_chg_info.pl_id,
        p_oipl_id              => l_chg_info.oipl_id,
        p_cvg_strt_dt          => l_previous_values.cvg_strt_dt,
        p_cvg_end_dt           => (l_previous_values.cvg_strt_dt-1),
        p_old_cvg_strt_dt      => l_previous_values.cvg_strt_dt,
        p_old_cvg_end_dt       => l_previous_values.cvg_thru_dt,
        p_prtt_enrt_rslt_id    => l_previous_values.prtt_enrt_rslt_id,
        p_per_in_ler_id        => l_previous_values.per_in_ler_id,
        p_elig_cvrd_dpnt_id    => p_elig_cvrd_dpnt_id,
        p_person_id            => l_chg_info.person_id,
        p_dpnt_person_id       => l_previous_values.dpnt_person_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => p_effective_date);
--
      if p_datetrack_mode = 'DELETE' then
        l2_datetrack_mode := 'DELETE';
      else
        l2_datetrack_mode := 'ZAP';
        --
      end if;
      --
      remove_usage (
       p_validate                 => p_validate
      ,p_elig_cvrd_dpnt_id        => p_elig_cvrd_dpnt_id
      ,p_cvg_thru_dt              => null
      ,p_effective_date           => p_effective_date
      ,p_datetrack_mode           => l2_datetrack_mode
       );
    --
 end if;
  --
  ben_pdp_del.del
    (
     p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
    --
    -- Bug No 4214527 Moved out the call to dpnt_actn_items after del
    --  Call Action item RCO if p_multi_row_actn = TRUE
    --
    if p_multi_row_actn then
    --
    dpnt_actn_items(
           p_prtt_enrt_rslt_id  => null
          ,p_elig_cvrd_dpnt_id  => p_elig_cvrd_dpnt_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => null
          ,p_validate           => p_validate
          ,p_datetrack_mode     => p_datetrack_mode
          );
    --
    end if;
  --
  --
  --
  --
  -- Delete certifications
  --
if p_datetrack_mode=hr_api.g_future_change then
  for ctfn_rec in dpnt_ctfn_c loop
   --
   l2_object_version_number := ctfn_rec.object_version_number;

   open  parent_c(ctfn_rec.prtt_enrt_actn_id,l_child_effective_date);
   fetch parent_c into l_parent_effective_end_date;
   close parent_c;

   if p_datetrack_mode = hr_api.g_future_change and
      ctfn_rec.effective_end_date<>hr_api.g_eot and
      l_parent_effective_end_date = hr_api.g_eot then
     ben_cvrd_dpnt_ctfn_prvdd_api.delete_cvrd_dpnt_ctfn_prvdd
       (p_validate                 => FALSE
       ,p_cvrd_dpnt_ctfn_prvdd_id  => ctfn_rec.cvrd_dpnt_ctfn_prvdd_id
       ,p_effective_start_date     => l2_effective_start_date
       ,p_effective_end_date       => l2_effective_end_date
       ,p_object_version_number    => l2_object_version_number
       ,p_business_group_id        => p_business_group_id
       ,p_effective_date           => l_child_effective_date
       ,p_datetrack_mode           => p_datetrack_mode
       );
  end if;

    --
  end loop;
end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk3.delete_ELIG_CVRD_DPNT_a
      (
       p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_CVRD_DPNT
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
    ROLLBACK TO delete_ELIG_CVRD_DPNT;
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
    ROLLBACK TO delete_ELIG_CVRD_DPNT;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_ELIG_CVRD_DPNT;
--
-- Overloaded Procedure.   2386000
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_CVRD_DPNT >----------------------|
-- ----------------------------------------------------------------------------
procedure delete_ELIG_CVRD_DPNT
  (p_validate                       in  boolean  default false
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  ,p_called_from                    in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_ELIG_CVRD_DPNT';
  l_object_version_number     ben_elig_cvrd_dpnt_f.object_version_number%TYPE;
  l_effective_start_date      ben_elig_cvrd_dpnt_f.effective_start_date%TYPE;
  l_effective_end_date        ben_elig_cvrd_dpnt_f.effective_end_date%TYPE;
  l_parent_effective_end_date ben_elig_cvrd_dpnt_f.effective_end_date%TYPE;
  l2_object_version_number    ben_cvrd_dpnt_ctfn_prvdd_f.object_version_number%TYPE;
  l2_effective_start_date     ben_cvrd_dpnt_ctfn_prvdd_f.effective_start_date%TYPE;
  l2_effective_end_date       ben_cvrd_dpnt_ctfn_prvdd_f.effective_end_date%TYPE;
  l3_object_version_number    ben_prmry_care_prvdr_f.object_version_number%TYPE;
  l3_effective_start_date     ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l3_effective_end_date       ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  l2_datetrack_mode           varchar2(30);
  l_child_effective_date      date;
  --
  cursor dpnt_info_c is
    select cvg_strt_dt,
           cvg_thru_dt,
           dpnt_person_id,
           prtt_enrt_rslt_id,
           per_in_ler_id
      from ben_elig_cvrd_dpnt_f
      where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
        and business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
  --
  l_previous_values     dpnt_info_c%rowtype;
  --
 cursor parent_c(cp_prtt_enrt_actn_id number,cp_effective_date date) is
     select effective_end_date
     from   ben_prtt_enrt_actn_f
     where  prtt_enrt_actn_id = cp_prtt_enrt_actn_id
     and    business_group_id + 0 = p_business_group_id
     and    cp_effective_date between effective_start_date and effective_end_date

 ;

  cursor dpnt_ctfn_c is
     select cvrd_dpnt_ctfn_prvdd_id,
            prtt_enrt_actn_id,
            object_version_number,
            effective_start_date,
            effective_end_date
       from ben_cvrd_dpnt_ctfn_prvdd_f
       where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
        and business_group_id = p_business_group_id
         and l_child_effective_date between effective_start_date
                                  and effective_end_date
      order by cvrd_dpnt_ctfn_prvdd_id asc;
  --
  cursor dpnt_pcp_c is
     select prmry_care_prvdr_id,
            object_version_number
       from  ben_prmry_care_prvdr_f
       where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
       and   business_group_id = p_business_group_id
       and   p_effective_date between effective_start_date
                                  and effective_end_date;
  --
  cursor c_chg_info (p_prtt_enrt_rslt_id  number) is
  SELECT pen.pl_id,
         pen.oipl_id,
         pen.person_id
  FROM   ben_prtt_enrt_rslt_f pen
  WHERE  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and    pen.prtt_enrt_rslt_stat_cd is null
  and    p_effective_date between pen.effective_start_date and pen.effective_end_date;
  --
  -- Bug 4879122
  --
  l_dpnt_pcp_actn_typ_id   NUMBER (30);
  --
  CURSOR c_dpnt_pcp_actn_item
  IS
     SELECT pea.object_version_number, pea.prtt_enrt_actn_id,
            pea.prtt_enrt_rslt_id, pea.effective_end_date -- 5096675
       FROM ben_prtt_enrt_actn_f pea
      WHERE pea.business_group_id = p_business_group_id
        AND p_effective_date BETWEEN pea.effective_start_date
                                 AND pea.effective_end_date
        AND pea.actn_typ_id = l_dpnt_pcp_actn_typ_id
        AND pea.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id;
  --
  l_chg_info    c_chg_info%rowtype;
  l_env_rec                ben_env_object.g_global_env_rec_type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if ben_back_out_life_event.g_bolfe_effective_date is not null then
    l_child_effective_date:=ben_back_out_life_event.g_bolfe_effective_date;
  else
    l_child_effective_date:=p_effective_date;
  end if;
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.effective_date is null then
      --
      ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
      --
    end if;
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_CVRD_DPNT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  -- Delete certifications
  --
  for ctfn_rec in dpnt_ctfn_c loop
   --
   l2_object_version_number := ctfn_rec.object_version_number;

--   open  parent_c(ctfn_rec.prtt_enrt_actn_id,l_child_effective_date);
--   fetch parent_c into l_parent_effective_end_date;
--   close parent_c;

   if p_datetrack_mode <> hr_api.g_future_change then
--and
--      (ctfn_rec.effective_end_date = hr_api.g_eot or
--       l_parent_effective_end_date = hr_api.g_eot)) then
     ben_cvrd_dpnt_ctfn_prvdd_api.delete_cvrd_dpnt_ctfn_prvdd
       (p_validate                 => FALSE
       ,p_cvrd_dpnt_ctfn_prvdd_id  => ctfn_rec.cvrd_dpnt_ctfn_prvdd_id
       ,p_effective_start_date     => l2_effective_start_date
       ,p_effective_end_date       => l2_effective_end_date
       ,p_object_version_number    => l2_object_version_number
       ,p_business_group_id        => p_business_group_id
       ,p_effective_date           => l_child_effective_date
       ,p_datetrack_mode           => p_datetrack_mode
       ,p_called_from              => p_called_from
       );
  end if;

    --
  end loop;
  --
  --
  -- Delete Primary Care Providers.
  --
  for pcp_rec in dpnt_pcp_c loop
     --
     l3_object_version_number := pcp_rec.object_version_number;
     --
     ben_prmry_care_prvdr_api.delete_prmry_care_prvdr
     (p_validate                 => FALSE
     ,p_prmry_care_prvdr_id      => pcp_rec.prmry_care_prvdr_id
     ,p_effective_start_date     => l3_effective_start_date
     ,p_effective_end_date       => l3_effective_end_date
     ,p_object_version_number    => l3_object_version_number
     ,p_effective_date           => p_effective_date
     ,p_datetrack_mode           => p_datetrack_mode
     ,p_called_from            => 'delete_enrollment'
     );
    --
  end loop;
  --
  -- Bug 4879122
  -- Delete Primary Care Providers Action Item.
  --
  l_dpnt_pcp_actn_typ_id := ben_enrollment_action_items.get_actn_typ_id
                                          (p_type_cd                => 'PCPDPNT',
                                           p_business_group_id      => p_business_group_id
                                          );
  --
  hr_utility.set_location('ACE l_dpnt_pcp_actn_typ_id = ' ||l_dpnt_pcp_actn_typ_id, 9999);
  --
  FOR l_dpnt_pcp_actn_item_rec IN c_dpnt_pcp_actn_item
  LOOP
     --
     hr_utility.set_location ('ACE prtt_enrt_actn_id = ' || l_dpnt_pcp_actn_item_rec.prtt_enrt_actn_id, 9999);
     --
     l3_object_version_number := l_dpnt_pcp_actn_item_rec.object_version_number;
     --
     -- 5096675, If Only one record exist in PEA for future change mode, dont call delete api
     if not ( p_datetrack_mode = hr_api.g_future_change and
          l_dpnt_pcp_actn_item_rec.effective_end_date = hr_api.g_eot ) then --5096675 rbingi
      --
      ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
          (p_validate                        => FALSE,
           p_effective_date                  => p_effective_date,
           p_business_group_id               => p_business_group_id,
           p_datetrack_mode                  => p_datetrack_mode,
           p_object_version_number           => l3_object_version_number,
           p_prtt_enrt_rslt_id               => l_dpnt_pcp_actn_item_rec.prtt_enrt_rslt_id,
           p_rslt_object_version_number      => l3_object_version_number,
           p_post_rslt_flag                  => 'N',
           p_unsuspend_enrt_flag             => 'Y',
           p_effective_start_date            => l3_effective_start_date,
           p_effective_end_date              => l3_effective_end_date,
           p_prtt_enrt_actn_id               => l_dpnt_pcp_actn_item_rec.prtt_enrt_actn_id
          );
          --
     end if;
     --
  END LOOP;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk3.delete_ELIG_CVRD_DPNT_b
      (
       p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_CVRD_DPNT
    --
  end;
  --
  open dpnt_info_c;
  fetch dpnt_info_c into l_previous_values;
  close dpnt_info_c;
  --
  if l_previous_values.cvg_strt_dt is not null and l_previous_values.cvg_thru_dt = hr_api.g_eot then
--
-- Added by pxdas for logging change event needed for extract.
--
    open c_chg_info(l_previous_values.prtt_enrt_rslt_id);
    fetch c_chg_info into l_chg_info;
    close c_chg_info;
    --
--  Call the extract change event logging process.
--
    ben_ext_chlg.log_dependent_chg
       (p_action               => 'DELETE',
        p_pl_id                => l_chg_info.pl_id,
        p_oipl_id              => l_chg_info.oipl_id,
        p_cvg_strt_dt          => l_previous_values.cvg_strt_dt,
        p_cvg_end_dt           => (l_previous_values.cvg_strt_dt-1),
        p_old_cvg_strt_dt      => l_previous_values.cvg_strt_dt,
        p_old_cvg_end_dt       => l_previous_values.cvg_thru_dt,
        p_prtt_enrt_rslt_id    => l_previous_values.prtt_enrt_rslt_id,
        p_per_in_ler_id        => l_previous_values.per_in_ler_id,
        p_elig_cvrd_dpnt_id    => p_elig_cvrd_dpnt_id,
        p_person_id            => l_chg_info.person_id,
        p_dpnt_person_id       => l_previous_values.dpnt_person_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => p_effective_date);
--
      if p_datetrack_mode = 'DELETE' then
        l2_datetrack_mode := 'DELETE';
      else
        l2_datetrack_mode := 'ZAP';
        --
      end if;
      --
      /*
		Bug: 1485862. To un_end_date 'DPNT' person_type_usage for the dependents if
		the employee's termination event is backed out.
      */
		if (p_called_from = 'benbolfe') then
			 un_end_date_dpnt_ptu (
			   p_validate                 => p_validate
			  ,p_elig_cvrd_dpnt_id        => p_elig_cvrd_dpnt_id
			  ,p_cvg_thru_dt              => null
			  ,p_effective_date           => p_effective_date
			  ,p_datetrack_mode           => l2_datetrack_mode
			   );
			   un_end_date_dpnt_pea
			   (
			   p_validate                => p_validate
		 	  ,p_elig_cvrd_dpnt_id       => p_elig_cvrd_dpnt_id
			  ,p_effective_date          => p_effective_date);
		 else
			  remove_usage (
			   p_validate                 => p_validate
			  ,p_elig_cvrd_dpnt_id        => p_elig_cvrd_dpnt_id
			  ,p_cvg_thru_dt              => null
			  ,p_effective_date           => p_effective_date
			  ,p_datetrack_mode           => l2_datetrack_mode
			   );
		 end if;
      /*
		Bug: 1485862. To un_end_date 'DPNT' person_type_usage for the dependents if
		the employee's termination event is backed out.
      */
  end if;
  --
  ben_pdp_del.del
    (
     p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
    --
    -- Bug No 4214527 Moved out call to dpnt_actn_items after del
    --  Call Action item RCO if p_multi_row_actn = TRUE
    --
    if p_multi_row_actn then
    --
    dpnt_actn_items(
           p_prtt_enrt_rslt_id  => null
          ,p_elig_cvrd_dpnt_id  => p_elig_cvrd_dpnt_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => null
          ,p_validate           => p_validate
          ,p_datetrack_mode     => p_datetrack_mode
          );
    --
    end if;
  --
  --
  --
  --
  -- Delete certifications
  --
if p_datetrack_mode=hr_api.g_future_change then
  for ctfn_rec in dpnt_ctfn_c loop
   --
   l2_object_version_number := ctfn_rec.object_version_number;

   open  parent_c(ctfn_rec.prtt_enrt_actn_id,l_child_effective_date);
   fetch parent_c into l_parent_effective_end_date;
   close parent_c;

   if p_datetrack_mode = hr_api.g_future_change and
      ctfn_rec.effective_end_date<>hr_api.g_eot and
      l_parent_effective_end_date = hr_api.g_eot then
     ben_cvrd_dpnt_ctfn_prvdd_api.delete_cvrd_dpnt_ctfn_prvdd
       (p_validate                 => FALSE
       ,p_cvrd_dpnt_ctfn_prvdd_id  => ctfn_rec.cvrd_dpnt_ctfn_prvdd_id
       ,p_effective_start_date     => l2_effective_start_date
       ,p_effective_end_date       => l2_effective_end_date
       ,p_object_version_number    => l2_object_version_number
       ,p_business_group_id        => p_business_group_id
       ,p_effective_date           => l_child_effective_date
       ,p_datetrack_mode           => p_datetrack_mode
       ,p_called_from              => p_called_from
       );
  end if;

    --
  end loop;
end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_CVRD_DPNT
    --
    ben_ELIG_CVRD_DPNT_bk3.delete_ELIG_CVRD_DPNT_a
      (
       p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_CVRD_DPNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_CVRD_DPNT
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
    ROLLBACK TO delete_ELIG_CVRD_DPNT;
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
    ROLLBACK TO delete_ELIG_CVRD_DPNT;
    raise;
    --
end delete_ELIG_CVRD_DPNT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_cvrd_dpnt_id                   in     number
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
  ben_pdp_shd.lck
    (
      p_elig_cvrd_dpnt_id                 => p_elig_cvrd_dpnt_id
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
-- ----------------------------------------------------------------------------
-- |-------------------------------< dpnt_actn_items >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure dpnt_actn_items
  (
   p_prtt_enrt_rslt_id              in     number
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_validate                       in     boolean default false
  ,p_datetrack_mode                 in     varchar2
  ) is
--
l_proc varchar2(72) := g_package||'dpnt_actn_items';
l_prtt_enrt_rslt_id   number(15);
l_business_group_id   number(15);
l_rslt_object_version_number number(9);
l_suspend_flag        varchar2(30);
l_dpnt_actn_warning   boolean;
--Bug No 4525608 new dummy variable to pass to process_dpnt_actn_items
l_ctfn_actn_warning   boolean;
--End Bug 4525608
l_pcp_dpnt_actn_warning   boolean;
--
cursor get_rslt_id_c is
   select prtt_enrt_rslt_id,
          business_group_id
    from ben_elig_cvrd_dpnt_f
    where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
      and p_effective_date between effective_start_date
                               and effective_end_date;
--
cursor get_rslt_ovn_c is
   select object_version_number,
          sspndd_flag
   from   ben_prtt_enrt_rslt_f
   where  prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
   and business_group_id = l_business_group_id
   and prtt_enrt_rslt_stat_cd is null
   and p_effective_date between effective_start_date and effective_end_date
   and p_effective_date < enrt_cvg_thru_dt ; -- 5173425: Need not determine dpnts for End-dated enrollments.
--
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   if p_prtt_enrt_rslt_id is null or
      p_business_group_id is null then
      open get_rslt_id_c;
      fetch get_rslt_id_c into l_prtt_enrt_rslt_id,
                               l_business_group_id;
      close get_rslt_id_c;
   else
      l_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
      l_business_group_id := p_business_group_id;
   end if;
   --
   if l_prtt_enrt_rslt_id is not null then
   --
     open get_rslt_ovn_c;
     fetch get_rslt_ovn_c into l_rslt_object_version_number,
                               l_suspend_flag;
     close get_rslt_ovn_c;
     --
     if l_rslt_object_version_number IS NOT NULL then -- 5173425: Added this condition
         ben_enrollment_action_items.process_dpnt_actn_items(
                        p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id
                       ,p_rslt_object_version_number => l_rslt_object_version_number
                       ,p_effective_date    => trunc(p_effective_date)
                       ,p_business_group_id => l_business_group_id
                       ,p_validate          => FALSE
                       ,p_datetrack_mode    => p_datetrack_mode
                       ,p_suspend_flag      => l_suspend_flag
                       ,p_dpnt_actn_warning => l_dpnt_actn_warning
               --Bug No 4525608 new dummy variable to pass to process_dpnt_actn_items
                       ,p_ctfn_actn_warning => l_ctfn_actn_warning
                       );
               --End Bug 4525608
         --
         ben_enrollment_action_items.process_pcp_dpnt_actn_items(
                        p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id
                       ,p_rslt_object_version_number => l_rslt_object_version_number
                       ,p_effective_date    => trunc(p_effective_date)
                       ,p_business_group_id => l_business_group_id
                       ,p_validate          => FALSE
                       ,p_datetrack_mode    => p_datetrack_mode
                       ,p_suspend_flag      => l_suspend_flag
                       ,p_pcp_dpnt_actn_warning => l_pcp_dpnt_actn_warning
                       );
        end if; -- 5173425
     --
   end if;
   --
   hr_utility.set_location('Exiting:'|| l_proc, 40);
   --
end dpnt_actn_items;
--
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< add_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_usage   (
   p_validate                       in     boolean  default false
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'add_usage';
  --
  l_person_type_id            number(15);
  l_person_type_usage_id      number(15);
  l_per_effective_start_date  date;
  l_effective_start_date      per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date        per_person_type_usages_f.effective_end_date%TYPE;
  l1_person_type_usage_id     number(15);
  l1_effective_start_date     per_person_type_usages_f.effective_start_date%TYPE;
  l1_effective_end_date       per_person_type_usages_f.effective_end_date%TYPE;
  l_object_version_number     per_person_type_usages_f.object_version_number%TYPE;
  --
  l_dpnt_person_id          number(15);
  l_cvg_strt_dt             date;
  l_business_group_id       number(15);
  --
  cursor get_dpnt_info_c is
    select dpnt_person_id,
           cvg_strt_dt,
           business_group_id
    from ben_elig_cvrd_dpnt_f
    where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
--
--
  cursor get_person_info_c is
     select min(per.effective_start_date)
     from   per_all_people_f per
     where  per.person_id = l_dpnt_person_id;
--
--
  cursor get_dpnt_type_id_c is
    select person_type_id
      from per_person_types
      where system_person_type = 'DPNT'
        and business_group_id = l_business_group_id;
  --
  -- find overlapping ptu segments
  --
  cursor find_ptu_ovlp_segments_c is
    select a.effective_start_date,
           a.effective_end_date,
           a.person_type_usage_id
    from per_person_type_usages_f    a
    where a.person_id = l_dpnt_person_id
      and a.person_type_id = l_person_type_id
--      and a.effective_start_date <= hr_api.g_date
      and a.effective_end_date >= l_cvg_strt_dt
      order by a.effective_start_date  -- 5604361
     ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open get_dpnt_info_c;
  fetch get_dpnt_info_c into l_dpnt_person_id,
                             l_cvg_strt_dt,
                             l_business_group_id;
  --
  if get_dpnt_info_c%NOTFOUND then
    -- error
    close get_dpnt_info_c;
    return;
    --
  end if;
  --
  close get_dpnt_info_c;
  --
  -- get the minimum effective start date of the dependents record.
  --
  open  get_person_info_c;
  fetch get_person_info_c into l_per_effective_start_date;
  close get_person_info_c;
  --
  -- Person type usage cannot start before the person exists.
  --
  if l_per_effective_start_date > l_cvg_strt_dt then
    l_cvg_strt_dt := l_per_effective_start_date;
  end if;
  --
  --
  -- get type id
  --
  open get_dpnt_type_id_c;
  fetch get_dpnt_type_id_c into l_person_type_id;
  if get_dpnt_type_id_c%FOUND then
    --
    open find_ptu_ovlp_segments_c;
    fetch find_ptu_ovlp_segments_c into l_effective_start_date,
                                               l_effective_end_date,
                                               l_person_type_usage_id;
    if find_ptu_ovlp_segments_c%NOTFOUND then
      --
      -- call create person_type usage api
      --
      hr_per_type_usage_internal.create_person_type_usage
               (p_validate               => FALSE
               ,p_person_id              => l_dpnt_person_id
               ,p_person_type_id         => l_person_type_id
               ,p_effective_date         => l_cvg_strt_dt
               ,p_person_type_usage_id   => l1_person_type_usage_id
               ,p_object_version_number  => l_object_version_number
               ,p_effective_start_date   => l1_effective_start_date
               ,p_effective_end_date     => l1_effective_end_date
               );
      --
    else
      --
      -- changed all g_date to g_eot
      --
      if l_effective_start_date <= l_cvg_strt_dt and
         l_effective_end_date >= hr_api.g_eot
        then
          null;
      elsif l_effective_start_date <= l_cvg_strt_dt and
            l_effective_end_date < hr_api.g_eot
        then
            update per_person_type_usages_f
                   set effective_end_date = hr_api.g_eot
            where person_type_usage_id = l_person_type_usage_id;
      elsif l_effective_start_date > l_cvg_strt_dt and
            l_effective_end_date = hr_api.g_eot then
            --
            update per_person_type_usages_f
                   set effective_start_date = l_cvg_strt_dt
            where person_type_usage_id = l_person_type_usage_id;
      --
      elsif l_effective_start_date > l_cvg_strt_dt and
            l_effective_end_date < hr_api.g_eot  then
      --
            update per_person_type_usages_f
                   set effective_start_date = l_cvg_strt_dt,
                       effective_end_date   = hr_api.g_eot
            where person_type_usage_id = l_person_type_usage_id;
      --
      end if;
    --
    close find_ptu_ovlp_segments_c;
    --
    end if;
  --
  end if;
  --
  close get_dpnt_type_id_c;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end add_usage;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< remove_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure remove_usage (
   p_validate                       in     boolean  default false
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_cvg_thru_dt                    in     date
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ) is
--
--
-- Declare cursors and local variables
--
l_proc                    varchar2(72) := g_package||'remove_usage';
l_exist                   varchar2(1);
l_dpnt_person_id          number(15);
l_cvg_strt_dt             date;
l_end_dt                  date;
l_person_type_usage_id    number(15);
l_object_version_number   number(9);
l_effective_start_date    date;
l_eff_strt_date           date;
l_effective_end_date      date;
l_business_group_id       number(15);
l_datetrack_mode         varchar2(30);
l_eff_end_date            date;
--
--
cursor get_dpnt_info_c is
  select dpnt_person_id,
         cvg_strt_dt,
         business_group_id
    from ben_elig_cvrd_dpnt_f
   where elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and p_effective_date between effective_start_date
                              and effective_end_date;
--
cursor other_dpnt_c is
     select null
       from ben_elig_cvrd_dpnt_f a,
            ben_per_in_ler pil
         where a.dpnt_person_id = l_dpnt_person_id
           and a.elig_cvrd_dpnt_id <> p_elig_cvrd_dpnt_id
           and a.cvg_strt_dt is not null
           and a.cvg_thru_dt = hr_api.g_eot
          -- and a.cvrd_flag = 'Y'
           and l_end_dt + 1 between a.cvg_strt_dt -- Bug 5451726
                                 and nvl(a.cvg_thru_dt, hr_api.g_date)
           and p_effective_date between a.effective_start_date
                                    and a.effective_end_date
           and   a.per_in_ler_id = pil.per_in_ler_id
           and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT');
--
cursor usage_c is
   select a.person_type_usage_id,
          a.object_version_number,
          a.effective_start_date,
          a.effective_end_date
     from per_person_type_usages_f a,
          per_person_types         b
    where a.person_id = l_dpnt_person_id
      and a.person_type_id = b.person_type_id
      and b.system_person_type = 'DPNT'
      and b.business_group_id = l_business_group_id
      and l_end_dt between a.effective_start_date
                            and a.effective_end_date;
--
begin
--
  open get_dpnt_info_c;
  fetch get_dpnt_info_c into l_dpnt_person_id,
                             l_cvg_strt_dt,
                             l_business_group_id;
  --
  if get_dpnt_info_c%NOTFOUND then
    -- error
    null;
    --
  end if;
  --
  close get_dpnt_info_c;
  --
  if (p_cvg_thru_dt is not null
     and p_cvg_thru_dt > l_cvg_strt_dt) then -- 5655342
     l_end_dt := p_cvg_thru_dt;
  else
     l_end_dt := l_cvg_strt_dt;
  end if;
  --
  open other_dpnt_c;
  fetch other_dpnt_c into l_exist;
  if other_dpnt_c%NOTFOUND then
    --
    open usage_c;
    fetch usage_c into l_person_type_usage_id,
                       l_object_version_number,
                       l_eff_strt_date,
                       l_eff_end_date;
    --
        if usage_c%FOUND then
          if p_datetrack_mode = 'ZAP' then
             if l_eff_strt_date < l_end_dt then
                l_datetrack_mode := 'DELETE';
                if l_eff_end_date=l_end_dt then
                  close usage_c;
                  close other_dpnt_c;
                  hr_utility.set_location(' Leaving:'||l_proc, 64);
                  return;
                end if;
             else
                l_datetrack_mode := 'ZAP';
             end if;
          --
          -- Check to see if the row is already end dated
          --
          elsif p_datetrack_mode=hr_api.g_delete and
                l_eff_end_date=l_end_dt then
            close usage_c;
            close other_dpnt_c;
            hr_utility.set_location(' Leaving:'||l_proc, 65);
            return;
          elsif p_cvg_thru_dt <  l_eff_strt_date then  -- 5655342
              l_datetrack_mode := 'ZAP';
          else
              l_datetrack_mode := p_datetrack_mode;
          end if;
          hr_per_type_usage_internal.delete_person_type_usage
            (p_validate               =>  FALSE
            ,p_person_type_usage_id   =>  l_person_type_usage_id
            ,p_effective_date         =>  l_end_dt
            ,p_datetrack_mode         =>  l_datetrack_mode
            ,p_object_version_number  =>  l_object_version_number
            ,p_effective_start_date   =>  l_effective_start_date
            ,p_effective_end_date     =>  l_effective_end_date
            );
        --
        end if;
    --
    close usage_c;
  --
  end if;
  --
  close other_dpnt_c;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end remove_usage;
--
--
-- bug : 1418754 : Max number of dependents for a comp object enrollment
-- have to be checked as part of post-forms commit.
-- If user uncovers one dependent and covers other dependent then,
-- this check have to be done after making changes to the rows.
--
Procedure chk_max_num_dpnt_for_pen (p_prtt_enrt_rslt_id      in number,
                            p_effective_date         in date,
                            p_business_group_id      in number) as
--
  g_package     varchar2(72) := null;
  l_proc         varchar2(72) := g_package||'chk_max_num_dpnt_for_pen';
  l_api_updating boolean;
--
  l_temp                   varchar2(1);
  l_total_num_dpnt         number(15);
  l_rlshp_num_dpnt         number(15);
  -- l_person_id              number(15);
  -- l_pl_id                  number(15);
  -- l_oipl_id                number(15);
  -- l_opt_id                 number(15);
  l_contact_type          per_contact_relationships.contact_type%type; -- varchar2(30);
  l_t_mx_dpnts_alwd_num    number(15);
  l_t_no_mx_num_dfnd_flag  varchar2(1);
  l_r_mx_dpnts_alwd_num    number(15);
  l_r_no_mx_num_dfnd_flag  varchar2(1);
  l_dsgn_rqmt_id           number(15);
  l_heir                   number(15);
  l_grp_rlshp_cd           varchar2(30);
  l_grp_rlshp_meaning      varchar2(30);
  ---- Added
  l_pl_name		ben_pl_f.name%type; -- UTF8 Change Bug 2254683
  l_opt_name		ben_opt_f.name%type; -- UTF8 Change Bug 2254683
  l_rel_name		hr_lookups.meaning%type; -- UTF8 Change Bug 2254683
  --
  --  get required info
  --
  cursor info1_c is
    select r.person_id
          ,egd.dpnt_person_id
          ,r.pl_id
          ,r.oipl_id
          ,o.opt_id
          ,egd.cvg_strt_dt
          ,egd.cvg_thru_dt
    from   ben_prtt_enrt_rslt_f r,
           ben_elig_cvrd_dpnt_f egd,
           ben_oipl_f o ,
           ben_per_in_ler pil
    where  r.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  r.prtt_enrt_rslt_id = egd.prtt_enrt_rslt_id
      and  r.business_group_id + 0 = p_business_group_id
      and  r.per_in_ler_id         = egd.per_in_ler_id
      and  r.per_in_ler_id         = pil.per_in_ler_id
      and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
      and  r.prtt_enrt_rslt_stat_cd is null
      and  p_effective_date between r.effective_start_date
                                and r.effective_end_date
      and  o.oipl_id(+) = r.oipl_id
      and  o.business_group_id(+)= p_business_group_id
      and  p_effective_date between o.effective_start_date(+)
                                and o.effective_end_date(+)
      and  egd.cvg_strt_dt is not null
      and  egd.cvg_thru_dt = hr_api.g_eot
      -- bug#2151619
      and  egd.effective_end_date = hr_api.g_eot;
/*
      and  p_effective_date between egd.effective_start_date
                                and egd.effective_end_date
           ;
*/
  --

  cursor info2_c(cv_person_id number,
                 cv_dpnt_person_id number) is
    select c.contact_type
    from   per_contact_relationships  c
    where  c.person_id = cv_person_id
      and  c.contact_person_id = cv_dpnt_person_id
      -- Bug 1762932 added the personal_flag condition
      and  nvl(c.personal_flag, 'N') = 'Y'
      and  c.business_group_id  = p_business_group_id
      and  p_effective_date between nvl(c.date_start, p_effective_date)
                                and nvl(c.date_end, p_effective_date)
           ;
  --
  -- total designation requirements
  --
  cursor total_rqmt_c(cv_pl_id number,
                    cv_oipl_id number,
                    cv_opt_id  number) is
    select  mx_dpnts_alwd_num
           ,no_mx_num_dfnd_flag
           ,decode(oipl_id, null, decode(opt_id, null, 3, 2), 1) heir
      from  ben_dsgn_rqmt_f
      where
           ((nvl(pl_id, hr_api.g_number)  = cv_pl_id)
        or (nvl(oipl_id, hr_api.g_number) = cv_oipl_id)
        or (nvl(opt_id, hr_api.g_number)  = cv_opt_id))
        and dsgn_typ_cd = 'DPNT'
        and grp_rlshp_cd is null
        and business_group_id + 0 = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        order by heir
           ;

  --
  -- any designation requirements for this comp object?
  --
  cursor any_rqmt_c(cv_pl_id number,
                    cv_oipl_id number,
                    cv_opt_id  number)is
    select 's'
    from ben_dsgn_rqmt_f       r
     where ((nvl(pl_id, hr_api.g_number) = cv_pl_id)
        or (nvl(oipl_id, hr_api.g_number) = cv_oipl_id)
        or (nvl(opt_id, hr_api.g_number) = cv_opt_id))
       and r.dsgn_typ_cd = 'DPNT'
       and r.business_group_id  = p_business_group_id
       and p_effective_date between nvl(r.effective_start_date, p_effective_date)
                                and nvl(r.effective_end_date, p_effective_date)
       ;

  --
  -- designation requirement for relationship type of this dpnt
  --
  cursor rlshp_rqmt_c(cv_pl_id number,
                    cv_oipl_id number,
                    cv_opt_id  number,
                    cv_person_id number,
                    cv_dpnt_person_id number) is
    select r.mx_dpnts_alwd_num
          ,r.no_mx_num_dfnd_flag
          ,r.dsgn_rqmt_id
          ,decode(oipl_id, null, decode(opt_id, null, 3, 2), 1) heir
	  ,r.grp_rlshp_cd
    from ben_dsgn_rqmt_f       r,
         ben_dsgn_rqmt_rlshp_typ dr
     where ((nvl(pl_id, hr_api.g_number) = cv_pl_id)
        or (nvl(oipl_id, hr_api.g_number) = cv_oipl_id)
        or (nvl(opt_id, hr_api.g_number) = cv_opt_id))
       and r.dsgn_typ_cd = 'DPNT'
       and r.business_group_id = p_business_group_id
       and p_effective_date between nvl(r.effective_start_date, p_effective_date)
                                and nvl(r.effective_end_date, p_effective_date)
       and dr.dsgn_rqmt_id = r.dsgn_rqmt_id
       and dr.rlshp_typ_cd in (select c.contact_type
                               from   per_contact_relationships  c
                               where  c.person_id = cv_person_id
                               and  c.contact_person_id = cv_dpnt_person_id
                               and  nvl(c.personal_flag, 'N') = 'Y'
                               and  c.business_group_id = p_business_group_id
                               and  p_effective_date between nvl(c.date_start, p_effective_date)
                                                 and nvl(c.date_end, p_effective_date) )
       order by heir ;
  --
  -- total number of covered dependents for the result
  --
  cursor total_num_dpnt_c(cv_cvg_strt_dt date,
                          cv_cvg_thru_dt date) is
    select count(elig_cvrd_dpnt_id)
      from ben_elig_cvrd_dpnt_f ecd ,
           ben_per_in_ler pil
      where  ecd.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and  ecd.cvg_strt_dt is not null
        and  ecd.cvg_thru_dt = hr_api.g_eot
        -- and  cvrd_flag = 'Y'
        and  ecd.business_group_id + 0 = p_business_group_id
        and  p_effective_date between ecd.effective_start_date
                                  and ecd.effective_end_date
        and  cv_cvg_strt_dt <= nvl(ecd.cvg_thru_dt, hr_api.g_date)
        and  nvl(cv_cvg_thru_dt, hr_api.g_date) >= ecd.cvg_strt_dt
        and  ecd.per_in_ler_id = pil.per_in_ler_id
        and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
        ;
  --
  --
  -- number of covered dependents of any of the rel types covered
  -- by the appropriate dsgn rqmt.

  cursor rlshp_num_dpnt_c(cv_person_id number,
                          cv_cvg_strt_dt date,
                          cv_cvg_thru_dt date) is
    select count(*)
      from  per_contact_relationships c
          , ben_elig_cvrd_dpnt_f  d
          , ben_per_in_ler pil
      where
             c.person_id = cv_person_id
        and  c.contact_person_id = d.dpnt_person_id
        and  d.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and  d.cvg_strt_dt is not null
        and  d.cvg_thru_dt = hr_api.g_eot
        and  cv_cvg_strt_dt <= nvl(d.cvg_thru_dt, hr_api.g_date)
        and  nvl(cv_cvg_thru_dt, hr_api.g_date) >= d.cvg_strt_dt
        and  c.business_group_id + 0 = p_business_group_id
        and  p_effective_date between nvl(c.date_start, p_effective_date)
                                  and nvl(c.date_end, p_effective_date)
        and  d.effective_end_date = hr_api.g_eot  -- bug 1237204
        and  d.business_group_id + 0 = p_business_group_id
        and  c.contact_type in
             (select rlshp_typ_cd
              from ben_dsgn_rqmt_rlshp_typ
              where dsgn_rqmt_id = l_dsgn_rqmt_id)
        and   d.per_in_ler_id = pil.per_in_ler_id
        and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
           ;



 -- Added for bug no. 1845251

 cursor get_pln_opt_c is

 	select p.name pl_name, o.name opt_name
 	  from	ben_pl_f p,
 	  	ben_opt_f o,
 	  	ben_oipl_f op,
 	  	ben_prtt_enrt_rslt_f en
 	  where en.prtt_enrt_rslt_id=p_prtt_enrt_rslt_id
 	  and 	p.pl_id=en.pl_id
	  and	en.oipl_id = op.oipl_id(+)
 	  and	op.opt_id=o.opt_id(+)
          and   en.prtt_enrt_rslt_stat_cd is null
 	  and	p_effective_date between en.effective_start_date and en.effective_end_date
 	  and   p_effective_date between p.effective_start_date and p.effective_end_date
 	  and   p_effective_date between o.effective_start_date(+) and o.effective_end_date(+)
 	  and   p_effective_date between op.effective_start_date(+) and op.effective_end_date(+)

 	  ;


 cursor get_rel_name_c(cv_contact_type varchar2) is

 	select meaning
 	from	hr_lookups
 	where lookup_code=cv_contact_type
 	and lookup_type='CONTACT'
 	;

  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if p_prtt_enrt_rslt_id is not null then
    --
    hr_utility.set_location('open info1_c :'||l_proc,10);
    --
    for l_pen_pdp_rec in info1_c loop
    --
      open info2_c(l_pen_pdp_rec.person_id,
                   l_pen_pdp_rec.dpnt_person_id);
      fetch info2_c into l_contact_type;
      if info2_c%notfound then
        --
        close info2_c;
        --
        -- raise error as there are no contact relationship
        --
        fnd_message.set_name('BEN', 'BEN_91652_NO_CNTCT_RLSHP');
        fnd_message.raise_error;
        --
      else
        -- Check if there are any requirements at all
        hr_utility.set_location(l_proc, 12);
        close info2_c;
        open any_rqmt_c(l_pen_pdp_rec.pl_id,
                        l_pen_pdp_rec.oipl_id,
                        l_pen_pdp_rec.opt_id);
        fetch any_rqmt_c into
              l_temp;
        --
        if any_rqmt_c%found then
          --
          close any_rqmt_c;
          -- Check total max requirement
          hr_utility.set_location(l_proc, 15);
          open total_rqmt_c(l_pen_pdp_rec.pl_id,
                        l_pen_pdp_rec.oipl_id,
                        l_pen_pdp_rec.opt_id);
          fetch total_rqmt_c into
              l_t_mx_dpnts_alwd_num
             ,l_t_no_mx_num_dfnd_flag
             ,l_heir;

          if total_rqmt_c%notfound then
            -- there is no total max # limitation
            close total_rqmt_c;

          else
            close total_rqmt_c;
            if l_t_no_mx_num_dfnd_flag = 'N' then
              open total_num_dpnt_c(l_pen_pdp_rec.cvg_strt_dt,
                                    l_pen_pdp_rec.cvg_thru_dt);
              fetch total_num_dpnt_c into l_total_num_dpnt;
              close total_num_dpnt_c;

              hr_utility.set_location('total_mx '||to_char(l_t_mx_dpnts_alwd_num)||
                'total_dpnt '||l_total_num_dpnt, 18);


              if l_total_num_dpnt  > l_t_mx_dpnts_alwd_num then
                -- error as total # of cov dependents will exceed total max

                fnd_message.set_name('BEN', 'BEN_91653_DPNT_MAX_NUM_EXCDD');
                fnd_message.raise_error;

              end if; -- l_total_num_dpnt  > l_t_mx_dpnts_alwd_num
            end if;   -- l_t_no_mx_num_dfnd_flag = 'N'
          end if;     -- total_rqmt_c

          -- Check max requirement for relationship type
          hr_utility.set_location('LAMC: l_contact_type '||l_contact_type,30);
          hr_utility.set_location('l_opt_id '||to_char(l_pen_pdp_rec.opt_id),30);
          hr_utility.set_location('l_oipl_id '||to_char(l_pen_pdp_rec.oipl_id), 30);

          open rlshp_rqmt_c(l_pen_pdp_rec.pl_id,
                        l_pen_pdp_rec.oipl_id,
                        l_pen_pdp_rec.opt_id,
                        l_pen_pdp_rec.person_id,
                        l_pen_pdp_rec.dpnt_person_id);
          fetch rlshp_rqmt_c into
              l_r_mx_dpnts_alwd_num
             ,l_r_no_mx_num_dfnd_flag
             ,l_dsgn_rqmt_id
             ,l_heir
	     ,l_grp_rlshp_cd;

          if rlshp_rqmt_c%notfound then

            -- No rqmts for this relationship type, do not allow dsgn.
            hr_utility.set_location('No rlshp rqmts', 20);
            close rlshp_rqmt_c;
            fnd_message.set_name('BEN', 'BEN_91971_NO_DPNTS_ALWD');
            fnd_message.raise_error;

          else
            hr_utility.set_location('total_rlshp_mx '||to_char(l_r_mx_dpnts_alwd_num), 20);
            close rlshp_rqmt_c;
            if l_r_no_mx_num_dfnd_flag = 'N' then

              hr_utility.set_location('l_dsgn_rqmt_id'||to_char(l_dsgn_rqmt_id),30);
              hr_utility.set_location('l_person_id'||to_char(l_pen_pdp_rec.person_id),30);
              open rlshp_num_dpnt_c(l_pen_pdp_rec.person_id,
                                    l_pen_pdp_rec.cvg_strt_dt,
                                    l_pen_pdp_rec.cvg_thru_dt);
              fetch rlshp_num_dpnt_c into l_rlshp_num_dpnt;
              close rlshp_num_dpnt_c;
              hr_utility.set_location('rlshp_dpnt_mx '||to_char(l_rlshp_num_dpnt), 30);

              if l_rlshp_num_dpnt  > l_r_mx_dpnts_alwd_num then

                -- error as # of cov dependents of this rel type will exceed max
                --
                --Bug 3015999
                -- Message without relationship type created
                --fnd_message.set_name('BEN', 'BEN_91654_DPNT_RL_MAX_NUM_EXCD');
		--Bug 4080815 Message with relationship group created
                fnd_message.set_name('BEN', 'BEN_94125_REL_GRP_MAX_EXCD');

                -- Added for bug no. 1845251
                --fnd_message.set_token('MAX',l_r_mx_dpnts_alwd_num);

                open get_pln_opt_c;
                fetch get_pln_opt_c into l_pl_name,l_opt_name;
                close get_pln_opt_c;
                fnd_message.set_token('PLANOPT',l_pl_name||' '||l_opt_name);

		l_grp_rlshp_meaning := hr_general.decode_lookup('BEN_GRP_RLSHP', l_grp_rlshp_cd);
                fnd_message.set_token('GROUP',l_grp_rlshp_meaning);
                --open get_rel_name_c(l_contact_type);
                --fetch get_rel_name_c into l_rel_name;
                --close get_rel_name_c;
                --fnd_message.set_token('REL',l_rel_name);
                --End Bug 3015999

                fnd_message.raise_error;

              end if;
            end if;
          end if;
        else
        --
        -- there are no rqmts at all, allow dsgn.
        --
          close any_rqmt_c;
        --
        end if; -- any_rqmt_c%FOUND
      end if;   -- info2_c%notfound
   end loop;    -- info1_c
  end if;       -- p_prtt_enrt_rslt_id is not null
  --
  hr_utility.set_location('Leaving:'||l_proc,99);
  --
end chk_max_num_dpnt_for_pen;
--
--
-- Self-service wrapper for dpnt_actn_items.
--
procedure dpnt_actn_items_w
  (p_prtt_enrt_rslt_id              in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_datetrack_mode                 in     varchar2)
is
begin

   dpnt_actn_items(
      p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
      p_elig_cvrd_dpnt_id => null,
      p_effective_date    => p_effective_date,
      p_business_group_id => p_business_group_id,
      p_datetrack_mode    => p_datetrack_mode);

   chk_max_num_dpnt_for_pen(
      p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
      p_effective_date    => p_effective_date,
      p_business_group_id => p_business_group_id);

exception
  when others then
    fnd_msg_pub.add;

end;
--
end ben_ELIG_CVRD_DPNT_api;

/
