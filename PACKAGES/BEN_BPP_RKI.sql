--------------------------------------------------------
--  DDL for Package BEN_BPP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPP_RKI" AUTHID CURRENT_USER as
/* $Header: bebpprhi.pkh 120.0 2005/05/28 00:48:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_bnft_prvdr_pool_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_pgm_pool_flag                  in varchar2
 ,p_excs_alwys_fftd_flag           in varchar2
 ,p_use_for_pgm_pool_flag          in varchar2
 ,p_pct_rndg_cd                    in varchar2
 ,p_pct_rndg_rl                    in number
 ,p_val_rndg_cd                    in varchar2
 ,p_val_rndg_rl                    in number
 ,p_dflt_excs_trtmt_cd             in varchar2
 ,p_dflt_excs_trtmt_rl             in number
 ,p_rlovr_rstrcn_cd                in varchar2
 ,p_no_mn_dstrbl_pct_flag          in varchar2
 ,p_no_mn_dstrbl_val_flag          in varchar2
 ,p_no_mx_dstrbl_pct_flag          in varchar2
 ,p_no_mx_dstrbl_val_flag          in varchar2
 ,p_auto_alct_excs_flag            in varchar2
 ,p_alws_ngtv_crs_flag             in varchar2
 ,p_uses_net_crs_mthd_flag         in varchar2
 ,p_mx_dfcit_pct_pool_crs_num      in number
 ,p_mx_dfcit_pct_comp_num          in number
 ,p_comp_lvl_fctr_id               in number
 ,p_mn_dstrbl_pct_num              in number
 ,p_mn_dstrbl_val                  in number
 ,p_mx_dstrbl_pct_num              in number
 ,p_mx_dstrbl_val                  in number
 ,p_excs_trtmt_cd                  in varchar2
 ,p_ptip_id                        in number
 ,p_plip_id                        in number
 ,p_pgm_id                         in number
 ,p_oiplip_id                      in number
 ,p_cmbn_plip_id                   in number
 ,p_cmbn_ptip_id                   in number
 ,p_cmbn_ptip_opt_id               in number
 ,p_business_group_id              in number
 ,p_bpp_attribute_category         in varchar2
 ,p_bpp_attribute1                 in varchar2
 ,p_bpp_attribute2                 in varchar2
 ,p_bpp_attribute3                 in varchar2
 ,p_bpp_attribute4                 in varchar2
 ,p_bpp_attribute5                 in varchar2
 ,p_bpp_attribute6                 in varchar2
 ,p_bpp_attribute7                 in varchar2
 ,p_bpp_attribute8                 in varchar2
 ,p_bpp_attribute9                 in varchar2
 ,p_bpp_attribute10                in varchar2
 ,p_bpp_attribute11                in varchar2
 ,p_bpp_attribute12                in varchar2
 ,p_bpp_attribute13                in varchar2
 ,p_bpp_attribute14                in varchar2
 ,p_bpp_attribute15                in varchar2
 ,p_bpp_attribute16                in varchar2
 ,p_bpp_attribute17                in varchar2
 ,p_bpp_attribute18                in varchar2
 ,p_bpp_attribute19                in varchar2
 ,p_bpp_attribute20                in varchar2
 ,p_bpp_attribute21                in varchar2
 ,p_bpp_attribute22                in varchar2
 ,p_bpp_attribute23                in varchar2
 ,p_bpp_attribute24                in varchar2
 ,p_bpp_attribute25                in varchar2
 ,p_bpp_attribute26                in varchar2
 ,p_bpp_attribute27                in varchar2
 ,p_bpp_attribute28                in varchar2
 ,p_bpp_attribute29                in varchar2
 ,p_bpp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_bpp_rki;

 

/
