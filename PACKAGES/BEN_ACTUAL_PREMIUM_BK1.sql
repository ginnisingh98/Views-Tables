--------------------------------------------------------
--  DDL for Package BEN_ACTUAL_PREMIUM_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTUAL_PREMIUM_BK1" AUTHID CURRENT_USER as
/* $Header: beaprapi.pkh 120.0 2005/05/28 00:26:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_actual_premium_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_actual_premium_b
  (
   p_name                           in  varchar2
  ,p_acty_ref_perd_cd               in  varchar2
  ,p_uom                            in  varchar2
  ,p_rt_typ_cd                      in  varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2
  ,p_val                            in  number
  ,p_mlt_cd                         in  varchar2
  ,p_prdct_cd                       in  varchar2
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_val_calc_rl                    in  number
  ,p_prem_asnmt_cd                  in  varchar2
  ,p_prem_asnmt_lvl_cd              in  varchar2
  ,p_actl_prem_typ_cd               in  varchar2
  ,p_prem_pyr_cd                    in  varchar2
  ,p_cr_lkbk_val                    in  number
  ,p_cr_lkbk_uom                    in  varchar2
  ,p_cr_lkbk_crnt_py_only_flag      in  varchar2
  ,p_prsptv_r_rtsptv_cd             in  varchar2
  ,p_upr_lmt_val                    in  number
  ,p_upr_lmt_calc_rl                in  number
  ,p_lwr_lmt_val                    in  number
  ,p_lwr_lmt_calc_rl                in  number
  ,p_cost_allocation_keyflex_id     in  number
  ,p_organization_id                in  number
  ,p_oipl_id                        in  number
  ,p_pl_id                          in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_apr_attribute_category         in  varchar2
  ,p_apr_attribute1                 in  varchar2
  ,p_apr_attribute2                 in  varchar2
  ,p_apr_attribute3                 in  varchar2
  ,p_apr_attribute4                 in  varchar2
  ,p_apr_attribute5                 in  varchar2
  ,p_apr_attribute6                 in  varchar2
  ,p_apr_attribute7                 in  varchar2
  ,p_apr_attribute8                 in  varchar2
  ,p_apr_attribute9                 in  varchar2
  ,p_apr_attribute10                in  varchar2
  ,p_apr_attribute11                in  varchar2
  ,p_apr_attribute12                in  varchar2
  ,p_apr_attribute13                in  varchar2
  ,p_apr_attribute14                in  varchar2
  ,p_apr_attribute15                in  varchar2
  ,p_apr_attribute16                in  varchar2
  ,p_apr_attribute17                in  varchar2
  ,p_apr_attribute18                in  varchar2
  ,p_apr_attribute19                in  varchar2
  ,p_apr_attribute20                in  varchar2
  ,p_apr_attribute21                in  varchar2
  ,p_apr_attribute22                in  varchar2
  ,p_apr_attribute23                in  varchar2
  ,p_apr_attribute24                in  varchar2
  ,p_apr_attribute25                in  varchar2
  ,p_apr_attribute26                in  varchar2
  ,p_apr_attribute27                in  varchar2
  ,p_apr_attribute28                in  varchar2
  ,p_apr_attribute29                in  varchar2
  ,p_apr_attribute30                in  varchar2
  ,p_prtl_mo_det_mthd_cd            in  varchar2
  ,p_prtl_mo_det_mthd_rl            in  number
  ,p_wsh_rl_dy_mo_num               in  number
  ,p_vrbl_rt_add_on_calc_rl         in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_actual_premium_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_actual_premium_a
  (
   p_actl_prem_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_name                           in  varchar2
  ,p_acty_ref_perd_cd               in  varchar2
  ,p_uom                            in  varchar2
  ,p_rt_typ_cd                      in  varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2
  ,p_val                            in  number
  ,p_mlt_cd                         in  varchar2
  ,p_prdct_cd                       in  varchar2
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_val_calc_rl                    in  number
  ,p_prem_asnmt_cd                  in  varchar2
  ,p_prem_asnmt_lvl_cd              in  varchar2
  ,p_actl_prem_typ_cd               in  varchar2
  ,p_prem_pyr_cd                    in  varchar2
  ,p_cr_lkbk_val                    in  number
  ,p_cr_lkbk_uom                    in  varchar2
  ,p_cr_lkbk_crnt_py_only_flag      in  varchar2
  ,p_prsptv_r_rtsptv_cd             in  varchar2
  ,p_upr_lmt_val                    in  number
  ,p_upr_lmt_calc_rl                in  number
  ,p_lwr_lmt_val                    in  number
  ,p_lwr_lmt_calc_rl                in  number
  ,p_cost_allocation_keyflex_id     in  number
  ,p_organization_id                in  number
  ,p_oipl_id                        in  number
  ,p_pl_id                          in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_apr_attribute_category         in  varchar2
  ,p_apr_attribute1                 in  varchar2
  ,p_apr_attribute2                 in  varchar2
  ,p_apr_attribute3                 in  varchar2
  ,p_apr_attribute4                 in  varchar2
  ,p_apr_attribute5                 in  varchar2
  ,p_apr_attribute6                 in  varchar2
  ,p_apr_attribute7                 in  varchar2
  ,p_apr_attribute8                 in  varchar2
  ,p_apr_attribute9                 in  varchar2
  ,p_apr_attribute10                in  varchar2
  ,p_apr_attribute11                in  varchar2
  ,p_apr_attribute12                in  varchar2
  ,p_apr_attribute13                in  varchar2
  ,p_apr_attribute14                in  varchar2
  ,p_apr_attribute15                in  varchar2
  ,p_apr_attribute16                in  varchar2
  ,p_apr_attribute17                in  varchar2
  ,p_apr_attribute18                in  varchar2
  ,p_apr_attribute19                in  varchar2
  ,p_apr_attribute20                in  varchar2
  ,p_apr_attribute21                in  varchar2
  ,p_apr_attribute22                in  varchar2
  ,p_apr_attribute23                in  varchar2
  ,p_apr_attribute24                in  varchar2
  ,p_apr_attribute25                in  varchar2
  ,p_apr_attribute26                in  varchar2
  ,p_apr_attribute27                in  varchar2
  ,p_apr_attribute28                in  varchar2
  ,p_apr_attribute29                in  varchar2
  ,p_apr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_prtl_mo_det_mthd_cd            in  varchar2
  ,p_prtl_mo_det_mthd_rl            in  number
  ,p_wsh_rl_dy_mo_num               in  number
  ,p_vrbl_rt_add_on_calc_rl         in  number
  ,p_effective_date                 in  date
  );
--
end ben_actual_premium_bk1;

 

/
