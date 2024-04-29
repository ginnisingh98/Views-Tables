--------------------------------------------------------
--  DDL for Package BEN_PERIOD_LIMIT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERIOD_LIMIT_BK1" AUTHID CURRENT_USER as
/* $Header: bepdlapi.pkh 120.0 2005/05/28 10:26:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_period_limit_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_period_limit_b
  (
   p_name                           in  varchar2
  ,p_mx_comp_to_cnsdr               in  number
  ,p_mx_val                         in  number
  ,p_mx_pct_val                     in  number
  ,p_ptd_lmt_calc_rl                in  number
  ,p_lmt_det_cd                     in  varchar2
  ,p_comp_lvl_fctr_id               in  number
  ,p_balance_type_id                in  number
  ,p_business_group_id              in  number
  ,p_pdl_attribute_category         in  varchar2
  ,p_pdl_attribute1                 in  varchar2
  ,p_pdl_attribute2                 in  varchar2
  ,p_pdl_attribute3                 in  varchar2
  ,p_pdl_attribute4                 in  varchar2
  ,p_pdl_attribute5                 in  varchar2
  ,p_pdl_attribute6                 in  varchar2
  ,p_pdl_attribute7                 in  varchar2
  ,p_pdl_attribute8                 in  varchar2
  ,p_pdl_attribute9                 in  varchar2
  ,p_pdl_attribute10                in  varchar2
  ,p_pdl_attribute11                in  varchar2
  ,p_pdl_attribute12                in  varchar2
  ,p_pdl_attribute13                in  varchar2
  ,p_pdl_attribute14                in  varchar2
  ,p_pdl_attribute15                in  varchar2
  ,p_pdl_attribute16                in  varchar2
  ,p_pdl_attribute17                in  varchar2
  ,p_pdl_attribute18                in  varchar2
  ,p_pdl_attribute19                in  varchar2
  ,p_pdl_attribute20                in  varchar2
  ,p_pdl_attribute21                in  varchar2
  ,p_pdl_attribute22                in  varchar2
  ,p_pdl_attribute23                in  varchar2
  ,p_pdl_attribute24                in  varchar2
  ,p_pdl_attribute25                in  varchar2
  ,p_pdl_attribute26                in  varchar2
  ,p_pdl_attribute27                in  varchar2
  ,p_pdl_attribute28                in  varchar2
  ,p_pdl_attribute29                in  varchar2
  ,p_pdl_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_period_limit_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_period_limit_a
  (
   p_ptd_lmt_id                     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_name                           in  varchar2
  ,p_mx_comp_to_cnsdr               in  number
  ,p_mx_val                         in  number
  ,p_mx_pct_val                     in  number
  ,p_ptd_lmt_calc_rl                in  number
  ,p_lmt_det_cd                     in  varchar2
  ,p_comp_lvl_fctr_id               in  number
  ,p_balance_type_id                in  number
  ,p_business_group_id              in  number
  ,p_pdl_attribute_category         in  varchar2
  ,p_pdl_attribute1                 in  varchar2
  ,p_pdl_attribute2                 in  varchar2
  ,p_pdl_attribute3                 in  varchar2
  ,p_pdl_attribute4                 in  varchar2
  ,p_pdl_attribute5                 in  varchar2
  ,p_pdl_attribute6                 in  varchar2
  ,p_pdl_attribute7                 in  varchar2
  ,p_pdl_attribute8                 in  varchar2
  ,p_pdl_attribute9                 in  varchar2
  ,p_pdl_attribute10                in  varchar2
  ,p_pdl_attribute11                in  varchar2
  ,p_pdl_attribute12                in  varchar2
  ,p_pdl_attribute13                in  varchar2
  ,p_pdl_attribute14                in  varchar2
  ,p_pdl_attribute15                in  varchar2
  ,p_pdl_attribute16                in  varchar2
  ,p_pdl_attribute17                in  varchar2
  ,p_pdl_attribute18                in  varchar2
  ,p_pdl_attribute19                in  varchar2
  ,p_pdl_attribute20                in  varchar2
  ,p_pdl_attribute21                in  varchar2
  ,p_pdl_attribute22                in  varchar2
  ,p_pdl_attribute23                in  varchar2
  ,p_pdl_attribute24                in  varchar2
  ,p_pdl_attribute25                in  varchar2
  ,p_pdl_attribute26                in  varchar2
  ,p_pdl_attribute27                in  varchar2
  ,p_pdl_attribute28                in  varchar2
  ,p_pdl_attribute29                in  varchar2
  ,p_pdl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_period_limit_bk1;

 

/
