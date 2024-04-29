--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_LIFE_EVENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_LIFE_EVENT_API" as
/* $Header: bepilapi.pkb 120.0 2005/05/28 10:49:37 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Person_Life_Event_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< derive_PIL_statcd_dates >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure derive_PIL_statcd_dates
  (p_per_in_ler_stat_cd in     varchar2
  ,p_effective_date     in     date
  ,p_procd_dt           in out NOCOPY date
  ,p_strtd_dt           in out NOCOPY date
  ,p_voidd_dt           in out NOCOPY date
  ,p_bckt_dt            in out NOCOPY date
  ,p_clsd_dt            in out NOCOPY date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'derive_PIL_statcd_dates';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Set OUT parameters
  --
  if p_per_in_ler_stat_cd = 'PROCD' then
    --
    p_procd_dt := p_effective_date;
  elsif p_per_in_ler_stat_cd = 'STRTD' then
    p_strtd_dt := p_effective_date;
  elsif p_per_in_ler_stat_cd = 'VOIDD' then
    p_voidd_dt := p_effective_date;
  elsif p_per_in_ler_stat_cd = 'BCKDT' then
    --
    -- Bug : 5231 : Set the backed out date to sysdate
    -- rather than p_effective_date.
    --
    p_bckt_dt := trunc(sysdate);
  elsif p_per_in_ler_stat_cd = 'CLSD' then
    p_clsd_dt := p_effective_date;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end derive_PIL_statcd_dates;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Person_Life_Event
  (p_validate                       in boolean    default false
  ,p_per_in_ler_id                  out NOCOPY number
  ,p_per_in_ler_stat_cd             in  varchar2  default null
  ,p_prvs_stat_cd                   in  varchar2  default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null --ABSE changes
  ,p_procd_dt                       out NOCOPY date
  ,p_strtd_dt                       out NOCOPY date
  ,p_voidd_dt                       out NOCOPY date
  ,p_bckt_dt                        in  date      default null
  ,p_clsd_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_ptnl_ler_for_per_id            in  number    default null
  ,p_bckt_per_in_ler_id             in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ASSIGNMENT_ID                  in  number    default null
  ,p_WS_MGR_ID                      in  number    default null
  ,p_GROUP_PL_ID                    in  number    default null
  ,p_MGR_OVRID_PERSON_ID            in  number    default null
  ,p_MGR_OVRID_DT                   in  date      default null
  ,p_pil_attribute_category         in  varchar2  default null
  ,p_pil_attribute1                 in  varchar2  default null
  ,p_pil_attribute2                 in  varchar2  default null
  ,p_pil_attribute3                 in  varchar2  default null
  ,p_pil_attribute4                 in  varchar2  default null
  ,p_pil_attribute5                 in  varchar2  default null
  ,p_pil_attribute6                 in  varchar2  default null
  ,p_pil_attribute7                 in  varchar2  default null
  ,p_pil_attribute8                 in  varchar2  default null
  ,p_pil_attribute9                 in  varchar2  default null
  ,p_pil_attribute10                in  varchar2  default null
  ,p_pil_attribute11                in  varchar2  default null
  ,p_pil_attribute12                in  varchar2  default null
  ,p_pil_attribute13                in  varchar2  default null
  ,p_pil_attribute14                in  varchar2  default null
  ,p_pil_attribute15                in  varchar2  default null
  ,p_pil_attribute16                in  varchar2  default null
  ,p_pil_attribute17                in  varchar2  default null
  ,p_pil_attribute18                in  varchar2  default null
  ,p_pil_attribute19                in  varchar2  default null
  ,p_pil_attribute20                in  varchar2  default null
  ,p_pil_attribute21                in  varchar2  default null
  ,p_pil_attribute22                in  varchar2  default null
  ,p_pil_attribute23                in  varchar2  default null
  ,p_pil_attribute24                in  varchar2  default null
  ,p_pil_attribute25                in  varchar2  default null
  ,p_pil_attribute26                in  varchar2  default null
  ,p_pil_attribute27                in  varchar2  default null
  ,p_pil_attribute28                in  varchar2  default null
  ,p_pil_attribute29                in  varchar2  default null
  ,p_pil_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out NOCOPY number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to pick suspended enrollment results for the person.
  --
  cursor c_sspndd_rslt is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number,
           pil.per_in_ler_id
    from   ben_prtt_enrt_rslt_f pen, ben_per_in_ler pil
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_id = pen.per_in_ler_id
    --Start Bug 2688172
    and    pil.lf_evt_ocrd_dt  <= p_lf_evt_ocrd_dt
    --End Bug 2688172
    and    pen.sspndd_flag = 'Y'
    and    pen.enrt_cvg_thru_dt = hr_api.g_eot
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    p_effective_date
           between pen.effective_start_date
           and     pen.effective_end_date;
  --
  l_rslt_ovn number(15);
  l_dummy_dt date;
  l_dummy_bool boolean;
  l_still_sspndd varchar2(30);
  --
  l_proc varchar2(72)     := g_package||'create_Person_Life_Event';
  --
  l_object_version_number number;
  l_per_in_ler_id         number;
  --
  l_procd_dt              date := null;
  l_strtd_dt              date := null;
  l_voidd_dt              date := null;
  l_bckt_dt               date := null;
  l_clsd_dt               date := null;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Person_Life_Event;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Person_Life_Event
    --
    ben_Person_Life_Event_bk1.create_Person_Life_Event_b
      (p_per_in_ler_stat_cd             =>  p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                   =>  p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_strtd_dt                       =>  trunc(p_strtd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_bckt_dt                        =>  trunc(p_bckt_dt)
      ,p_clsd_dt                        =>  trunc(p_clsd_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id             =>  p_bckt_per_in_ler_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category         =>  p_pil_attribute_category
      ,p_pil_attribute1                 =>  p_pil_attribute1
      ,p_pil_attribute2                 =>  p_pil_attribute2
      ,p_pil_attribute3                 =>  p_pil_attribute3
      ,p_pil_attribute4                 =>  p_pil_attribute4
      ,p_pil_attribute5                 =>  p_pil_attribute5
      ,p_pil_attribute6                 =>  p_pil_attribute6
      ,p_pil_attribute7                 =>  p_pil_attribute7
      ,p_pil_attribute8                 =>  p_pil_attribute8
      ,p_pil_attribute9                 =>  p_pil_attribute9
      ,p_pil_attribute10                =>  p_pil_attribute10
      ,p_pil_attribute11                =>  p_pil_attribute11
      ,p_pil_attribute12                =>  p_pil_attribute12
      ,p_pil_attribute13                =>  p_pil_attribute13
      ,p_pil_attribute14                =>  p_pil_attribute14
      ,p_pil_attribute15                =>  p_pil_attribute15
      ,p_pil_attribute16                =>  p_pil_attribute16
      ,p_pil_attribute17                =>  p_pil_attribute17
      ,p_pil_attribute18                =>  p_pil_attribute18
      ,p_pil_attribute19                =>  p_pil_attribute19
      ,p_pil_attribute20                =>  p_pil_attribute20
      ,p_pil_attribute21                =>  p_pil_attribute21
      ,p_pil_attribute22                =>  p_pil_attribute22
      ,p_pil_attribute23                =>  p_pil_attribute23
      ,p_pil_attribute24                =>  p_pil_attribute24
      ,p_pil_attribute25                =>  p_pil_attribute25
      ,p_pil_attribute26                =>  p_pil_attribute26
      ,p_pil_attribute27                =>  p_pil_attribute27
      ,p_pil_attribute28                =>  p_pil_attribute28
      ,p_pil_attribute29                =>  p_pil_attribute29
      ,p_pil_attribute30                =>  p_pil_attribute30
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
        (p_module_name => 'CREATE_Person_Life_Event'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_Person_Life_Event
    --
  end;
  --
  -- MM. deleted the  action items cleanup code for CFW
  --
  -- Derive date column values for the per in ler status code
  --
  derive_PIL_statcd_dates
    (p_per_in_ler_stat_cd => p_per_in_ler_stat_cd
    ,p_effective_date     => p_effective_date
    ,p_procd_dt           => l_procd_dt
    ,p_strtd_dt           => l_strtd_dt
    ,p_voidd_dt           => l_voidd_dt
    ,p_bckt_dt            => l_bckt_dt
    ,p_clsd_dt            => l_clsd_dt);
  --
  ben_pil_ins.ins
    (p_per_in_ler_id                 => l_per_in_ler_id
    ,p_per_in_ler_stat_cd            => p_per_in_ler_stat_cd
    ,p_prvs_stat_cd                  => p_prvs_stat_cd
    ,p_lf_evt_ocrd_dt                => trunc(p_lf_evt_ocrd_dt)
    ,p_trgr_table_pk_id              => p_trgr_table_pk_id --ABSE changes
    ,p_procd_dt                      => l_procd_dt
    ,p_strtd_dt                      => l_strtd_dt
    ,p_voidd_dt                      => l_voidd_dt
    ,p_bckt_dt                       => l_bckt_dt
    ,p_clsd_dt                       => l_clsd_dt
    ,p_ntfn_dt                       => trunc(p_ntfn_dt)
    ,p_ptnl_ler_for_per_id           => p_ptnl_ler_for_per_id
    ,p_bckt_per_in_ler_id            => p_bckt_per_in_ler_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_ASSIGNMENT_ID                 =>  p_ASSIGNMENT_ID
    ,p_WS_MGR_ID                     =>  p_WS_MGR_ID
    ,p_GROUP_PL_ID                   =>  p_GROUP_PL_ID
    ,p_MGR_OVRID_PERSON_ID           =>  p_MGR_OVRID_PERSON_ID
    ,p_MGR_OVRID_DT                  =>  p_MGR_OVRID_DT
    ,p_pil_attribute_category        => p_pil_attribute_category
    ,p_pil_attribute1                => p_pil_attribute1
    ,p_pil_attribute2                => p_pil_attribute2
    ,p_pil_attribute3                => p_pil_attribute3
    ,p_pil_attribute4                => p_pil_attribute4
    ,p_pil_attribute5                => p_pil_attribute5
    ,p_pil_attribute6                => p_pil_attribute6
    ,p_pil_attribute7                => p_pil_attribute7
    ,p_pil_attribute8                => p_pil_attribute8
    ,p_pil_attribute9                => p_pil_attribute9
    ,p_pil_attribute10               => p_pil_attribute10
    ,p_pil_attribute11               => p_pil_attribute11
    ,p_pil_attribute12               => p_pil_attribute12
    ,p_pil_attribute13               => p_pil_attribute13
    ,p_pil_attribute14               => p_pil_attribute14
    ,p_pil_attribute15               => p_pil_attribute15
    ,p_pil_attribute16               => p_pil_attribute16
    ,p_pil_attribute17               => p_pil_attribute17
    ,p_pil_attribute18               => p_pil_attribute18
    ,p_pil_attribute19               => p_pil_attribute19
    ,p_pil_attribute20               => p_pil_attribute20
    ,p_pil_attribute21               => p_pil_attribute21
    ,p_pil_attribute22               => p_pil_attribute22
    ,p_pil_attribute23               => p_pil_attribute23
    ,p_pil_attribute24               => p_pil_attribute24
    ,p_pil_attribute25               => p_pil_attribute25
    ,p_pil_attribute26               => p_pil_attribute26
    ,p_pil_attribute27               => p_pil_attribute27
    ,p_pil_attribute28               => p_pil_attribute28
    ,p_pil_attribute29               => p_pil_attribute29
    ,p_pil_attribute30               => p_pil_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => trunc(p_program_update_date)
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Person_Life_Event
    --
    ben_Person_Life_Event_bk1.create_Person_Life_Event_a
      (p_per_in_ler_id                  =>  l_per_in_ler_id
      ,p_per_in_ler_stat_cd             =>  p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                   =>  p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                       =>  l_procd_dt
      ,p_strtd_dt                       =>  l_strtd_dt
      ,p_voidd_dt                       =>  l_voidd_dt
      ,p_bckt_dt                        =>  l_bckt_dt
      ,p_clsd_dt                        =>  l_clsd_dt
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id             =>  p_bckt_per_in_ler_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category         =>  p_pil_attribute_category
      ,p_pil_attribute1                 =>  p_pil_attribute1
      ,p_pil_attribute2                 =>  p_pil_attribute2
      ,p_pil_attribute3                 =>  p_pil_attribute3
      ,p_pil_attribute4                 =>  p_pil_attribute4
      ,p_pil_attribute5                 =>  p_pil_attribute5
      ,p_pil_attribute6                 =>  p_pil_attribute6
      ,p_pil_attribute7                 =>  p_pil_attribute7
      ,p_pil_attribute8                 =>  p_pil_attribute8
      ,p_pil_attribute9                 =>  p_pil_attribute9
      ,p_pil_attribute10                =>  p_pil_attribute10
      ,p_pil_attribute11                =>  p_pil_attribute11
      ,p_pil_attribute12                =>  p_pil_attribute12
      ,p_pil_attribute13                =>  p_pil_attribute13
      ,p_pil_attribute14                =>  p_pil_attribute14
      ,p_pil_attribute15                =>  p_pil_attribute15
      ,p_pil_attribute16                =>  p_pil_attribute16
      ,p_pil_attribute17                =>  p_pil_attribute17
      ,p_pil_attribute18                =>  p_pil_attribute18
      ,p_pil_attribute19                =>  p_pil_attribute19
      ,p_pil_attribute20                =>  p_pil_attribute20
      ,p_pil_attribute21                =>  p_pil_attribute21
      ,p_pil_attribute22                =>  p_pil_attribute22
      ,p_pil_attribute23                =>  p_pil_attribute23
      ,p_pil_attribute24                =>  p_pil_attribute24
      ,p_pil_attribute25                =>  p_pil_attribute25
      ,p_pil_attribute26                =>  p_pil_attribute26
      ,p_pil_attribute27                =>  p_pil_attribute27
      ,p_pil_attribute28                =>  p_pil_attribute28
      ,p_pil_attribute29                =>  p_pil_attribute29
      ,p_pil_attribute30                =>  p_pil_attribute30
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
        (p_module_name => 'CREATE_Person_Life_Event'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_Person_Life_Event
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
  p_per_in_ler_id         := l_per_in_ler_id;
  p_object_version_number := l_object_version_number;
  p_procd_dt              := l_procd_dt;
  p_strtd_dt              := l_strtd_dt;
  p_voidd_dt              := l_voidd_dt;
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
    ROLLBACK TO create_Person_Life_Event;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_in_ler_id := null;
    p_object_version_number  := null;
    p_procd_dt               := null;
    p_strtd_dt               := null;
    p_voidd_dt               := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Person_Life_Event;
    raise;
    --
end create_Person_Life_Event;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Person_Life_Event_perf >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Person_Life_Event_perf
  (p_validate                       in boolean    default false
  ,p_per_in_ler_id                  out NOCOPY number
  ,p_per_in_ler_stat_cd             in  varchar2  default null
  ,p_prvs_stat_cd                   in  varchar2  default null
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_trgr_table_pk_id               in  number    default null --ABSE changes
  ,p_procd_dt                       out NOCOPY date
  ,p_strtd_dt                       out NOCOPY date
  ,p_voidd_dt                       out NOCOPY date
  ,p_bckt_dt                        in  date      default null
  ,p_clsd_dt                        in  date      default null
  ,p_ntfn_dt                        in  date      default null
  ,p_ptnl_ler_for_per_id            in  number    default null
  ,p_bckt_per_in_ler_id             in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ASSIGNMENT_ID                  in  number    default null
  ,p_WS_MGR_ID                      in  number    default null
  ,p_GROUP_PL_ID                    in  number    default null
  ,p_MGR_OVRID_PERSON_ID            in  number    default null
  ,p_MGR_OVRID_DT                   in  date      default null
  ,p_pil_attribute_category         in  varchar2  default null
  ,p_pil_attribute1                 in  varchar2  default null
  ,p_pil_attribute2                 in  varchar2  default null
  ,p_pil_attribute3                 in  varchar2  default null
  ,p_pil_attribute4                 in  varchar2  default null
  ,p_pil_attribute5                 in  varchar2  default null
  ,p_pil_attribute6                 in  varchar2  default null
  ,p_pil_attribute7                 in  varchar2  default null
  ,p_pil_attribute8                 in  varchar2  default null
  ,p_pil_attribute9                 in  varchar2  default null
  ,p_pil_attribute10                in  varchar2  default null
  ,p_pil_attribute11                in  varchar2  default null
  ,p_pil_attribute12                in  varchar2  default null
  ,p_pil_attribute13                in  varchar2  default null
  ,p_pil_attribute14                in  varchar2  default null
  ,p_pil_attribute15                in  varchar2  default null
  ,p_pil_attribute16                in  varchar2  default null
  ,p_pil_attribute17                in  varchar2  default null
  ,p_pil_attribute18                in  varchar2  default null
  ,p_pil_attribute19                in  varchar2  default null
  ,p_pil_attribute20                in  varchar2  default null
  ,p_pil_attribute21                in  varchar2  default null
  ,p_pil_attribute22                in  varchar2  default null
  ,p_pil_attribute23                in  varchar2  default null
  ,p_pil_attribute24                in  varchar2  default null
  ,p_pil_attribute25                in  varchar2  default null
  ,p_pil_attribute26                in  varchar2  default null
  ,p_pil_attribute27                in  varchar2  default null
  ,p_pil_attribute28                in  varchar2  default null
  ,p_pil_attribute29                in  varchar2  default null
  ,p_pil_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out NOCOPY number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to pick suspended enrollment results for the person.
  --
  cursor c_sspndd_rslt is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number,
           pil.per_in_ler_id
    from   ben_prtt_enrt_rslt_f pen, ben_per_in_ler pil
    where  pil.person_id = p_person_id
    and    pil.per_in_ler_id = pen.per_in_ler_id
    --Start Bug 2688172
    and    pil.lf_evt_ocrd_dt <= p_lf_evt_ocrd_dt
    -- End Bug 2688172
    and    pen.sspndd_flag = 'Y'
    and    pen.enrt_cvg_thru_dt = hr_api.g_eot
    and    pen.effective_end_date = hr_api.g_eot
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.business_group_id +0 = p_business_group_id
    and    p_effective_date
           between pen.effective_start_date
           and     pen.effective_end_date;
  --
  l_rslt_ovn number(15);
  l_dummy_dt date;
  l_dummy_bool boolean;
  l_still_sspndd varchar2(30);
  --
  l_proc varchar2(72)     := g_package||'create_Person_Life_Event';
  --
  l_object_version_number number;
  l_per_in_ler_id         number;
  --
  l_procd_dt              date := null;
  l_strtd_dt              date := null;
  l_voidd_dt              date := null;
  l_bckt_dt               date := null;
  l_clsd_dt               date := null;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Person_Life_Event;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Person_Life_Event
    --
    ben_Person_Life_Event_bk1.create_Person_Life_Event_b
      (p_per_in_ler_stat_cd             =>  p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                   =>  p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_strtd_dt                       =>  trunc(p_strtd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_bckt_dt                        =>  trunc(p_bckt_dt)
      ,p_clsd_dt                        =>  trunc(p_clsd_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id             =>  p_bckt_per_in_ler_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category         =>  p_pil_attribute_category
      ,p_pil_attribute1                 =>  p_pil_attribute1
      ,p_pil_attribute2                 =>  p_pil_attribute2
      ,p_pil_attribute3                 =>  p_pil_attribute3
      ,p_pil_attribute4                 =>  p_pil_attribute4
      ,p_pil_attribute5                 =>  p_pil_attribute5
      ,p_pil_attribute6                 =>  p_pil_attribute6
      ,p_pil_attribute7                 =>  p_pil_attribute7
      ,p_pil_attribute8                 =>  p_pil_attribute8
      ,p_pil_attribute9                 =>  p_pil_attribute9
      ,p_pil_attribute10                =>  p_pil_attribute10
      ,p_pil_attribute11                =>  p_pil_attribute11
      ,p_pil_attribute12                =>  p_pil_attribute12
      ,p_pil_attribute13                =>  p_pil_attribute13
      ,p_pil_attribute14                =>  p_pil_attribute14
      ,p_pil_attribute15                =>  p_pil_attribute15
      ,p_pil_attribute16                =>  p_pil_attribute16
      ,p_pil_attribute17                =>  p_pil_attribute17
      ,p_pil_attribute18                =>  p_pil_attribute18
      ,p_pil_attribute19                =>  p_pil_attribute19
      ,p_pil_attribute20                =>  p_pil_attribute20
      ,p_pil_attribute21                =>  p_pil_attribute21
      ,p_pil_attribute22                =>  p_pil_attribute22
      ,p_pil_attribute23                =>  p_pil_attribute23
      ,p_pil_attribute24                =>  p_pil_attribute24
      ,p_pil_attribute25                =>  p_pil_attribute25
      ,p_pil_attribute26                =>  p_pil_attribute26
      ,p_pil_attribute27                =>  p_pil_attribute27
      ,p_pil_attribute28                =>  p_pil_attribute28
      ,p_pil_attribute29                =>  p_pil_attribute29
      ,p_pil_attribute30                =>  p_pil_attribute30
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
        (p_module_name => 'CREATE_Person_Life_Event'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_Person_Life_Event
    --
  end;
  --
  -- BEGIN CODE FOR CLEANING UP SUSPENDED ENROLLMENTS PRIOR TO CREATING A NEW
  -- PER IN LER
  --
  -- Loop through all the suspended enrollments for the person.
  --
/*  for l_rec in c_sspndd_rslt loop
    --
    -- Initialize variables for this iteration.
    --
    l_rslt_ovn := l_rec.object_version_number;
    l_still_sspndd := 'N';
    --
    -- Call determine action items close open required action items and
    -- unsuspend the enrollment.
    --
    ben_enrollment_action_items.determine_action_items
      (p_prtt_enrt_rslt_id          => l_rec.prtt_enrt_rslt_id
      ,p_effective_date             => p_effective_date
      ,p_business_group_id          => p_business_group_id
      ,p_validate                   => FALSE
      ,p_rslt_object_version_number => l_rslt_ovn
      ,p_suspend_flag               => l_still_sspndd
      ,p_dpnt_actn_warning          => l_dummy_bool
      ,p_bnf_actn_warning           => l_dummy_bool
      ,p_ctfn_actn_warning          => l_dummy_bool);
    --
    -- If the enrollment is still suspended after the call above, then delete
    -- the enrollment, else leave it alone.
    --
    if l_still_sspndd = 'Y' then
      --
      ben_prtt_enrt_result_api.delete_enrollment
        (p_validate                => FALSE
        ,p_per_in_ler_id           => l_rec.per_in_ler_id
        ,p_prtt_enrt_rslt_id       => l_rec.prtt_enrt_rslt_id
        ,p_business_group_id       => p_business_group_id
        ,p_effective_start_date    => l_dummy_dt
        ,p_effective_end_date      => l_dummy_dt
        ,p_object_version_number   => l_rec.object_version_number
        ,p_effective_date          => p_effective_date
        ,p_datetrack_mode          => hr_api.g_delete
        ,p_multi_row_validate      => TRUE
        ,p_source                  => 'bepilapi');
      --
    end if;
    --
  end loop;
  --
  -- END CODE FOR CLEANUP
*/
  --
  -- Derive date column values for the per in ler status code
  --
  derive_PIL_statcd_dates
    (p_per_in_ler_stat_cd => p_per_in_ler_stat_cd
    ,p_effective_date     => p_effective_date
    ,p_procd_dt           => l_procd_dt
    ,p_strtd_dt           => l_strtd_dt
    ,p_voidd_dt           => l_voidd_dt
    ,p_bckt_dt            => l_bckt_dt
    ,p_clsd_dt            => l_clsd_dt);
  --
  select ben_per_in_ler_s.nextval
  into   l_per_in_ler_id
  from   sys.dual;
  --
  l_object_version_number := 1;
  --
  insert into ben_per_in_ler
    (per_in_ler_id
    ,per_in_ler_stat_cd
    ,prvs_stat_cd
    ,lf_evt_ocrd_dt
    ,trgr_table_pk_id --ABSE changes
    ,procd_dt
    ,strtd_dt
    ,voidd_dt
    ,bckt_dt
    ,clsd_dt
    ,ntfn_dt
    ,ptnl_ler_for_per_id
    ,bckt_per_in_ler_id
    ,ler_id
    ,person_id
    ,business_group_id
    ,ASSIGNMENT_ID
    ,WS_MGR_ID
    ,GROUP_PL_ID
    ,MGR_OVRID_PERSON_ID
    ,MGR_OVRID_DT
    ,pil_attribute_category
    ,pil_attribute1
    ,pil_attribute2
    ,pil_attribute3
    ,pil_attribute4
    ,pil_attribute5
    ,pil_attribute6
    ,pil_attribute7
    ,pil_attribute8
    ,pil_attribute9
    ,pil_attribute10
    ,pil_attribute11
    ,pil_attribute12
    ,pil_attribute13
    ,pil_attribute14
    ,pil_attribute15
    ,pil_attribute16
    ,pil_attribute17
    ,pil_attribute18
    ,pil_attribute19
    ,pil_attribute20
    ,pil_attribute21
    ,pil_attribute22
    ,pil_attribute23
    ,pil_attribute24
    ,pil_attribute25
    ,pil_attribute26
    ,pil_attribute27
    ,pil_attribute28
    ,pil_attribute29
    ,pil_attribute30
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,object_version_number)
  values
    (l_per_in_ler_id
    ,p_per_in_ler_stat_cd
    ,p_prvs_stat_cd
    ,trunc(p_lf_evt_ocrd_dt)
    ,p_trgr_table_pk_id --ABSE changes
    ,l_procd_dt
    ,l_strtd_dt
    ,l_voidd_dt
    ,l_bckt_dt
    ,l_clsd_dt
    ,trunc(p_ntfn_dt)
    ,p_ptnl_ler_for_per_id
    ,p_bckt_per_in_ler_id
    ,p_ler_id
    ,p_person_id
    ,p_business_group_id
    ,p_ASSIGNMENT_ID
    ,p_WS_MGR_ID
    ,p_GROUP_PL_ID
    ,p_MGR_OVRID_PERSON_ID
    ,p_MGR_OVRID_DT
    ,p_pil_attribute_category
    ,p_pil_attribute1
    ,p_pil_attribute2
    ,p_pil_attribute3
    ,p_pil_attribute4
    ,p_pil_attribute5
    ,p_pil_attribute6
    ,p_pil_attribute7
    ,p_pil_attribute8
    ,p_pil_attribute9
    ,p_pil_attribute10
    ,p_pil_attribute11
    ,p_pil_attribute12
    ,p_pil_attribute13
    ,p_pil_attribute14
    ,p_pil_attribute15
    ,p_pil_attribute16
    ,p_pil_attribute17
    ,p_pil_attribute18
    ,p_pil_attribute19
    ,p_pil_attribute20
    ,p_pil_attribute21
    ,p_pil_attribute22
    ,p_pil_attribute23
    ,p_pil_attribute24
    ,p_pil_attribute25
    ,p_pil_attribute26
    ,p_pil_attribute27
    ,p_pil_attribute28
    ,p_pil_attribute29
    ,p_pil_attribute30
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,trunc(p_program_update_date)
    ,l_object_version_number);
  --
   -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_pil_rki.after_insert
      (p_per_in_ler_id                 =>l_per_in_ler_id
      ,p_per_in_ler_stat_cd            =>p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                  =>p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                =>trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id              =>p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                      =>l_procd_dt
      ,p_strtd_dt                      =>l_strtd_dt
      ,p_voidd_dt                      =>l_voidd_dt
      ,p_bckt_dt                       =>l_bckt_dt
      ,p_clsd_dt                       =>l_clsd_dt
      ,p_ntfn_dt                       =>trunc(p_ntfn_dt)
      ,p_ptnl_ler_for_per_id           =>p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id            =>p_bckt_per_in_ler_id
      ,p_ler_id                        =>p_ler_id
      ,p_person_id                     =>p_person_id
      ,p_business_group_id             =>p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category        =>p_pil_attribute_category
      ,p_pil_attribute1                =>p_pil_attribute1
      ,p_pil_attribute2                =>p_pil_attribute2
      ,p_pil_attribute3                =>p_pil_attribute3
      ,p_pil_attribute4                =>p_pil_attribute4
      ,p_pil_attribute5                =>p_pil_attribute5
      ,p_pil_attribute6                =>p_pil_attribute6
      ,p_pil_attribute7                =>p_pil_attribute7
      ,p_pil_attribute8                =>p_pil_attribute8
      ,p_pil_attribute9                =>p_pil_attribute9
      ,p_pil_attribute10               =>p_pil_attribute10
      ,p_pil_attribute11               =>p_pil_attribute11
      ,p_pil_attribute12               =>p_pil_attribute12
      ,p_pil_attribute13               =>p_pil_attribute13
      ,p_pil_attribute14               =>p_pil_attribute14
      ,p_pil_attribute15               =>p_pil_attribute15
      ,p_pil_attribute16               =>p_pil_attribute16
      ,p_pil_attribute17               =>p_pil_attribute17
      ,p_pil_attribute18               =>p_pil_attribute18
      ,p_pil_attribute19               =>p_pil_attribute19
      ,p_pil_attribute20               =>p_pil_attribute20
      ,p_pil_attribute21               =>p_pil_attribute21
      ,p_pil_attribute22               =>p_pil_attribute22
      ,p_pil_attribute23               =>p_pil_attribute23
      ,p_pil_attribute24               =>p_pil_attribute24
      ,p_pil_attribute25               =>p_pil_attribute25
      ,p_pil_attribute26               =>p_pil_attribute26
      ,p_pil_attribute27               =>p_pil_attribute27
      ,p_pil_attribute28               =>p_pil_attribute28
      ,p_pil_attribute29               =>p_pil_attribute29
      ,p_pil_attribute30               =>p_pil_attribute30
      ,p_request_id                    =>p_request_id
      ,p_program_application_id        =>p_program_application_id
      ,p_program_id                    =>p_program_id
      ,p_program_update_date           =>trunc(p_program_update_date)
      ,p_object_version_number         =>l_object_version_number
      ,p_effective_date                =>trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_per_in_ler'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Person_Life_Event
    --
    ben_Person_Life_Event_bk1.create_Person_Life_Event_a
      (p_per_in_ler_id                  =>  l_per_in_ler_id
      ,p_per_in_ler_stat_cd             =>  p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                   =>  p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                       =>  l_procd_dt
      ,p_strtd_dt                       =>  l_strtd_dt
      ,p_voidd_dt                       =>  l_voidd_dt
      ,p_bckt_dt                        =>  l_bckt_dt
      ,p_clsd_dt                        =>  l_clsd_dt
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id             =>  p_bckt_per_in_ler_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category         =>  p_pil_attribute_category
      ,p_pil_attribute1                 =>  p_pil_attribute1
      ,p_pil_attribute2                 =>  p_pil_attribute2
      ,p_pil_attribute3                 =>  p_pil_attribute3
      ,p_pil_attribute4                 =>  p_pil_attribute4
      ,p_pil_attribute5                 =>  p_pil_attribute5
      ,p_pil_attribute6                 =>  p_pil_attribute6
      ,p_pil_attribute7                 =>  p_pil_attribute7
      ,p_pil_attribute8                 =>  p_pil_attribute8
      ,p_pil_attribute9                 =>  p_pil_attribute9
      ,p_pil_attribute10                =>  p_pil_attribute10
      ,p_pil_attribute11                =>  p_pil_attribute11
      ,p_pil_attribute12                =>  p_pil_attribute12
      ,p_pil_attribute13                =>  p_pil_attribute13
      ,p_pil_attribute14                =>  p_pil_attribute14
      ,p_pil_attribute15                =>  p_pil_attribute15
      ,p_pil_attribute16                =>  p_pil_attribute16
      ,p_pil_attribute17                =>  p_pil_attribute17
      ,p_pil_attribute18                =>  p_pil_attribute18
      ,p_pil_attribute19                =>  p_pil_attribute19
      ,p_pil_attribute20                =>  p_pil_attribute20
      ,p_pil_attribute21                =>  p_pil_attribute21
      ,p_pil_attribute22                =>  p_pil_attribute22
      ,p_pil_attribute23                =>  p_pil_attribute23
      ,p_pil_attribute24                =>  p_pil_attribute24
      ,p_pil_attribute25                =>  p_pil_attribute25
      ,p_pil_attribute26                =>  p_pil_attribute26
      ,p_pil_attribute27                =>  p_pil_attribute27
      ,p_pil_attribute28                =>  p_pil_attribute28
      ,p_pil_attribute29                =>  p_pil_attribute29
      ,p_pil_attribute30                =>  p_pil_attribute30
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
        (p_module_name => 'CREATE_Person_Life_Event'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_Person_Life_Event
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
  p_per_in_ler_id         := l_per_in_ler_id;
  p_object_version_number := l_object_version_number;
  p_procd_dt              := l_procd_dt;
  p_strtd_dt              := l_strtd_dt;
  p_voidd_dt              := l_voidd_dt;
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
    ROLLBACK TO create_Person_Life_Event;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_in_ler_id := null;
    p_object_version_number  := null;
    p_procd_dt               := null;
    p_strtd_dt               := null;
    p_voidd_dt               := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Person_Life_Event;
    raise;
    --
end create_Person_Life_Event_perf;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Person_Life_Event
  (p_validate                       in boolean    default false
  ,p_per_in_ler_id                  in  number
  ,p_per_in_ler_stat_cd             in  varchar2  default hr_api.g_varchar2
  ,p_prvs_stat_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_trgr_table_pk_id               in  number    default hr_api.g_number --ABSE changes
  ,p_procd_dt                       out NOCOPY date
  ,p_strtd_dt                       out NOCOPY date
  ,p_voidd_dt                       out NOCOPY date
  ,p_bckt_dt                        in  date      default hr_api.g_date
  ,p_clsd_dt                        in  date      default hr_api.g_date
  ,p_ntfn_dt                        in  date      default hr_api.g_date
  ,p_ptnl_ler_for_per_id            in  number    default hr_api.g_number
  ,p_bckt_per_in_ler_id             in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ASSIGNMENT_ID                  in  number    default hr_api.g_number
  ,p_WS_MGR_ID                      in  number    default hr_api.g_number
  ,p_GROUP_PL_ID                    in  number    default hr_api.g_number
  ,p_MGR_OVRID_PERSON_ID            in  number    default hr_api.g_number
  ,p_MGR_OVRID_DT                   in  date      default hr_api.g_date
  ,p_pil_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pil_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Person_Life_Event';
  l_object_version_number ben_per_in_ler.object_version_number%TYPE;
  --
  l_procd_dt              date := hr_api.g_date;
  l_strtd_dt              date := hr_api.g_date;
  l_voidd_dt              date := hr_api.g_date;
  l_bckt_dt               date := hr_api.g_date;
  l_clsd_dt               date := hr_api.g_date;
  l_ntfn_dt               date := hr_api.g_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Person_Life_Event;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Person_Life_Event
    --
    ben_Person_Life_Event_bk2.update_Person_Life_Event_b
      (p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_per_in_ler_stat_cd             =>  p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                   =>  p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                       =>  trunc(p_procd_dt)
      ,p_strtd_dt                       =>  trunc(p_strtd_dt)
      ,p_voidd_dt                       =>  trunc(p_voidd_dt)
      ,p_bckt_dt                        =>  trunc(p_bckt_dt)
      ,p_clsd_dt                        =>  trunc(p_clsd_dt)
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id             =>  p_bckt_per_in_ler_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category         =>  p_pil_attribute_category
      ,p_pil_attribute1                 =>  p_pil_attribute1
      ,p_pil_attribute2                 =>  p_pil_attribute2
      ,p_pil_attribute3                 =>  p_pil_attribute3
      ,p_pil_attribute4                 =>  p_pil_attribute4
      ,p_pil_attribute5                 =>  p_pil_attribute5
      ,p_pil_attribute6                 =>  p_pil_attribute6
      ,p_pil_attribute7                 =>  p_pil_attribute7
      ,p_pil_attribute8                 =>  p_pil_attribute8
      ,p_pil_attribute9                 =>  p_pil_attribute9
      ,p_pil_attribute10                =>  p_pil_attribute10
      ,p_pil_attribute11                =>  p_pil_attribute11
      ,p_pil_attribute12                =>  p_pil_attribute12
      ,p_pil_attribute13                =>  p_pil_attribute13
      ,p_pil_attribute14                =>  p_pil_attribute14
      ,p_pil_attribute15                =>  p_pil_attribute15
      ,p_pil_attribute16                =>  p_pil_attribute16
      ,p_pil_attribute17                =>  p_pil_attribute17
      ,p_pil_attribute18                =>  p_pil_attribute18
      ,p_pil_attribute19                =>  p_pil_attribute19
      ,p_pil_attribute20                =>  p_pil_attribute20
      ,p_pil_attribute21                =>  p_pil_attribute21
      ,p_pil_attribute22                =>  p_pil_attribute22
      ,p_pil_attribute23                =>  p_pil_attribute23
      ,p_pil_attribute24                =>  p_pil_attribute24
      ,p_pil_attribute25                =>  p_pil_attribute25
      ,p_pil_attribute26                =>  p_pil_attribute26
      ,p_pil_attribute27                =>  p_pil_attribute27
      ,p_pil_attribute28                =>  p_pil_attribute28
      ,p_pil_attribute29                =>  p_pil_attribute29
      ,p_pil_attribute30                =>  p_pil_attribute30
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
        (p_module_name => 'UPDATE_Person_Life_Event'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_Person_Life_Event
    --
  end;
  --
  -- Derive date column values for the per in ler status code
  --
  derive_PIL_statcd_dates
    (p_per_in_ler_stat_cd => p_per_in_ler_stat_cd
    ,p_effective_date     => p_effective_date
    ,p_procd_dt           => l_procd_dt
    ,p_strtd_dt           => l_strtd_dt
    ,p_voidd_dt           => l_voidd_dt
    ,p_bckt_dt            => l_bckt_dt
    ,p_clsd_dt            => l_clsd_dt);
  --
  hr_utility.set_location(l_proc, 20);
  hr_utility.set_location(l_proc||' l_procd_dt: '||l_procd_dt, 20);
  --
  ben_pil_upd.upd
    (p_per_in_ler_id                 => p_per_in_ler_id
    ,p_per_in_ler_stat_cd            => p_per_in_ler_stat_cd
    ,p_prvs_stat_cd                  => p_prvs_stat_cd
    ,p_lf_evt_ocrd_dt                => trunc(p_lf_evt_ocrd_dt)
    ,p_trgr_table_pk_id              => p_trgr_table_pk_id --ABSE changes
    ,p_procd_dt                      => l_procd_dt
    ,p_strtd_dt                      => l_strtd_dt
    ,p_voidd_dt                      => l_voidd_dt
    ,p_bckt_dt                       => l_bckt_dt
    ,p_clsd_dt                       => l_clsd_dt
    ,p_ntfn_dt                       => trunc(p_ntfn_dt)
    ,p_ptnl_ler_for_per_id           => p_ptnl_ler_for_per_id
    ,p_bckt_per_in_ler_id            => p_bckt_per_in_ler_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_ASSIGNMENT_ID                 =>  p_ASSIGNMENT_ID
    ,p_WS_MGR_ID                     =>  p_WS_MGR_ID
    ,p_GROUP_PL_ID                   =>  p_GROUP_PL_ID
    ,p_MGR_OVRID_PERSON_ID           =>  p_MGR_OVRID_PERSON_ID
    ,p_MGR_OVRID_DT                  =>  p_MGR_OVRID_DT
    ,p_pil_attribute_category        => p_pil_attribute_category
    ,p_pil_attribute1                => p_pil_attribute1
    ,p_pil_attribute2                => p_pil_attribute2
    ,p_pil_attribute3                => p_pil_attribute3
    ,p_pil_attribute4                => p_pil_attribute4
    ,p_pil_attribute5                => p_pil_attribute5
    ,p_pil_attribute6                => p_pil_attribute6
    ,p_pil_attribute7                => p_pil_attribute7
    ,p_pil_attribute8                => p_pil_attribute8
    ,p_pil_attribute9                => p_pil_attribute9
    ,p_pil_attribute10               => p_pil_attribute10
    ,p_pil_attribute11               => p_pil_attribute11
    ,p_pil_attribute12               => p_pil_attribute12
    ,p_pil_attribute13               => p_pil_attribute13
    ,p_pil_attribute14               => p_pil_attribute14
    ,p_pil_attribute15               => p_pil_attribute15
    ,p_pil_attribute16               => p_pil_attribute16
    ,p_pil_attribute17               => p_pil_attribute17
    ,p_pil_attribute18               => p_pil_attribute18
    ,p_pil_attribute19               => p_pil_attribute19
    ,p_pil_attribute20               => p_pil_attribute20
    ,p_pil_attribute21               => p_pil_attribute21
    ,p_pil_attribute22               => p_pil_attribute22
    ,p_pil_attribute23               => p_pil_attribute23
    ,p_pil_attribute24               => p_pil_attribute24
    ,p_pil_attribute25               => p_pil_attribute25
    ,p_pil_attribute26               => p_pil_attribute26
    ,p_pil_attribute27               => p_pil_attribute27
    ,p_pil_attribute28               => p_pil_attribute28
    ,p_pil_attribute29               => p_pil_attribute29
    ,p_pil_attribute30               => p_pil_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => trunc(p_program_update_date)
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Person_Life_Event
    --
    ben_Person_Life_Event_bk2.update_Person_Life_Event_a
      (p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_per_in_ler_stat_cd             =>  p_per_in_ler_stat_cd
      ,p_prvs_stat_cd                   =>  p_prvs_stat_cd
      ,p_lf_evt_ocrd_dt                 =>  trunc(p_lf_evt_ocrd_dt)
      ,p_trgr_table_pk_id               =>  p_trgr_table_pk_id --ABSE changes
      ,p_procd_dt                       =>  l_procd_dt
      ,p_strtd_dt                       =>  l_strtd_dt
      ,p_voidd_dt                       =>  l_voidd_dt
      ,p_bckt_dt                        =>  l_bckt_dt
      ,p_clsd_dt                        =>  l_clsd_dt
      ,p_ntfn_dt                        =>  trunc(p_ntfn_dt)
      ,p_ptnl_ler_for_per_id            =>  p_ptnl_ler_for_per_id
      ,p_bckt_per_in_ler_id             =>  p_bckt_per_in_ler_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ASSIGNMENT_ID                  =>  p_ASSIGNMENT_ID
      ,p_WS_MGR_ID                      =>  p_WS_MGR_ID
      ,p_GROUP_PL_ID                    =>  p_GROUP_PL_ID
      ,p_MGR_OVRID_PERSON_ID            =>  p_MGR_OVRID_PERSON_ID
      ,p_MGR_OVRID_DT                   =>  p_MGR_OVRID_DT
      ,p_pil_attribute_category         =>  p_pil_attribute_category
      ,p_pil_attribute1                 =>  p_pil_attribute1
      ,p_pil_attribute2                 =>  p_pil_attribute2
      ,p_pil_attribute3                 =>  p_pil_attribute3
      ,p_pil_attribute4                 =>  p_pil_attribute4
      ,p_pil_attribute5                 =>  p_pil_attribute5
      ,p_pil_attribute6                 =>  p_pil_attribute6
      ,p_pil_attribute7                 =>  p_pil_attribute7
      ,p_pil_attribute8                 =>  p_pil_attribute8
      ,p_pil_attribute9                 =>  p_pil_attribute9
      ,p_pil_attribute10                =>  p_pil_attribute10
      ,p_pil_attribute11                =>  p_pil_attribute11
      ,p_pil_attribute12                =>  p_pil_attribute12
      ,p_pil_attribute13                =>  p_pil_attribute13
      ,p_pil_attribute14                =>  p_pil_attribute14
      ,p_pil_attribute15                =>  p_pil_attribute15
      ,p_pil_attribute16                =>  p_pil_attribute16
      ,p_pil_attribute17                =>  p_pil_attribute17
      ,p_pil_attribute18                =>  p_pil_attribute18
      ,p_pil_attribute19                =>  p_pil_attribute19
      ,p_pil_attribute20                =>  p_pil_attribute20
      ,p_pil_attribute21                =>  p_pil_attribute21
      ,p_pil_attribute22                =>  p_pil_attribute22
      ,p_pil_attribute23                =>  p_pil_attribute23
      ,p_pil_attribute24                =>  p_pil_attribute24
      ,p_pil_attribute25                =>  p_pil_attribute25
      ,p_pil_attribute26                =>  p_pil_attribute26
      ,p_pil_attribute27                =>  p_pil_attribute27
      ,p_pil_attribute28                =>  p_pil_attribute28
      ,p_pil_attribute29                =>  p_pil_attribute29
      ,p_pil_attribute30                =>  p_pil_attribute30
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
        (p_module_name => 'UPDATE_Person_Life_Event'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_Person_Life_Event
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
  p_procd_dt              := l_procd_dt;
  p_strtd_dt              := l_strtd_dt;
  p_voidd_dt              := l_voidd_dt;
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
    ROLLBACK TO update_Person_Life_Event;
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
    ROLLBACK TO update_Person_Life_Event;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_procd_dt              := null;
    p_strtd_dt              := null;
    p_voidd_dt              := null;
    raise;
    --
end update_Person_Life_Event;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Person_Life_Event >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Person_Life_Event
  (p_validate                       in  boolean  default false
  ,p_per_in_ler_id                  in  number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Person_Life_Event';
  l_object_version_number ben_per_in_ler.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Person_Life_Event;
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
    -- Start of API User Hook for the before hook of delete_Person_Life_Event
    --
    ben_Person_Life_Event_bk3.delete_Person_Life_Event_b
      (p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Person_Life_Event'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_Person_Life_Event
    --
  end;
  --
  ben_pil_del.del
    (p_per_in_ler_id                 => p_per_in_ler_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Person_Life_Event
    --
    ben_Person_Life_Event_bk3.delete_Person_Life_Event_a
      (p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Person_Life_Event'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_Person_Life_Event
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
    ROLLBACK TO delete_Person_Life_Event;
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
    ROLLBACK TO delete_Person_Life_Event;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_Person_Life_Event;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_per_in_ler_id                  in     number
  ,p_object_version_number          in     number) is
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
  ben_pil_shd.lck
    (p_per_in_ler_id              => p_per_in_ler_id
    ,p_object_version_number      => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Person_Life_Event_api;

/
