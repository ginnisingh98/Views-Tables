--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_BENEFICIARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_BENEFICIARY_API" as
/* $Header: bepbnapi.pkb 120.4.12010000.2 2008/08/05 15:04:40 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PLAN_BENEFICIARY_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PLAN_BENEFICIARY >----------------------|
-- ----------------------------------------------------------------------------
--
--
procedure create_PLAN_BENEFICIARY
  (p_validate                       in  boolean   default false
  ,p_pl_bnf_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_bnf_person_id                  in  number    default null
  ,p_organization_id                in  number    default null
  ,p_ttee_person_id                 in  number    default null
  ,p_prmry_cntngnt_cd               in  varchar2  default null
  ,p_pct_dsgd_num                   in  number    default null
  ,p_amt_dsgd_val                   in  number    default null
  ,p_amt_dsgd_uom                   in  varchar2  default null
  ,p_dsgn_strt_dt                   in  date      default null
  ,p_dsgn_thru_dt                   in  date      default null
  ,p_addl_instrn_txt                in  varchar2  default null
  ,p_pbn_attribute_category         in  varchar2  default null
  ,p_pbn_attribute1                 in  varchar2  default null
  ,p_pbn_attribute2                 in  varchar2  default null
  ,p_pbn_attribute3                 in  varchar2  default null
  ,p_pbn_attribute4                 in  varchar2  default null
  ,p_pbn_attribute5                 in  varchar2  default null
  ,p_pbn_attribute6                 in  varchar2  default null
  ,p_pbn_attribute7                 in  varchar2  default null
  ,p_pbn_attribute8                 in  varchar2  default null
  ,p_pbn_attribute9                 in  varchar2  default null
  ,p_pbn_attribute10                in  varchar2  default null
  ,p_pbn_attribute11                in  varchar2  default null
  ,p_pbn_attribute12                in  varchar2  default null
  ,p_pbn_attribute13                in  varchar2  default null
  ,p_pbn_attribute14                in  varchar2  default null
  ,p_pbn_attribute15                in  varchar2  default null
  ,p_pbn_attribute16                in  varchar2  default null
  ,p_pbn_attribute17                in  varchar2  default null
  ,p_pbn_attribute18                in  varchar2  default null
  ,p_pbn_attribute19                in  varchar2  default null
  ,p_pbn_attribute20                in  varchar2  default null
  ,p_pbn_attribute21                in  varchar2  default null
  ,p_pbn_attribute22                in  varchar2  default null
  ,p_pbn_attribute23                in  varchar2  default null
  ,p_pbn_attribute24                in  varchar2  default null
  ,p_pbn_attribute25                in  varchar2  default null
  ,p_pbn_attribute26                in  varchar2  default null
  ,p_pbn_attribute27                in  varchar2  default null
  ,p_pbn_attribute28                in  varchar2  default null
  ,p_pbn_attribute29                in  varchar2  default null
  ,p_pbn_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_effective_date                 in  date
  ,p_multi_row_actn                 in  boolean   default TRUE
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_pl_bnf_id                  ben_pl_bnf_f.pl_bnf_id%TYPE;
  l_effective_start_date       ben_pl_bnf_f.effective_start_date%TYPE;
  l_effective_end_date         ben_pl_bnf_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PLAN_BENEFICIARY';
  l_object_version_number      ben_pl_bnf_f.object_version_number%TYPE;
  l_per_in_ler_id              ben_pl_bnf_f.per_in_ler_id%TYPE;
  --
 cursor c_pil is
  select pil.per_in_ler_id
from ben_prtt_enrt_rslt_f pen ,
     ben_per_in_ler pil
where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
  and pen.per_in_ler_id = pil.per_in_ler_id
  and pen.prtt_enrt_rslt_stat_cd is null
  and pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
  order by pil.lf_evt_ocrd_dt asc;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if fnd_global.conc_request_id = -1 then
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
  -- Issue a savepoint if operating in validation only mode
  --
  /***
    Start 5883382 - Get the earliest possible PIL for BNF
  ***/
     l_per_in_ler_id := null ;
     open c_pil;
     fetch c_pil into l_per_in_ler_id;
     close c_pil;



   l_per_in_ler_id := nvl(l_per_in_ler_id,p_per_in_ler_id);

  /***
    End 5883382 - Get the earliest possible PIL for BNF
  ***/
  savepoint create_PLAN_BENEFICIARY;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PLAN_BENEFICIARY
    --
    ben_PLAN_BENEFICIARY_bk1.create_PLAN_BENEFICIARY_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_organization_id                =>  p_organization_id
      ,p_ttee_person_id                 =>  p_ttee_person_id
      ,p_prmry_cntngnt_cd               =>  p_prmry_cntngnt_cd
      ,p_pct_dsgd_num                   =>  p_pct_dsgd_num
      ,p_amt_dsgd_val                   =>  p_amt_dsgd_val
      ,p_amt_dsgd_uom                   =>  p_amt_dsgd_uom
      ,p_dsgn_strt_dt                   =>  p_dsgn_strt_dt
      ,p_dsgn_thru_dt                   =>  p_dsgn_thru_dt
      ,p_addl_instrn_txt                =>  p_addl_instrn_txt
      ,p_pbn_attribute_category         =>  p_pbn_attribute_category
      ,p_pbn_attribute1                 =>  p_pbn_attribute1
      ,p_pbn_attribute2                 =>  p_pbn_attribute2
      ,p_pbn_attribute3                 =>  p_pbn_attribute3
      ,p_pbn_attribute4                 =>  p_pbn_attribute4
      ,p_pbn_attribute5                 =>  p_pbn_attribute5
      ,p_pbn_attribute6                 =>  p_pbn_attribute6
      ,p_pbn_attribute7                 =>  p_pbn_attribute7
      ,p_pbn_attribute8                 =>  p_pbn_attribute8
      ,p_pbn_attribute9                 =>  p_pbn_attribute9
      ,p_pbn_attribute10                =>  p_pbn_attribute10
      ,p_pbn_attribute11                =>  p_pbn_attribute11
      ,p_pbn_attribute12                =>  p_pbn_attribute12
      ,p_pbn_attribute13                =>  p_pbn_attribute13
      ,p_pbn_attribute14                =>  p_pbn_attribute14
      ,p_pbn_attribute15                =>  p_pbn_attribute15
      ,p_pbn_attribute16                =>  p_pbn_attribute16
      ,p_pbn_attribute17                =>  p_pbn_attribute17
      ,p_pbn_attribute18                =>  p_pbn_attribute18
      ,p_pbn_attribute19                =>  p_pbn_attribute19
      ,p_pbn_attribute20                =>  p_pbn_attribute20
      ,p_pbn_attribute21                =>  p_pbn_attribute21
      ,p_pbn_attribute22                =>  p_pbn_attribute22
      ,p_pbn_attribute23                =>  p_pbn_attribute23
      ,p_pbn_attribute24                =>  p_pbn_attribute24
      ,p_pbn_attribute25                =>  p_pbn_attribute25
      ,p_pbn_attribute26                =>  p_pbn_attribute26
      ,p_pbn_attribute27                =>  p_pbn_attribute27
      ,p_pbn_attribute28                =>  p_pbn_attribute28
      ,p_pbn_attribute29                =>  p_pbn_attribute29
      ,p_pbn_attribute30                =>  p_pbn_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_per_in_ler_id                  =>  l_per_in_ler_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PLAN_BENEFICIARY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PLAN_BENEFICIARY
    --
  end;
  --
  ben_pbn_ins.ins
    (
     p_pl_bnf_id                     => l_pl_bnf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_bnf_person_id                 => p_bnf_person_id
    ,p_organization_id               => p_organization_id
    ,p_ttee_person_id                => p_ttee_person_id
    ,p_prmry_cntngnt_cd              => p_prmry_cntngnt_cd
    ,p_pct_dsgd_num                  => p_pct_dsgd_num
    ,p_amt_dsgd_val                  => p_amt_dsgd_val
    ,p_amt_dsgd_uom                  => p_amt_dsgd_uom
    ,p_dsgn_strt_dt                  => p_dsgn_strt_dt
    ,p_dsgn_thru_dt                  => p_dsgn_thru_dt
    ,p_addl_instrn_txt               => p_addl_instrn_txt
    ,p_pbn_attribute_category        => p_pbn_attribute_category
    ,p_pbn_attribute1                => p_pbn_attribute1
    ,p_pbn_attribute2                => p_pbn_attribute2
    ,p_pbn_attribute3                => p_pbn_attribute3
    ,p_pbn_attribute4                => p_pbn_attribute4
    ,p_pbn_attribute5                => p_pbn_attribute5
    ,p_pbn_attribute6                => p_pbn_attribute6
    ,p_pbn_attribute7                => p_pbn_attribute7
    ,p_pbn_attribute8                => p_pbn_attribute8
    ,p_pbn_attribute9                => p_pbn_attribute9
    ,p_pbn_attribute10               => p_pbn_attribute10
    ,p_pbn_attribute11               => p_pbn_attribute11
    ,p_pbn_attribute12               => p_pbn_attribute12
    ,p_pbn_attribute13               => p_pbn_attribute13
    ,p_pbn_attribute14               => p_pbn_attribute14
    ,p_pbn_attribute15               => p_pbn_attribute15
    ,p_pbn_attribute16               => p_pbn_attribute16
    ,p_pbn_attribute17               => p_pbn_attribute17
    ,p_pbn_attribute18               => p_pbn_attribute18
    ,p_pbn_attribute19               => p_pbn_attribute19
    ,p_pbn_attribute20               => p_pbn_attribute20
    ,p_pbn_attribute21               => p_pbn_attribute21
    ,p_pbn_attribute22               => p_pbn_attribute22
    ,p_pbn_attribute23               => p_pbn_attribute23
    ,p_pbn_attribute24               => p_pbn_attribute24
    ,p_pbn_attribute25               => p_pbn_attribute25
    ,p_pbn_attribute26               => p_pbn_attribute26
    ,p_pbn_attribute27               => p_pbn_attribute27
    ,p_pbn_attribute28               => p_pbn_attribute28
    ,p_pbn_attribute29               => p_pbn_attribute29
    ,p_pbn_attribute30               => p_pbn_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_per_in_ler_id                 => l_per_in_ler_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  --  Call Action item RCO if p_multi_row_actn = TRUE
  --
  if p_multi_row_actn then
    --
    bnf_actn_items(
           p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
          ,p_pl_bnf_id          => l_pl_bnf_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_validate           => p_validate
          ,p_datetrack_mode     => null
          );
    --
  end if;
  --
  --  Create person type usage, if needed
  --
  if p_bnf_person_id is not null then
    --
    add_usage(
                  p_validate             => p_validate
                 ,p_pl_bnf_id            => l_pl_bnf_id
                 ,p_bnf_person_id        => p_bnf_person_id
                 ,p_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id
                 ,p_business_group_id    => p_business_group_id
                 ,p_effective_date       => p_effective_date
                 ,p_datetrack_mode       => null
             );

    --
  end if;
  --
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PLAN_BENEFICIARY
    --
    ben_PLAN_BENEFICIARY_bk1.create_PLAN_BENEFICIARY_a
      (
       p_pl_bnf_id                      =>  l_pl_bnf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_organization_id                =>  p_organization_id
      ,p_ttee_person_id                 =>  p_ttee_person_id
      ,p_prmry_cntngnt_cd               =>  p_prmry_cntngnt_cd
      ,p_pct_dsgd_num                   =>  p_pct_dsgd_num
      ,p_amt_dsgd_val                   =>  p_amt_dsgd_val
      ,p_amt_dsgd_uom                   =>  p_amt_dsgd_uom
      ,p_dsgn_strt_dt                   =>  p_dsgn_strt_dt
      ,p_dsgn_thru_dt                   =>  p_dsgn_thru_dt
      ,p_addl_instrn_txt                =>  p_addl_instrn_txt
      ,p_pbn_attribute_category         =>  p_pbn_attribute_category
      ,p_pbn_attribute1                 =>  p_pbn_attribute1
      ,p_pbn_attribute2                 =>  p_pbn_attribute2
      ,p_pbn_attribute3                 =>  p_pbn_attribute3
      ,p_pbn_attribute4                 =>  p_pbn_attribute4
      ,p_pbn_attribute5                 =>  p_pbn_attribute5
      ,p_pbn_attribute6                 =>  p_pbn_attribute6
      ,p_pbn_attribute7                 =>  p_pbn_attribute7
      ,p_pbn_attribute8                 =>  p_pbn_attribute8
      ,p_pbn_attribute9                 =>  p_pbn_attribute9
      ,p_pbn_attribute10                =>  p_pbn_attribute10
      ,p_pbn_attribute11                =>  p_pbn_attribute11
      ,p_pbn_attribute12                =>  p_pbn_attribute12
      ,p_pbn_attribute13                =>  p_pbn_attribute13
      ,p_pbn_attribute14                =>  p_pbn_attribute14
      ,p_pbn_attribute15                =>  p_pbn_attribute15
      ,p_pbn_attribute16                =>  p_pbn_attribute16
      ,p_pbn_attribute17                =>  p_pbn_attribute17
      ,p_pbn_attribute18                =>  p_pbn_attribute18
      ,p_pbn_attribute19                =>  p_pbn_attribute19
      ,p_pbn_attribute20                =>  p_pbn_attribute20
      ,p_pbn_attribute21                =>  p_pbn_attribute21
      ,p_pbn_attribute22                =>  p_pbn_attribute22
      ,p_pbn_attribute23                =>  p_pbn_attribute23
      ,p_pbn_attribute24                =>  p_pbn_attribute24
      ,p_pbn_attribute25                =>  p_pbn_attribute25
      ,p_pbn_attribute26                =>  p_pbn_attribute26
      ,p_pbn_attribute27                =>  p_pbn_attribute27
      ,p_pbn_attribute28                =>  p_pbn_attribute28
      ,p_pbn_attribute29                =>  p_pbn_attribute29
      ,p_pbn_attribute30                =>  p_pbn_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_per_in_ler_id                  =>  l_per_in_ler_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PLAN_BENEFICIARY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PLAN_BENEFICIARY
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
  p_pl_bnf_id := l_pl_bnf_id;
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
    ROLLBACK TO create_PLAN_BENEFICIARY;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_bnf_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PLAN_BENEFICIARY;
    p_pl_bnf_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
End CREATE_PLAN_BENEFICIARY;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_PLAN_BENEFICIARY_w >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PLAN_BENEFICIARY_w
(
   p_validate                       in  varchar2
  ,p_pl_bnf_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_bnf_person_id                  in  number default null
  ,p_organization_id                in  number default null
  ,p_prmry_cntngnt_cd               in  varchar2
  ,p_pct_dsgd_num                   in  number
  ,p_dsgn_strt_dt                   in  date
  ,p_dsgn_thru_dt                   in  date
  ,p_object_version_number          out nocopy number
  ,p_per_in_ler_id                  in  number
  ,p_effective_date                 in  date
  ,p_multi_row_actn                 in  varchar2
)
is

  l_proc varchar2(72)          := g_package||'create_plan_beneficiary wrapper';

  l_pl_bnf_id                  ben_pl_bnf_f.pl_bnf_id%TYPE;
  l_effective_start_date       ben_pl_bnf_f.effective_start_date%TYPE;
  l_effective_end_date         ben_pl_bnf_f.effective_end_date%TYPE;
  l_object_version_number      ben_pl_bnf_f.object_version_number%TYPE;

  l_validate       BOOLEAN;
  l_multi_row_actn BOOLEAN;
  --
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if fnd_global.conc_request_id in (0,-1) then
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
  hr_utility.set_location(l_proc, 20);
  --
  --
  if upper(p_validate) = 'TRUE'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;

  if upper(p_multi_row_actn) = 'TRUE'
  then
    l_multi_row_actn := TRUE;
  else
    l_multi_row_actn := FALSE;
  end if;

  create_PLAN_BENEFICIARY
  (
     p_validate                =>    l_validate
    ,p_pl_bnf_id               =>    l_pl_bnf_id
    ,p_effective_start_date    =>    l_effective_start_date
    ,p_effective_end_date      =>    l_effective_end_date
    ,p_business_group_id       =>    p_business_group_id
    ,p_prtt_enrt_rslt_id       =>    p_prtt_enrt_rslt_id
    ,p_bnf_person_id           =>    p_bnf_person_id
    ,p_organization_id         =>    p_organization_id
    ,p_prmry_cntngnt_cd        =>    p_prmry_cntngnt_cd
    ,p_pct_dsgd_num            =>    p_pct_dsgd_num
    ,p_dsgn_strt_dt            =>    p_dsgn_strt_dt
    ,p_dsgn_thru_dt            =>    p_dsgn_thru_dt
    ,p_object_version_number   =>    l_object_version_number
    ,p_per_in_ler_id           =>    p_per_in_ler_id
    ,p_effective_date          =>    p_effective_date
    ,p_multi_row_actn          =>    l_multi_row_actn
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Set all output arguments
  --
  p_pl_bnf_id             := l_pl_bnf_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_pl_bnf_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    fnd_msg_pub.add;
    --
End CREATE_PLAN_BENEFICIARY_w;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_PLAN_BENEFICIARY >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PLAN_BENEFICIARY
  (p_validate                       in  boolean   default false
  ,p_pl_bnf_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_bnf_person_id                  in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_ttee_person_id                 in  number    default hr_api.g_number
  ,p_prmry_cntngnt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pct_dsgd_num                   in  number    default hr_api.g_number
  ,p_amt_dsgd_val                   in  number    default hr_api.g_number
  ,p_amt_dsgd_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_dsgn_strt_dt                   in  date      default hr_api.g_date
  ,p_dsgn_thru_dt                   in  date      default hr_api.g_date
  ,p_addl_instrn_txt                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pbn_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
 ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  boolean   default TRUE
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc varchar2(72) := g_package||'update_PLAN_BENEFICIARY';
  l_object_version_number ben_pl_bnf_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_bnf_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_bnf_f.effective_end_date%TYPE;
  l2_datetrack_mode         varchar2(30);
  l_rslt_object_version_number  number;
  l_actn_typ_id                 number;
  l_prtt_enrt_actn_id           number;
  l_cmpltd_dt                   date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if fnd_global.conc_request_id = -1 then
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
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PLAN_BENEFICIARY;
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
    -- Start of API User Hook for the before hook of update_PLAN_BENEFICIARY
    --
    ben_PLAN_BENEFICIARY_bk2.update_PLAN_BENEFICIARY_b
      (
       p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_organization_id                =>  p_organization_id
      ,p_ttee_person_id                 =>  p_ttee_person_id
      ,p_prmry_cntngnt_cd               =>  p_prmry_cntngnt_cd
      ,p_pct_dsgd_num                   =>  p_pct_dsgd_num
      ,p_amt_dsgd_val                   =>  p_amt_dsgd_val
      ,p_amt_dsgd_uom                   =>  p_amt_dsgd_uom
      ,p_dsgn_strt_dt                   =>  p_dsgn_strt_dt
      ,p_dsgn_thru_dt                   =>  p_dsgn_thru_dt
      ,p_addl_instrn_txt                =>  p_addl_instrn_txt
      ,p_pbn_attribute_category         =>  p_pbn_attribute_category
      ,p_pbn_attribute1                 =>  p_pbn_attribute1
      ,p_pbn_attribute2                 =>  p_pbn_attribute2
      ,p_pbn_attribute3                 =>  p_pbn_attribute3
      ,p_pbn_attribute4                 =>  p_pbn_attribute4
      ,p_pbn_attribute5                 =>  p_pbn_attribute5
      ,p_pbn_attribute6                 =>  p_pbn_attribute6
      ,p_pbn_attribute7                 =>  p_pbn_attribute7
      ,p_pbn_attribute8                 =>  p_pbn_attribute8
      ,p_pbn_attribute9                 =>  p_pbn_attribute9
      ,p_pbn_attribute10                =>  p_pbn_attribute10
      ,p_pbn_attribute11                =>  p_pbn_attribute11
      ,p_pbn_attribute12                =>  p_pbn_attribute12
      ,p_pbn_attribute13                =>  p_pbn_attribute13
      ,p_pbn_attribute14                =>  p_pbn_attribute14
      ,p_pbn_attribute15                =>  p_pbn_attribute15
      ,p_pbn_attribute16                =>  p_pbn_attribute16
      ,p_pbn_attribute17                =>  p_pbn_attribute17
      ,p_pbn_attribute18                =>  p_pbn_attribute18
      ,p_pbn_attribute19                =>  p_pbn_attribute19
      ,p_pbn_attribute20                =>  p_pbn_attribute20
      ,p_pbn_attribute21                =>  p_pbn_attribute21
      ,p_pbn_attribute22                =>  p_pbn_attribute22
      ,p_pbn_attribute23                =>  p_pbn_attribute23
      ,p_pbn_attribute24                =>  p_pbn_attribute24
      ,p_pbn_attribute25                =>  p_pbn_attribute25
      ,p_pbn_attribute26                =>  p_pbn_attribute26
      ,p_pbn_attribute27                =>  p_pbn_attribute27
      ,p_pbn_attribute28                =>  p_pbn_attribute28
      ,p_pbn_attribute29                =>  p_pbn_attribute29
      ,p_pbn_attribute30                =>  p_pbn_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PLAN_BENEFICIARY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PLAN_BENEFICIARY
    --
  end;
  --
  ben_pbn_upd.upd
    (
     p_pl_bnf_id                     => p_pl_bnf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_bnf_person_id                 => p_bnf_person_id
    ,p_organization_id               => p_organization_id
    ,p_ttee_person_id                => p_ttee_person_id
    ,p_prmry_cntngnt_cd              => p_prmry_cntngnt_cd
    ,p_pct_dsgd_num                  => p_pct_dsgd_num
    ,p_amt_dsgd_val                  => p_amt_dsgd_val
    ,p_amt_dsgd_uom                  => p_amt_dsgd_uom
    ,p_dsgn_strt_dt                  => p_dsgn_strt_dt
    ,p_dsgn_thru_dt                  => p_dsgn_thru_dt
    ,p_addl_instrn_txt               => p_addl_instrn_txt
    ,p_pbn_attribute_category        => p_pbn_attribute_category
    ,p_pbn_attribute1                => p_pbn_attribute1
    ,p_pbn_attribute2                => p_pbn_attribute2
    ,p_pbn_attribute3                => p_pbn_attribute3
    ,p_pbn_attribute4                => p_pbn_attribute4
    ,p_pbn_attribute5                => p_pbn_attribute5
    ,p_pbn_attribute6                => p_pbn_attribute6
    ,p_pbn_attribute7                => p_pbn_attribute7
    ,p_pbn_attribute8                => p_pbn_attribute8
    ,p_pbn_attribute9                => p_pbn_attribute9
    ,p_pbn_attribute10               => p_pbn_attribute10
    ,p_pbn_attribute11               => p_pbn_attribute11
    ,p_pbn_attribute12               => p_pbn_attribute12
    ,p_pbn_attribute13               => p_pbn_attribute13
    ,p_pbn_attribute14               => p_pbn_attribute14
    ,p_pbn_attribute15               => p_pbn_attribute15
    ,p_pbn_attribute16               => p_pbn_attribute16
    ,p_pbn_attribute17               => p_pbn_attribute17
    ,p_pbn_attribute18               => p_pbn_attribute18
    ,p_pbn_attribute19               => p_pbn_attribute19
    ,p_pbn_attribute20               => p_pbn_attribute20
    ,p_pbn_attribute21               => p_pbn_attribute21
    ,p_pbn_attribute22               => p_pbn_attribute22
    ,p_pbn_attribute23               => p_pbn_attribute23
    ,p_pbn_attribute24               => p_pbn_attribute24
    ,p_pbn_attribute25               => p_pbn_attribute25
    ,p_pbn_attribute26               => p_pbn_attribute26
    ,p_pbn_attribute27               => p_pbn_attribute27
    ,p_pbn_attribute28               => p_pbn_attribute28
    ,p_pbn_attribute29               => p_pbn_attribute29
    ,p_pbn_attribute30               => p_pbn_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  --bug#3976575 - remove action item for spousal certification if any when contingent
  if p_prmry_cntngnt_cd = 'CNTNGNT' then
    --
    l_actn_typ_id := ben_enrollment_action_items.get_actn_typ_id
                        (p_type_cd           => 'BNFSCCTFN'
                        ,p_business_group_id => p_business_group_id);
   --
    ben_enrollment_action_items.get_prtt_enrt_actn_id
        (p_actn_typ_id           => l_actn_typ_id
        ,p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id
        ,p_pl_bnf_id             => p_pl_bnf_id
        ,p_effective_date        => p_effective_date
        ,p_business_group_id     => p_business_group_id
        ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
        ,p_cmpltd_dt             => l_cmpltd_dt
        ,p_object_version_number => l_object_version_number);
   --
   if l_prtt_enrt_actn_id is not null then
     --
     ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
          (p_validate              => p_validate,
           p_effective_date        => p_effective_date,
           p_business_group_id     => p_business_group_id,
           p_datetrack_mode        => hr_api.g_zap,
           p_object_version_number => l_object_version_number,
           p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
           p_rslt_object_version_number => l_rslt_object_version_number,
           p_unsuspend_enrt_flag   => 'N',
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id);
     --
   end if;
   --
 end if;

  -----tilak

  -- If not covered, call delete useage
  --
  if not(p_dsgn_strt_dt is not null and p_dsgn_thru_dt = hr_api.g_eot) then
    --
    --
    if p_datetrack_mode = 'UPDATE' then
      l2_datetrack_mode := 'DELETE';
    else
      l2_datetrack_mode := 'ZAP';
      --
    end if;
    --
    hr_utility.set_location('through ' || p_dsgn_thru_dt ,99);
    hr_utility.set_location('mode  ' || l2_datetrack_mode ,99);
    remove_usage(
       p_validate          => p_validate
      ,p_pl_bnf_id         => p_pl_bnf_id
      ,p_effective_date    => p_effective_date
      ,p_datetrack_mode    => l2_datetrack_mode
      ,p_business_group_id => p_business_group_id
			-- 5668052
			,p_dsgn_thru_dt      => p_dsgn_strt_dt
     );

    --

  end if ;

  --
  --  Call Action item RCO if p_multi_row_actn = TRUE
  --
  if p_multi_row_actn then
    --
    bnf_actn_items(
           p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
          ,p_pl_bnf_id          => p_pl_bnf_id
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
    -- Start of API User Hook for the after hook of update_PLAN_BENEFICIARY
    --
    ben_PLAN_BENEFICIARY_bk2.update_PLAN_BENEFICIARY_a
      (
       p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_bnf_person_id                  =>  p_bnf_person_id
      ,p_organization_id                =>  p_organization_id
      ,p_ttee_person_id                 =>  p_ttee_person_id
      ,p_prmry_cntngnt_cd               =>  p_prmry_cntngnt_cd
      ,p_pct_dsgd_num                   =>  p_pct_dsgd_num
      ,p_amt_dsgd_val                   =>  p_amt_dsgd_val
      ,p_amt_dsgd_uom                   =>  p_amt_dsgd_uom
      ,p_dsgn_strt_dt                   =>  p_dsgn_strt_dt
      ,p_dsgn_thru_dt                   =>  p_dsgn_thru_dt
      ,p_addl_instrn_txt                =>  p_addl_instrn_txt
      ,p_pbn_attribute_category         =>  p_pbn_attribute_category
      ,p_pbn_attribute1                 =>  p_pbn_attribute1
      ,p_pbn_attribute2                 =>  p_pbn_attribute2
      ,p_pbn_attribute3                 =>  p_pbn_attribute3
      ,p_pbn_attribute4                 =>  p_pbn_attribute4
      ,p_pbn_attribute5                 =>  p_pbn_attribute5
      ,p_pbn_attribute6                 =>  p_pbn_attribute6
      ,p_pbn_attribute7                 =>  p_pbn_attribute7
      ,p_pbn_attribute8                 =>  p_pbn_attribute8
      ,p_pbn_attribute9                 =>  p_pbn_attribute9
      ,p_pbn_attribute10                =>  p_pbn_attribute10
      ,p_pbn_attribute11                =>  p_pbn_attribute11
      ,p_pbn_attribute12                =>  p_pbn_attribute12
      ,p_pbn_attribute13                =>  p_pbn_attribute13
      ,p_pbn_attribute14                =>  p_pbn_attribute14
      ,p_pbn_attribute15                =>  p_pbn_attribute15
      ,p_pbn_attribute16                =>  p_pbn_attribute16
      ,p_pbn_attribute17                =>  p_pbn_attribute17
      ,p_pbn_attribute18                =>  p_pbn_attribute18
      ,p_pbn_attribute19                =>  p_pbn_attribute19
      ,p_pbn_attribute20                =>  p_pbn_attribute20
      ,p_pbn_attribute21                =>  p_pbn_attribute21
      ,p_pbn_attribute22                =>  p_pbn_attribute22
      ,p_pbn_attribute23                =>  p_pbn_attribute23
      ,p_pbn_attribute24                =>  p_pbn_attribute24
      ,p_pbn_attribute25                =>  p_pbn_attribute25
      ,p_pbn_attribute26                =>  p_pbn_attribute26
      ,p_pbn_attribute27                =>  p_pbn_attribute27
      ,p_pbn_attribute28                =>  p_pbn_attribute28
      ,p_pbn_attribute29                =>  p_pbn_attribute29
      ,p_pbn_attribute30                =>  p_pbn_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PLAN_BENEFICIARY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PLAN_BENEFICIARY
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
    ROLLBACK TO update_PLAN_BENEFICIARY;
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
    ROLLBACK TO update_PLAN_BENEFICIARY;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_PLAN_BENEFICIARY;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_plan_beneficiary_w >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_plan_beneficiary_w
(
   p_validate                       in  varchar2
  ,p_pl_bnf_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_bnf_person_id                  in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_prmry_cntngnt_cd               in  varchar2
  ,p_pct_dsgd_num                   in  number
  ,p_dsgn_strt_dt                   in  date
  ,p_dsgn_thru_dt                   in  date
  ,p_object_version_number      in  out nocopy number
  ,p_per_in_ler_id                  in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_multi_row_actn                 in  varchar2
)
is

  l_proc varchar2(72) := g_package||'update_plan_beneficiary - wrapper';

  l_effective_start_date       ben_pl_bnf_f.effective_start_date%TYPE;
  l_effective_end_date         ben_pl_bnf_f.effective_end_date%TYPE;
  l_object_version_number      ben_pl_bnf_f.object_version_number%TYPE;

  l_validate       BOOLEAN;
  l_multi_row_actn BOOLEAN;
  --
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if fnd_global.conc_request_id in (0,-1) then
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
  hr_utility.set_location(l_proc, 20);
  --
  --
  if upper(p_validate) = 'TRUE'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;
  --
  if upper(p_multi_row_actn) = 'TRUE'
  then
    l_multi_row_actn := TRUE;
  else
    l_multi_row_actn := FALSE;
  end if;
  --
  l_object_version_number := p_object_version_number;
  --
  update_plan_beneficiary
  (
     p_validate                =>    l_validate
    ,p_pl_bnf_id               =>    p_pl_bnf_id
    ,p_effective_start_date    =>    l_effective_start_date
    ,p_effective_end_date      =>    l_effective_end_date
    ,p_business_group_id       =>    p_business_group_id
    ,p_prtt_enrt_rslt_id       =>    p_prtt_enrt_rslt_id
    ,p_bnf_person_id           =>    p_bnf_person_id
    ,p_organization_id         =>    p_organization_id
    ,p_prmry_cntngnt_cd        =>    p_prmry_cntngnt_cd
    ,p_pct_dsgd_num            =>    p_pct_dsgd_num
    ,p_amt_dsgd_val            =>    null
    ,p_amt_dsgd_uom            =>    null
    ,p_dsgn_strt_dt            =>    p_dsgn_strt_dt
    ,p_dsgn_thru_dt            =>    p_dsgn_thru_dt
    ,p_object_version_number   =>    l_object_version_number
    ,p_per_in_ler_id           =>    p_per_in_ler_id
    ,p_effective_date          =>    p_effective_date
    ,p_datetrack_mode          =>    p_datetrack_mode
    ,p_multi_row_actn          =>    l_multi_row_actn
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Set all output arguments
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    fnd_msg_pub.add;
    --
end update_plan_beneficiary_w;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PLAN_BENEFICIARY >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PLAN_BENEFICIARY
  (p_validate                       in  boolean  default false
  ,p_pl_bnf_id                      in  number
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
  l_proc varchar2(72) := g_package||'DELETE_PLAN_BENEFICIARY';
  l_object_version_number   ben_pl_bnf_f.object_version_number%TYPE;
  l_effective_start_date    ben_pl_bnf_f.effective_start_date%TYPE;
  l_effective_end_date      ben_pl_bnf_f.effective_end_date%TYPE;
  --
  l_pl_bnf_ctfn_prvdd_id    number;
  l2_object_version_number  ben_pl_bnf_ctfn_prvdd_f.object_version_number%TYPE;
  l2_effective_start_date   ben_pl_bnf_ctfn_prvdd_f.effective_start_date%TYPE;
  l2_effective_end_date     ben_pl_bnf_ctfn_prvdd_f.effective_end_date%TYPE;
  --mactec
  l_effective_date          date;
  l_datetrack_mode          varchar2(30);
  --
  cursor c_pl_bnf(p_pl_bnf_id number, p_effective_date date) is
     select effective_start_date
       from ben_pl_bnf_f pnb
      where pnb.pl_bnf_id = p_pl_bnf_id
        and p_effective_date between pnb.effective_start_date
                                 and pnb.effective_end_date ;
  l_pl_bnf  c_pl_bnf%rowtype;
  --
  cursor bnf_ctfn_c is
     select pl_bnf_ctfn_prvdd_id,
            object_version_number,
            effective_end_date
       from ben_pl_bnf_ctfn_prvdd_f
       where pl_bnf_id = p_pl_bnf_id
         and business_group_id = p_business_group_id
         and l_effective_date between effective_start_date
                                  and effective_end_date;
  --
  cursor c_future_row (p_pl_bnf_ctfn_prvdd_id number,
                       p_effective_date date) is
    select null
    from ben_pl_bnf_ctfn_prvdd_f
    where pl_bnf_ctfn_prvdd_id = p_pl_bnf_ctfn_prvdd_id
    and   effective_start_date > p_effective_date;
  --
  cursor bnf_ctfn_id_zap_c is
     select distinct pl_bnf_ctfn_prvdd_id
     from   ben_pl_bnf_ctfn_prvdd_f
     where  pl_bnf_id = p_pl_bnf_id;
  --
  cursor bnf_ctfn_ovn_zap_c(l_pl_bnf_ctfn_prvdd_id in number) is
     select max(object_version_number)
     from   ben_pl_bnf_ctfn_prvdd_f
     where  pl_bnf_ctfn_prvdd_id = l_pl_bnf_ctfn_prvdd_id;
  --
  l_dummy  varchar2(300);
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_effective_date'||p_effective_date,10);
  --mactec
  open c_pl_bnf(p_pl_bnf_id,p_effective_date);
    fetch c_pl_bnf into l_pl_bnf ;
  close c_pl_bnf ;
  --
  if l_pl_bnf.effective_start_date = p_effective_date then
    l_datetrack_mode := hr_api.g_zap ;
    l_effective_date := p_effective_date ;
  elsif p_datetrack_mode = hr_api.g_delete then
    l_effective_date := p_effective_date - 1 ;
    l_datetrack_mode := p_datetrack_mode ;
  else
    l_effective_date := p_effective_date ;
    l_datetrack_mode := p_datetrack_mode ;
  end if;
  --
  hr_utility.set_location('l_effective_date '||l_effective_date,10);
  hr_utility.set_location('l_datetrack_mode '||l_datetrack_mode,10);
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => l_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PLAN_BENEFICIARY;
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
  if p_datetrack_mode = hr_api.g_zap then
     --
     for ctfn_rec in bnf_ctfn_id_zap_c loop
         --
         open  bnf_ctfn_ovn_zap_c(ctfn_rec.pl_bnf_ctfn_prvdd_id);
         fetch bnf_ctfn_ovn_zap_c into l2_object_version_number;
         close bnf_ctfn_ovn_zap_c;
         --
         ben_pl_bnf_ctfn_prvdd_api.delete_pl_bnf_ctfn_prvdd
           (p_validate                 => FALSE
           ,p_pl_bnf_ctfn_prvdd_id     => ctfn_rec.pl_bnf_ctfn_prvdd_id
           ,p_effective_start_date     => l2_effective_start_date
           ,p_effective_end_date       => l2_effective_end_date
           ,p_object_version_number    => l2_object_version_number
           ,p_business_group_id        => p_business_group_id
           ,p_effective_date           => l_effective_date
           ,p_datetrack_mode           => l_datetrack_mode
           );
          --
     end loop;
     --
  else
     --
     for ctfn_rec in bnf_ctfn_c loop
         --
         l2_object_version_number := ctfn_rec.object_version_number;
         --
         --bug#2564387 - if the record is not end dated don't call delete in future-change mode
         --Bug 4064635 we can't delete the cert which is already deleted
         if not (p_datetrack_mode = 'FUTURE_CHANGE' and
                  ctfn_rec.effective_end_date = hr_api.g_eot)  and
                  ctfn_rec.effective_end_date <> l_effective_date   then
           --
            if p_datetrack_mode = 'FUTURE_CHANGE' then
               --if there is no future row change the mode to delete
               open c_future_row (ctfn_rec.pl_bnf_ctfn_prvdd_id, ctfn_rec.effective_end_date);
               fetch c_future_row into l_dummy;
               if c_future_row%notfound then
                 l_datetrack_mode := hr_api.g_delete;
               end if;
               close c_future_row;
               --
            end if;
            --
            ben_pl_bnf_ctfn_prvdd_api.delete_pl_bnf_ctfn_prvdd
              (p_validate                 => FALSE
              ,p_pl_bnf_ctfn_prvdd_id     => ctfn_rec.pl_bnf_ctfn_prvdd_id
              ,p_effective_start_date     => l2_effective_start_date
              ,p_effective_end_date       => l2_effective_end_date
              ,p_object_version_number    => l2_object_version_number
              ,p_business_group_id        => p_business_group_id
              ,p_effective_date           => l_effective_date
              ,p_datetrack_mode           => l_datetrack_mode
              );
             --
         end if;
      end loop;
      --
  end if;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_PLAN_BENEFICIARY
    --
    ben_PLAN_BENEFICIARY_bk3.delete_PLAN_BENEFICIARY_b
      (
       p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                      => trunc(l_effective_date)
      ,p_datetrack_mode                      => l_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PLAN_BENEFICIARY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PLAN_BENEFICIARY
    --
  end;
  --
  --
  /* BUG 4086994. This call should be made after deleting the plan Benificiary
     otherwise process will recreate the action items which got deleted above.
  --  Call Action item RCO if p_multi_row_actn = TRUE
  --
  if p_multi_row_actn then
    --
    bnf_actn_items(
           p_prtt_enrt_rslt_id  => null
          ,p_pl_bnf_id          => p_pl_bnf_id
          ,p_effective_date     => l_effective_date
          ,p_business_group_id  => null
          ,p_validate           => p_validate
          ,p_datetrack_mode     => l_datetrack_mode
          ,p_delete_flag        => 'Y'
          );
    --
  end if;
  --
  */
  -- remove usage
  --
  -- in future-change mode and delete_next_change mode the beneficiary will still be
  -- continuing - no need to remove the usage
  if p_datetrack_mode not in ('FUTURE_CHANGE','DELETE_NEXT_CHANGE') then
   --
    remove_usage(
     p_validate          => p_validate
    ,p_pl_bnf_id         => p_pl_bnf_id
    ,p_effective_date    => l_effective_date
    ,p_datetrack_mode    => l_datetrack_mode
    ,p_business_group_id => p_business_group_id
		-- 5668052
		,p_dsgn_thru_dt      => NULL
    );
  --
  end if;
  --
  ben_pbn_del.del
    (
     p_pl_bnf_id                     => p_pl_bnf_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => l_effective_date
    ,p_datetrack_mode                => l_datetrack_mode
    );
  -- 4879576 : moved the code to delete_PLAN_BENEFICIARY_w
  -- BUG 4086994
  --
 /* if p_multi_row_actn then
    --
    bnf_actn_items(
           p_prtt_enrt_rslt_id  => null
          ,p_pl_bnf_id          => p_pl_bnf_id
          ,p_effective_date     => l_effective_date
          ,p_business_group_id  => null
          ,p_validate           => p_validate
          ,p_datetrack_mode     => l_datetrack_mode
          ,p_delete_flag        => 'Y'
          );
    --
  end if; */
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PLAN_BENEFICIARY
    --
    ben_PLAN_BENEFICIARY_bk3.delete_PLAN_BENEFICIARY_a
      (
       p_pl_bnf_id                      =>  p_pl_bnf_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(l_effective_date)
    ,p_datetrack_mode                      => l_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PLAN_BENEFICIARY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PLAN_BENEFICIARY
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
    ROLLBACK TO delete_PLAN_BENEFICIARY;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_PLAN_BENEFICIARY;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_PLAN_BENEFICIARY;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_plan_beneficiary_w >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_plan_beneficiary_w
(
   p_validate                       in  varchar2
  ,p_pl_bnf_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number      in  out nocopy number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_prtt_enrt_rslt_id              in number
  ,p_multi_row_actn                 in  varchar2
  )
is

  l_proc varchar2(72) := g_package||'delete_plan_beneficiary - wrapper';

  l_effective_start_date       ben_pl_bnf_f.effective_start_date%TYPE;
  l_effective_end_date         ben_pl_bnf_f.effective_end_date%TYPE;
  l_object_version_number      ben_pl_bnf_f.object_version_number%TYPE;

  l_validate       BOOLEAN;
  l_multi_row_actn BOOLEAN;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if fnd_global.conc_request_id in (0,-1) then
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
  hr_utility.set_location(l_proc, 20);
  --
  --
  if upper(p_validate) = 'TRUE'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;
  --
  --4879576 : uncommented following code
  if upper(p_multi_row_actn) = 'TRUE'
  then
    l_multi_row_actn := TRUE;
  else
    l_multi_row_actn := FALSE;
  end if;


  --BUG 4086994
  --This is always FALSE from PUI
  --We don't need multi row action for DELETE
--  l_multi_row_actn := FALSE; -- 4879576 : commented
  --
  l_object_version_number := p_object_version_number;
  --
  delete_plan_beneficiary
  (
     p_validate                =>    l_validate
    ,p_pl_bnf_id               =>    p_pl_bnf_id
    ,p_effective_start_date    =>    l_effective_start_date
    ,p_effective_end_date      =>    l_effective_end_date
    ,p_business_group_id       =>    p_business_group_id
    ,p_object_version_number   =>    l_object_version_number
    ,p_effective_date          =>    p_effective_date
    ,p_datetrack_mode          =>    p_datetrack_mode
    ,p_multi_row_actn          =>    l_multi_row_actn
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  -- -- 4879576 : moved the bnf_actn_items from delete_plan_beneficiary
  -- and passed correct values to the params.
  if l_multi_row_actn then

    bnf_actn_items(
           p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
          ,p_pl_bnf_id          => null
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_validate           => l_validate
          ,p_datetrack_mode     => p_datetrack_mode
          ,p_delete_flag        => 'N'
          );

    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    fnd_msg_pub.add;
    --
end delete_plan_beneficiary_w;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_bnf_id                   in     number
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
  ben_pbn_shd.lck
    (
      p_pl_bnf_id                 => p_pl_bnf_id
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
-- |-------------------------------< bnf_actn_items >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure bnf_actn_items
  (
   p_prtt_enrt_rslt_id              in     number
  ,p_pl_bnf_id                      in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_validate                       in     boolean default FALSE
  ,p_datetrack_mode                 in     varchar2
  ,p_delete_flag                    in     varchar2 default 'N'
  ) is
--
l_proc varchar2(72) := g_package||'bnf_actn_items';
l_prtt_enrt_rslt_id   number(15);
l_business_group_id   number(15);
l_suspend_flag        varchar2(30);
l_rslt_object_version_number number(9);
l_bnf_actn_warning    boolean;
l_bnft_amt            number;
l_prmry_dsgd_pct          number := 0;
l_prmry_dsgd_amt          number := 0;
l_cntngnt_dsgd_pct        number := 0;
l_cntngnt_dsgd_amt        number := 0;
l_total_prmry_pct         number;
l_total_prmry_amt         number;
l_total_cntngnt_pct       number;
l_total_cntngnt_amt       number;
--
cursor get_rslt_id_c is
   select prtt_enrt_rslt_id,
          business_group_id,
          decode(prmry_cntngnt_cd, 'PRIMY',pct_dsgd_num,0)   prmry_dsgd_pct,
          decode(prmry_cntngnt_cd, 'CNTNGNT',pct_dsgd_num,0) cntngnt_dsgd_pct,
          decode(prmry_cntngnt_cd, 'PRIMY',amt_dsgd_val,0)   prmry_dsgd_amt,
          decode(prmry_cntngnt_cd, 'CNTNGNT',amt_dsgd_val,0) cntngnt_dsgd_amt
    from ben_pl_bnf_f
    where pl_bnf_id = p_pl_bnf_id
      and p_effective_date between effective_start_date
                               and effective_end_date;
--
cursor get_rslt_ovn_c is
   select object_version_number,
          sspndd_flag,
          bnft_amt
   from   ben_prtt_enrt_rslt_f
   where  prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
   and    business_group_id = l_business_group_id
   and    prtt_enrt_rslt_stat_cd is null
   and    p_effective_date
          between effective_start_date and effective_end_date;
  --
  cursor c_sum_bnf is
  select pbn.prmry_cntngnt_cd prmry_cntngnt_cd,
         sum(pbn.pct_dsgd_num) prcnt,
         sum(pbn.amt_dsgd_val) amount
    from ben_pl_bnf_f pbn,
         ben_per_in_ler pil
   where pbn.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
     and pbn.business_group_id = l_business_group_id
     -- and p_effective_date between pbn.effective_start_date and pbn.effective_end_date
     and p_effective_date >= pbn.effective_start_date
     and p_effective_date <   pbn.effective_end_date
     and pil.per_in_ler_id=pbn.per_in_ler_id
     and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
   group by pbn.prmry_cntngnt_cd;
  --
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   if p_prtt_enrt_rslt_id is null or
      p_business_group_id is null or
      p_delete_flag  = 'Y' then
      --
      open get_rslt_id_c;
      fetch get_rslt_id_c into l_prtt_enrt_rslt_id,
                               l_business_group_id,
                               l_prmry_dsgd_pct,
                               l_cntngnt_dsgd_pct,
                               l_prmry_dsgd_amt,
                               l_cntngnt_dsgd_amt;
      close get_rslt_id_c;
      --
      if p_delete_flag = 'N' then
        l_prmry_dsgd_pct   := 0;
        l_cntngnt_dsgd_pct := 0;
        l_prmry_dsgd_amt   := 0;
        l_cntngnt_dsgd_amt := 0;
      end if;
      --
   else
      l_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
      l_business_group_id := p_business_group_id;
   end if;
   --
   open get_rslt_ovn_c;
   fetch get_rslt_ovn_c into l_rslt_object_version_number,
                             l_suspend_flag,
                             l_bnft_amt;
   close get_rslt_ovn_c;
   --
   for l_sum_bnf in c_sum_bnf loop
     --
     if l_sum_bnf.prmry_cntngnt_cd = 'PRIMY' then
       --
       l_total_prmry_pct := l_sum_bnf.prcnt - l_prmry_dsgd_pct;
       l_total_prmry_amt := l_sum_bnf.amount - l_prmry_dsgd_amt;
       --
     elsif l_sum_bnf.prmry_cntngnt_cd = 'CNTNGNT' then
       --
       l_total_cntngnt_pct := l_sum_bnf.prcnt - l_cntngnt_dsgd_pct;
       l_total_cntngnt_amt := l_sum_bnf.amount  - l_cntngnt_dsgd_amt;
       --
     end if;
     --
   end loop;
   --
   if l_total_prmry_pct > 100 or l_total_cntngnt_pct > 100 then
     --
     fnd_message.set_name('BEN', 'BEN_91644_BNF_TTL_PCT_EXCEEDED');
     fnd_message.raise_error;
     --
   end if;
   --  start - bug 2317471
   if (l_total_prmry_pct < 100 and nvl(l_total_prmry_pct,0) > 0  ) or
   ( l_total_cntngnt_pct < 100 and nvl(l_total_cntngnt_pct,0) > 0)
   then
     --
     fnd_message.set_name('BEN', 'BEN_93122_PCT_LESS_HUND');
     fnd_message.raise_error;
     --
   end if;
   -- end - bug 2317471
   if l_total_prmry_amt > l_bnft_amt or l_total_cntngnt_amt > l_bnft_amt then
     --
     fnd_message.set_name('BEN', 'BEN_91645_BNF_TTL_AMT_EXCEEDED');
     fnd_message.raise_error;
     --
   end if;
   --
   -- Contingent beneficiary cannot be defined without defining a primary
   -- beneficiary. (Bug 1368196)
   --
   if ( (l_total_cntngnt_pct > 0 and nvl(l_total_prmry_pct, 0) = 0)
      OR
        (l_total_cntngnt_amt > 0 and nvl(l_total_prmry_amt, 0) = 0)) then
     --
     fnd_message.set_name('BEN', 'BEN_92565_CNTGNT_NO_PRIMY');
     fnd_message.raise_error;
     --
   end if;
   --
   ben_enrollment_action_items.process_bnf_actn_items(
                    p_prtt_enrt_rslt_id          => l_prtt_enrt_rslt_id
                   ,p_rslt_object_version_number => l_rslt_object_version_number
                   ,p_effective_date             => trunc(p_effective_date)
                   ,p_business_group_id          => l_business_group_id
                   ,p_validate                   => FALSE
                   ,p_datetrack_mode             => p_datetrack_mode
                   ,p_suspend_flag               => l_suspend_flag
                   ,p_bnf_actn_warning           => l_bnf_actn_warning
                   );
   --
   hr_utility.set_location('Exiting:'|| l_proc, 40);
end bnf_actn_items;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< add_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_usage
  (
   p_validate                       in     boolean  default false
  ,p_pl_bnf_id                      in     number
  ,p_bnf_person_id                  in     number
  ,p_prtt_enrt_rslt_id              in     number
  ,p_business_group_id              in     number
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
  l_effective_start_date      per_person_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date        per_person_type_usages_f.effective_end_date%TYPE;
  --
  l1_person_type_usage_id      number(15);
  l1_effective_start_date      per_person_type_usages_f.effective_start_date%TYPE;
  l1_effective_end_date        per_person_type_usages_f.effective_end_date%TYPE;
  --
  l_object_version_number     per_person_type_usages_f.object_version_number%TYPE;
  l_enrt_cvg_strt_dt          date;
  l_dsg_strt_dt               date;
  --
  --
  cursor get_bnf_type_id_c is
    select person_type_id
      from per_person_types
      where system_person_type = 'BNF'
        and business_group_id = p_business_group_id;
  --
  cursor get_enrt_cvg_strt_dt_c is
    select enrt_cvg_strt_dt
      from ben_prtt_enrt_rslt_f   a
      where a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and a.business_group_id = p_business_group_id
        and a.prtt_enrt_rslt_stat_cd is null
        and p_effective_date between nvl(a.effective_start_date, p_effective_date)
                                 and nvl(a.effective_end_date, p_effective_date);
  --
  -- find overlapping ptu segments
  --
  cursor find_ptu_ovlp_segments_c is
    select a.effective_start_date,
           a.effective_end_date,
           a.person_type_usage_id
    from per_person_type_usages_f    a
    where a.person_id = p_bnf_person_id
      and a.person_type_id = l_person_type_id
     -- and a.effective_start_date <= hr_api.g_date
      and a.effective_end_date >= l_dsg_strt_dt
     ;
  --
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_enrt_cvg_strt_dt := null;
  l_dsg_strt_dt      := p_effective_date;
  --
  --  Create person type usage, if needed
  --
                                        --  Is this a person?
  if p_bnf_person_id is not null then
  --
                                       -- get type id
    --
    hr_utility.set_location('This is a person:'|| l_proc, 15);
    -- dbms_output.put_line('This is a person '||to_char(p_bnf_person_id));
    --
    open get_bnf_type_id_c;
    fetch get_bnf_type_id_c into l_person_type_id;
    if get_bnf_type_id_c%FOUND then
    --
      hr_utility.set_location('Got BNF type ID:'|| l_proc, 20);
      -- get cvg start dt
      open get_enrt_cvg_strt_dt_c;
      fetch get_enrt_cvg_strt_dt_c into l_enrt_cvg_strt_dt;
      close get_enrt_cvg_strt_dt_c;
      --
      if l_enrt_cvg_strt_dt is not null then
                                                     -- this logic will be changed when
                                                     -- dsg_strt_dt column is added to BNF
        if p_effective_date < l_enrt_cvg_strt_dt then
           l_dsg_strt_dt := l_enrt_cvg_strt_dt;
        end if;
        --
        hr_utility.set_location('Got start date:'|| l_proc, 25);
        -- dbms_output.put_line('Strt date is ' || to_char(l_dsg_strt_dt));
        --
        -- does BNF usage exist as of dsg strt date?
        --
        open find_ptu_ovlp_segments_c;
        fetch find_ptu_ovlp_segments_c into l_effective_start_date,
                                            l_effective_end_date,
                                            l_person_type_usage_id;
        if find_ptu_ovlp_segments_c%NOTFOUND then
          --
          hr_utility.set_location('No overlapping segments:'|| l_proc, 30);
          -- dbms_output.put_line('No overlapping segments');
          -- call create person_type usage api
          --
          hr_per_type_usage_internal.create_person_type_usage
               (p_validate               => FALSE
               ,p_person_id              => p_bnf_person_id
               ,p_person_type_id         => l_person_type_id
               ,p_effective_date         => l_dsg_strt_dt
               ,p_person_type_usage_id   => l1_person_type_usage_id
               ,p_object_version_number  => l_object_version_number
               ,p_effective_start_date   => l1_effective_start_date
               ,p_effective_end_date     => l1_effective_end_date
               );
          --
        else
            if l_effective_start_date <= l_dsg_strt_dt and
               l_effective_end_date >= hr_api.g_date
            then
               null;
            elsif l_effective_start_date <= l_dsg_strt_dt and
                  l_effective_end_date < hr_api.g_date
              then
               update per_person_type_usages_f
                   set effective_end_date = hr_api.g_date
                   where person_type_usage_id = l_person_type_usage_id;
            elsif l_effective_start_date > l_dsg_strt_dt and
                  l_effective_end_date = hr_api.g_date then
              --
              update per_person_type_usages_f
                   set effective_start_date = l_dsg_strt_dt
                where person_type_usage_id = l_person_type_usage_id;
              --
            elsif l_effective_start_date > l_dsg_strt_dt and
                  l_effective_end_date < hr_api.g_date  then
              --
              update per_person_type_usages_f
                   set effective_start_date = l_dsg_strt_dt,
                       effective_end_date   = hr_api.g_date
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
    end if;
  --
  close get_bnf_type_id_c;
  --
 end if;
 --
hr_utility.set_location(' Leaving:'||l_proc, 70);
--
end add_usage;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< remove_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure remove_usage
  (
   p_validate                       in     boolean  default false
  ,p_pl_bnf_id                      in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_business_group_id              in     number
	-- bug 5668052
	,p_dsgn_thru_dt                   in     date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'remove_usage';
  l_effective_start_date            date;
  l_effective_end_date              date;
  l_object_version_number           number(9);
  l_bnf_person_id                   number(15);
  l_business_group_id               number(15);
  l_exist                           varchar2(1);
  l_person_type_usage_id            number(15);
--
  cursor bnf_person_c is
    select b.bnf_person_id,
           b.business_group_id
      from ben_pl_bnf_f  b
     where b.pl_bnf_id = p_pl_bnf_id
       and business_group_id = p_business_group_id
       and p_effective_date between b.effective_start_date
                                and b.effective_end_date;
  --
  cursor other_bnf_c is
     select null
       from ben_pl_bnf_f a
      where a.bnf_person_id = l_bnf_person_id
        and a.business_group_id = p_business_group_id
        and a.pl_bnf_id <> p_pl_bnf_id
        -- and p_effective_date between a.effective_start_date
        --                            and a.effective_end_date;
	      -- bug 5668052
				and p_effective_date < a.effective_end_date;
  --
  cursor usage_c is
    select a.person_type_usage_id,
           a.object_version_number,
           a.effective_end_date
					 -- bug 5668052
					 ,a.effective_start_date
      from per_person_type_usages_f a,
           per_person_types         b
     where a.person_id = l_bnf_person_id
       and a.person_type_id = b.person_type_id
       and b.system_person_type = 'BNF'
       and b.business_group_id = l_business_group_id
       and p_effective_date between a.effective_start_date
                                     and a.effective_end_date;
--
   -- bug 5668052
   CURSOR bnf_rec_exists (v_bnf_person_id IN NUMBER)
   IS
      SELECT pl_bnf_id
        FROM ben_pl_bnf_f pbn
       WHERE pbn.bnf_person_id = v_bnf_person_id
			   AND pbn.pl_bnf_id <> p_pl_bnf_id
         AND pbn.business_group_id = p_business_group_id;

   l_dummy                   NUMBER;
	 l_datetrack_mode          varchar(30);
	 l_usg_effective_start_date      date;
--
begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
  hr_utility.set_location('mode '||p_datetrack_mode  , 5);
	l_datetrack_mode := p_datetrack_mode;
  open bnf_person_c;
  fetch bnf_person_c into l_bnf_person_id,
                          l_business_group_id;
  close bnf_person_c;
  if l_bnf_person_id is not null then
		 open other_bnf_c;
     fetch other_bnf_c into l_exist;
     --
     if other_bnf_c%NOTFOUND then
     --
       open usage_c;
       fetch usage_c into l_person_type_usage_id,
                          l_object_version_number,
                          l_effective_end_date,
													l_usg_effective_start_date;
       --
       if usage_c%FOUND then
        --
				-- bug 5668052
				if p_dsgn_thru_dt is not null
				 then
				   if l_datetrack_mode = hr_api.g_delete
					    and p_dsgn_thru_dt < l_usg_effective_start_date
					    then
						   l_datetrack_mode := 'ZAP';
           end if;
				end if;
        -- if p_datetrack_mode = 'DELETE' AND l_effective_end_date = hr_api.g_eot
				if l_datetrack_mode = 'DELETE' AND l_effective_end_date = hr_api.g_eot
                               then


					hr_per_type_usage_internal.delete_person_type_usage
          (p_validate               =>  FALSE
          ,p_person_type_usage_id   =>  l_person_type_usage_id
          ,p_effective_date         =>  p_effective_date
          -- ,p_datetrack_mode         =>  p_datetrack_mode
					,p_datetrack_mode         =>  l_datetrack_mode
          ,p_object_version_number  =>  l_object_version_number
          ,p_effective_start_date   =>  l_effective_start_date
          ,p_effective_end_date     =>  l_effective_end_date
          );
        --
				-- start bug 5668052
 		    elsif l_datetrack_mode = hr_api.g_zap then
						 hr_utility.set_location('Checking deletion in zap mode ',121);
						 open bnf_rec_exists(l_bnf_person_id);
						 fetch bnf_rec_exists into l_dummy;
						 if bnf_rec_exists%notfound then

								hr_utility.set_location('Deleteing in zap mode ',121);
								hr_per_type_usage_internal.delete_person_type_usage
								(p_validate               =>  FALSE
								,p_person_type_usage_id   =>  l_person_type_usage_id
								,p_effective_date         =>  p_effective_date
								-- ,p_datetrack_mode         =>  p_datetrack_mode
								,p_datetrack_mode         =>  l_datetrack_mode
								,p_object_version_number  =>  l_object_version_number
								,p_effective_start_date   =>  l_effective_start_date
								,p_effective_end_date     =>  l_effective_end_date
								);
							else
							  hr_utility.set_location('Cant zap record exists ' || l_dummy,121);
							end if;
							close bnf_rec_exists;
        end if;
       end if;
       --
       close usage_c;
     --
     else
       hr_utility.set_location(' other benefit found ' , 30);
     end if;
     --
     close other_bnf_c;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end remove_usage;
--
--
end ben_PLAN_BENEFICIARY_api;

/
