--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_PER_ELC_CHC_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_PER_ELC_CHC_SWI" As
/* $Header: beepeswi.pkb 120.3 2006/01/06 05:38:02 narvenka noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ben_elig_per_elc_chc_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_elig_per_elc_chc >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id          out nocopy number
  ,p_enrt_typ_cycl_cd             in     varchar2  default null
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_enrt_perd_end_dt             in     date      default null
  ,p_enrt_perd_strt_dt            in     date      default null
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_pil_elctbl_chc_popl_id       in     number    default null
  ,p_roll_crs_flag                in     varchar2  default null
  ,p_crntly_enrd_flag             in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_elctbl_flag                  in     varchar2  default null
  ,p_mndtry_flag                  in     varchar2  default null
  ,p_in_pndg_wkflow_flag          in     varchar2  default null
  ,p_dflt_enrt_dt                 in     date      default null
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_enrt_cvg_strt_dt             in     date      default null
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default null
  ,p_dpnt_dsgn_cd                 in     varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default null
  ,p_erlst_deenrt_dt              in     date      default null
  ,p_procg_end_dt                 in     date      default null
  ,p_comp_lvl_cd                  in     varchar2  default null
  ,p_pl_id                        in     number    default null
  ,p_oipl_id                      in     number    default null
  ,p_pgm_id                       in     number    default null
  ,p_pgm_typ_cd                   in     varchar2  default null
  ,p_plip_id                      in     number    default null
  ,p_ptip_id                      in     number    default null
  ,p_pl_typ_id                    in     number    default null
  ,p_oiplip_id                    in     number    default null
  ,p_cmbn_plip_id                 in     number    default null
  ,p_cmbn_ptip_id                 in     number    default null
  ,p_cmbn_ptip_opt_id             in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_spcl_rt_pl_id                in     number    default null
  ,p_spcl_rt_oipl_id              in     number    default null
  ,p_must_enrl_anthr_pl_id        in     number    default null
  ,p_int_elig_per_elctbl_chc_id   in     number    default null
  ,p_prtt_enrt_rslt_id            in     number    default null
  ,p_bnft_prvdr_pool_id           in     number    default null
  ,p_per_in_ler_id                in     number    default null
  ,p_yr_perd_id                   in     number    default null
  ,p_auto_enrt_flag               in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_pl_ordr_num                  in     number    default null
  ,p_plip_ordr_num                in     number    default null
  ,p_ptip_ordr_num                in     number    default null
  ,p_oipl_ordr_num                in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_elig_flag                    in     varchar2  default null
  ,p_elig_ovrid_dt                in     date      default null
  ,p_elig_ovrid_person_id         in     number    default null
  ,p_inelig_rsn_cd                in     varchar2  default null
  ,p_mgr_ovrid_dt                 in     date      default null
  ,p_mgr_ovrid_person_id          in     number    default null
  ,p_ws_mgr_id                    in     number    default null
  ,p_epe_attribute_category       in     varchar2  default null
  ,p_epe_attribute1               in     varchar2  default null
  ,p_epe_attribute2               in     varchar2  default null
  ,p_epe_attribute3               in     varchar2  default null
  ,p_epe_attribute4               in     varchar2  default null
  ,p_epe_attribute5               in     varchar2  default null
  ,p_epe_attribute6               in     varchar2  default null
  ,p_epe_attribute7               in     varchar2  default null
  ,p_epe_attribute8               in     varchar2  default null
  ,p_epe_attribute9               in     varchar2  default null
  ,p_epe_attribute10              in     varchar2  default null
  ,p_epe_attribute11              in     varchar2  default null
  ,p_epe_attribute12              in     varchar2  default null
  ,p_epe_attribute13              in     varchar2  default null
  ,p_epe_attribute14              in     varchar2  default null
  ,p_epe_attribute15              in     varchar2  default null
  ,p_epe_attribute16              in     varchar2  default null
  ,p_epe_attribute17              in     varchar2  default null
  ,p_epe_attribute18              in     varchar2  default null
  ,p_epe_attribute19              in     varchar2  default null
  ,p_epe_attribute20              in     varchar2  default null
  ,p_epe_attribute21              in     varchar2  default null
  ,p_epe_attribute22              in     varchar2  default null
  ,p_epe_attribute23              in     varchar2  default null
  ,p_epe_attribute24              in     varchar2  default null
  ,p_epe_attribute25              in     varchar2  default null
  ,p_epe_attribute26              in     varchar2  default null
  ,p_epe_attribute27              in     varchar2  default null
  ,p_epe_attribute28              in     varchar2  default null
  ,p_epe_attribute29              in     varchar2  default null
  ,p_epe_attribute30              in     varchar2  default null
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_enrt_perd_id                 in     number    default null
  ,p_lee_rsn_id                   in     number    default null
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default null
  ,p_uom                          in     varchar2  default null
  ,p_acty_ref_perd_cd             in     varchar2  default null
  ,p_approval_status_cd           in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_elig_per_elc_chc';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_elig_per_elc_chc_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ben_elig_per_elc_chc_api.create_elig_per_elc_chc
    (p_validate                     => l_validate
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_enrt_typ_cycl_cd             => p_enrt_typ_cycl_cd
    ,p_enrt_cvg_strt_dt_cd          => p_enrt_cvg_strt_dt_cd
    ,p_enrt_perd_end_dt             => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt            => p_enrt_perd_strt_dt
    ,p_enrt_cvg_strt_dt_rl          => p_enrt_cvg_strt_dt_rl
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
    ,p_roll_crs_flag                => p_roll_crs_flag
    ,p_crntly_enrd_flag             => p_crntly_enrd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_elctbl_flag                  => p_elctbl_flag
    ,p_mndtry_flag                  => p_mndtry_flag
    ,p_in_pndg_wkflow_flag          => p_in_pndg_wkflow_flag
    ,p_dflt_enrt_dt                 => p_dflt_enrt_dt
    ,p_dpnt_cvg_strt_dt_cd          => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl          => p_dpnt_cvg_strt_dt_rl
    ,p_enrt_cvg_strt_dt             => p_enrt_cvg_strt_dt
    ,p_alws_dpnt_dsgn_flag          => p_alws_dpnt_dsgn_flag
    ,p_dpnt_dsgn_cd                 => p_dpnt_dsgn_cd
    ,p_ler_chg_dpnt_cvg_cd          => p_ler_chg_dpnt_cvg_cd
    ,p_erlst_deenrt_dt              => p_erlst_deenrt_dt
    ,p_procg_end_dt                 => p_procg_end_dt
    ,p_comp_lvl_cd                  => p_comp_lvl_cd
    ,p_pl_id                        => p_pl_id
    ,p_oipl_id                      => p_oipl_id
    ,p_pgm_id                       => p_pgm_id
    ,p_pgm_typ_cd                   => p_pgm_typ_cd
    ,p_plip_id                      => p_plip_id
    ,p_ptip_id                      => p_ptip_id
    ,p_pl_typ_id                    => p_pl_typ_id
    ,p_oiplip_id                    => p_oiplip_id
    ,p_cmbn_plip_id                 => p_cmbn_plip_id
    ,p_cmbn_ptip_id                 => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id             => p_cmbn_ptip_opt_id
    ,p_assignment_id                => p_assignment_id
    ,p_spcl_rt_pl_id                => p_spcl_rt_pl_id
    ,p_spcl_rt_oipl_id              => p_spcl_rt_oipl_id
    ,p_must_enrl_anthr_pl_id        => p_must_enrl_anthr_pl_id
    ,p_int_elig_per_elctbl_chc_id   => p_int_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
    ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
    ,p_per_in_ler_id                => p_per_in_ler_id
    ,p_yr_perd_id                   => p_yr_perd_id
    ,p_auto_enrt_flag               => p_auto_enrt_flag
    ,p_business_group_id            => p_business_group_id
    ,p_pl_ordr_num                  => p_pl_ordr_num
    ,p_plip_ordr_num                => p_plip_ordr_num
    ,p_ptip_ordr_num                => p_ptip_ordr_num
    ,p_oipl_ordr_num                => p_oipl_ordr_num
    ,p_comments                     => p_comments
    ,p_elig_flag                    => p_elig_flag
    ,p_elig_ovrid_dt                => p_elig_ovrid_dt
    ,p_elig_ovrid_person_id         => p_elig_ovrid_person_id
    ,p_inelig_rsn_cd                => p_inelig_rsn_cd
    ,p_mgr_ovrid_dt                 => p_mgr_ovrid_dt
    ,p_mgr_ovrid_person_id          => p_mgr_ovrid_person_id
    ,p_ws_mgr_id                    => p_ws_mgr_id
    ,p_epe_attribute_category       => p_epe_attribute_category
    ,p_epe_attribute1               => p_epe_attribute1
    ,p_epe_attribute2               => p_epe_attribute2
    ,p_epe_attribute3               => p_epe_attribute3
    ,p_epe_attribute4               => p_epe_attribute4
    ,p_epe_attribute5               => p_epe_attribute5
    ,p_epe_attribute6               => p_epe_attribute6
    ,p_epe_attribute7               => p_epe_attribute7
    ,p_epe_attribute8               => p_epe_attribute8
    ,p_epe_attribute9               => p_epe_attribute9
    ,p_epe_attribute10              => p_epe_attribute10
    ,p_epe_attribute11              => p_epe_attribute11
    ,p_epe_attribute12              => p_epe_attribute12
    ,p_epe_attribute13              => p_epe_attribute13
    ,p_epe_attribute14              => p_epe_attribute14
    ,p_epe_attribute15              => p_epe_attribute15
    ,p_epe_attribute16              => p_epe_attribute16
    ,p_epe_attribute17              => p_epe_attribute17
    ,p_epe_attribute18              => p_epe_attribute18
    ,p_epe_attribute19              => p_epe_attribute19
    ,p_epe_attribute20              => p_epe_attribute20
    ,p_epe_attribute21              => p_epe_attribute21
    ,p_epe_attribute22              => p_epe_attribute22
    ,p_epe_attribute23              => p_epe_attribute23
    ,p_epe_attribute24              => p_epe_attribute24
    ,p_epe_attribute25              => p_epe_attribute25
    ,p_epe_attribute26              => p_epe_attribute26
    ,p_epe_attribute27              => p_epe_attribute27
    ,p_epe_attribute28              => p_epe_attribute28
    ,p_epe_attribute29              => p_epe_attribute29
    ,p_epe_attribute30              => p_epe_attribute30
    ,p_cryfwd_elig_dpnt_cd          => p_cryfwd_elig_dpnt_cd
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_enrt_perd_id                 => p_enrt_perd_id
    ,p_lee_rsn_id                   => p_lee_rsn_id
    ,p_cls_enrt_dt_to_use_cd        => p_cls_enrt_dt_to_use_cd
    ,p_uom                          => p_uom
    ,p_acty_ref_perd_cd             => p_acty_ref_perd_cd
    ,p_approval_status_cd           => p_approval_status_cd
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_elig_per_elc_chc_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_per_elctbl_chc_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_elig_per_elc_chc_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_elig_per_elctbl_chc_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_elig_per_elc_chc;
-- ----------------------------------------------------------------------------
-- |---------------------< create_perf_elig_per_elc_chc >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_perf_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id          out nocopy number
  ,p_enrt_typ_cycl_cd             in     varchar2  default null
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_enrt_perd_end_dt             in     date      default null
  ,p_enrt_perd_strt_dt            in     date      default null
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_pil_elctbl_chc_popl_id       in     number    default null
  ,p_roll_crs_flag                in     varchar2  default null
  ,p_crntly_enrd_flag             in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_elctbl_flag                  in     varchar2  default null
  ,p_mndtry_flag                  in     varchar2  default null
  ,p_in_pndg_wkflow_flag          in     varchar2  default null
  ,p_dflt_enrt_dt                 in     date      default null
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default null
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default null
  ,p_enrt_cvg_strt_dt             in     date      default null
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default null
  ,p_dpnt_dsgn_cd                 in     varchar2  default null
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default null
  ,p_erlst_deenrt_dt              in     date      default null
  ,p_procg_end_dt                 in     date      default null
  ,p_comp_lvl_cd                  in     varchar2  default null
  ,p_pl_id                        in     number    default null
  ,p_oipl_id                      in     number    default null
  ,p_pgm_id                       in     number    default null
  ,p_pgm_typ_cd                   in     varchar2  default null
  ,p_plip_id                      in     number    default null
  ,p_ptip_id                      in     number    default null
  ,p_pl_typ_id                    in     number    default null
  ,p_oiplip_id                    in     number    default null
  ,p_cmbn_plip_id                 in     number    default null
  ,p_cmbn_ptip_id                 in     number    default null
  ,p_cmbn_ptip_opt_id             in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_spcl_rt_pl_id                in     number    default null
  ,p_spcl_rt_oipl_id              in     number    default null
  ,p_must_enrl_anthr_pl_id        in     number    default null
  ,p_int_elig_per_elctbl_chc_id   in     number    default null
  ,p_prtt_enrt_rslt_id            in     number    default null
  ,p_bnft_prvdr_pool_id           in     number    default null
  ,p_per_in_ler_id                in     number    default null
  ,p_yr_perd_id                   in     number    default null
  ,p_auto_enrt_flag               in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_pl_ordr_num                  in     number    default null
  ,p_plip_ordr_num                in     number    default null
  ,p_ptip_ordr_num                in     number    default null
  ,p_oipl_ordr_num                in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_elig_flag                    in     varchar2  default null
  ,p_elig_ovrid_dt                in     date      default null
  ,p_elig_ovrid_person_id         in     number    default null
  ,p_inelig_rsn_cd                in     varchar2  default null
  ,p_mgr_ovrid_dt                 in     date      default null
  ,p_mgr_ovrid_person_id          in     number    default null
  ,p_ws_mgr_id                    in     number    default null
  ,p_epe_attribute_category       in     varchar2  default null
  ,p_epe_attribute1               in     varchar2  default null
  ,p_epe_attribute2               in     varchar2  default null
  ,p_epe_attribute3               in     varchar2  default null
  ,p_epe_attribute4               in     varchar2  default null
  ,p_epe_attribute5               in     varchar2  default null
  ,p_epe_attribute6               in     varchar2  default null
  ,p_epe_attribute7               in     varchar2  default null
  ,p_epe_attribute8               in     varchar2  default null
  ,p_epe_attribute9               in     varchar2  default null
  ,p_epe_attribute10              in     varchar2  default null
  ,p_epe_attribute11              in     varchar2  default null
  ,p_epe_attribute12              in     varchar2  default null
  ,p_epe_attribute13              in     varchar2  default null
  ,p_epe_attribute14              in     varchar2  default null
  ,p_epe_attribute15              in     varchar2  default null
  ,p_epe_attribute16              in     varchar2  default null
  ,p_epe_attribute17              in     varchar2  default null
  ,p_epe_attribute18              in     varchar2  default null
  ,p_epe_attribute19              in     varchar2  default null
  ,p_epe_attribute20              in     varchar2  default null
  ,p_epe_attribute21              in     varchar2  default null
  ,p_epe_attribute22              in     varchar2  default null
  ,p_epe_attribute23              in     varchar2  default null
  ,p_epe_attribute24              in     varchar2  default null
  ,p_epe_attribute25              in     varchar2  default null
  ,p_epe_attribute26              in     varchar2  default null
  ,p_epe_attribute27              in     varchar2  default null
  ,p_epe_attribute28              in     varchar2  default null
  ,p_epe_attribute29              in     varchar2  default null
  ,p_epe_attribute30              in     varchar2  default null
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_enrt_perd_id                 in     number    default null
  ,p_lee_rsn_id                   in     number    default null
  ,p_cls_enrt_dt_to_use_cd        in     varchar2  default null
  ,p_uom                          in     varchar2  default null
  ,p_acty_ref_perd_cd             in     varchar2  default null
  ,p_mode                         in     varchar2  default null
  ,p_approval_status_cd           in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_perf_elig_per_elc_chc';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint crt_perf_elig_per_elc_chc_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ben_elig_per_elc_chc_api.create_perf_elig_per_elc_chc
    (p_validate                     => l_validate
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_enrt_typ_cycl_cd             => p_enrt_typ_cycl_cd
    ,p_enrt_cvg_strt_dt_cd          => p_enrt_cvg_strt_dt_cd
    ,p_enrt_perd_end_dt             => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt            => p_enrt_perd_strt_dt
    ,p_enrt_cvg_strt_dt_rl          => p_enrt_cvg_strt_dt_rl
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
    ,p_roll_crs_flag                => p_roll_crs_flag
    ,p_crntly_enrd_flag             => p_crntly_enrd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_elctbl_flag                  => p_elctbl_flag
    ,p_mndtry_flag                  => p_mndtry_flag
    ,p_in_pndg_wkflow_flag          => p_in_pndg_wkflow_flag
    ,p_dflt_enrt_dt                 => p_dflt_enrt_dt
    ,p_dpnt_cvg_strt_dt_cd          => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl          => p_dpnt_cvg_strt_dt_rl
    ,p_enrt_cvg_strt_dt             => p_enrt_cvg_strt_dt
    ,p_alws_dpnt_dsgn_flag          => p_alws_dpnt_dsgn_flag
    ,p_dpnt_dsgn_cd                 => p_dpnt_dsgn_cd
    ,p_ler_chg_dpnt_cvg_cd          => p_ler_chg_dpnt_cvg_cd
    ,p_erlst_deenrt_dt              => p_erlst_deenrt_dt
    ,p_procg_end_dt                 => p_procg_end_dt
    ,p_comp_lvl_cd                  => p_comp_lvl_cd
    ,p_pl_id                        => p_pl_id
    ,p_oipl_id                      => p_oipl_id
    ,p_pgm_id                       => p_pgm_id
    ,p_pgm_typ_cd                   => p_pgm_typ_cd
    ,p_plip_id                      => p_plip_id
    ,p_ptip_id                      => p_ptip_id
    ,p_pl_typ_id                    => p_pl_typ_id
    ,p_oiplip_id                    => p_oiplip_id
    ,p_cmbn_plip_id                 => p_cmbn_plip_id
    ,p_cmbn_ptip_id                 => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id             => p_cmbn_ptip_opt_id
    ,p_assignment_id                => p_assignment_id
    ,p_spcl_rt_pl_id                => p_spcl_rt_pl_id
    ,p_spcl_rt_oipl_id              => p_spcl_rt_oipl_id
    ,p_must_enrl_anthr_pl_id        => p_must_enrl_anthr_pl_id
    ,p_int_elig_per_elctbl_chc_id   => p_int_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
    ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
    ,p_per_in_ler_id                => p_per_in_ler_id
    ,p_yr_perd_id                   => p_yr_perd_id
    ,p_auto_enrt_flag               => p_auto_enrt_flag
    ,p_business_group_id            => p_business_group_id
    ,p_pl_ordr_num                  => p_pl_ordr_num
    ,p_plip_ordr_num                => p_plip_ordr_num
    ,p_ptip_ordr_num                => p_ptip_ordr_num
    ,p_oipl_ordr_num                => p_oipl_ordr_num
    ,p_comments                     => p_comments
    ,p_elig_flag                    => p_elig_flag
    ,p_elig_ovrid_dt                => p_elig_ovrid_dt
    ,p_elig_ovrid_person_id         => p_elig_ovrid_person_id
    ,p_inelig_rsn_cd                => p_inelig_rsn_cd
    ,p_mgr_ovrid_dt                 => p_mgr_ovrid_dt
    ,p_mgr_ovrid_person_id          => p_mgr_ovrid_person_id
    ,p_ws_mgr_id                    => p_ws_mgr_id
    ,p_epe_attribute_category       => p_epe_attribute_category
    ,p_epe_attribute1               => p_epe_attribute1
    ,p_epe_attribute2               => p_epe_attribute2
    ,p_epe_attribute3               => p_epe_attribute3
    ,p_epe_attribute4               => p_epe_attribute4
    ,p_epe_attribute5               => p_epe_attribute5
    ,p_epe_attribute6               => p_epe_attribute6
    ,p_epe_attribute7               => p_epe_attribute7
    ,p_epe_attribute8               => p_epe_attribute8
    ,p_epe_attribute9               => p_epe_attribute9
    ,p_epe_attribute10              => p_epe_attribute10
    ,p_epe_attribute11              => p_epe_attribute11
    ,p_epe_attribute12              => p_epe_attribute12
    ,p_epe_attribute13              => p_epe_attribute13
    ,p_epe_attribute14              => p_epe_attribute14
    ,p_epe_attribute15              => p_epe_attribute15
    ,p_epe_attribute16              => p_epe_attribute16
    ,p_epe_attribute17              => p_epe_attribute17
    ,p_epe_attribute18              => p_epe_attribute18
    ,p_epe_attribute19              => p_epe_attribute19
    ,p_epe_attribute20              => p_epe_attribute20
    ,p_epe_attribute21              => p_epe_attribute21
    ,p_epe_attribute22              => p_epe_attribute22
    ,p_epe_attribute23              => p_epe_attribute23
    ,p_epe_attribute24              => p_epe_attribute24
    ,p_epe_attribute25              => p_epe_attribute25
    ,p_epe_attribute26              => p_epe_attribute26
    ,p_epe_attribute27              => p_epe_attribute27
    ,p_epe_attribute28              => p_epe_attribute28
    ,p_epe_attribute29              => p_epe_attribute29
    ,p_epe_attribute30              => p_epe_attribute30
    ,p_cryfwd_elig_dpnt_cd          => p_cryfwd_elig_dpnt_cd
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_enrt_perd_id                 => p_enrt_perd_id
    ,p_lee_rsn_id                   => p_lee_rsn_id
    ,p_cls_enrt_dt_to_use_cd        => p_cls_enrt_dt_to_use_cd
    ,p_uom                          => p_uom
    ,p_acty_ref_perd_cd             => p_acty_ref_perd_cd
    ,p_approval_status_cd           => p_approval_status_cd
    ,p_mode                         => p_mode
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to crt_perf_elig_per_elc_chc_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_elig_per_elctbl_chc_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to crt_perf_elig_per_elc_chc_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_elig_per_elctbl_chc_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_perf_elig_per_elc_chc;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_elig_per_elc_chc >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_elig_per_elc_chc';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_elig_per_elc_chc_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ben_elig_per_elc_chc_api.delete_elig_per_elc_chc
    (p_validate                     => l_validate
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_elig_per_elc_chc_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_elig_per_elc_chc_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_elig_per_elc_chc;
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_elig_per_elctbl_chc_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'lck';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint lck_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ben_elig_per_elc_chc_api.lck
    (p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to lck_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to lck_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end lck;
-- ----------------------------------------------------------------------------
-- |------------------------< update_elig_per_elc_chc >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id       in     number
  ,p_enrt_typ_cycl_cd             in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_end_dt             in     date      default hr_api.g_date
  ,p_enrt_perd_strt_dt            in     date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id       in     number    default hr_api.g_number
  ,p_roll_crs_flag                in     varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_dt                 in     date      default hr_api.g_date
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt             in     date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt              in     date      default hr_api.g_date
  ,p_procg_end_dt                 in     date      default hr_api.g_date
  ,p_comp_lvl_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_oipl_id                      in     number    default hr_api.g_number
  ,p_pgm_id                       in     number    default hr_api.g_number
  ,p_plip_id                      in     number    default hr_api.g_number
  ,p_ptip_id                      in     number    default hr_api.g_number
  ,p_pl_typ_id                    in     number    default hr_api.g_number
  ,p_oiplip_id                    in     number    default hr_api.g_number
  ,p_cmbn_plip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id             in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_spcl_rt_pl_id                in     number    default hr_api.g_number
  ,p_spcl_rt_oipl_id              in     number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id        in     number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id   in     number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id            in     number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id           in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ,p_yr_perd_id                   in     number    default hr_api.g_number
  ,p_auto_enrt_flag               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pl_ordr_num                  in     number    default hr_api.g_number
  ,p_plip_ordr_num                in     number    default hr_api.g_number
  ,p_ptip_ordr_num                in     number    default hr_api.g_number
  ,p_oipl_ordr_num                in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_elig_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_ovrid_dt                in     date      default hr_api.g_date
  ,p_elig_ovrid_person_id         in     number    default hr_api.g_number
  ,p_inelig_rsn_cd                in     varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                 in     date      default hr_api.g_date
  ,p_mgr_ovrid_person_id          in     number    default hr_api.g_number
  ,p_ws_mgr_id                    in     number    default hr_api.g_number
  ,p_epe_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_approval_status_cd           in   varchar2    default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_elig_per_elc_chc';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_elig_per_elc_chc_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ben_elig_per_elc_chc_api.update_elig_per_elc_chc
    (p_validate                     => l_validate
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_enrt_typ_cycl_cd             => p_enrt_typ_cycl_cd
    ,p_enrt_cvg_strt_dt_cd          => p_enrt_cvg_strt_dt_cd
    ,p_enrt_perd_end_dt             => p_enrt_perd_end_dt
    ,p_enrt_perd_strt_dt            => p_enrt_perd_strt_dt
    ,p_enrt_cvg_strt_dt_rl          => p_enrt_cvg_strt_dt_rl
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
    ,p_roll_crs_flag                => p_roll_crs_flag
    ,p_crntly_enrd_flag             => p_crntly_enrd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_elctbl_flag                  => p_elctbl_flag
    ,p_mndtry_flag                  => p_mndtry_flag
    ,p_in_pndg_wkflow_flag          => p_in_pndg_wkflow_flag
    ,p_dflt_enrt_dt                 => p_dflt_enrt_dt
    ,p_dpnt_cvg_strt_dt_cd          => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl          => p_dpnt_cvg_strt_dt_rl
    ,p_enrt_cvg_strt_dt             => p_enrt_cvg_strt_dt
    ,p_alws_dpnt_dsgn_flag          => p_alws_dpnt_dsgn_flag
    ,p_dpnt_dsgn_cd                 => p_dpnt_dsgn_cd
    ,p_ler_chg_dpnt_cvg_cd          => p_ler_chg_dpnt_cvg_cd
    ,p_erlst_deenrt_dt              => p_erlst_deenrt_dt
    ,p_procg_end_dt                 => p_procg_end_dt
    ,p_comp_lvl_cd                  => p_comp_lvl_cd
    ,p_pl_id                        => p_pl_id
    ,p_oipl_id                      => p_oipl_id
    ,p_pgm_id                       => p_pgm_id
    ,p_plip_id                      => p_plip_id
    ,p_ptip_id                      => p_ptip_id
    ,p_pl_typ_id                    => p_pl_typ_id
    ,p_oiplip_id                    => p_oiplip_id
    ,p_cmbn_plip_id                 => p_cmbn_plip_id
    ,p_cmbn_ptip_id                 => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id             => p_cmbn_ptip_opt_id
    ,p_assignment_id                => p_assignment_id
    ,p_spcl_rt_pl_id                => p_spcl_rt_pl_id
    ,p_spcl_rt_oipl_id              => p_spcl_rt_oipl_id
    ,p_must_enrl_anthr_pl_id        => p_must_enrl_anthr_pl_id
    ,p_int_elig_per_elctbl_chc_id   => p_int_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
    ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
    ,p_per_in_ler_id                => p_per_in_ler_id
    ,p_yr_perd_id                   => p_yr_perd_id
    ,p_auto_enrt_flag               => p_auto_enrt_flag
    ,p_business_group_id            => p_business_group_id
    ,p_pl_ordr_num                  => p_pl_ordr_num
    ,p_plip_ordr_num                => p_plip_ordr_num
    ,p_ptip_ordr_num                => p_ptip_ordr_num
    ,p_oipl_ordr_num                => p_oipl_ordr_num
    ,p_comments                     => p_comments
    ,p_elig_flag                    => p_elig_flag
    ,p_elig_ovrid_dt                => p_elig_ovrid_dt
    ,p_elig_ovrid_person_id         => p_elig_ovrid_person_id
    ,p_inelig_rsn_cd                => p_inelig_rsn_cd
    ,p_mgr_ovrid_dt                 => p_mgr_ovrid_dt
    ,p_mgr_ovrid_person_id          => p_mgr_ovrid_person_id
    ,p_ws_mgr_id                    => p_ws_mgr_id
    ,p_epe_attribute_category       => p_epe_attribute_category
    ,p_epe_attribute1               => p_epe_attribute1
    ,p_epe_attribute2               => p_epe_attribute2
    ,p_epe_attribute3               => p_epe_attribute3
    ,p_epe_attribute4               => p_epe_attribute4
    ,p_epe_attribute5               => p_epe_attribute5
    ,p_epe_attribute6               => p_epe_attribute6
    ,p_epe_attribute7               => p_epe_attribute7
    ,p_epe_attribute8               => p_epe_attribute8
    ,p_epe_attribute9               => p_epe_attribute9
    ,p_epe_attribute10              => p_epe_attribute10
    ,p_epe_attribute11              => p_epe_attribute11
    ,p_epe_attribute12              => p_epe_attribute12
    ,p_epe_attribute13              => p_epe_attribute13
    ,p_epe_attribute14              => p_epe_attribute14
    ,p_epe_attribute15              => p_epe_attribute15
    ,p_epe_attribute16              => p_epe_attribute16
    ,p_epe_attribute17              => p_epe_attribute17
    ,p_epe_attribute18              => p_epe_attribute18
    ,p_epe_attribute19              => p_epe_attribute19
    ,p_epe_attribute20              => p_epe_attribute20
    ,p_epe_attribute21              => p_epe_attribute21
    ,p_epe_attribute22              => p_epe_attribute22
    ,p_epe_attribute23              => p_epe_attribute23
    ,p_epe_attribute24              => p_epe_attribute24
    ,p_epe_attribute25              => p_epe_attribute25
    ,p_epe_attribute26              => p_epe_attribute26
    ,p_epe_attribute27              => p_epe_attribute27
    ,p_epe_attribute28              => p_epe_attribute28
    ,p_epe_attribute29              => p_epe_attribute29
    ,p_epe_attribute30              => p_epe_attribute30
    ,p_cryfwd_elig_dpnt_cd          => p_cryfwd_elig_dpnt_cd
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_approval_status_cd           =>  p_approval_status_cd
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_elig_per_elc_chc_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_elig_per_elc_chc_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_elig_per_elc_chc;
-- ----------------------------------------------------------------------------
-- |---------------------< update_perf_elig_per_elc_chc >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_perf_elig_per_elc_chc
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_elig_per_elctbl_chc_id       in     number
  ,p_enrt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_pil_elctbl_chc_popl_id       in     number    default hr_api.g_number
  ,p_roll_crs_flag                in     varchar2  default hr_api.g_varchar2
  ,p_crntly_enrd_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elctbl_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_mndtry_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_in_pndg_wkflow_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_strt_dt_rl          in     varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt             in     date      default hr_api.g_date
  ,p_alws_dpnt_dsgn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgn_cd                 in     varchar2  default hr_api.g_varchar2
  ,p_ler_chg_dpnt_cvg_cd          in     varchar2  default hr_api.g_varchar2
  ,p_erlst_deenrt_dt              in     date      default hr_api.g_date
  ,p_procg_end_dt                 in     date      default hr_api.g_date
  ,p_comp_lvl_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_pl_id                        in     number    default hr_api.g_number
  ,p_oipl_id                      in     number    default hr_api.g_number
  ,p_pgm_id                       in     number    default hr_api.g_number
  ,p_plip_id                      in     number    default hr_api.g_number
  ,p_ptip_id                      in     number    default hr_api.g_number
  ,p_pl_typ_id                    in     number    default hr_api.g_number
  ,p_oiplip_id                    in     number    default hr_api.g_number
  ,p_cmbn_plip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_id                 in     number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id             in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_spcl_rt_pl_id                in     number    default hr_api.g_number
  ,p_spcl_rt_oipl_id              in     number    default hr_api.g_number
  ,p_must_enrl_anthr_pl_id        in     number    default hr_api.g_number
  ,p_int_elig_per_elctbl_chc_id   in     number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id            in     number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id           in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ,p_yr_perd_id                   in     number    default hr_api.g_number
  ,p_auto_enrt_flag               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_pl_ordr_num                  in     number    default hr_api.g_number
  ,p_plip_ordr_num                in     number    default hr_api.g_number
  ,p_ptip_ordr_num                in     number    default hr_api.g_number
  ,p_oipl_ordr_num                in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_elig_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_ovrid_dt                in     date      default hr_api.g_date
  ,p_elig_ovrid_person_id         in     number    default hr_api.g_number
  ,p_inelig_rsn_cd                in     varchar2  default hr_api.g_varchar2
  ,p_mgr_ovrid_dt                 in     date      default hr_api.g_date
  ,p_mgr_ovrid_person_id          in     number    default hr_api.g_number
  ,p_ws_mgr_id                    in     number    default hr_api.g_number
  ,p_epe_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_epe_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_cryfwd_elig_dpnt_cd          in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_approval_status_cd           in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_perf_elig_per_elc_chc';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint upd_perf_elig_per_elc_chc_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ben_elig_per_elc_chc_api.update_perf_elig_per_elc_chc
    (p_validate                     => l_validate
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_enrt_cvg_strt_dt_cd          => p_enrt_cvg_strt_dt_cd
    ,p_enrt_cvg_strt_dt_rl          => p_enrt_cvg_strt_dt_rl
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_pil_elctbl_chc_popl_id       => p_pil_elctbl_chc_popl_id
    ,p_roll_crs_flag                => p_roll_crs_flag
    ,p_crntly_enrd_flag             => p_crntly_enrd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_elctbl_flag                  => p_elctbl_flag
    ,p_mndtry_flag                  => p_mndtry_flag
    ,p_in_pndg_wkflow_flag          => p_in_pndg_wkflow_flag
    ,p_dpnt_cvg_strt_dt_cd          => p_dpnt_cvg_strt_dt_cd
    ,p_dpnt_cvg_strt_dt_rl          => p_dpnt_cvg_strt_dt_rl
    ,p_enrt_cvg_strt_dt             => p_enrt_cvg_strt_dt
    ,p_alws_dpnt_dsgn_flag          => p_alws_dpnt_dsgn_flag
    ,p_dpnt_dsgn_cd                 => p_dpnt_dsgn_cd
    ,p_ler_chg_dpnt_cvg_cd          => p_ler_chg_dpnt_cvg_cd
    ,p_erlst_deenrt_dt              => p_erlst_deenrt_dt
    ,p_procg_end_dt                 => p_procg_end_dt
    ,p_comp_lvl_cd                  => p_comp_lvl_cd
    ,p_pl_id                        => p_pl_id
    ,p_oipl_id                      => p_oipl_id
    ,p_pgm_id                       => p_pgm_id
    ,p_plip_id                      => p_plip_id
    ,p_ptip_id                      => p_ptip_id
    ,p_pl_typ_id                    => p_pl_typ_id
    ,p_oiplip_id                    => p_oiplip_id
    ,p_cmbn_plip_id                 => p_cmbn_plip_id
    ,p_cmbn_ptip_id                 => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id             => p_cmbn_ptip_opt_id
    ,p_assignment_id                => p_assignment_id
    ,p_spcl_rt_pl_id                => p_spcl_rt_pl_id
    ,p_spcl_rt_oipl_id              => p_spcl_rt_oipl_id
    ,p_must_enrl_anthr_pl_id        => p_must_enrl_anthr_pl_id
    ,p_int_elig_per_elctbl_chc_id   => p_int_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id            => p_prtt_enrt_rslt_id
    ,p_bnft_prvdr_pool_id           => p_bnft_prvdr_pool_id
    ,p_per_in_ler_id                => p_per_in_ler_id
    ,p_yr_perd_id                   => p_yr_perd_id
    ,p_auto_enrt_flag               => p_auto_enrt_flag
    ,p_business_group_id            => p_business_group_id
    ,p_pl_ordr_num                  => p_pl_ordr_num
    ,p_plip_ordr_num                => p_plip_ordr_num
    ,p_ptip_ordr_num                => p_ptip_ordr_num
    ,p_oipl_ordr_num                => p_oipl_ordr_num
    ,p_comments                     => p_comments
    ,p_elig_flag                    => p_elig_flag
    ,p_elig_ovrid_dt                => p_elig_ovrid_dt
    ,p_elig_ovrid_person_id         => p_elig_ovrid_person_id
    ,p_inelig_rsn_cd                => p_inelig_rsn_cd
    ,p_mgr_ovrid_dt                 => p_mgr_ovrid_dt
    ,p_mgr_ovrid_person_id          => p_mgr_ovrid_person_id
    ,p_ws_mgr_id                    => p_ws_mgr_id
    ,p_epe_attribute_category       => p_epe_attribute_category
    ,p_epe_attribute1               => p_epe_attribute1
    ,p_epe_attribute2               => p_epe_attribute2
    ,p_epe_attribute3               => p_epe_attribute3
    ,p_epe_attribute4               => p_epe_attribute4
    ,p_epe_attribute5               => p_epe_attribute5
    ,p_epe_attribute6               => p_epe_attribute6
    ,p_epe_attribute7               => p_epe_attribute7
    ,p_epe_attribute8               => p_epe_attribute8
    ,p_epe_attribute9               => p_epe_attribute9
    ,p_epe_attribute10              => p_epe_attribute10
    ,p_epe_attribute11              => p_epe_attribute11
    ,p_epe_attribute12              => p_epe_attribute12
    ,p_epe_attribute13              => p_epe_attribute13
    ,p_epe_attribute14              => p_epe_attribute14
    ,p_epe_attribute15              => p_epe_attribute15
    ,p_epe_attribute16              => p_epe_attribute16
    ,p_epe_attribute17              => p_epe_attribute17
    ,p_epe_attribute18              => p_epe_attribute18
    ,p_epe_attribute19              => p_epe_attribute19
    ,p_epe_attribute20              => p_epe_attribute20
    ,p_epe_attribute21              => p_epe_attribute21
    ,p_epe_attribute22              => p_epe_attribute22
    ,p_epe_attribute23              => p_epe_attribute23
    ,p_epe_attribute24              => p_epe_attribute24
    ,p_epe_attribute25              => p_epe_attribute25
    ,p_epe_attribute26              => p_epe_attribute26
    ,p_epe_attribute27              => p_epe_attribute27
    ,p_epe_attribute28              => p_epe_attribute28
    ,p_epe_attribute29              => p_epe_attribute29
    ,p_epe_attribute30              => p_epe_attribute30
    ,p_cryfwd_elig_dpnt_cd          => p_cryfwd_elig_dpnt_cd
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_approval_status_cd           => p_approval_status_cd
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to upd_perf_elig_per_elc_chc_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to upd_perf_elig_per_elc_chc_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_perf_elig_per_elc_chc;
-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------
procedure process_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_object_version_number number;
   l_commitElement xmldom.DOMElement;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_api';

   --

BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);

   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');

   --Get in/out parameters
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');

   if l_postState = '2' then
     --
     ben_elig_per_elc_chc_swi.update_perf_elig_per_elc_chc
        (p_validate                     =>       p_validate
        ,p_elig_per_elctbl_chc_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'EligPerElctblChcId')
        ,p_enrt_cvg_strt_dt_cd          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EnrtCvgStrtDtCd')
        ,p_enrt_cvg_strt_dt_rl          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EnrtCvgStrtDtRl')
        ,p_ctfn_rqd_flag                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'CtfnRqdFlag')
        ,p_pil_elctbl_chc_popl_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PilElctblChcPoplId')
        ,p_roll_crs_flag                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'RollCrsFlag')
        ,p_crntly_enrd_flag             =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'CrntlyEnrdFlag')
        ,p_dflt_flag                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DfltFlag')
        ,p_elctbl_flag                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ElctblFlag')
        ,p_mndtry_flag                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'MndtryFlag')
        ,p_in_pndg_wkflow_flag          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'InPndgWkflowFlag')
        ,p_dpnt_cvg_strt_dt_cd          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DpntCvgStrtDtCd')
        ,p_dpnt_cvg_strt_dt_rl          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DpntCvgStrtDtRl')
        ,p_enrt_cvg_strt_dt             =>       hr_transaction_swi.getDateValue(l_CommitNode,'EnrtCvgStrtDt')
        ,p_alws_dpnt_dsgn_flag          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AlwsDpntDsgnFlag')
        ,p_dpnt_dsgn_cd                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DpntDsgnCd')
        ,p_ler_chg_dpnt_cvg_cd          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'LerChgDpntCvgCd')
        ,p_erlst_deenrt_dt              =>       hr_transaction_swi.getDateValue(l_CommitNode,'ErlstDeenrtDt')
        ,p_procg_end_dt                 =>       hr_transaction_swi.getDateValue(l_CommitNode,'ProcgEndDt')
        ,p_comp_lvl_cd                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'CompLvlCd')
        ,p_pl_id                        =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PlId')
        ,p_oipl_id                      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'OiplId')
        ,p_pgm_id                       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PgmId')
        ,p_plip_id                      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PlipId')
        ,p_ptip_id                      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PtipId')
        ,p_pl_typ_id                    =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PlTypId')
        ,p_oiplip_id                    =>       hr_transaction_swi.getNumberValue(l_CommitNode,'OiplipId')
        ,p_cmbn_plip_id                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CmbnPlipId')
        ,p_cmbn_ptip_id                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CmbnPtipId')
        ,p_cmbn_ptip_opt_id             =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CmbnPtipOptId')
        ,p_assignment_id                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentId')
        ,p_spcl_rt_pl_id                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SpclRtPlId')
        ,p_spcl_rt_oipl_id              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SpclRtOiplId')
        ,p_must_enrl_anthr_pl_id        =>       hr_transaction_swi.getNumberValue(l_CommitNode,'MustEnrlAnthrPlId')
        ,p_int_elig_per_elctbl_chc_id   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'IntEligPerElctblChcId')
        ,p_prtt_enrt_rslt_id            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PrttEnrtRsltId')
        ,p_bnft_prvdr_pool_id           =>       hr_transaction_swi.getNumberValue(l_CommitNode,'BnftPrvdrPoolId')
        ,p_per_in_ler_id                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PerInLerId')
        ,p_yr_perd_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'YrPerdId')
        ,p_auto_enrt_flag               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AutoEnrtFlag')
        ,p_business_group_id            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId')
        ,p_pl_ordr_num                  =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PlOrdrNum')
        ,p_plip_ordr_num                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PlipOrdrNum')
        ,p_ptip_ordr_num                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PtipOrdrNum')
        ,p_oipl_ordr_num                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'OiplOrdrNum')
        ,p_comments                     =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
        ,p_elig_flag                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EligFlag')
        ,p_elig_ovrid_dt                =>       hr_transaction_swi.getDateValue(l_CommitNode,'EligOvridDt')
        ,p_elig_ovrid_person_id         =>       hr_transaction_swi.getNumberValue(l_CommitNode,'EligOvridPersonId')
        ,p_inelig_rsn_cd                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'IneligRsnCd')
        ,p_mgr_ovrid_dt                 =>       hr_transaction_swi.getDateValue(l_CommitNode,'MgrOvridDt')
        ,p_mgr_ovrid_person_id          =>       hr_transaction_swi.getNumberValue(l_CommitNode,'MgrOvridPersonId')
        ,p_ws_mgr_id                    =>       hr_transaction_swi.getNumberValue(l_CommitNode,'WsMgrId')
        ,p_epe_attribute_category       =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttributeCategory')
        ,p_epe_attribute1               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute1')
        ,p_epe_attribute2               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute2')
        ,p_epe_attribute3               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute3')
        ,p_epe_attribute4               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute4')
        ,p_epe_attribute5               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute5')
        ,p_epe_attribute6               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute6')
        ,p_epe_attribute7               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute7')
        ,p_epe_attribute8               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute8')
        ,p_epe_attribute9               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute9')
        ,p_epe_attribute10              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute10')
        ,p_epe_attribute11              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute11')
        ,p_epe_attribute12              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute12')
        ,p_epe_attribute13              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute13')
        ,p_epe_attribute14              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute14')
        ,p_epe_attribute15              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute15')
        ,p_epe_attribute16              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute16')
        ,p_epe_attribute17              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute17')
        ,p_epe_attribute18              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute18')
        ,p_epe_attribute19              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute19')
        ,p_epe_attribute20              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute20')
        ,p_epe_attribute21              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute21')
        ,p_epe_attribute22              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute22')
        ,p_epe_attribute23              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute23')
        ,p_epe_attribute24              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute24')
        ,p_epe_attribute25              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute25')
        ,p_epe_attribute26              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute26')
        ,p_epe_attribute27              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute27')
        ,p_epe_attribute28              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute28')
        ,p_epe_attribute29              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute29')
        ,p_epe_attribute30              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EpeAttribute30')
        ,p_cryfwd_elig_dpnt_cd          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'CryfwdEligDpntCd')
        ,p_request_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'RequestId')
        ,p_program_application_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProgramApplicationId')
        ,p_program_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProgramId')
        ,p_program_update_date          =>       hr_transaction_swi.getDateValue(l_CommitNode,'ProgramUpdateDate')
        ,p_object_version_number        =>       l_object_version_number
        ,p_effective_date               =>       p_effective_date
        ,p_approval_status_cd           =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ApprovalStatusCd')
        ,p_return_status                =>       l_return_status
        );
     --
     --
   end if;
   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,40);

end process_api;

end ben_elig_per_elc_chc_swi;

/
