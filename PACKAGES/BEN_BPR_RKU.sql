--------------------------------------------------------
--  DDL for Package BEN_BPR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPR_RKU" AUTHID CURRENT_USER as
/* $Header: bebprrhi.pkh 120.0.12010000.1 2008/07/29 10:59:35 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_bnft_pool_rlovr_rqmt_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_no_mn_rlovr_pct_dfnd_flag      in varchar2
 ,p_no_mx_rlovr_pct_dfnd_flag      in varchar2
 ,p_no_mn_rlovr_val_dfnd_flag      in varchar2
 ,p_no_mx_rlovr_val_dfnd_flag      in varchar2
 ,p_rlovr_val_incrmt_num           in number
 ,p_rlovr_val_rl                   in number
 ,p_mn_rlovr_val                   in number
 ,p_mx_rlovr_val                   in number
 ,p_val_rndg_cd                    in varchar2
 ,p_val_rndg_rl                    in number
 ,p_pct_rndg_cd                    in varchar2
 ,p_pct_rndg_rl                    in number
 ,p_prtt_elig_rlovr_rl             in number
 ,p_mx_rchd_dflt_ordr_num          in number
 ,p_pct_rlovr_incrmt_num           in number
 ,p_mn_rlovr_pct_num               in number
 ,p_mx_rlovr_pct_num               in number
 ,p_crs_rlovr_procg_cd             in varchar2
 ,p_mx_pct_ttl_crs_cn_roll_num     in number
 ,p_bnft_prvdr_pool_id             in number
 ,p_acty_base_rt_id                in number
 ,p_business_group_id              in number
 ,p_bpr_attribute_category         in varchar2
 ,p_bpr_attribute1                 in varchar2
 ,p_bpr_attribute2                 in varchar2
 ,p_bpr_attribute3                 in varchar2
 ,p_bpr_attribute4                 in varchar2
 ,p_bpr_attribute5                 in varchar2
 ,p_bpr_attribute6                 in varchar2
 ,p_bpr_attribute7                 in varchar2
 ,p_bpr_attribute8                 in varchar2
 ,p_bpr_attribute9                 in varchar2
 ,p_bpr_attribute10                in varchar2
 ,p_bpr_attribute11                in varchar2
 ,p_bpr_attribute12                in varchar2
 ,p_bpr_attribute13                in varchar2
 ,p_bpr_attribute14                in varchar2
 ,p_bpr_attribute15                in varchar2
 ,p_bpr_attribute16                in varchar2
 ,p_bpr_attribute17                in varchar2
 ,p_bpr_attribute18                in varchar2
 ,p_bpr_attribute19                in varchar2
 ,p_bpr_attribute20                in varchar2
 ,p_bpr_attribute21                in varchar2
 ,p_bpr_attribute22                in varchar2
 ,p_bpr_attribute23                in varchar2
 ,p_bpr_attribute24                in varchar2
 ,p_bpr_attribute25                in varchar2
 ,p_bpr_attribute26                in varchar2
 ,p_bpr_attribute27                in varchar2
 ,p_bpr_attribute28                in varchar2
 ,p_bpr_attribute29                in varchar2
 ,p_bpr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_no_mn_rlovr_pct_dfnd_flag_o    in varchar2
 ,p_no_mx_rlovr_pct_dfnd_flag_o    in varchar2
 ,p_no_mn_rlovr_val_dfnd_flag_o    in varchar2
 ,p_no_mx_rlovr_val_dfnd_flag_o    in varchar2
 ,p_rlovr_val_incrmt_num_o         in number
 ,p_rlovr_val_rl_o                 in number
 ,p_mn_rlovr_val_o                 in number
 ,p_mx_rlovr_val_o                 in number
 ,p_val_rndg_cd_o                  in varchar2
 ,p_val_rndg_rl_o                  in number
 ,p_pct_rndg_cd_o                  in varchar2
 ,p_pct_rndg_rl_o                  in number
 ,p_prtt_elig_rlovr_rl_o           in number
 ,p_mx_rchd_dflt_ordr_num_o        in number
 ,p_pct_rlovr_incrmt_num_o         in number
 ,p_mn_rlovr_pct_num_o             in number
 ,p_mx_rlovr_pct_num_o             in number
 ,p_crs_rlovr_procg_cd_o           in varchar2
 ,p_mx_pct_ttl_crs_cn_roll_num_o   in number
 ,p_bnft_prvdr_pool_id_o           in number
 ,p_acty_base_rt_id_o              in number
 ,p_business_group_id_o            in number
 ,p_bpr_attribute_category_o       in varchar2
 ,p_bpr_attribute1_o               in varchar2
 ,p_bpr_attribute2_o               in varchar2
 ,p_bpr_attribute3_o               in varchar2
 ,p_bpr_attribute4_o               in varchar2
 ,p_bpr_attribute5_o               in varchar2
 ,p_bpr_attribute6_o               in varchar2
 ,p_bpr_attribute7_o               in varchar2
 ,p_bpr_attribute8_o               in varchar2
 ,p_bpr_attribute9_o               in varchar2
 ,p_bpr_attribute10_o              in varchar2
 ,p_bpr_attribute11_o              in varchar2
 ,p_bpr_attribute12_o              in varchar2
 ,p_bpr_attribute13_o              in varchar2
 ,p_bpr_attribute14_o              in varchar2
 ,p_bpr_attribute15_o              in varchar2
 ,p_bpr_attribute16_o              in varchar2
 ,p_bpr_attribute17_o              in varchar2
 ,p_bpr_attribute18_o              in varchar2
 ,p_bpr_attribute19_o              in varchar2
 ,p_bpr_attribute20_o              in varchar2
 ,p_bpr_attribute21_o              in varchar2
 ,p_bpr_attribute22_o              in varchar2
 ,p_bpr_attribute23_o              in varchar2
 ,p_bpr_attribute24_o              in varchar2
 ,p_bpr_attribute25_o              in varchar2
 ,p_bpr_attribute26_o              in varchar2
 ,p_bpr_attribute27_o              in varchar2
 ,p_bpr_attribute28_o              in varchar2
 ,p_bpr_attribute29_o              in varchar2
 ,p_bpr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_bpr_rku;

/
