--------------------------------------------------------
--  DDL for Package Body BEN_ENROLLMENT_RATE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLLMENT_RATE_SWI" As
/* $Header: beecrswi.pkb 120.3 2006/01/06 05:18:18 narvenka noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ben_enrollment_rate_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrollment_rate >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                      out nocopy number
  ,p_ordr_num			  in     number    default null
  ,p_acty_typ_cd                  in     varchar2  default null
  ,p_tx_typ_cd                    in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default null
  ,p_dsply_on_enrt_flag           in     varchar2  default null
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default null
  ,p_entr_val_at_enrt_flag        in     varchar2  default null
  ,p_asn_on_enrt_flag             in     varchar2  default null
  ,p_rl_crs_only_flag             in     varchar2  default null
  ,p_dflt_val                     in     number    default null
  ,p_ann_val                      in     number    default null
  ,p_ann_mn_elcn_val              in     number    default null
  ,p_ann_mx_elcn_val              in     number    default null
  ,p_val                          in     number    default null
  ,p_nnmntry_uom                  in     varchar2  default null
  ,p_mx_elcn_val                  in     number    default null
  ,p_mn_elcn_val                  in     number    default null
  ,p_incrmt_elcn_val              in     number    default null
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default null
  ,p_cmcd_mn_elcn_val             in     number    default null
  ,p_cmcd_mx_elcn_val             in     number    default null
  ,p_cmcd_val                     in     number    default null
  ,p_cmcd_dflt_val                in     number    default null
  ,p_rt_usg_cd                    in     varchar2  default null
  ,p_ann_dflt_val                 in     number    default null
  ,p_bnft_rt_typ_cd               in     varchar2  default null
  ,p_rt_mlt_cd                    in     varchar2  default null
  ,p_dsply_mn_elcn_val            in     number    default null
  ,p_dsply_mx_elcn_val            in     number    default null
  ,p_entr_ann_val_flag            in     varchar2  default null
  ,p_rt_strt_dt                   in     date      default null
  ,p_rt_strt_dt_cd                in     varchar2  default null
  ,p_rt_strt_dt_rl                in     number    default null
  ,p_rt_typ_cd                    in     varchar2  default null
  ,p_elig_per_elctbl_chc_id       in     number    default null
  ,p_acty_base_rt_id              in     number    default null
  ,p_spcl_rt_enrt_rt_id           in     number    default null
  ,p_enrt_bnft_id                 in     number    default null
  ,p_prtt_rt_val_id               in     number    default null
  ,p_decr_bnft_prvdr_pool_id      in     number    default null
  ,p_cvg_amt_calc_mthd_id         in     number    default null
  ,p_actl_prem_id                 in     number    default null
  ,p_comp_lvl_fctr_id             in     number    default null
  ,p_ptd_comp_lvl_fctr_id         in     number    default null
  ,p_clm_comp_lvl_fctr_id         in     number    default null
  ,p_business_group_id            in     number
  ,p_perf_min_max_edit            in     varchar2  default null
  ,p_iss_val                      in     number    default null
  ,p_val_last_upd_date            in     date      default null
  ,p_val_last_upd_person_id       in     number    default null
  ,p_pp_in_yr_used_num            in     number    default null
  ,p_ecr_attribute_category       in     varchar2  default null
  ,p_ecr_attribute1               in     varchar2  default null
  ,p_ecr_attribute2               in     varchar2  default null
  ,p_ecr_attribute3               in     varchar2  default null
  ,p_ecr_attribute4               in     varchar2  default null
  ,p_ecr_attribute5               in     varchar2  default null
  ,p_ecr_attribute6               in     varchar2  default null
  ,p_ecr_attribute7               in     varchar2  default null
  ,p_ecr_attribute8               in     varchar2  default null
  ,p_ecr_attribute9               in     varchar2  default null
  ,p_ecr_attribute10              in     varchar2  default null
  ,p_ecr_attribute11              in     varchar2  default null
  ,p_ecr_attribute12              in     varchar2  default null
  ,p_ecr_attribute13              in     varchar2  default null
  ,p_ecr_attribute14              in     varchar2  default null
  ,p_ecr_attribute15              in     varchar2  default null
  ,p_ecr_attribute16              in     varchar2  default null
  ,p_ecr_attribute17              in     varchar2  default null
  ,p_ecr_attribute18              in     varchar2  default null
  ,p_ecr_attribute19              in     varchar2  default null
  ,p_ecr_attribute20              in     varchar2  default null
  ,p_ecr_attribute21              in     varchar2  default null
  ,p_ecr_attribute22              in     varchar2  default null
  ,p_ecr_attribute23              in     varchar2  default null
  ,p_ecr_attribute24              in     varchar2  default null
  ,p_ecr_attribute25              in     varchar2  default null
  ,p_ecr_attribute26              in     varchar2  default null
  ,p_ecr_attribute27              in     varchar2  default null
  ,p_ecr_attribute28              in     varchar2  default null
  ,p_ecr_attribute29              in     varchar2  default null
  ,p_ecr_attribute30              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_enrollment_rate';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_enrollment_rate_swi;
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
  ben_enrollment_rate_api.create_enrollment_rate
    (p_validate                     => l_validate
    ,p_enrt_rt_id                   => p_enrt_rt_id
    ,p_ordr_num                     => p_ordr_num
    ,p_acty_typ_cd                  => p_acty_typ_cd
    ,p_tx_typ_cd                    => p_tx_typ_cd
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_dflt_pndg_ctfn_flag          => p_dflt_pndg_ctfn_flag
    ,p_dsply_on_enrt_flag           => p_dsply_on_enrt_flag
    ,p_use_to_calc_net_flx_cr_flag  => p_use_to_calc_net_flx_cr_flag
    ,p_entr_val_at_enrt_flag        => p_entr_val_at_enrt_flag
    ,p_asn_on_enrt_flag             => p_asn_on_enrt_flag
    ,p_rl_crs_only_flag             => p_rl_crs_only_flag
    ,p_dflt_val                     => p_dflt_val
    ,p_ann_val                      => p_ann_val
    ,p_ann_mn_elcn_val              => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val              => p_ann_mx_elcn_val
    ,p_val                          => p_val
    ,p_nnmntry_uom                  => p_nnmntry_uom
    ,p_mx_elcn_val                  => p_mx_elcn_val
    ,p_mn_elcn_val                  => p_mn_elcn_val
    ,p_incrmt_elcn_val              => p_incrmt_elcn_val
    ,p_cmcd_acty_ref_perd_cd        => p_cmcd_acty_ref_perd_cd
    ,p_cmcd_mn_elcn_val             => p_cmcd_mn_elcn_val
    ,p_cmcd_mx_elcn_val             => p_cmcd_mx_elcn_val
    ,p_cmcd_val                     => p_cmcd_val
    ,p_cmcd_dflt_val                => p_cmcd_dflt_val
    ,p_rt_usg_cd                    => p_rt_usg_cd
    ,p_ann_dflt_val                 => p_ann_dflt_val
    ,p_bnft_rt_typ_cd               => p_bnft_rt_typ_cd
    ,p_rt_mlt_cd                    => p_rt_mlt_cd
    ,p_dsply_mn_elcn_val            => p_dsply_mn_elcn_val
    ,p_dsply_mx_elcn_val            => p_dsply_mx_elcn_val
    ,p_entr_ann_val_flag            => p_entr_ann_val_flag
    ,p_rt_strt_dt                   => p_rt_strt_dt
    ,p_rt_strt_dt_cd                => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                => p_rt_strt_dt_rl
    ,p_rt_typ_cd                    => p_rt_typ_cd
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_acty_base_rt_id              => p_acty_base_rt_id
    ,p_spcl_rt_enrt_rt_id           => p_spcl_rt_enrt_rt_id
    ,p_enrt_bnft_id                 => p_enrt_bnft_id
    ,p_prtt_rt_val_id               => p_prtt_rt_val_id
    ,p_decr_bnft_prvdr_pool_id      => p_decr_bnft_prvdr_pool_id
    ,p_cvg_amt_calc_mthd_id         => p_cvg_amt_calc_mthd_id
    ,p_actl_prem_id                 => p_actl_prem_id
    ,p_comp_lvl_fctr_id             => p_comp_lvl_fctr_id
    ,p_ptd_comp_lvl_fctr_id         => p_ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id         => p_clm_comp_lvl_fctr_id
    ,p_business_group_id            => p_business_group_id
    ,p_perf_min_max_edit            => p_perf_min_max_edit
    ,p_iss_val                      => p_iss_val
    ,p_val_last_upd_date            => p_val_last_upd_date
    ,p_val_last_upd_person_id       => p_val_last_upd_person_id
    ,p_pp_in_yr_used_num            => p_pp_in_yr_used_num
    ,p_ecr_attribute_category       => p_ecr_attribute_category
    ,p_ecr_attribute1               => p_ecr_attribute1
    ,p_ecr_attribute2               => p_ecr_attribute2
    ,p_ecr_attribute3               => p_ecr_attribute3
    ,p_ecr_attribute4               => p_ecr_attribute4
    ,p_ecr_attribute5               => p_ecr_attribute5
    ,p_ecr_attribute6               => p_ecr_attribute6
    ,p_ecr_attribute7               => p_ecr_attribute7
    ,p_ecr_attribute8               => p_ecr_attribute8
    ,p_ecr_attribute9               => p_ecr_attribute9
    ,p_ecr_attribute10              => p_ecr_attribute10
    ,p_ecr_attribute11              => p_ecr_attribute11
    ,p_ecr_attribute12              => p_ecr_attribute12
    ,p_ecr_attribute13              => p_ecr_attribute13
    ,p_ecr_attribute14              => p_ecr_attribute14
    ,p_ecr_attribute15              => p_ecr_attribute15
    ,p_ecr_attribute16              => p_ecr_attribute16
    ,p_ecr_attribute17              => p_ecr_attribute17
    ,p_ecr_attribute18              => p_ecr_attribute18
    ,p_ecr_attribute19              => p_ecr_attribute19
    ,p_ecr_attribute20              => p_ecr_attribute20
    ,p_ecr_attribute21              => p_ecr_attribute21
    ,p_ecr_attribute22              => p_ecr_attribute22
    ,p_ecr_attribute23              => p_ecr_attribute23
    ,p_ecr_attribute24              => p_ecr_attribute24
    ,p_ecr_attribute25              => p_ecr_attribute25
    ,p_ecr_attribute26              => p_ecr_attribute26
    ,p_ecr_attribute27              => p_ecr_attribute27
    ,p_ecr_attribute28              => p_ecr_attribute28
    ,p_ecr_attribute29              => p_ecr_attribute29
    ,p_ecr_attribute30              => p_ecr_attribute30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to create_enrollment_rate_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_enrt_rt_id                   := null;
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
    rollback to create_enrollment_rate_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_enrt_rt_id                   := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_enrollment_rate;
-- ----------------------------------------------------------------------------
-- |----------------------< create_perf_enrollment_rate >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_perf_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                      out nocopy number
  ,p_ordr_num			  in     number    default null
  ,p_acty_typ_cd                  in     varchar2  default null
  ,p_tx_typ_cd                    in     varchar2  default null
  ,p_ctfn_rqd_flag                in     varchar2  default null
  ,p_dflt_flag                    in     varchar2  default null
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default null
  ,p_dsply_on_enrt_flag           in     varchar2  default null
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default null
  ,p_entr_val_at_enrt_flag        in     varchar2  default null
  ,p_asn_on_enrt_flag             in     varchar2  default null
  ,p_rl_crs_only_flag             in     varchar2  default null
  ,p_dflt_val                     in     number    default null
  ,p_ann_val                      in     number    default null
  ,p_ann_mn_elcn_val              in     number    default null
  ,p_ann_mx_elcn_val              in     number    default null
  ,p_val                          in     number    default null
  ,p_nnmntry_uom                  in     varchar2  default null
  ,p_mx_elcn_val                  in     number    default null
  ,p_mn_elcn_val                  in     number    default null
  ,p_incrmt_elcn_val              in     number    default null
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default null
  ,p_cmcd_mn_elcn_val             in     number    default null
  ,p_cmcd_mx_elcn_val             in     number    default null
  ,p_cmcd_val                     in     number    default null
  ,p_cmcd_dflt_val                in     number    default null
  ,p_rt_usg_cd                    in     varchar2  default null
  ,p_ann_dflt_val                 in     number    default null
  ,p_bnft_rt_typ_cd               in     varchar2  default null
  ,p_rt_mlt_cd                    in     varchar2  default null
  ,p_dsply_mn_elcn_val            in     number    default null
  ,p_dsply_mx_elcn_val            in     number    default null
  ,p_entr_ann_val_flag            in     varchar2
  ,p_rt_strt_dt                   in     date      default null
  ,p_rt_strt_dt_cd                in     varchar2  default null
  ,p_rt_strt_dt_rl                in     number    default null
  ,p_rt_typ_cd                    in     varchar2  default null
  ,p_elig_per_elctbl_chc_id       in     number    default null
  ,p_acty_base_rt_id              in     number    default null
  ,p_spcl_rt_enrt_rt_id           in     number    default null
  ,p_enrt_bnft_id                 in     number    default null
  ,p_prtt_rt_val_id               in     number    default null
  ,p_decr_bnft_prvdr_pool_id      in     number    default null
  ,p_cvg_amt_calc_mthd_id         in     number    default null
  ,p_actl_prem_id                 in     number    default null
  ,p_comp_lvl_fctr_id             in     number    default null
  ,p_ptd_comp_lvl_fctr_id         in     number    default null
  ,p_clm_comp_lvl_fctr_id         in     number    default null
  ,p_business_group_id            in     number
  ,p_perf_min_max_edit            in     varchar2  default null
  ,p_iss_val                      in     number    default null
  ,p_val_last_upd_date            in     date      default null
  ,p_val_last_upd_person_id       in     number    default null
  ,p_pp_in_yr_used_num            in     number    default null
  ,p_ecr_attribute_category       in     varchar2  default null
  ,p_ecr_attribute1               in     varchar2  default null
  ,p_ecr_attribute2               in     varchar2  default null
  ,p_ecr_attribute3               in     varchar2  default null
  ,p_ecr_attribute4               in     varchar2  default null
  ,p_ecr_attribute5               in     varchar2  default null
  ,p_ecr_attribute6               in     varchar2  default null
  ,p_ecr_attribute7               in     varchar2  default null
  ,p_ecr_attribute8               in     varchar2  default null
  ,p_ecr_attribute9               in     varchar2  default null
  ,p_ecr_attribute10              in     varchar2  default null
  ,p_ecr_attribute11              in     varchar2  default null
  ,p_ecr_attribute12              in     varchar2  default null
  ,p_ecr_attribute13              in     varchar2  default null
  ,p_ecr_attribute14              in     varchar2  default null
  ,p_ecr_attribute15              in     varchar2  default null
  ,p_ecr_attribute16              in     varchar2  default null
  ,p_ecr_attribute17              in     varchar2  default null
  ,p_ecr_attribute18              in     varchar2  default null
  ,p_ecr_attribute19              in     varchar2  default null
  ,p_ecr_attribute20              in     varchar2  default null
  ,p_ecr_attribute21              in     varchar2  default null
  ,p_ecr_attribute22              in     varchar2  default null
  ,p_ecr_attribute23              in     varchar2  default null
  ,p_ecr_attribute24              in     varchar2  default null
  ,p_ecr_attribute25              in     varchar2  default null
  ,p_ecr_attribute26              in     varchar2  default null
  ,p_ecr_attribute27              in     varchar2  default null
  ,p_ecr_attribute28              in     varchar2  default null
  ,p_ecr_attribute29              in     varchar2  default null
  ,p_ecr_attribute30              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_perf_enrollment_rate';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint creat_perf_enrollment_rate_swi;
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
  ben_enrollment_rate_api.create_perf_enrollment_rate
    (p_validate                     => l_validate
    ,p_enrt_rt_id                   => p_enrt_rt_id
    ,p_ordr_num                     => p_ordr_num
    ,p_acty_typ_cd                  => p_acty_typ_cd
    ,p_tx_typ_cd                    => p_tx_typ_cd
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_dflt_pndg_ctfn_flag          => p_dflt_pndg_ctfn_flag
    ,p_dsply_on_enrt_flag           => p_dsply_on_enrt_flag
    ,p_use_to_calc_net_flx_cr_flag  => p_use_to_calc_net_flx_cr_flag
    ,p_entr_val_at_enrt_flag        => p_entr_val_at_enrt_flag
    ,p_asn_on_enrt_flag             => p_asn_on_enrt_flag
    ,p_rl_crs_only_flag             => p_rl_crs_only_flag
    ,p_dflt_val                     => p_dflt_val
    ,p_ann_val                      => p_ann_val
    ,p_ann_mn_elcn_val              => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val              => p_ann_mx_elcn_val
    ,p_val                          => p_val
    ,p_nnmntry_uom                  => p_nnmntry_uom
    ,p_mx_elcn_val                  => p_mx_elcn_val
    ,p_mn_elcn_val                  => p_mn_elcn_val
    ,p_incrmt_elcn_val              => p_incrmt_elcn_val
    ,p_cmcd_acty_ref_perd_cd        => p_cmcd_acty_ref_perd_cd
    ,p_cmcd_mn_elcn_val             => p_cmcd_mn_elcn_val
    ,p_cmcd_mx_elcn_val             => p_cmcd_mx_elcn_val
    ,p_cmcd_val                     => p_cmcd_val
    ,p_cmcd_dflt_val                => p_cmcd_dflt_val
    ,p_rt_usg_cd                    => p_rt_usg_cd
    ,p_ann_dflt_val                 => p_ann_dflt_val
    ,p_bnft_rt_typ_cd               => p_bnft_rt_typ_cd
    ,p_rt_mlt_cd                    => p_rt_mlt_cd
    ,p_dsply_mn_elcn_val            => p_dsply_mn_elcn_val
    ,p_dsply_mx_elcn_val            => p_dsply_mx_elcn_val
    ,p_entr_ann_val_flag            => p_entr_ann_val_flag
    ,p_rt_strt_dt                   => p_rt_strt_dt
    ,p_rt_strt_dt_cd                => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                => p_rt_strt_dt_rl
    ,p_rt_typ_cd                    => p_rt_typ_cd
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_acty_base_rt_id              => p_acty_base_rt_id
    ,p_spcl_rt_enrt_rt_id           => p_spcl_rt_enrt_rt_id
    ,p_enrt_bnft_id                 => p_enrt_bnft_id
    ,p_prtt_rt_val_id               => p_prtt_rt_val_id
    ,p_decr_bnft_prvdr_pool_id      => p_decr_bnft_prvdr_pool_id
    ,p_cvg_amt_calc_mthd_id         => p_cvg_amt_calc_mthd_id
    ,p_actl_prem_id                 => p_actl_prem_id
    ,p_comp_lvl_fctr_id             => p_comp_lvl_fctr_id
    ,p_ptd_comp_lvl_fctr_id         => p_ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id         => p_clm_comp_lvl_fctr_id
    ,p_business_group_id            => p_business_group_id
    ,p_perf_min_max_edit            => p_perf_min_max_edit
    ,p_iss_val                      => p_iss_val
    ,p_val_last_upd_date            => p_val_last_upd_date
    ,p_val_last_upd_person_id       => p_val_last_upd_person_id
    ,p_pp_in_yr_used_num            => p_pp_in_yr_used_num
    ,p_ecr_attribute_category       => p_ecr_attribute_category
    ,p_ecr_attribute1               => p_ecr_attribute1
    ,p_ecr_attribute2               => p_ecr_attribute2
    ,p_ecr_attribute3               => p_ecr_attribute3
    ,p_ecr_attribute4               => p_ecr_attribute4
    ,p_ecr_attribute5               => p_ecr_attribute5
    ,p_ecr_attribute6               => p_ecr_attribute6
    ,p_ecr_attribute7               => p_ecr_attribute7
    ,p_ecr_attribute8               => p_ecr_attribute8
    ,p_ecr_attribute9               => p_ecr_attribute9
    ,p_ecr_attribute10              => p_ecr_attribute10
    ,p_ecr_attribute11              => p_ecr_attribute11
    ,p_ecr_attribute12              => p_ecr_attribute12
    ,p_ecr_attribute13              => p_ecr_attribute13
    ,p_ecr_attribute14              => p_ecr_attribute14
    ,p_ecr_attribute15              => p_ecr_attribute15
    ,p_ecr_attribute16              => p_ecr_attribute16
    ,p_ecr_attribute17              => p_ecr_attribute17
    ,p_ecr_attribute18              => p_ecr_attribute18
    ,p_ecr_attribute19              => p_ecr_attribute19
    ,p_ecr_attribute20              => p_ecr_attribute20
    ,p_ecr_attribute21              => p_ecr_attribute21
    ,p_ecr_attribute22              => p_ecr_attribute22
    ,p_ecr_attribute23              => p_ecr_attribute23
    ,p_ecr_attribute24              => p_ecr_attribute24
    ,p_ecr_attribute25              => p_ecr_attribute25
    ,p_ecr_attribute26              => p_ecr_attribute26
    ,p_ecr_attribute27              => p_ecr_attribute27
    ,p_ecr_attribute28              => p_ecr_attribute28
    ,p_ecr_attribute29              => p_ecr_attribute29
    ,p_ecr_attribute30              => p_ecr_attribute30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to creat_perf_enrollment_rate_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_enrt_rt_id                   := null;
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
    rollback to creat_perf_enrollment_rate_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_enrt_rt_id                   := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_perf_enrollment_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrollment_rate >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                   in     number
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
  l_proc    varchar2(72) := g_package ||'delete_enrollment_rate';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_enrollment_rate_swi;
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
  ben_enrollment_rate_api.delete_enrollment_rate
    (p_validate                     => l_validate
    ,p_enrt_rt_id                   => p_enrt_rt_id
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
    rollback to delete_enrollment_rate_swi;
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
    rollback to delete_enrollment_rate_swi;
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
end delete_enrollment_rate;
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_enrt_rt_id                   in     number
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
  ben_enrollment_rate_api.lck
    (p_enrt_rt_id                   => p_enrt_rt_id
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
-- |-----------------------< override_enrollment_rate >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE override_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_id                    in     number
  ,p_enrt_rt_id                   in     number
  ,p_ordr_num	                  in     number    default hr_api.g_number
  ,p_acty_typ_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag           in     varchar2  default hr_api.g_varchar2
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default hr_api.g_varchar2
  ,p_entr_val_at_enrt_flag        in     varchar2  default hr_api.g_varchar2
  ,p_asn_on_enrt_flag             in     varchar2  default hr_api.g_varchar2
  ,p_rl_crs_only_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_val                     in     number    default hr_api.g_number
  ,p_old_ann_val                  in     number    default hr_api.g_number
  ,p_ann_val                      in     number    default hr_api.g_number
  ,p_ann_mn_elcn_val              in     number    default hr_api.g_number
  ,p_ann_mx_elcn_val              in     number    default hr_api.g_number
  ,p_old_val                      in     number    default hr_api.g_number
  ,p_val                          in     number    default hr_api.g_number
  ,p_nnmntry_uom                  in     varchar2  default hr_api.g_varchar2
  ,p_mx_elcn_val                  in     number    default hr_api.g_number
  ,p_mn_elcn_val                  in     number    default hr_api.g_number
  ,p_incrmt_elcn_val              in     number    default hr_api.g_number
  ,p_acty_ref_perd_cd             in     varchar2  default hr_api.g_varchar2
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default hr_api.g_varchar2
  ,p_cmcd_mn_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_mx_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_val                     in     number    default hr_api.g_number
  ,p_cmcd_dflt_val                in     number    default hr_api.g_number
  ,p_rt_usg_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ann_dflt_val                 in     number    default hr_api.g_number
  ,p_bnft_rt_typ_cd               in     varchar2  default hr_api.g_varchar2
  ,p_rt_mlt_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_dsply_mn_elcn_val            in     number    default hr_api.g_number
  ,p_dsply_mx_elcn_val            in     number    default hr_api.g_number
  ,p_entr_ann_val_flag            in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt                   in     date      default hr_api.g_date
  ,p_rt_strt_dt_cd                in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                in     number    default hr_api.g_number
  ,p_rt_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id       in     number    default hr_api.g_number
  ,p_acty_base_rt_id              in     number    default hr_api.g_number
  ,p_spcl_rt_enrt_rt_id           in     number    default hr_api.g_number
  ,p_enrt_bnft_id                 in     number    default hr_api.g_number
  ,p_prtt_rt_val_id               in     number    default hr_api.g_number
  ,p_decr_bnft_prvdr_pool_id      in     number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id         in     number    default hr_api.g_number
  ,p_actl_prem_id                 in     number    default hr_api.g_number
  ,p_comp_lvl_fctr_id             in     number    default hr_api.g_number
  ,p_ptd_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_clm_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_perf_min_max_edit            in     varchar2  default hr_api.g_varchar2
  ,p_iss_val                      in     number    default hr_api.g_number
  ,p_val_last_upd_date            in     date      default hr_api.g_date
  ,p_val_last_upd_person_id       in     number    default hr_api.g_number
  ,p_pp_in_yr_used_num            in     number    default hr_api.g_number
  ,p_ecr_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
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
  l_proc    varchar2(72) := g_package ||'override_enrollment_rate';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint override_enrollment_rate_swi;
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
  ben_enrollment_rate_api.override_enrollment_rate
    (p_validate                     => l_validate
    ,p_person_id                    => p_person_id
    ,p_enrt_rt_id                   => p_enrt_rt_id
    ,p_ordr_num                     => p_ordr_num
    ,p_acty_typ_cd                  => p_acty_typ_cd
    ,p_tx_typ_cd                    => p_tx_typ_cd
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_dflt_pndg_ctfn_flag          => p_dflt_pndg_ctfn_flag
    ,p_dsply_on_enrt_flag           => p_dsply_on_enrt_flag
    ,p_use_to_calc_net_flx_cr_flag  => p_use_to_calc_net_flx_cr_flag
    ,p_entr_val_at_enrt_flag        => p_entr_val_at_enrt_flag
    ,p_asn_on_enrt_flag             => p_asn_on_enrt_flag
    ,p_rl_crs_only_flag             => p_rl_crs_only_flag
    ,p_dflt_val                     => p_dflt_val
    ,p_old_ann_val                  => p_old_ann_val
    ,p_ann_val                      => p_ann_val
    ,p_ann_mn_elcn_val              => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val              => p_ann_mx_elcn_val
    ,p_old_val                      => p_old_val
    ,p_val                          => p_val
    ,p_nnmntry_uom                  => p_nnmntry_uom
    ,p_mx_elcn_val                  => p_mx_elcn_val
    ,p_mn_elcn_val                  => p_mn_elcn_val
    ,p_incrmt_elcn_val              => p_incrmt_elcn_val
    ,p_acty_ref_perd_cd             => p_acty_ref_perd_cd
    ,p_cmcd_acty_ref_perd_cd        => p_cmcd_acty_ref_perd_cd
    ,p_cmcd_mn_elcn_val             => p_cmcd_mn_elcn_val
    ,p_cmcd_mx_elcn_val             => p_cmcd_mx_elcn_val
    ,p_cmcd_val                     => p_cmcd_val
    ,p_cmcd_dflt_val                => p_cmcd_dflt_val
    ,p_rt_usg_cd                    => p_rt_usg_cd
    ,p_ann_dflt_val                 => p_ann_dflt_val
    ,p_bnft_rt_typ_cd               => p_bnft_rt_typ_cd
    ,p_rt_mlt_cd                    => p_rt_mlt_cd
    ,p_dsply_mn_elcn_val            => p_dsply_mn_elcn_val
    ,p_dsply_mx_elcn_val            => p_dsply_mx_elcn_val
    ,p_entr_ann_val_flag            => p_entr_ann_val_flag
    ,p_rt_strt_dt                   => p_rt_strt_dt
    ,p_rt_strt_dt_cd                => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                => p_rt_strt_dt_rl
    ,p_rt_typ_cd                    => p_rt_typ_cd
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_acty_base_rt_id              => p_acty_base_rt_id
    ,p_spcl_rt_enrt_rt_id           => p_spcl_rt_enrt_rt_id
    ,p_enrt_bnft_id                 => p_enrt_bnft_id
    ,p_prtt_rt_val_id               => p_prtt_rt_val_id
    ,p_decr_bnft_prvdr_pool_id      => p_decr_bnft_prvdr_pool_id
    ,p_cvg_amt_calc_mthd_id         => p_cvg_amt_calc_mthd_id
    ,p_actl_prem_id                 => p_actl_prem_id
    ,p_comp_lvl_fctr_id             => p_comp_lvl_fctr_id
    ,p_ptd_comp_lvl_fctr_id         => p_ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id         => p_clm_comp_lvl_fctr_id
    ,p_business_group_id            => p_business_group_id
    ,p_perf_min_max_edit            => p_perf_min_max_edit
    ,p_iss_val                      => p_iss_val
    ,p_val_last_upd_date            => p_val_last_upd_date
    ,p_val_last_upd_person_id       => p_val_last_upd_person_id
    ,p_pp_in_yr_used_num            => p_pp_in_yr_used_num
    ,p_ecr_attribute_category       => p_ecr_attribute_category
    ,p_ecr_attribute1               => p_ecr_attribute1
    ,p_ecr_attribute2               => p_ecr_attribute2
    ,p_ecr_attribute3               => p_ecr_attribute3
    ,p_ecr_attribute4               => p_ecr_attribute4
    ,p_ecr_attribute5               => p_ecr_attribute5
    ,p_ecr_attribute6               => p_ecr_attribute6
    ,p_ecr_attribute7               => p_ecr_attribute7
    ,p_ecr_attribute8               => p_ecr_attribute8
    ,p_ecr_attribute9               => p_ecr_attribute9
    ,p_ecr_attribute10              => p_ecr_attribute10
    ,p_ecr_attribute11              => p_ecr_attribute11
    ,p_ecr_attribute12              => p_ecr_attribute12
    ,p_ecr_attribute13              => p_ecr_attribute13
    ,p_ecr_attribute14              => p_ecr_attribute14
    ,p_ecr_attribute15              => p_ecr_attribute15
    ,p_ecr_attribute16              => p_ecr_attribute16
    ,p_ecr_attribute17              => p_ecr_attribute17
    ,p_ecr_attribute18              => p_ecr_attribute18
    ,p_ecr_attribute19              => p_ecr_attribute19
    ,p_ecr_attribute20              => p_ecr_attribute20
    ,p_ecr_attribute21              => p_ecr_attribute21
    ,p_ecr_attribute22              => p_ecr_attribute22
    ,p_ecr_attribute23              => p_ecr_attribute23
    ,p_ecr_attribute24              => p_ecr_attribute24
    ,p_ecr_attribute25              => p_ecr_attribute25
    ,p_ecr_attribute26              => p_ecr_attribute26
    ,p_ecr_attribute27              => p_ecr_attribute27
    ,p_ecr_attribute28              => p_ecr_attribute28
    ,p_ecr_attribute29              => p_ecr_attribute29
    ,p_ecr_attribute30              => p_ecr_attribute30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to override_enrollment_rate_swi;
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
    rollback to override_enrollment_rate_swi;
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
end override_enrollment_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< update_enrollment_rate >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_enrollment_rate
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrt_rt_id                   in     number
  ,p_ordr_num			  in     number    default hr_api.g_number
  ,p_acty_typ_cd                  in     varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                in     varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                    in     varchar2  default hr_api.g_varchar2
  ,p_dflt_pndg_ctfn_flag          in     varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag           in     varchar2  default hr_api.g_varchar2
  ,p_use_to_calc_net_flx_cr_flag  in     varchar2  default hr_api.g_varchar2
  ,p_entr_val_at_enrt_flag        in     varchar2  default hr_api.g_varchar2
  ,p_asn_on_enrt_flag             in     varchar2  default hr_api.g_varchar2
  ,p_rl_crs_only_flag             in     varchar2  default hr_api.g_varchar2
  ,p_dflt_val                     in     number    default hr_api.g_number
  ,p_ann_val                      in     number    default hr_api.g_number
  ,p_ann_mn_elcn_val              in     number    default hr_api.g_number
  ,p_ann_mx_elcn_val              in     number    default hr_api.g_number
  ,p_val                          in     number    default hr_api.g_number
  ,p_nnmntry_uom                  in     varchar2  default hr_api.g_varchar2
  ,p_mx_elcn_val                  in     number    default hr_api.g_number
  ,p_mn_elcn_val                  in     number    default hr_api.g_number
  ,p_incrmt_elcn_val              in     number    default hr_api.g_number
  ,p_cmcd_acty_ref_perd_cd        in     varchar2  default hr_api.g_varchar2
  ,p_cmcd_mn_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_mx_elcn_val             in     number    default hr_api.g_number
  ,p_cmcd_val                     in     number    default hr_api.g_number
  ,p_cmcd_dflt_val                in     number    default hr_api.g_number
  ,p_rt_usg_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_ann_dflt_val                 in     number    default hr_api.g_number
  ,p_bnft_rt_typ_cd               in     varchar2  default hr_api.g_varchar2
  ,p_rt_mlt_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_dsply_mn_elcn_val            in     number    default hr_api.g_number
  ,p_dsply_mx_elcn_val            in     number    default hr_api.g_number
  ,p_entr_ann_val_flag            in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt                   in     date      default hr_api.g_date
  ,p_rt_strt_dt_cd                in     varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                in     number    default hr_api.g_number
  ,p_rt_typ_cd                    in     varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id       in     number    default hr_api.g_number
  ,p_acty_base_rt_id              in     number    default hr_api.g_number
  ,p_spcl_rt_enrt_rt_id           in     number    default hr_api.g_number
  ,p_enrt_bnft_id                 in     number    default hr_api.g_number
  ,p_prtt_rt_val_id               in     number    default hr_api.g_number
  ,p_decr_bnft_prvdr_pool_id      in     number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id         in     number    default hr_api.g_number
  ,p_actl_prem_id                 in     number    default hr_api.g_number
  ,p_comp_lvl_fctr_id             in     number    default hr_api.g_number
  ,p_ptd_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_clm_comp_lvl_fctr_id         in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_perf_min_max_edit            in     varchar2  default hr_api.g_varchar2
  ,p_iss_val                      in     number    default hr_api.g_number
  ,p_val_last_upd_date            in     date      default hr_api.g_date
  ,p_val_last_upd_person_id       in     number    default hr_api.g_number
  ,p_pp_in_yr_used_num            in     number    default hr_api.g_number
  ,p_ecr_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ecr_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
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
  l_proc    varchar2(72) := g_package ||'update_enrollment_rate';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_enrollment_rate_swi;
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
  ben_enrollment_rate_api.update_enrollment_rate
    (p_validate                     => l_validate
    ,p_enrt_rt_id                   => p_enrt_rt_id
    ,p_ordr_num                     => p_ordr_num
    ,p_acty_typ_cd                  => p_acty_typ_cd
    ,p_tx_typ_cd                    => p_tx_typ_cd
    ,p_ctfn_rqd_flag                => p_ctfn_rqd_flag
    ,p_dflt_flag                    => p_dflt_flag
    ,p_dflt_pndg_ctfn_flag          => p_dflt_pndg_ctfn_flag
    ,p_dsply_on_enrt_flag           => p_dsply_on_enrt_flag
    ,p_use_to_calc_net_flx_cr_flag  => p_use_to_calc_net_flx_cr_flag
    ,p_entr_val_at_enrt_flag        => p_entr_val_at_enrt_flag
    ,p_asn_on_enrt_flag             => p_asn_on_enrt_flag
    ,p_rl_crs_only_flag             => p_rl_crs_only_flag
    ,p_dflt_val                     => p_dflt_val
    ,p_ann_val                      => p_ann_val
    ,p_ann_mn_elcn_val              => p_ann_mn_elcn_val
    ,p_ann_mx_elcn_val              => p_ann_mx_elcn_val
    ,p_val                          => p_val
    ,p_nnmntry_uom                  => p_nnmntry_uom
    ,p_mx_elcn_val                  => p_mx_elcn_val
    ,p_mn_elcn_val                  => p_mn_elcn_val
    ,p_incrmt_elcn_val              => p_incrmt_elcn_val
    ,p_cmcd_acty_ref_perd_cd        => p_cmcd_acty_ref_perd_cd
    ,p_cmcd_mn_elcn_val             => p_cmcd_mn_elcn_val
    ,p_cmcd_mx_elcn_val             => p_cmcd_mx_elcn_val
    ,p_cmcd_val                     => p_cmcd_val
    ,p_cmcd_dflt_val                => p_cmcd_dflt_val
    ,p_rt_usg_cd                    => p_rt_usg_cd
    ,p_ann_dflt_val                 => p_ann_dflt_val
    ,p_bnft_rt_typ_cd               => p_bnft_rt_typ_cd
    ,p_rt_mlt_cd                    => p_rt_mlt_cd
    ,p_dsply_mn_elcn_val            => p_dsply_mn_elcn_val
    ,p_dsply_mx_elcn_val            => p_dsply_mx_elcn_val
    ,p_entr_ann_val_flag            => p_entr_ann_val_flag
    ,p_rt_strt_dt                   => p_rt_strt_dt
    ,p_rt_strt_dt_cd                => p_rt_strt_dt_cd
    ,p_rt_strt_dt_rl                => p_rt_strt_dt_rl
    ,p_rt_typ_cd                    => p_rt_typ_cd
    ,p_elig_per_elctbl_chc_id       => p_elig_per_elctbl_chc_id
    ,p_acty_base_rt_id              => p_acty_base_rt_id
    ,p_spcl_rt_enrt_rt_id           => p_spcl_rt_enrt_rt_id
    ,p_enrt_bnft_id                 => p_enrt_bnft_id
    ,p_prtt_rt_val_id               => p_prtt_rt_val_id
    ,p_decr_bnft_prvdr_pool_id      => p_decr_bnft_prvdr_pool_id
    ,p_cvg_amt_calc_mthd_id         => p_cvg_amt_calc_mthd_id
    ,p_actl_prem_id                 => p_actl_prem_id
    ,p_comp_lvl_fctr_id             => p_comp_lvl_fctr_id
    ,p_ptd_comp_lvl_fctr_id         => p_ptd_comp_lvl_fctr_id
    ,p_clm_comp_lvl_fctr_id         => p_clm_comp_lvl_fctr_id
    ,p_business_group_id            => p_business_group_id
    ,p_perf_min_max_edit            => p_perf_min_max_edit
    ,p_iss_val                      => p_iss_val
    ,p_val_last_upd_date            => p_val_last_upd_date
    ,p_val_last_upd_person_id       => p_val_last_upd_person_id
    ,p_pp_in_yr_used_num            => p_pp_in_yr_used_num
    ,p_ecr_attribute_category       => p_ecr_attribute_category
    ,p_ecr_attribute1               => p_ecr_attribute1
    ,p_ecr_attribute2               => p_ecr_attribute2
    ,p_ecr_attribute3               => p_ecr_attribute3
    ,p_ecr_attribute4               => p_ecr_attribute4
    ,p_ecr_attribute5               => p_ecr_attribute5
    ,p_ecr_attribute6               => p_ecr_attribute6
    ,p_ecr_attribute7               => p_ecr_attribute7
    ,p_ecr_attribute8               => p_ecr_attribute8
    ,p_ecr_attribute9               => p_ecr_attribute9
    ,p_ecr_attribute10              => p_ecr_attribute10
    ,p_ecr_attribute11              => p_ecr_attribute11
    ,p_ecr_attribute12              => p_ecr_attribute12
    ,p_ecr_attribute13              => p_ecr_attribute13
    ,p_ecr_attribute14              => p_ecr_attribute14
    ,p_ecr_attribute15              => p_ecr_attribute15
    ,p_ecr_attribute16              => p_ecr_attribute16
    ,p_ecr_attribute17              => p_ecr_attribute17
    ,p_ecr_attribute18              => p_ecr_attribute18
    ,p_ecr_attribute19              => p_ecr_attribute19
    ,p_ecr_attribute20              => p_ecr_attribute20
    ,p_ecr_attribute21              => p_ecr_attribute21
    ,p_ecr_attribute22              => p_ecr_attribute22
    ,p_ecr_attribute23              => p_ecr_attribute23
    ,p_ecr_attribute24              => p_ecr_attribute24
    ,p_ecr_attribute25              => p_ecr_attribute25
    ,p_ecr_attribute26              => p_ecr_attribute26
    ,p_ecr_attribute27              => p_ecr_attribute27
    ,p_ecr_attribute28              => p_ecr_attribute28
    ,p_ecr_attribute29              => p_ecr_attribute29
    ,p_ecr_attribute30              => p_ecr_attribute30
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => p_program_update_date
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
    rollback to update_enrollment_rate_swi;
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
    rollback to update_enrollment_rate_swi;
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
end update_enrollment_rate;
-- ----------------------------------------------------------------------------
-- |-----------------------------< process_api >------------------------------|
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
   ben_enrollment_rate_swi.update_enrollment_rate
      (p_validate                     =>       p_validate
      ,p_enrt_rt_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'EnrtRtId')
      ,p_ordr_num                     =>       hr_transaction_swi.getNumberValue(l_CommitNode,'OrdrNum')
      ,p_acty_typ_cd                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ActyTypCd')
      ,p_tx_typ_cd                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'TxTypCd')
      ,p_ctfn_rqd_flag                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'CtfnRqdFlag')
      ,p_dflt_flag                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DfltFlag')
      ,p_dflt_pndg_ctfn_flag          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DfltPndgCtfnFlag')
      ,p_dsply_on_enrt_flag           =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DsplyOnEnrtFlag')
      ,p_use_to_calc_net_flx_cr_flag  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'UseToCalcNetFlxCrFlag')
      ,p_entr_val_at_enrt_flag        =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EntrValAtEnrtFlag')
      ,p_asn_on_enrt_flag             =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AsnOnEnrtFlag')
      ,p_rl_crs_only_flag             =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'RlCrsOnlyFlag')
      ,p_dflt_val                     =>       hr_transaction_swi.getNumberValue(l_CommitNode,'DfltVal')
      ,p_ann_val                      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'AnnVal')
      ,p_ann_mn_elcn_val              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'AnnMnElcnVal')
      ,p_ann_mx_elcn_val              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'AnnMxElcnVal')
      ,p_val                          =>       hr_transaction_swi.getNumberValue(l_CommitNode,'Val')
      ,p_nnmntry_uom                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'NnmntryUom')
      ,p_mx_elcn_val                  =>       hr_transaction_swi.getNumberValue(l_CommitNode,'MxElcnVal')
      ,p_mn_elcn_val                  =>       hr_transaction_swi.getNumberValue(l_CommitNode,'MnElcnVal')
      ,p_incrmt_elcn_val              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'IncrmtElcnVal')
      ,p_cmcd_acty_ref_perd_cd        =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'CmcdActyRefPerdCd')
      ,p_cmcd_mn_elcn_val             =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CmcdMnElcnVal')
      ,p_cmcd_mx_elcn_val             =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CmcdMxElcnVal')
      ,p_cmcd_val                     =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CmcdVal')
      ,p_cmcd_dflt_val                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CmcdDfltVal')
      ,p_rt_usg_cd                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'RtUsgCd')
      ,p_ann_dflt_val                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'AnnDfltVal')
      ,p_bnft_rt_typ_cd               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'BnftRtTypCd')
      ,p_rt_mlt_cd                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'RtMltCd')
      ,p_dsply_mn_elcn_val            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'DsplyMnElcnVal')
      ,p_dsply_mx_elcn_val            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'DsplyMxElcnVal')
      ,p_entr_ann_val_flag            =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EntrAnnValFlag')
      ,p_rt_strt_dt                   =>       hr_transaction_swi.getDateValue(l_CommitNode,'RtStrtDt')
      ,p_rt_strt_dt_cd                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'RtStrtDtCd')
      ,p_rt_strt_dt_rl                =>       hr_transaction_swi.getNumberValue(l_CommitNode,'RtStrtDtRl')
      ,p_rt_typ_cd                    =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'RtTypCd')
      ,p_elig_per_elctbl_chc_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'EligPerElctblChcId')
      ,p_acty_base_rt_id              =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ActyBaseRtId')
      ,p_spcl_rt_enrt_rt_id           =>       hr_transaction_swi.getNumberValue(l_CommitNode,'SpclRtEnrtRtId')
      ,p_enrt_bnft_id                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'EnrtBnftId')
      ,p_prtt_rt_val_id               =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PrttRtValId')
      ,p_decr_bnft_prvdr_pool_id      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'DecrBnftPrvdrPoolId')
      ,p_cvg_amt_calc_mthd_id         =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CvgAmtCalcMthdId')
      ,p_actl_prem_id                 =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ActlPremId')
      ,p_comp_lvl_fctr_id             =>       hr_transaction_swi.getNumberValue(l_CommitNode,'CompLvlFctrId')
      ,p_ptd_comp_lvl_fctr_id         =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PtdCompLvlFctrId')
      ,p_clm_comp_lvl_fctr_id         =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ClmCompLvlFctrId')
      ,p_business_group_id            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId')
      ,p_perf_min_max_edit            =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'PerfMinMaxEdit')
      ,p_iss_val                      =>       hr_transaction_swi.getNumberValue(l_CommitNode,'IssVal')
      ,p_val_last_upd_date            =>       hr_transaction_swi.getDateValue(l_CommitNode,'ValLastUpdDate')
      ,p_val_last_upd_person_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ValLastUpdPersonId')
      ,p_pp_in_yr_used_num            =>       hr_transaction_swi.getNumberValue(l_CommitNode,'PpInYrUsedNum')
      ,p_ecr_attribute_category       =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttributeCategory')
      ,p_ecr_attribute1               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute1')
      ,p_ecr_attribute2               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute2')
      ,p_ecr_attribute3               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute3')
      ,p_ecr_attribute4               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute4')
      ,p_ecr_attribute5               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute5')
      ,p_ecr_attribute6               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute6')
      ,p_ecr_attribute7               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute7')
      ,p_ecr_attribute8               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute8')
      ,p_ecr_attribute9               =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute9')
      ,p_ecr_attribute10              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute10')
      ,p_ecr_attribute11              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute11')
      ,p_ecr_attribute12              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute12')
      ,p_ecr_attribute13              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute13')
      ,p_ecr_attribute14              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute14')
      ,p_ecr_attribute15              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute15')
      ,p_ecr_attribute16              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute16')
      ,p_ecr_attribute17              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute17')
      ,p_ecr_attribute18              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute18')
      ,p_ecr_attribute19              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute19')
      ,p_ecr_attribute20              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute20')
      ,p_ecr_attribute21              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute21')
      ,p_ecr_attribute22              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute22')
      ,p_ecr_attribute23              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute23')
      ,p_ecr_attribute24              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute24')
      ,p_ecr_attribute25              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute25')
      ,p_ecr_attribute26              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute26')
      ,p_ecr_attribute27              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute27')
      ,p_ecr_attribute28              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute28')
      ,p_ecr_attribute29              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute29')
      ,p_ecr_attribute30              =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'EcrAttribute30')
      ,p_request_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'RequestId')
      ,p_program_application_id       =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProgramApplicationId')
      ,p_program_id                   =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ProgramId')
      ,p_program_update_date          =>       hr_transaction_swi.getDateValue(l_CommitNode,'ProgramUpdateDate')
      ,p_object_version_number        =>       l_object_version_number
      ,p_effective_date               =>       p_effective_date
      ,p_return_status                =>       l_return_status
      );
     --
   end if;
   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,40);

end process_api;

end ben_enrollment_rate_swi;

/
