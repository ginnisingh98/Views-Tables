--------------------------------------------------------
--  DDL for Package Body BEN_PIL_ELCTBL_CHC_POPL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_ELCTBL_CHC_POPL_API" as
/* $Header: bepelapi.pkb 120.0.12000000.2 2007/05/13 23:07:23 rtagarra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Pil_Elctbl_chc_Popl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Pil_Elctbl_chc_Popl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Pil_Elctbl_chc_Popl
  (p_validate                       in  boolean   default false
  ,p_pil_elctbl_chc_popl_id         out nocopy number
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_dflt_asnd_dt                   in  date      default null
  ,p_elcns_made_dt                  in  date      default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_enrt_perd_end_dt               in  date      default null
  ,p_enrt_perd_strt_dt              in  date      default null
  ,p_procg_end_dt                   in  date      default null
  ,p_pil_elctbl_popl_stat_cd        in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_comments                            in  varchar2  default null
  ,p_mgr_ovrid_dt                            in  date  default null
  ,p_ws_mgr_id                            in  number  default null
  ,p_mgr_ovrid_person_id                            in  number  default null
  ,p_assignment_id                            in  number  default null
  --cwb
  ,p_bdgt_acc_cd                    in varchar2         default null
  ,p_pop_cd                         in varchar2         default null
  ,p_bdgt_due_dt                    in date             default null
  ,p_bdgt_export_flag               in varchar2         default 'N'
  ,p_bdgt_iss_dt                    in date             default null
  ,p_bdgt_stat_cd                   in varchar2         default null
  ,p_ws_acc_cd                      in varchar2         default null
  ,p_ws_due_dt                      in date             default null
  ,p_ws_export_flag                 in varchar2         default 'N'
  ,p_ws_iss_dt                      in date             default null
  ,p_ws_stat_cd                     in varchar2         default null
  --cwb
  ,p_reinstate_cd                   in  varchar2  default null
  ,p_reinstate_ovrdn_cd             in  varchar2  default null
  ,p_auto_asnd_dt                   in  date      default null
  ,p_cbr_elig_perd_strt_dt          in  date      default null
  ,p_cbr_elig_perd_end_dt           in  date      default null
  ,p_lee_rsn_id                     in  number    default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pel_attribute_category         in  varchar2  default null
  ,p_pel_attribute1                 in  varchar2  default null
  ,p_pel_attribute2                 in  varchar2  default null
  ,p_pel_attribute3                 in  varchar2  default null
  ,p_pel_attribute4                 in  varchar2  default null
  ,p_pel_attribute5                 in  varchar2  default null
  ,p_pel_attribute6                 in  varchar2  default null
  ,p_pel_attribute7                 in  varchar2  default null
  ,p_pel_attribute8                 in  varchar2  default null
  ,p_pel_attribute9                 in  varchar2  default null
  ,p_pel_attribute10                in  varchar2  default null
  ,p_pel_attribute11                in  varchar2  default null
  ,p_pel_attribute12                in  varchar2  default null
  ,p_pel_attribute13                in  varchar2  default null
  ,p_pel_attribute14                in  varchar2  default null
  ,p_pel_attribute15                in  varchar2  default null
  ,p_pel_attribute16                in  varchar2  default null
  ,p_pel_attribute17                in  varchar2  default null
  ,p_pel_attribute18                in  varchar2  default null
  ,p_pel_attribute19                in  varchar2  default null
  ,p_pel_attribute20                in  varchar2  default null
  ,p_pel_attribute21                in  varchar2  default null
  ,p_pel_attribute22                in  varchar2  default null
  ,p_pel_attribute23                in  varchar2  default null
  ,p_pel_attribute24                in  varchar2  default null
  ,p_pel_attribute25                in  varchar2  default null
  ,p_pel_attribute26                in  varchar2  default null
  ,p_pel_attribute27                in  varchar2  default null
  ,p_pel_attribute28                in  varchar2  default null
  ,p_pel_attribute29                in  varchar2  default null
  ,p_pel_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_defer_deenrol_flag             in varchar2   default 'N'
  ,p_deenrol_made_dt                in date       default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pil_elctbl_chc_popl_id ben_pil_elctbl_chc_popl.pil_elctbl_chc_popl_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Pil_Elctbl_chc_Popl';
  l_object_version_number ben_pil_elctbl_chc_popl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Pil_Elctbl_chc_Popl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Pil_Elctbl_chc_Popl
    --
    ben_Pil_Elctbl_chc_Popl_bk1.create_Pil_Elctbl_chc_Popl_b
      (
       p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_dflt_asnd_dt                   =>  p_dflt_asnd_dt
      ,p_elcns_made_dt                  =>  p_elcns_made_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_pil_elctbl_popl_stat_cd        =>  p_pil_elctbl_popl_stat_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_comments                            =>  p_comments
      ,p_mgr_ovrid_dt                            =>  p_mgr_ovrid_dt
      ,p_ws_mgr_id                            =>  p_ws_mgr_id
      ,p_mgr_ovrid_person_id                            =>  p_mgr_ovrid_person_id
      ,p_assignment_id                            =>  p_assignment_id
      --cwb
      ,p_bdgt_acc_cd                    =>  p_bdgt_acc_cd
      ,p_pop_cd                         =>  p_pop_cd
      ,p_bdgt_due_dt                    =>  p_bdgt_due_dt
      ,p_bdgt_export_flag               =>  p_bdgt_export_flag
      ,p_bdgt_iss_dt                    =>  p_bdgt_iss_dt
      ,p_bdgt_stat_cd                   =>  p_bdgt_stat_cd
      ,p_ws_acc_cd                      =>  p_ws_acc_cd
      ,p_ws_due_dt                      =>  p_ws_due_dt
      ,p_ws_export_flag                 =>  p_ws_export_flag
      ,p_ws_iss_dt                      =>  p_ws_iss_dt
      ,p_ws_stat_cd                     =>  p_ws_stat_cd
      --cwb
      ,p_reinstate_cd                   =>  p_reinstate_cd
      ,p_reinstate_ovrdn_cd             =>  p_reinstate_ovrdn_cd
      ,p_auto_asnd_dt                   =>  p_auto_asnd_dt
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pel_attribute_category         =>  p_pel_attribute_category
      ,p_pel_attribute1                 =>  p_pel_attribute1
      ,p_pel_attribute2                 =>  p_pel_attribute2
      ,p_pel_attribute3                 =>  p_pel_attribute3
      ,p_pel_attribute4                 =>  p_pel_attribute4
      ,p_pel_attribute5                 =>  p_pel_attribute5
      ,p_pel_attribute6                 =>  p_pel_attribute6
      ,p_pel_attribute7                 =>  p_pel_attribute7
      ,p_pel_attribute8                 =>  p_pel_attribute8
      ,p_pel_attribute9                 =>  p_pel_attribute9
      ,p_pel_attribute10                =>  p_pel_attribute10
      ,p_pel_attribute11                =>  p_pel_attribute11
      ,p_pel_attribute12                =>  p_pel_attribute12
      ,p_pel_attribute13                =>  p_pel_attribute13
      ,p_pel_attribute14                =>  p_pel_attribute14
      ,p_pel_attribute15                =>  p_pel_attribute15
      ,p_pel_attribute16                =>  p_pel_attribute16
      ,p_pel_attribute17                =>  p_pel_attribute17
      ,p_pel_attribute18                =>  p_pel_attribute18
      ,p_pel_attribute19                =>  p_pel_attribute19
      ,p_pel_attribute20                =>  p_pel_attribute20
      ,p_pel_attribute21                =>  p_pel_attribute21
      ,p_pel_attribute22                =>  p_pel_attribute22
      ,p_pel_attribute23                =>  p_pel_attribute23
      ,p_pel_attribute24                =>  p_pel_attribute24
      ,p_pel_attribute25                =>  p_pel_attribute25
      ,p_pel_attribute26                =>  p_pel_attribute26
      ,p_pel_attribute27                =>  p_pel_attribute27
      ,p_pel_attribute28                =>  p_pel_attribute28
      ,p_pel_attribute29                =>  p_pel_attribute29
      ,p_pel_attribute30                =>  p_pel_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_defer_deenrol_flag             =>  p_defer_deenrol_flag
      ,p_deenrol_made_dt                =>  p_deenrol_made_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Pil_Elctbl_chc_Popl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Pil_Elctbl_chc_Popl
    --
  end;
  --
  ben_pel_ins.ins
    (
     p_pil_elctbl_chc_popl_id        => l_pil_elctbl_chc_popl_id
    ,p_dflt_enrt_dt                  => p_dflt_enrt_dt
    ,p_dflt_asnd_dt                  => p_dflt_asnd_dt
    ,p_elcns_made_dt                 => p_elcns_made_dt
    ,p_cls_enrt_dt_to_use_cd         => p_cls_enrt_dt_to_use_cd
    ,p_enrt_typ_cycl_cd              => p_enrt_typ_cycl_cd
    ,p_enrt_perd_end_dt              => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt             => p_enrt_perd_strt_dt
    ,p_procg_end_dt                  => p_procg_end_dt
    ,p_pil_elctbl_popl_stat_cd       => p_pil_elctbl_popl_stat_cd
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_uom                           => p_uom
    ,p_comments                           => p_comments
    ,p_mgr_ovrid_dt                           => p_mgr_ovrid_dt
    ,p_ws_mgr_id                           => p_ws_mgr_id
    ,p_mgr_ovrid_person_id                           => p_mgr_ovrid_person_id
    ,p_assignment_id                           => p_assignment_id
    --cwb
    ,p_bdgt_acc_cd                    =>  p_bdgt_acc_cd
    ,p_pop_cd                         =>  p_pop_cd
    ,p_bdgt_due_dt                    =>  p_bdgt_due_dt
    ,p_bdgt_export_flag               =>  p_bdgt_export_flag
    ,p_bdgt_iss_dt                    =>  p_bdgt_iss_dt
    ,p_bdgt_stat_cd                   =>  p_bdgt_stat_cd
    ,p_ws_acc_cd                      =>  p_ws_acc_cd
    ,p_ws_due_dt                      =>  p_ws_due_dt
    ,p_ws_export_flag                 =>  p_ws_export_flag
    ,p_ws_iss_dt                      =>  p_ws_iss_dt
    ,p_ws_stat_cd                     =>  p_ws_stat_cd
    --cwb
    ,p_reinstate_cd                   =>  p_reinstate_cd
    ,p_reinstate_ovrdn_cd             =>  p_reinstate_ovrdn_cd
    ,p_auto_asnd_dt                  => p_auto_asnd_dt
    ,p_cbr_elig_perd_strt_dt         => p_cbr_elig_perd_strt_dt
    ,p_cbr_elig_perd_end_dt          => p_cbr_elig_perd_end_dt
    ,p_lee_rsn_id                    => p_lee_rsn_id
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pel_attribute_category        => p_pel_attribute_category
    ,p_pel_attribute1                => p_pel_attribute1
    ,p_pel_attribute2                => p_pel_attribute2
    ,p_pel_attribute3                => p_pel_attribute3
    ,p_pel_attribute4                => p_pel_attribute4
    ,p_pel_attribute5                => p_pel_attribute5
    ,p_pel_attribute6                => p_pel_attribute6
    ,p_pel_attribute7                => p_pel_attribute7
    ,p_pel_attribute8                => p_pel_attribute8
    ,p_pel_attribute9                => p_pel_attribute9
    ,p_pel_attribute10               => p_pel_attribute10
    ,p_pel_attribute11               => p_pel_attribute11
    ,p_pel_attribute12               => p_pel_attribute12
    ,p_pel_attribute13               => p_pel_attribute13
    ,p_pel_attribute14               => p_pel_attribute14
    ,p_pel_attribute15               => p_pel_attribute15
    ,p_pel_attribute16               => p_pel_attribute16
    ,p_pel_attribute17               => p_pel_attribute17
    ,p_pel_attribute18               => p_pel_attribute18
    ,p_pel_attribute19               => p_pel_attribute19
    ,p_pel_attribute20               => p_pel_attribute20
    ,p_pel_attribute21               => p_pel_attribute21
    ,p_pel_attribute22               => p_pel_attribute22
    ,p_pel_attribute23               => p_pel_attribute23
    ,p_pel_attribute24               => p_pel_attribute24
    ,p_pel_attribute25               => p_pel_attribute25
    ,p_pel_attribute26               => p_pel_attribute26
    ,p_pel_attribute27               => p_pel_attribute27
    ,p_pel_attribute28               => p_pel_attribute28
    ,p_pel_attribute29               => p_pel_attribute29
    ,p_pel_attribute30               => p_pel_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_defer_deenrol_flag            => p_defer_deenrol_flag
    ,p_deenrol_made_dt               => p_deenrol_made_dt
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Pil_Elctbl_chc_Popl
    --
    ben_Pil_Elctbl_chc_Popl_bk1.create_Pil_Elctbl_chc_Popl_a
      (
       p_pil_elctbl_chc_popl_id         =>  l_pil_elctbl_chc_popl_id
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_dflt_asnd_dt                   =>  p_dflt_asnd_dt
      ,p_elcns_made_dt                  =>  p_elcns_made_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_pil_elctbl_popl_stat_cd        =>  p_pil_elctbl_popl_stat_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_comments                            =>  p_comments
      ,p_mgr_ovrid_dt                            =>  p_mgr_ovrid_dt
      ,p_ws_mgr_id                            =>  p_ws_mgr_id
      ,p_mgr_ovrid_person_id                            =>  p_mgr_ovrid_person_id
      ,p_assignment_id                            =>  p_assignment_id
      --cwb
      ,p_bdgt_acc_cd                    =>  p_bdgt_acc_cd
      ,p_pop_cd                         =>  p_pop_cd
      ,p_bdgt_due_dt                    =>  p_bdgt_due_dt
      ,p_bdgt_export_flag               =>  p_bdgt_export_flag
      ,p_bdgt_iss_dt                    =>  p_bdgt_iss_dt
      ,p_bdgt_stat_cd                   =>  p_bdgt_stat_cd
      ,p_ws_acc_cd                      =>  p_ws_acc_cd
      ,p_ws_due_dt                      =>  p_ws_due_dt
      ,p_ws_export_flag                 =>  p_ws_export_flag
      ,p_ws_iss_dt                      =>  p_ws_iss_dt
      ,p_ws_stat_cd                     =>  p_ws_stat_cd
      --cwb
      ,p_reinstate_cd                   =>  p_reinstate_cd
      ,p_reinstate_ovrdn_cd             =>  p_reinstate_ovrdn_cd
      ,p_auto_asnd_dt                   =>  p_auto_asnd_dt
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pel_attribute_category         =>  p_pel_attribute_category
      ,p_pel_attribute1                 =>  p_pel_attribute1
      ,p_pel_attribute2                 =>  p_pel_attribute2
      ,p_pel_attribute3                 =>  p_pel_attribute3
      ,p_pel_attribute4                 =>  p_pel_attribute4
      ,p_pel_attribute5                 =>  p_pel_attribute5
      ,p_pel_attribute6                 =>  p_pel_attribute6
      ,p_pel_attribute7                 =>  p_pel_attribute7
      ,p_pel_attribute8                 =>  p_pel_attribute8
      ,p_pel_attribute9                 =>  p_pel_attribute9
      ,p_pel_attribute10                =>  p_pel_attribute10
      ,p_pel_attribute11                =>  p_pel_attribute11
      ,p_pel_attribute12                =>  p_pel_attribute12
      ,p_pel_attribute13                =>  p_pel_attribute13
      ,p_pel_attribute14                =>  p_pel_attribute14
      ,p_pel_attribute15                =>  p_pel_attribute15
      ,p_pel_attribute16                =>  p_pel_attribute16
      ,p_pel_attribute17                =>  p_pel_attribute17
      ,p_pel_attribute18                =>  p_pel_attribute18
      ,p_pel_attribute19                =>  p_pel_attribute19
      ,p_pel_attribute20                =>  p_pel_attribute20
      ,p_pel_attribute21                =>  p_pel_attribute21
      ,p_pel_attribute22                =>  p_pel_attribute22
      ,p_pel_attribute23                =>  p_pel_attribute23
      ,p_pel_attribute24                =>  p_pel_attribute24
      ,p_pel_attribute25                =>  p_pel_attribute25
      ,p_pel_attribute26                =>  p_pel_attribute26
      ,p_pel_attribute27                =>  p_pel_attribute27
      ,p_pel_attribute28                =>  p_pel_attribute28
      ,p_pel_attribute29                =>  p_pel_attribute29
      ,p_pel_attribute30                =>  p_pel_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_defer_deenrol_flag             => p_defer_deenrol_flag
      ,p_deenrol_made_dt                => p_deenrol_made_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Pil_Elctbl_chc_Popl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Pil_Elctbl_chc_Popl
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
  p_pil_elctbl_chc_popl_id := l_pil_elctbl_chc_popl_id;
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
    ROLLBACK TO create_Pil_Elctbl_chc_Popl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pil_elctbl_chc_popl_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    -- nocopy changes
    ROLLBACK TO create_Pil_Elctbl_chc_Popl;
    p_pil_elctbl_chc_popl_id := null;
    p_object_version_number  := null;

    raise;
    --
end create_Pil_Elctbl_chc_Popl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Pil_Elctbl_chc_Popl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Pil_Elctbl_chc_Popl
  (p_validate                       in  boolean   default false
  ,p_pil_elctbl_chc_popl_id         in  number
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_dflt_asnd_dt                   in  date      default hr_api.g_date
  ,p_elcns_made_dt                  in  date      default hr_api.g_date
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt               in  date      default hr_api.g_date
  ,p_enrt_perd_strt_dt              in  date      default hr_api.g_date
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_pil_elctbl_popl_stat_cd        in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_comments                            in  varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                            in  date  default hr_api.g_date
  ,p_ws_mgr_id                            in  number  default hr_api.g_number
  ,p_mgr_ovrid_person_id                            in  number  default hr_api.g_number
  ,p_assignment_id                            in  number  default hr_api.g_number
  --cwb
  ,p_bdgt_acc_cd                    in varchar2   default hr_api.g_varchar2
  ,p_pop_cd                         in varchar2   default hr_api.g_varchar2
  ,p_bdgt_due_dt                    in date       default hr_api.g_date
  ,p_bdgt_export_flag               in varchar2   default hr_api.g_varchar2
  ,p_bdgt_iss_dt                    in date       default hr_api.g_date
  ,p_bdgt_stat_cd                   in varchar2   default hr_api.g_varchar2
  ,p_ws_acc_cd                      in varchar2   default hr_api.g_varchar2
  ,p_ws_due_dt                      in date       default hr_api.g_date
  ,p_ws_export_flag                 in varchar2   default hr_api.g_varchar2
  ,p_ws_iss_dt                      in date       default hr_api.g_date
  ,p_ws_stat_cd                     in varchar2   default hr_api.g_varchar2
  --cwb
  ,p_reinstate_cd                   in varchar2   default hr_api.g_varchar2
  ,p_reinstate_ovrdn_cd             in varchar2   default hr_api.g_varchar2
  ,p_auto_asnd_dt                   in  date      default hr_api.g_date
  ,p_cbr_elig_perd_strt_dt          in  date      default hr_api.g_date
  ,p_cbr_elig_perd_end_dt           in  date      default hr_api.g_date
  ,p_lee_rsn_id                     in  number    default hr_api.g_number
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pel_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pel_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_defer_deenrol_flag             in varchar2   default hr_api.g_varchar2
  ,p_deenrol_made_dt                in date       default hr_api.g_date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Pil_Elctbl_chc_Popl';
  l_object_version_number ben_pil_elctbl_chc_popl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Pil_Elctbl_chc_Popl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Pil_Elctbl_chc_Popl
    --
    ben_Pil_Elctbl_chc_Popl_bk2.update_Pil_Elctbl_chc_Popl_b
      (
       p_pil_elctbl_chc_popl_id         =>  p_pil_elctbl_chc_popl_id
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_dflt_asnd_dt                   =>  p_dflt_asnd_dt
      ,p_elcns_made_dt                  =>  p_elcns_made_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_pil_elctbl_popl_stat_cd        =>  p_pil_elctbl_popl_stat_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_comments                            =>  p_comments
      ,p_mgr_ovrid_dt                            =>  p_mgr_ovrid_dt
      ,p_ws_mgr_id                            =>  p_ws_mgr_id
      ,p_mgr_ovrid_person_id                            =>  p_mgr_ovrid_person_id
      ,p_assignment_id                            =>  p_assignment_id
      --cwb
      ,p_bdgt_acc_cd                    =>  p_bdgt_acc_cd
      ,p_pop_cd                         =>  p_pop_cd
      ,p_bdgt_due_dt                    =>  p_bdgt_due_dt
      ,p_bdgt_export_flag               =>  p_bdgt_export_flag
      ,p_bdgt_iss_dt                    =>  p_bdgt_iss_dt
      ,p_bdgt_stat_cd                   =>  p_bdgt_stat_cd
      ,p_ws_acc_cd                      =>  p_ws_acc_cd
      ,p_ws_due_dt                      =>  p_ws_due_dt
      ,p_ws_export_flag                 =>  p_ws_export_flag
      ,p_ws_iss_dt                      =>  p_ws_iss_dt
      ,p_ws_stat_cd                     =>  p_ws_stat_cd
      --cwb
      ,p_reinstate_cd                   =>  p_reinstate_cd
      ,p_reinstate_ovrdn_cd             =>  p_reinstate_ovrdn_cd
      ,p_auto_asnd_dt                   =>  p_auto_asnd_dt
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pel_attribute_category         =>  p_pel_attribute_category
      ,p_pel_attribute1                 =>  p_pel_attribute1
      ,p_pel_attribute2                 =>  p_pel_attribute2
      ,p_pel_attribute3                 =>  p_pel_attribute3
      ,p_pel_attribute4                 =>  p_pel_attribute4
      ,p_pel_attribute5                 =>  p_pel_attribute5
      ,p_pel_attribute6                 =>  p_pel_attribute6
      ,p_pel_attribute7                 =>  p_pel_attribute7
      ,p_pel_attribute8                 =>  p_pel_attribute8
      ,p_pel_attribute9                 =>  p_pel_attribute9
      ,p_pel_attribute10                =>  p_pel_attribute10
      ,p_pel_attribute11                =>  p_pel_attribute11
      ,p_pel_attribute12                =>  p_pel_attribute12
      ,p_pel_attribute13                =>  p_pel_attribute13
      ,p_pel_attribute14                =>  p_pel_attribute14
      ,p_pel_attribute15                =>  p_pel_attribute15
      ,p_pel_attribute16                =>  p_pel_attribute16
      ,p_pel_attribute17                =>  p_pel_attribute17
      ,p_pel_attribute18                =>  p_pel_attribute18
      ,p_pel_attribute19                =>  p_pel_attribute19
      ,p_pel_attribute20                =>  p_pel_attribute20
      ,p_pel_attribute21                =>  p_pel_attribute21
      ,p_pel_attribute22                =>  p_pel_attribute22
      ,p_pel_attribute23                =>  p_pel_attribute23
      ,p_pel_attribute24                =>  p_pel_attribute24
      ,p_pel_attribute25                =>  p_pel_attribute25
      ,p_pel_attribute26                =>  p_pel_attribute26
      ,p_pel_attribute27                =>  p_pel_attribute27
      ,p_pel_attribute28                =>  p_pel_attribute28
      ,p_pel_attribute29                =>  p_pel_attribute29
      ,p_pel_attribute30                =>  p_pel_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_defer_deenrol_flag             => p_defer_deenrol_flag
      ,p_deenrol_made_dt                => p_deenrol_made_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Pil_Elctbl_chc_Popl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Pil_Elctbl_chc_Popl
    --
  end;
  --
  ben_pel_upd.upd
    (
     p_pil_elctbl_chc_popl_id        => p_pil_elctbl_chc_popl_id
    ,p_dflt_enrt_dt                  => p_dflt_enrt_dt
    ,p_dflt_asnd_dt                  => p_dflt_asnd_dt
    ,p_elcns_made_dt                 => p_elcns_made_dt
    ,p_cls_enrt_dt_to_use_cd         => p_cls_enrt_dt_to_use_cd
    ,p_enrt_typ_cycl_cd              => p_enrt_typ_cycl_cd
    ,p_enrt_perd_end_dt              => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt             => p_enrt_perd_strt_dt
    ,p_procg_end_dt                  => p_procg_end_dt
    ,p_pil_elctbl_popl_stat_cd       => p_pil_elctbl_popl_stat_cd
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_uom                           => p_uom
    ,p_comments                           => p_comments
    ,p_mgr_ovrid_dt                           => p_mgr_ovrid_dt
    ,p_ws_mgr_id                           => p_ws_mgr_id
    ,p_mgr_ovrid_person_id                           => p_mgr_ovrid_person_id
    ,p_assignment_id                           => p_assignment_id
    --cwb
    ,p_bdgt_acc_cd                    =>  p_bdgt_acc_cd
    ,p_pop_cd                         =>  p_pop_cd
    ,p_bdgt_due_dt                    =>  p_bdgt_due_dt
    ,p_bdgt_export_flag               =>  p_bdgt_export_flag
    ,p_bdgt_iss_dt                    =>  p_bdgt_iss_dt
    ,p_bdgt_stat_cd                   =>  p_bdgt_stat_cd
    ,p_ws_acc_cd                      =>  p_ws_acc_cd
    ,p_ws_due_dt                      =>  p_ws_due_dt
    ,p_ws_export_flag                 =>  p_ws_export_flag
    ,p_ws_iss_dt                      =>  p_ws_iss_dt
    ,p_ws_stat_cd                     =>  p_ws_stat_cd
      --cwb
    ,p_reinstate_cd                   =>  p_reinstate_cd
    ,p_reinstate_ovrdn_cd             =>  p_reinstate_ovrdn_cd
    ,p_auto_asnd_dt                  => p_auto_asnd_dt
    ,p_cbr_elig_perd_strt_dt         => p_cbr_elig_perd_strt_dt
    ,p_cbr_elig_perd_end_dt          => p_cbr_elig_perd_end_dt
    ,p_lee_rsn_id                    => p_lee_rsn_id
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pel_attribute_category        => p_pel_attribute_category
    ,p_pel_attribute1                => p_pel_attribute1
    ,p_pel_attribute2                => p_pel_attribute2
    ,p_pel_attribute3                => p_pel_attribute3
    ,p_pel_attribute4                => p_pel_attribute4
    ,p_pel_attribute5                => p_pel_attribute5
    ,p_pel_attribute6                => p_pel_attribute6
    ,p_pel_attribute7                => p_pel_attribute7
    ,p_pel_attribute8                => p_pel_attribute8
    ,p_pel_attribute9                => p_pel_attribute9
    ,p_pel_attribute10               => p_pel_attribute10
    ,p_pel_attribute11               => p_pel_attribute11
    ,p_pel_attribute12               => p_pel_attribute12
    ,p_pel_attribute13               => p_pel_attribute13
    ,p_pel_attribute14               => p_pel_attribute14
    ,p_pel_attribute15               => p_pel_attribute15
    ,p_pel_attribute16               => p_pel_attribute16
    ,p_pel_attribute17               => p_pel_attribute17
    ,p_pel_attribute18               => p_pel_attribute18
    ,p_pel_attribute19               => p_pel_attribute19
    ,p_pel_attribute20               => p_pel_attribute20
    ,p_pel_attribute21               => p_pel_attribute21
    ,p_pel_attribute22               => p_pel_attribute22
    ,p_pel_attribute23               => p_pel_attribute23
    ,p_pel_attribute24               => p_pel_attribute24
    ,p_pel_attribute25               => p_pel_attribute25
    ,p_pel_attribute26               => p_pel_attribute26
    ,p_pel_attribute27               => p_pel_attribute27
    ,p_pel_attribute28               => p_pel_attribute28
    ,p_pel_attribute29               => p_pel_attribute29
    ,p_pel_attribute30               => p_pel_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_defer_deenrol_flag            => p_defer_deenrol_flag
    ,p_deenrol_made_dt               => p_deenrol_made_dt
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Pil_Elctbl_chc_Popl
    --
    ben_Pil_Elctbl_chc_Popl_bk2.update_Pil_Elctbl_chc_Popl_a
      (
       p_pil_elctbl_chc_popl_id         =>  p_pil_elctbl_chc_popl_id
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_dflt_asnd_dt                   =>  p_dflt_asnd_dt
      ,p_elcns_made_dt                  =>  p_elcns_made_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_enrt_perd_end_dt               =>  p_enrt_perd_end_dt
      ,p_enrt_perd_strt_dt              =>  p_enrt_perd_strt_dt
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_pil_elctbl_popl_stat_cd        =>  p_pil_elctbl_popl_stat_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_comments                            =>  p_comments
      ,p_mgr_ovrid_dt                            =>  p_mgr_ovrid_dt
      ,p_ws_mgr_id                            =>  p_ws_mgr_id
      ,p_mgr_ovrid_person_id                            =>  p_mgr_ovrid_person_id
      ,p_assignment_id                            =>  p_assignment_id
      --cwb
      ,p_bdgt_acc_cd                    =>  p_bdgt_acc_cd
      ,p_pop_cd                         =>  p_pop_cd
      ,p_bdgt_due_dt                    =>  p_bdgt_due_dt
      ,p_bdgt_export_flag               =>  p_bdgt_export_flag
      ,p_bdgt_iss_dt                    =>  p_bdgt_iss_dt
      ,p_bdgt_stat_cd                   =>  p_bdgt_stat_cd
      ,p_ws_acc_cd                      =>  p_ws_acc_cd
      ,p_ws_due_dt                      =>  p_ws_due_dt
      ,p_ws_export_flag                 =>  p_ws_export_flag
      ,p_ws_iss_dt                      =>  p_ws_iss_dt
      ,p_ws_stat_cd                     =>  p_ws_stat_cd
      --cwb
      ,p_reinstate_cd                   =>  p_reinstate_cd
      ,p_reinstate_ovrdn_cd             =>  p_reinstate_ovrdn_cd
      ,p_auto_asnd_dt                   =>  p_auto_asnd_dt
      ,p_cbr_elig_perd_strt_dt          =>  p_cbr_elig_perd_strt_dt
      ,p_cbr_elig_perd_end_dt           =>  p_cbr_elig_perd_end_dt
      ,p_lee_rsn_id                     =>  p_lee_rsn_id
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pel_attribute_category         =>  p_pel_attribute_category
      ,p_pel_attribute1                 =>  p_pel_attribute1
      ,p_pel_attribute2                 =>  p_pel_attribute2
      ,p_pel_attribute3                 =>  p_pel_attribute3
      ,p_pel_attribute4                 =>  p_pel_attribute4
      ,p_pel_attribute5                 =>  p_pel_attribute5
      ,p_pel_attribute6                 =>  p_pel_attribute6
      ,p_pel_attribute7                 =>  p_pel_attribute7
      ,p_pel_attribute8                 =>  p_pel_attribute8
      ,p_pel_attribute9                 =>  p_pel_attribute9
      ,p_pel_attribute10                =>  p_pel_attribute10
      ,p_pel_attribute11                =>  p_pel_attribute11
      ,p_pel_attribute12                =>  p_pel_attribute12
      ,p_pel_attribute13                =>  p_pel_attribute13
      ,p_pel_attribute14                =>  p_pel_attribute14
      ,p_pel_attribute15                =>  p_pel_attribute15
      ,p_pel_attribute16                =>  p_pel_attribute16
      ,p_pel_attribute17                =>  p_pel_attribute17
      ,p_pel_attribute18                =>  p_pel_attribute18
      ,p_pel_attribute19                =>  p_pel_attribute19
      ,p_pel_attribute20                =>  p_pel_attribute20
      ,p_pel_attribute21                =>  p_pel_attribute21
      ,p_pel_attribute22                =>  p_pel_attribute22
      ,p_pel_attribute23                =>  p_pel_attribute23
      ,p_pel_attribute24                =>  p_pel_attribute24
      ,p_pel_attribute25                =>  p_pel_attribute25
      ,p_pel_attribute26                =>  p_pel_attribute26
      ,p_pel_attribute27                =>  p_pel_attribute27
      ,p_pel_attribute28                =>  p_pel_attribute28
      ,p_pel_attribute29                =>  p_pel_attribute29
      ,p_pel_attribute30                =>  p_pel_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_defer_deenrol_flag             =>  p_defer_deenrol_flag
      ,p_deenrol_made_dt                =>  p_deenrol_made_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Pil_Elctbl_chc_Popl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Pil_Elctbl_chc_Popl
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
    ROLLBACK TO update_Pil_Elctbl_chc_Popl;
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
    ROLLBACK TO update_Pil_Elctbl_chc_Popl;
    --nocopy change
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_Pil_Elctbl_chc_Popl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Pil_Elctbl_chc_Popl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Pil_Elctbl_chc_Popl
  (p_validate                       in  boolean  default false
  ,p_pil_elctbl_chc_popl_id         in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Pil_Elctbl_chc_Popl';
  l_object_version_number ben_pil_elctbl_chc_popl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Pil_Elctbl_chc_Popl;
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
    -- Start of API User Hook for the before hook of delete_Pil_Elctbl_chc_Popl
    --
    ben_Pil_Elctbl_chc_Popl_bk3.delete_Pil_Elctbl_chc_Popl_b
      (
       p_pil_elctbl_chc_popl_id         =>  p_pil_elctbl_chc_popl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Pil_Elctbl_chc_Popl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Pil_Elctbl_chc_Popl
    --
  end;
  --
  ben_pel_del.del
    (
     p_pil_elctbl_chc_popl_id        => p_pil_elctbl_chc_popl_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Pil_Elctbl_chc_Popl
    --
    ben_Pil_Elctbl_chc_Popl_bk3.delete_Pil_Elctbl_chc_Popl_a
      (
       p_pil_elctbl_chc_popl_id         =>  p_pil_elctbl_chc_popl_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Pil_Elctbl_chc_Popl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Pil_Elctbl_chc_Popl
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
    ROLLBACK TO delete_Pil_Elctbl_chc_Popl;
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
    ROLLBACK TO delete_Pil_Elctbl_chc_Popl;
    --nocopy change
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_Pil_Elctbl_chc_Popl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pil_elctbl_chc_popl_id                   in     number
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
  ben_pel_shd.lck
    (
      p_pil_elctbl_chc_popl_id                 => p_pil_elctbl_chc_popl_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Pil_Elctbl_chc_Popl_api;

/
