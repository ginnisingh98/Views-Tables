--------------------------------------------------------
--  DDL for Package Body BEN_PTNL_LER_FOR_PER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTNL_LER_FOR_PER_API" as
/* $Header: bepplapi.pkb 120.0 2005/05/28 10:58:30 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ptnl_ler_for_per_api.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_PPL_statcd_dates >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure derive_PPL_statcd_dates
  (p_ptnl_ler_for_per_stat_cd in  varchar2
  ,p_effective_date           in  date
  ,p_mnl_dt                   out nocopy date
  ,p_dtctd_dt                 out nocopy date
  ,p_procd_dt                 out nocopy date
  ,p_unprocd_dt               out nocopy date
  ,p_voidd_dt                 out nocopy date) is
  --
  -- Declare cursors and local variables
  --
  -- l_proc varchar2(72) := g_package||'derive_PPL_statcd_dates';
  --
begin
  --
  -- DEBUG : Not critical to have set_location.
  --
  --
  -- Set OUT parameters
  --
  if p_ptnl_ler_for_per_stat_cd = 'DTCTD' then
    --
    p_dtctd_dt   := p_effective_date;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'UNPROCD' then
    --
    p_unprocd_dt := p_effective_date;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'PROCD' then
    --
    p_procd_dt   := p_effective_date;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'VOIDD' then
    --
    p_voidd_dt   := p_effective_date;
    --
  elsif p_ptnl_ler_for_per_stat_cd = 'MNL' then
    --
    p_mnl_dt     := p_effective_date;
    --
  end if;
  --
  -- DEBUG : Not critical to have set_location.
  --
end derive_PPL_statcd_dates;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ptnl_ler_for_per >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptnl_ler_for_per
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            out nocopy number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
  ,p_mnl_dt                         in  date      default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dtctd_dt                       in  date      default null
  ,p_procd_dt                       in  date      default null
  ,p_unprocd_dt                     in  date      default null
  ,p_voidd_dt                       in  date      default null
  ,p_mnlo_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_ptnl_ler_for_per_id ben_ptnl_ler_for_per.ptnl_ler_for_per_id%TYPE;
  l_proc varchar2(72) ;
  l_object_version_number ben_ptnl_ler_for_per.object_version_number%TYPE;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'create_ptnl_ler_for_per';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    --
    savepoint create_ptnl_ler_for_per;
    --
  end if;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk1.create_ptnl_ler_for_per_b
      (p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  trunc(p_mnl_dt)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  trunc(p_dtctd_dt)
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ptnl_ler_for_per'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_ptnl_ler_for_per
    --
  end;
  --
  ben_ppl_ins.ins
    (p_ptnl_ler_for_per_id           => l_ptnl_ler_for_per_id
    ,p_csd_by_ptnl_ler_for_per_id    => p_csd_by_ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt                => trunc(p_lf_evt_ocrd_dt)
    ,p_trgr_table_pk_id              => p_trgr_table_pk_id
    ,p_ptnl_ler_for_per_stat_cd      => p_ptnl_ler_for_per_stat_cd
    ,p_ptnl_ler_for_per_src_cd       => p_ptnl_ler_for_per_src_cd
    ,p_mnl_dt                        => trunc(p_mnl_dt)
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_dtctd_dt                      => trunc(p_dtctd_dt)
    ,p_procd_dt                      => trunc(p_procd_dt)
    ,p_unprocd_dt                    => trunc(p_unprocd_dt)
    ,p_voidd_dt                      => trunc(p_voidd_dt)
    ,p_mnlo_dt                       => trunc(p_mnlo_dt)
    ,p_ntfn_dt                       => trunc(p_ntfn_dt)
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => trunc(p_program_update_date)
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk1.create_ptnl_ler_for_per_a
      (p_ptnl_ler_for_per_id            =>  l_ptnl_ler_for_per_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  trunc(p_mnl_dt)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  trunc(p_dtctd_dt)
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ptnl_ler_for_per'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_ptnl_ler_for_per
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
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
  p_ptnl_ler_for_per_id   := l_ptnl_ler_for_per_id;
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ptnl_ler_for_per;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ptnl_ler_for_per_id   := null;
    p_object_version_number := null;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    /* Inserted for nocopy changes */
    p_ptnl_ler_for_per_id   := null;
    p_object_version_number := null;
    raise;
    --
end create_ptnl_ler_for_per;
-- ----------------------------------------------------------------------------
-- |------------------------< create_ptnl_ler_for_per_perf >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptnl_ler_for_per_perf
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            out nocopy number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default null
  ,p_mnl_dt                         in  date      default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dtctd_dt                       in  date      default null
  ,p_procd_dt                       in  date      default null
  ,p_unprocd_dt                     in  date      default null
  ,p_voidd_dt                       in  date      default null
  ,p_mnlo_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_ptnl_ler_for_per_id ben_ptnl_ler_for_per.ptnl_ler_for_per_id%TYPE;
  -- DEBUG : l_proc varchar2(72) := g_package||'create_ptnl_ler_for_per';
  l_object_version_number ben_ptnl_ler_for_per.object_version_number%TYPE;
  --
begin
  --
  if p_validate then
    --
    savepoint create_ptnl_ler_for_per;
    --
  end if;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk1.create_ptnl_ler_for_per_b
      (p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  p_mnl_dt
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  trunc(p_dtctd_dt)
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ptnl_ler_for_per'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_ptnl_ler_for_per
    --
  end;
  --
  l_object_version_number := 1;
  --
  select ben_ptnl_ler_for_per_s.nextval
  into   l_ptnl_ler_for_per_id
  from   sys.dual;
  --
  insert into ben_ptnl_ler_for_per
    (ptnl_ler_for_per_id
    ,csd_by_ptnl_ler_for_per_id
    ,lf_evt_ocrd_dt
    ,trgr_table_pk_id
    ,ptnl_ler_for_per_stat_cd
    ,ptnl_ler_for_per_src_cd
    ,mnl_dt
    ,enrt_perd_id
    ,ler_id
    ,person_id
    ,business_group_id
    ,dtctd_dt
    ,procd_dt
    ,unprocd_dt
    ,voidd_dt
    ,mnlo_dt
    ,ntfn_dt
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,object_version_number)
  values
    (l_ptnl_ler_for_per_id
    ,p_csd_by_ptnl_ler_for_per_id
    ,trunc(p_lf_evt_ocrd_dt)
    ,p_trgr_table_pk_id
    ,p_ptnl_ler_for_per_stat_cd
    ,p_ptnl_ler_for_per_src_cd
    ,trunc(p_mnl_dt)
    ,p_enrt_perd_id
    ,p_ler_id
    ,p_person_id
    ,p_business_group_id
    ,trunc(p_dtctd_dt)
    ,trunc(p_procd_dt)
    ,trunc(p_unprocd_dt)
    ,trunc(p_voidd_dt)
    ,trunc(p_mnlo_dt)
    ,trunc(p_ntfn_dt)
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,l_object_version_number);
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk1.create_ptnl_ler_for_per_a
      (p_ptnl_ler_for_per_id            =>  l_ptnl_ler_for_per_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  trunc(p_mnl_dt)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  trunc(p_dtctd_dt)
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ptnl_ler_for_per'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_ptnl_ler_for_per
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
  p_ptnl_ler_for_per_id   := l_ptnl_ler_for_per_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ptnl_ler_for_per;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ptnl_ler_for_per_id   := null;
    p_object_version_number := null;
    -- DEBUG : hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    /* Inserted for nocopy changes */
    p_ptnl_ler_for_per_id   := null;
    p_object_version_number := null;
    raise;
    --
end create_ptnl_ler_for_per_perf;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptnl_ler_for_per >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptnl_ler_for_per
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            in  number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default hr_api.g_number
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_trgr_table_pk_id               in  number    default hr_api.g_number
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default hr_api.g_varchar2
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default hr_api.g_varchar2
  ,p_mnl_dt                         in  date      default hr_api.g_date
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dtctd_dt                       in  date      default hr_api.g_date
  ,p_procd_dt                       in  date      default hr_api.g_date
  ,p_unprocd_dt                     in  date      default hr_api.g_date
  ,p_voidd_dt                       in  date      default hr_api.g_date
  ,p_mnlo_dt                        in  date      default hr_api.g_date
  ,p_ntfn_dt                        in  date      default hr_api.g_date
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_object_version_number ben_ptnl_ler_for_per.object_version_number%TYPE;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'update_ptnl_ler_for_per';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    --
    savepoint update_ptnl_ler_for_per;
    --
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk2.update_ptnl_ler_for_per_b
      (p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  trunc(p_mnl_dt)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  trunc(p_dtctd_dt)
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ptnl_ler_for_per'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_ptnl_ler_for_per
    --
  end;
  --
  ben_ppl_upd.upd
    (p_ptnl_ler_for_per_id           => p_ptnl_ler_for_per_id
    ,p_csd_by_ptnl_ler_for_per_id    => p_csd_by_ptnl_ler_for_per_id
    ,p_lf_evt_ocrd_dt                => trunc(p_lf_evt_ocrd_dt)
    ,p_trgr_table_pk_id              => p_trgr_table_pk_id
    ,p_ptnl_ler_for_per_stat_cd      => p_ptnl_ler_for_per_stat_cd
    ,p_ptnl_ler_for_per_src_cd       => p_ptnl_ler_for_per_src_cd
    ,p_mnl_dt                        => trunc(p_mnl_dt)
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_dtctd_dt                      => trunc(p_dtctd_dt)
    ,p_procd_dt                      => trunc(p_procd_dt )
    ,p_unprocd_dt                    => trunc(p_unprocd_dt)
    ,p_voidd_dt                      => trunc(p_voidd_dt)
    ,p_mnlo_dt                       => trunc(p_mnlo_dt)
    ,p_ntfn_dt                       => trunc(p_ntfn_dt)
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => trunc(p_program_update_date)
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk2.update_ptnl_ler_for_per_a
      (p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  trunc(p_mnl_dt)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  trunc(p_dtctd_dt)
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ptnl_ler_for_per'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_ptnl_ler_for_per
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
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
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ptnl_ler_for_per;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_ptnl_ler_for_per;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptnl_ler_for_per_perf >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptnl_ler_for_per_perf
  (p_validate                       in boolean    default false
  ,p_ptnl_ler_for_per_id            in  number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default hr_api.g_number
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_trgr_table_pk_id               in  number    default hr_api.g_number
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default hr_api.g_varchar2
  ,p_ptnl_ler_for_per_src_cd        in  varchar2  default hr_api.g_varchar2
  ,p_mnl_dt                         in  date      default hr_api.g_date
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dtctd_dt                       in  date      default hr_api.g_date
  ,p_procd_dt                       in  date      default hr_api.g_date
  ,p_unprocd_dt                     in  date      default hr_api.g_date
  ,p_voidd_dt                       in  date      default hr_api.g_date
  ,p_mnlo_dt                        in  date      default hr_api.g_date
  ,p_ntfn_dt                        in  date      default hr_api.g_date
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  -- l_proc varchar2(72) := g_package||'update_ptnl_ler_for_per';
  l_object_version_number ben_ptnl_ler_for_per.object_version_number%TYPE;
  --
  l_ptnl_ler_for_per_id      number;
  l_csd_by_ptnl_ler_for_per_id      number;
  l_lf_evt_ocrd_dt           date;
  l_trgr_table_pk_id         number;
  l_ntfn_dt                  date;
  l_dtctd_dt                 date;
  l_procd_dt                 date;
  l_unprocd_dt               date;
  l_voidd_dt                 date;
  l_mnlo_dt                  date;
  l_mnl_dt                   date;
  l_ptnl_ler_for_per_stat_cd varchar2(30);
  l_ptnl_ler_for_per_src_cd  varchar2(30);
  l_enrt_perd_id             number;
  l_ler_id                   number;
  l_business_group_id        number;
  l_person_id                number;
  l_request_id               number;
  l_program_application_id   number;
  l_program_id               number;
  l_program_update_date      date;
  --
begin
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    --
    savepoint update_ptnl_ler_for_per;
    --
  end if;
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk2.update_ptnl_ler_for_per_b
      (p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  trunc(p_mnl_dt)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  p_dtctd_dt
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ptnl_ler_for_per'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_ptnl_ler_for_per
    --
  end;
  --
  -- Lock the record so we can default properly
  --
  ben_ppl_shd.lck(p_ptnl_ler_for_per_id   => p_ptnl_ler_for_per_id,
                  p_object_version_number => l_object_version_number);
  --
  -- default variables for update
  --
  l_csd_by_ptnl_ler_for_per_id := p_csd_by_ptnl_ler_for_per_id;
  If (l_csd_by_ptnl_ler_for_per_id = hr_api.g_number) then
    l_csd_by_ptnl_ler_for_per_id :=
    ben_ppl_shd.g_old_rec.csd_by_ptnl_ler_for_per_id;
  End If;
  l_lf_evt_ocrd_dt := trunc(p_lf_evt_ocrd_dt);
  If (p_lf_evt_ocrd_dt = hr_api.g_date) then
    l_lf_evt_ocrd_dt :=
    ben_ppl_shd.g_old_rec.lf_evt_ocrd_dt;
  End If;
  l_trgr_table_pk_id := p_trgr_table_pk_id;
  If (p_trgr_table_pk_id = hr_api.g_number) then
    l_trgr_table_pk_id :=
    ben_ppl_shd.g_old_rec.trgr_table_pk_id;
  End If;
  l_ptnl_ler_for_per_stat_cd := p_ptnl_ler_for_per_stat_cd;
  If (l_ptnl_ler_for_per_stat_cd = hr_api.g_varchar2) then
    l_ptnl_ler_for_per_stat_cd :=
    ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd;
  End If;
  l_ptnl_ler_for_per_src_cd := p_ptnl_ler_for_per_src_cd;
  If (l_ptnl_ler_for_per_src_cd = hr_api.g_varchar2) then
    l_ptnl_ler_for_per_src_cd :=
    ben_ppl_shd.g_old_rec.ptnl_ler_for_per_src_cd;
  End If;
  l_enrt_perd_id := p_enrt_perd_id;
  If (l_enrt_perd_id = hr_api.g_number) then
    l_enrt_perd_id :=
    ben_ppl_shd.g_old_rec.enrt_perd_id;
  End If;
  l_ler_id := p_ler_id;
  If (l_ler_id = hr_api.g_number) then
    l_ler_id :=
    ben_ppl_shd.g_old_rec.ler_id;
  End If;
  l_ntfn_dt := trunc(p_ntfn_dt);
  If (l_ntfn_dt = hr_api.g_date) then
    l_ntfn_dt :=
    ben_ppl_shd.g_old_rec.ntfn_dt;
  End If;
  l_dtctd_dt := trunc(p_dtctd_dt);
  If (l_dtctd_dt = hr_api.g_date) then
    l_dtctd_dt :=
    ben_ppl_shd.g_old_rec.dtctd_dt;
  End If;
  l_procd_dt := trunc(p_procd_dt);
  If (l_procd_dt = hr_api.g_date) then
    l_procd_dt :=
    ben_ppl_shd.g_old_rec.procd_dt;
  End If;
  l_unprocd_dt := trunc(p_unprocd_dt);
  If (l_unprocd_dt = hr_api.g_date) then
    l_unprocd_dt :=
    ben_ppl_shd.g_old_rec.unprocd_dt;
  End If;
  l_voidd_dt := trunc(p_voidd_dt);
  If (l_voidd_dt = hr_api.g_date) then
    l_voidd_dt :=
    ben_ppl_shd.g_old_rec.voidd_dt;
  End If;
  l_mnlo_dt := trunc(p_mnlo_dt);
  If (l_mnlo_dt = hr_api.g_date) then
    l_mnlo_dt :=
    ben_ppl_shd.g_old_rec.mnlo_dt;
  End If;
  l_mnl_dt := trunc(p_mnl_dt);
  If (l_mnl_dt = hr_api.g_date) then
    l_mnl_dt :=
    ben_ppl_shd.g_old_rec.mnl_dt;
  End If;
  l_person_id := p_person_id;
  If (l_person_id = hr_api.g_number) then
    l_person_id :=
    ben_ppl_shd.g_old_rec.person_id;
  End If;
  l_business_group_id := p_business_group_id;
  If (l_business_group_id = hr_api.g_number) then
    l_business_group_id :=
    ben_ppl_shd.g_old_rec.business_group_id;
  End If;
  l_request_id := p_request_id;
  If (l_request_id = hr_api.g_number) then
    l_request_id :=
    ben_ppl_shd.g_old_rec.request_id;
  End If;
  l_program_application_id := p_program_application_id;
  If (l_program_application_id = hr_api.g_number) then
    l_program_application_id :=
    ben_ppl_shd.g_old_rec.program_application_id;
  End If;
  l_program_id := p_program_id;
  If (l_program_id = hr_api.g_number) then
    l_program_id :=
    ben_ppl_shd.g_old_rec.program_id;
  End If;
  l_program_update_date := trunc(p_program_update_date);
  If (l_program_update_date = hr_api.g_date) then
    l_program_update_date :=
    ben_ppl_shd.g_old_rec.program_update_date;
  End If;
  --
  l_object_version_number := l_object_version_number + 1;
  --
  -- Update the row using the old values for defaulted parameters and
  -- any changed values for passed parameters.
  --
  update ben_ptnl_ler_for_per
    set lf_evt_ocrd_dt           = l_lf_evt_ocrd_dt,
        trgr_table_pk_id         = l_trgr_table_pk_id,
        csd_by_ptnl_ler_for_per_id = l_csd_by_ptnl_ler_for_per_id,
        ptnl_ler_for_per_stat_cd = l_ptnl_ler_for_per_stat_cd,
        ptnl_ler_for_per_src_cd  = l_ptnl_ler_for_per_src_cd,
        mnl_dt                   = l_mnl_dt,
        enrt_perd_id             = l_enrt_perd_id,
        ler_id                   = l_ler_id,
        person_id                = l_person_id,
        business_group_id        = l_business_group_id,
        dtctd_dt                 = l_dtctd_dt,
        procd_dt                 = l_procd_dt,
        unprocd_dt               = l_unprocd_dt,
        voidd_dt                 = l_voidd_dt,
        mnlo_dt                  = l_mnlo_dt,
        ntfn_dt                  = l_ntfn_dt,
        request_id               = l_request_id,
        program_application_id   = l_program_application_id,
        program_id               = l_program_id,
        program_update_date      = l_program_update_date,
        object_version_number    = l_object_version_number
    where ptnl_ler_for_per_id    = p_ptnl_ler_for_per_id;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk2.update_ptnl_ler_for_per_a
      (p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_csd_by_ptnl_ler_for_per_id     =>  p_csd_by_ptnl_ler_for_per_id
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd        =>  p_ptnl_ler_for_per_src_cd
      ,p_mnl_dt                         =>  trunc(p_mnl_dt)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dtctd_dt                       =>  trunc(p_dtctd_dt)
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_unprocd_dt                     =>  trunc(p_unprocd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_mnlo_dt                        =>  trunc(p_mnlo_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  trunc(p_program_update_date)
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ptnl_ler_for_per'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_ptnl_ler_for_per
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
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ptnl_ler_for_per;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_ptnl_ler_for_per_perf;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ptnl_ler_for_per >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptnl_ler_for_per
  (p_validate                       in  boolean  default false
  ,p_ptnl_ler_for_per_id            in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number ben_ptnl_ler_for_per.object_version_number%TYPE;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'update_ptnl_ler_for_per';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  if p_validate then
    --
    savepoint delete_ptnl_ler_for_per;
    --
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk3.delete_ptnl_ler_for_per_b
      (p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ptnl_ler_for_per'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_ptnl_ler_for_per
    --
  end;
  --
  ben_ppl_del.del
    (p_ptnl_ler_for_per_id           => p_ptnl_ler_for_per_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ptnl_ler_for_per
    --
    ben_ptnl_ler_for_per_bk3.delete_ptnl_ler_for_per_a
      (p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ptnl_ler_for_per'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_ptnl_ler_for_per
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ptnl_ler_for_per;
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
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_ptnl_ler_for_per;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_ptnl_ler_for_per_id            in     number
  ,p_object_version_number          in     number) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'lck';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  ben_ppl_shd.lck
    (p_ptnl_ler_for_per_id        => p_ptnl_ler_for_per_id
    ,p_object_version_number      => p_object_version_number);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
end lck;
--
end ben_ptnl_ler_for_per_api;

/
