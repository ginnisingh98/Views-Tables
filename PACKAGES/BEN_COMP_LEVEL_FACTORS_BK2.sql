--------------------------------------------------------
--  DDL for Package BEN_COMP_LEVEL_FACTORS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_LEVEL_FACTORS_BK2" AUTHID CURRENT_USER as
/* $Header: beclfapi.pkh 120.0 2005/05/28 01:03:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_comp_level_factors_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_comp_level_factors_b
  (
   p_comp_lvl_fctr_id               in  number
  ,p_name                           in  varchar2
  ,p_comp_lvl_det_cd                in  varchar2
  ,p_comp_lvl_det_rl                in  number
  ,p_comp_lvl_uom                   in  varchar2
  ,p_comp_src_cd                    in  varchar2
  ,p_no_mn_comp_flag                in  varchar2
  ,p_no_mx_comp_flag                in  varchar2
  ,p_mx_comp_val                    in  number
  ,p_mn_comp_val                    in  number
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_defined_balance_id             in  number
  ,p_bnfts_bal_id                   in  number
  ,p_comp_alt_val_to_use_cd         in  varchar2
  ,p_comp_calc_rl                   in  number
  ,p_business_group_id              in  number
  ,p_proration_flag                 in Varchar2
  ,p_start_day_mo                   in Varchar2
  ,p_end_day_mo                     in Varchar2
  ,p_start_year                     in Varchar2
  ,p_end_year                       in Varchar2
  ,p_clf_attribute_category         in  varchar2
  ,p_clf_attribute1                 in  varchar2
  ,p_clf_attribute2                 in  varchar2
  ,p_clf_attribute3                 in  varchar2
  ,p_clf_attribute4                 in  varchar2
  ,p_clf_attribute5                 in  varchar2
  ,p_clf_attribute6                 in  varchar2
  ,p_clf_attribute7                 in  varchar2
  ,p_clf_attribute8                 in  varchar2
  ,p_clf_attribute9                 in  varchar2
  ,p_clf_attribute10                in  varchar2
  ,p_clf_attribute11                in  varchar2
  ,p_clf_attribute12                in  varchar2
  ,p_clf_attribute13                in  varchar2
  ,p_clf_attribute14                in  varchar2
  ,p_clf_attribute15                in  varchar2
  ,p_clf_attribute16                in  varchar2
  ,p_clf_attribute17                in  varchar2
  ,p_clf_attribute18                in  varchar2
  ,p_clf_attribute19                in  varchar2
  ,p_clf_attribute20                in  varchar2
  ,p_clf_attribute21                in  varchar2
  ,p_clf_attribute22                in  varchar2
  ,p_clf_attribute23                in  varchar2
  ,p_clf_attribute24                in  varchar2
  ,p_clf_attribute25                in  varchar2
  ,p_clf_attribute26                in  varchar2
  ,p_clf_attribute27                in  varchar2
  ,p_clf_attribute28                in  varchar2
  ,p_clf_attribute29                in  varchar2
  ,p_clf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_sttd_sal_prdcty_cd             in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_comp_level_factors_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_comp_level_factors_a
  (
   p_comp_lvl_fctr_id               in  number
  ,p_name                           in  varchar2
  ,p_comp_lvl_det_cd                in  varchar2
  ,p_comp_lvl_det_rl                in  number
  ,p_comp_lvl_uom                   in  varchar2
  ,p_comp_src_cd                    in  varchar2
  ,p_no_mn_comp_flag                in  varchar2
  ,p_no_mx_comp_flag                in  varchar2
  ,p_mx_comp_val                    in  number
  ,p_mn_comp_val                    in  number
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_defined_balance_id             in  number
  ,p_bnfts_bal_id                   in  number
  ,p_comp_alt_val_to_use_cd         in  varchar2
  ,p_comp_calc_rl                   in  number
  ,p_business_group_id              in  number
  ,p_proration_flag                 in Varchar2
  ,p_start_day_mo                   in Varchar2
  ,p_end_day_mo                     in Varchar2
  ,p_start_year                     in Varchar2
  ,p_end_year                       in Varchar2
  ,p_clf_attribute_category         in  varchar2
  ,p_clf_attribute1                 in  varchar2
  ,p_clf_attribute2                 in  varchar2
  ,p_clf_attribute3                 in  varchar2
  ,p_clf_attribute4                 in  varchar2
  ,p_clf_attribute5                 in  varchar2
  ,p_clf_attribute6                 in  varchar2
  ,p_clf_attribute7                 in  varchar2
  ,p_clf_attribute8                 in  varchar2
  ,p_clf_attribute9                 in  varchar2
  ,p_clf_attribute10                in  varchar2
  ,p_clf_attribute11                in  varchar2
  ,p_clf_attribute12                in  varchar2
  ,p_clf_attribute13                in  varchar2
  ,p_clf_attribute14                in  varchar2
  ,p_clf_attribute15                in  varchar2
  ,p_clf_attribute16                in  varchar2
  ,p_clf_attribute17                in  varchar2
  ,p_clf_attribute18                in  varchar2
  ,p_clf_attribute19                in  varchar2
  ,p_clf_attribute20                in  varchar2
  ,p_clf_attribute21                in  varchar2
  ,p_clf_attribute22                in  varchar2
  ,p_clf_attribute23                in  varchar2
  ,p_clf_attribute24                in  varchar2
  ,p_clf_attribute25                in  varchar2
  ,p_clf_attribute26                in  varchar2
  ,p_clf_attribute27                in  varchar2
  ,p_clf_attribute28                in  varchar2
  ,p_clf_attribute29                in  varchar2
  ,p_clf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_sttd_sal_prdcty_cd             in  varchar2
  );
--
end ben_comp_level_factors_bk2;

 

/
