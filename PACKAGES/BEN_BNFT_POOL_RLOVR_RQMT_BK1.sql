--------------------------------------------------------
--  DDL for Package BEN_BNFT_POOL_RLOVR_RQMT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNFT_POOL_RLOVR_RQMT_BK1" AUTHID CURRENT_USER as
/* $Header: bebprapi.pkh 120.0 2005/05/28 00:49:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Bnft_Pool_Rlovr_Rqmt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Bnft_Pool_Rlovr_Rqmt_b
  (
   p_no_mn_rlovr_pct_dfnd_flag      in  varchar2
  ,p_no_mx_rlovr_pct_dfnd_flag      in  varchar2
  ,p_no_mn_rlovr_val_dfnd_flag      in  varchar2
  ,p_no_mx_rlovr_val_dfnd_flag      in  varchar2
  ,p_rlovr_val_incrmt_num           in  number
  ,p_rlovr_val_rl                   in  number
  ,p_mn_rlovr_val                   in  number
  ,p_mx_rlovr_val                   in  number
  ,p_val_rndg_cd                    in  varchar2
  ,p_val_rndg_rl                    in  number
  ,p_pct_rndg_cd                    in  varchar2
  ,p_pct_rndg_rl                    in  number
  ,p_prtt_elig_rlovr_rl             in  number
  ,p_mx_rchd_dflt_ordr_num          in  number
  ,p_pct_rlovr_incrmt_num           in  number
  ,p_mn_rlovr_pct_num               in  number
  ,p_mx_rlovr_pct_num               in  number
  ,p_crs_rlovr_procg_cd             in  varchar2
  ,p_mx_pct_ttl_crs_cn_roll_num     in  number
  ,p_bnft_prvdr_pool_id             in  number
  ,p_acty_base_rt_id                in  number
  ,p_business_group_id              in  number
  ,p_bpr_attribute_category         in  varchar2
  ,p_bpr_attribute1                 in  varchar2
  ,p_bpr_attribute2                 in  varchar2
  ,p_bpr_attribute3                 in  varchar2
  ,p_bpr_attribute4                 in  varchar2
  ,p_bpr_attribute5                 in  varchar2
  ,p_bpr_attribute6                 in  varchar2
  ,p_bpr_attribute7                 in  varchar2
  ,p_bpr_attribute8                 in  varchar2
  ,p_bpr_attribute9                 in  varchar2
  ,p_bpr_attribute10                in  varchar2
  ,p_bpr_attribute11                in  varchar2
  ,p_bpr_attribute12                in  varchar2
  ,p_bpr_attribute13                in  varchar2
  ,p_bpr_attribute14                in  varchar2
  ,p_bpr_attribute15                in  varchar2
  ,p_bpr_attribute16                in  varchar2
  ,p_bpr_attribute17                in  varchar2
  ,p_bpr_attribute18                in  varchar2
  ,p_bpr_attribute19                in  varchar2
  ,p_bpr_attribute20                in  varchar2
  ,p_bpr_attribute21                in  varchar2
  ,p_bpr_attribute22                in  varchar2
  ,p_bpr_attribute23                in  varchar2
  ,p_bpr_attribute24                in  varchar2
  ,p_bpr_attribute25                in  varchar2
  ,p_bpr_attribute26                in  varchar2
  ,p_bpr_attribute27                in  varchar2
  ,p_bpr_attribute28                in  varchar2
  ,p_bpr_attribute29                in  varchar2
  ,p_bpr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Bnft_Pool_Rlovr_Rqmt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Bnft_Pool_Rlovr_Rqmt_a
  (
   p_bnft_pool_rlovr_rqmt_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_no_mn_rlovr_pct_dfnd_flag      in  varchar2
  ,p_no_mx_rlovr_pct_dfnd_flag      in  varchar2
  ,p_no_mn_rlovr_val_dfnd_flag      in  varchar2
  ,p_no_mx_rlovr_val_dfnd_flag      in  varchar2
  ,p_rlovr_val_incrmt_num           in  number
  ,p_rlovr_val_rl                   in  number
  ,p_mn_rlovr_val                   in  number
  ,p_mx_rlovr_val                   in  number
  ,p_val_rndg_cd                    in  varchar2
  ,p_val_rndg_rl                    in  number
  ,p_pct_rndg_cd                    in  varchar2
  ,p_pct_rndg_rl                    in  number
  ,p_prtt_elig_rlovr_rl             in  number
  ,p_mx_rchd_dflt_ordr_num          in  number
  ,p_pct_rlovr_incrmt_num           in  number
  ,p_mn_rlovr_pct_num               in  number
  ,p_mx_rlovr_pct_num               in  number
  ,p_crs_rlovr_procg_cd             in  varchar2
  ,p_mx_pct_ttl_crs_cn_roll_num     in  number
  ,p_bnft_prvdr_pool_id             in  number
  ,p_acty_base_rt_id                in  number
  ,p_business_group_id              in  number
  ,p_bpr_attribute_category         in  varchar2
  ,p_bpr_attribute1                 in  varchar2
  ,p_bpr_attribute2                 in  varchar2
  ,p_bpr_attribute3                 in  varchar2
  ,p_bpr_attribute4                 in  varchar2
  ,p_bpr_attribute5                 in  varchar2
  ,p_bpr_attribute6                 in  varchar2
  ,p_bpr_attribute7                 in  varchar2
  ,p_bpr_attribute8                 in  varchar2
  ,p_bpr_attribute9                 in  varchar2
  ,p_bpr_attribute10                in  varchar2
  ,p_bpr_attribute11                in  varchar2
  ,p_bpr_attribute12                in  varchar2
  ,p_bpr_attribute13                in  varchar2
  ,p_bpr_attribute14                in  varchar2
  ,p_bpr_attribute15                in  varchar2
  ,p_bpr_attribute16                in  varchar2
  ,p_bpr_attribute17                in  varchar2
  ,p_bpr_attribute18                in  varchar2
  ,p_bpr_attribute19                in  varchar2
  ,p_bpr_attribute20                in  varchar2
  ,p_bpr_attribute21                in  varchar2
  ,p_bpr_attribute22                in  varchar2
  ,p_bpr_attribute23                in  varchar2
  ,p_bpr_attribute24                in  varchar2
  ,p_bpr_attribute25                in  varchar2
  ,p_bpr_attribute26                in  varchar2
  ,p_bpr_attribute27                in  varchar2
  ,p_bpr_attribute28                in  varchar2
  ,p_bpr_attribute29                in  varchar2
  ,p_bpr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Bnft_Pool_Rlovr_Rqmt_bk1;

 

/
