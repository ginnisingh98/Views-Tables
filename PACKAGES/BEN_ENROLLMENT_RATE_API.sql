--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_RATE_API" AUTHID CURRENT_USER as
/* $Header: beecrapi.pkh 120.0 2005/05/28 01:52:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Enrollment_Rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_enrt_rt_id                   Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
g_perf_min_max_edit varchar2(30);
--
procedure create_Enrollment_Rate
(
    p_validate                    in  boolean default false,
	p_enrt_rt_id                  out nocopy NUMBER,
	p_ordr_num			    in  number    default null,
	p_acty_typ_cd                 in  VARCHAR2  DEFAULT NULL,
	p_tx_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT 'N',
	p_dflt_flag                   in  VARCHAR2  DEFAULT 'N',
	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT 'N',
	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT 'N',
	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT 'N',
	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT 'N',
	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT 'N',
	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT 'N',
	p_dflt_val                    in  NUMBER    DEFAULT NULL,
	p_ann_val                     in  NUMBER    DEFAULT NULL,
	p_ann_mn_elcn_val             in  NUMBER    DEFAULT NULL,
	p_ann_mx_elcn_val             in  NUMBER    DEFAULT NULL,
	p_val                         in  NUMBER    DEFAULT NULL,
	p_nnmntry_uom                 in  VARCHAR2  DEFAULT NULL,
	p_mx_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_mn_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_incrmt_elcn_val             in  NUMBER    DEFAULT NULL,
	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT NULL,
	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_val                    in  NUMBER    DEFAULT NULL,
	p_cmcd_dflt_val               in  NUMBER    DEFAULT NULL,
	p_rt_usg_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ann_dflt_val                in  NUMBER    DEFAULT NULL,
	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT NULL,
	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT NULL,
	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT NULL,
	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT NULL,
	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT 'N',
	p_rt_strt_dt                  in  DATE      DEFAULT NULL,
	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT NULL,
	p_rt_strt_dt_rl               in  NUMBER    DEFAULT NULL,
	p_rt_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT NULL,
	p_acty_base_rt_id             in  NUMBER    DEFAULT NULL,
	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT NULL,
	p_enrt_bnft_id                in  NUMBER    DEFAULT NULL,
	p_prtt_rt_val_id              in  NUMBER    DEFAULT NULL,
	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT NULL,
	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT NULL,
	p_actl_prem_id                in  NUMBER    DEFAULT NULL,
	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT NULL,
	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_business_group_id           in  NUMBER,
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT NULL,
        p_val_last_upd_date           in  date      DEFAULT NULL,
        p_val_last_upd_person_id      in  number    DEFAULT NULL,
        p_pp_in_yr_used_num           in  number    default null,
	p_ecr_attribute_category      in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute1              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute2              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute3              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute4              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute5              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute6              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute7              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute8              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute9              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute10             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute11             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute12             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute13             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute14             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute15             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute16             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute17             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute18             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute19             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute20             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute21             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute22             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT NULL,
    p_request_id                  in  NUMBER    DEFAULT NULL,
    p_program_application_id      in  NUMBER    DEFAULT NULL,
    p_program_id                  in  NUMBER    DEFAULT NULL,
    p_program_update_date         in  DATE      DEFAULT NULL,
    p_object_version_number       out nocopy NUMBER,
    p_effective_date              in  date
 );
--
-- Performance cover
--
procedure create_perf_Enrollment_Rate
  (p_validate                    in  boolean default false,
	p_enrt_rt_id                  out nocopy NUMBER,
	p_ordr_num			    in  number    default null,
	p_acty_typ_cd                 in  VARCHAR2  DEFAULT NULL,
	p_tx_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT 'N',
	p_dflt_flag                   in  VARCHAR2  DEFAULT 'N',
	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT 'N',
	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT 'N',
	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT 'N',
	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT 'N',
	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT 'N',
	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT 'N',
	p_dflt_val                    in  NUMBER    DEFAULT NULL,
	p_ann_val                     in  NUMBER    DEFAULT NULL,
	p_ann_mn_elcn_val             in  NUMBER    DEFAULT NULL,
	p_ann_mx_elcn_val             in  NUMBER    DEFAULT NULL,
	p_val                         in  NUMBER    DEFAULT NULL,
	p_nnmntry_uom                 in  VARCHAR2  DEFAULT NULL,
	p_mx_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_mn_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_incrmt_elcn_val             in  NUMBER    DEFAULT NULL,
	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT NULL,
	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_val                    in  NUMBER    DEFAULT NULL,
	p_cmcd_dflt_val               in  NUMBER    DEFAULT NULL,
	p_rt_usg_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ann_dflt_val                in  NUMBER    DEFAULT NULL,
	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT NULL,
	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT NULL,
	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT NULL,
	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT NULL,
	p_entr_ann_val_flag           in  VARCHAR2,
	p_rt_strt_dt                  in  DATE      DEFAULT NULL,
	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT NULL,
	p_rt_strt_dt_rl               in  NUMBER    DEFAULT NULL,
	p_rt_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT NULL,
	p_acty_base_rt_id             in  NUMBER    DEFAULT NULL,
	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT NULL,
	p_enrt_bnft_id                in  NUMBER    DEFAULT NULL,
	p_prtt_rt_val_id              in  NUMBER    DEFAULT NULL,
	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT NULL,
	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT NULL,
	p_actl_prem_id                in  NUMBER    DEFAULT NULL,
	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT NULL,
	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_business_group_id           in  NUMBER,
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT NULL,
        p_val_last_upd_date           in  date      DEFAULT NULL,
        p_val_last_upd_person_id      in  number    DEFAULT NULL,
        p_pp_in_yr_used_num           in  number    default null,
	p_ecr_attribute_category      in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute1              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute2              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute3              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute4              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute5              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute6              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute7              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute8              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute9              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute10             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute11             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute12             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute13             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute14             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute15             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute16             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute17             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute18             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute19             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute20             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute21             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute22             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT NULL,
    p_request_id                  in  NUMBER    DEFAULT NULL,
    p_program_application_id      in  NUMBER    DEFAULT NULL,
    p_program_id                  in  NUMBER    DEFAULT NULL,
    p_program_update_date         in  DATE      DEFAULT NULL,
    p_object_version_number       out nocopy NUMBER,
    p_effective_date              in  date
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_Enrollment_Rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_Enrollment_Rate
  (
    p_validate                    in boolean    default false,
  	p_enrt_rt_id                  in  NUMBER,
  	p_ordr_num			    in number     default hr_api.g_number,
  	p_acty_typ_cd                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_tx_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_flag                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_val                     in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mn_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mx_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_val                         in  NUMBER    DEFAULT hr_api.g_number,
  	p_nnmntry_uom                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_mx_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_mn_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_incrmt_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_dflt_val               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_usg_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ann_dflt_val                in  NUMBER    DEFAULT hr_api.g_number,
  	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt                  in  DATE      DEFAULT hr_api.g_date,
  	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt_rl               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT hr_api.g_number,
  	p_acty_base_rt_id             in  NUMBER    DEFAULT hr_api.g_number,
  	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT hr_api.g_number,
  	p_enrt_bnft_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_prtt_rt_val_id              in  NUMBER    DEFAULT hr_api.g_number,
  	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT hr_api.g_number,
  	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_actl_prem_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT hr_api.g_number,
  	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_business_group_id           in  NUMBER    DEFAULT hr_api.g_number,
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT hr_api.g_number,
        p_val_last_upd_date           in  date      DEFAULT hr_api.g_date,
        p_val_last_upd_person_id      in  number    DEFAULT hr_api.g_number,
        p_pp_in_yr_used_num           in  number    default hr_api.g_number,
  	p_ecr_attribute_category      in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute1              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute2              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute3              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute4              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute5              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute6              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute7              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute8              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute9              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute10             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute11             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute12             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute13             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute14             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute15             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute16             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute17             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute18             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute19             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute20             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute21             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute22             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_request_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_application_id      in  NUMBER    DEFAULT hr_api.g_number,
    p_program_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_update_date         in  DATE      DEFAULT hr_api.g_date,
    p_object_version_number       in out nocopy NUMBER,
    p_effective_date              in  date
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< override_Enrollment_Rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE override_Enrollment_Rate
  (
        p_validate                    in boolean    default false,
        --
        p_person_id                   in  NUMBER,
        --
  	p_enrt_rt_id                  in  NUMBER,
  	p_ordr_num			    in number     default hr_api.g_number,
  	p_acty_typ_cd                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_tx_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_flag                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_val                    in  NUMBER    DEFAULT hr_api.g_number,
        --
        p_old_ann_val                 in  NUMBER    DEFAULT hr_api.g_number,
        --
  	p_ann_val                     in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mn_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mx_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
        --
        p_old_val                     in  NUMBER    DEFAULT hr_api.g_number,
        --
  	p_val                         in  NUMBER    DEFAULT hr_api.g_number,
  	p_nnmntry_uom                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_mx_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_mn_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_incrmt_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
        --
        p_acty_ref_perd_cd            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
        --
  	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_dflt_val               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_usg_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ann_dflt_val                in  NUMBER    DEFAULT hr_api.g_number,
  	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt                  in  DATE      DEFAULT hr_api.g_date,
  	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt_rl               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT hr_api.g_number,
  	p_acty_base_rt_id             in  NUMBER    DEFAULT hr_api.g_number,
  	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT hr_api.g_number,
  	p_enrt_bnft_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_prtt_rt_val_id              in  NUMBER    DEFAULT hr_api.g_number,
  	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT hr_api.g_number,
  	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_actl_prem_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT hr_api.g_number,
  	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_business_group_id           in  NUMBER    DEFAULT hr_api.g_number,
        p_perf_min_max_edit           in  VARCHAR2  DEFAULT NULL,
        p_iss_val                     in  number    DEFAULT hr_api.g_number,
        p_val_last_upd_date           in  date      DEFAULT hr_api.g_date,
        p_val_last_upd_person_id      in  number    DEFAULT hr_api.g_number,
        p_pp_in_yr_used_num           in  number    default hr_api.g_number,
  	p_ecr_attribute_category      in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute1              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute2              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute3              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute4              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute5              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute6              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute7              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute8              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute9              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute10             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute11             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute12             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute13             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute14             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute15             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute16             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute17             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute18             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute19             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute20             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute21             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute22             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_request_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_application_id      in  NUMBER    DEFAULT hr_api.g_number,
    p_program_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_update_date         in  DATE      DEFAULT hr_api.g_date,
    p_object_version_number       in out nocopy NUMBER,
    p_effective_date              in  date
  ) ;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Enrollment_Rate >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_enrt_rt_id                   Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_Enrollment_Rate
  (
   p_validate                       in boolean        default false
  ,p_enrt_rt_id                     in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_enrt_rt_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_enrt_rt_id                 in number
   ,p_object_version_number        in number
  );
--
end ben_Enrollment_Rate_api;

 

/
