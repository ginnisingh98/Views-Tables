--------------------------------------------------------
--  DDL for Package BEN_MATCHING_RATES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MATCHING_RATES_BK2" AUTHID CURRENT_USER as
/* $Header: bemtrapi.pkh 120.0 2005/05/28 03:39:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_MATCHING_RATES_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_MATCHING_RATES_b
  (
   p_mtchg_rt_id                    in  number
  ,p_ordr_num                       in  number
  ,p_from_pct_val                   in  number
  ,p_to_pct_val                     in  number
  ,p_pct_val                        in  number
  ,p_mx_amt_of_py_num               in  number
  ,p_mx_pct_of_py_num               in  number
  ,p_mx_mtch_amt                    in  number
  ,p_mn_mtch_amt                    in  number
  ,p_mtchg_rt_calc_rl               in  number
  ,p_no_mx_mtch_amt_flag            in  varchar2
  ,p_no_mx_pct_of_py_num_flag       in  varchar2
  ,p_cntnu_mtch_aftr_mx_rl_flag     in  varchar2
  ,p_no_mx_amt_of_py_num_flag       in  varchar2
  ,p_acty_base_rt_id                in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_mtr_attribute_category         in  varchar2
  ,p_mtr_attribute1                 in  varchar2
  ,p_mtr_attribute2                 in  varchar2
  ,p_mtr_attribute3                 in  varchar2
  ,p_mtr_attribute4                 in  varchar2
  ,p_mtr_attribute5                 in  varchar2
  ,p_mtr_attribute6                 in  varchar2
  ,p_mtr_attribute7                 in  varchar2
  ,p_mtr_attribute8                 in  varchar2
  ,p_mtr_attribute9                 in  varchar2
  ,p_mtr_attribute10                in  varchar2
  ,p_mtr_attribute11                in  varchar2
  ,p_mtr_attribute12                in  varchar2
  ,p_mtr_attribute13                in  varchar2
  ,p_mtr_attribute14                in  varchar2
  ,p_mtr_attribute15                in  varchar2
  ,p_mtr_attribute16                in  varchar2
  ,p_mtr_attribute17                in  varchar2
  ,p_mtr_attribute18                in  varchar2
  ,p_mtr_attribute19                in  varchar2
  ,p_mtr_attribute20                in  varchar2
  ,p_mtr_attribute21                in  varchar2
  ,p_mtr_attribute22                in  varchar2
  ,p_mtr_attribute23                in  varchar2
  ,p_mtr_attribute24                in  varchar2
  ,p_mtr_attribute25                in  varchar2
  ,p_mtr_attribute26                in  varchar2
  ,p_mtr_attribute27                in  varchar2
  ,p_mtr_attribute28                in  varchar2
  ,p_mtr_attribute29                in  varchar2
  ,p_mtr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_MATCHING_RATES_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_MATCHING_RATES_a
  (
   p_mtchg_rt_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_from_pct_val                   in  number
  ,p_to_pct_val                     in  number
  ,p_pct_val                        in  number
  ,p_mx_amt_of_py_num               in  number
  ,p_mx_pct_of_py_num               in  number
  ,p_mx_mtch_amt                    in  number
  ,p_mn_mtch_amt                    in  number
  ,p_mtchg_rt_calc_rl               in  number
  ,p_no_mx_mtch_amt_flag            in  varchar2
  ,p_no_mx_pct_of_py_num_flag       in  varchar2
  ,p_cntnu_mtch_aftr_mx_rl_flag     in  varchar2
  ,p_no_mx_amt_of_py_num_flag       in  varchar2
  ,p_acty_base_rt_id                in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_business_group_id              in  number
  ,p_mtr_attribute_category         in  varchar2
  ,p_mtr_attribute1                 in  varchar2
  ,p_mtr_attribute2                 in  varchar2
  ,p_mtr_attribute3                 in  varchar2
  ,p_mtr_attribute4                 in  varchar2
  ,p_mtr_attribute5                 in  varchar2
  ,p_mtr_attribute6                 in  varchar2
  ,p_mtr_attribute7                 in  varchar2
  ,p_mtr_attribute8                 in  varchar2
  ,p_mtr_attribute9                 in  varchar2
  ,p_mtr_attribute10                in  varchar2
  ,p_mtr_attribute11                in  varchar2
  ,p_mtr_attribute12                in  varchar2
  ,p_mtr_attribute13                in  varchar2
  ,p_mtr_attribute14                in  varchar2
  ,p_mtr_attribute15                in  varchar2
  ,p_mtr_attribute16                in  varchar2
  ,p_mtr_attribute17                in  varchar2
  ,p_mtr_attribute18                in  varchar2
  ,p_mtr_attribute19                in  varchar2
  ,p_mtr_attribute20                in  varchar2
  ,p_mtr_attribute21                in  varchar2
  ,p_mtr_attribute22                in  varchar2
  ,p_mtr_attribute23                in  varchar2
  ,p_mtr_attribute24                in  varchar2
  ,p_mtr_attribute25                in  varchar2
  ,p_mtr_attribute26                in  varchar2
  ,p_mtr_attribute27                in  varchar2
  ,p_mtr_attribute28                in  varchar2
  ,p_mtr_attribute29                in  varchar2
  ,p_mtr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_MATCHING_RATES_bk2;

 

/
