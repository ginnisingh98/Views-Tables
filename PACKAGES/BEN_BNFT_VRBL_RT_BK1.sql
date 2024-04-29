--------------------------------------------------------
--  DDL for Package BEN_BNFT_VRBL_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNFT_VRBL_RT_BK1" AUTHID CURRENT_USER as
/* $Header: bebvrapi.pkh 120.0 2005/05/28 00:54:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_bnft_vrbl_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_bnft_vrbl_rt_b
  (
   p_cvg_amt_calc_mthd_id           in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_bvr_attribute_category         in  varchar2
  ,p_bvr_attribute1                 in  varchar2
  ,p_bvr_attribute2                 in  varchar2
  ,p_bvr_attribute3                 in  varchar2
  ,p_bvr_attribute4                 in  varchar2
  ,p_bvr_attribute5                 in  varchar2
  ,p_bvr_attribute6                 in  varchar2
  ,p_bvr_attribute7                 in  varchar2
  ,p_bvr_attribute8                 in  varchar2
  ,p_bvr_attribute9                 in  varchar2
  ,p_bvr_attribute10                in  varchar2
  ,p_bvr_attribute11                in  varchar2
  ,p_bvr_attribute12                in  varchar2
  ,p_bvr_attribute13                in  varchar2
  ,p_bvr_attribute14                in  varchar2
  ,p_bvr_attribute15                in  varchar2
  ,p_bvr_attribute16                in  varchar2
  ,p_bvr_attribute17                in  varchar2
  ,p_bvr_attribute18                in  varchar2
  ,p_bvr_attribute19                in  varchar2
  ,p_bvr_attribute20                in  varchar2
  ,p_bvr_attribute21                in  varchar2
  ,p_bvr_attribute22                in  varchar2
  ,p_bvr_attribute23                in  varchar2
  ,p_bvr_attribute24                in  varchar2
  ,p_bvr_attribute25                in  varchar2
  ,p_bvr_attribute26                in  varchar2
  ,p_bvr_attribute27                in  varchar2
  ,p_bvr_attribute28                in  varchar2
  ,p_bvr_attribute29                in  varchar2
  ,p_bvr_attribute30                in  varchar2
  ,p_ordr_num                       in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_bnft_vrbl_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_bnft_vrbl_rt_a
  (
   p_bnft_vrbl_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_bvr_attribute_category         in  varchar2
  ,p_bvr_attribute1                 in  varchar2
  ,p_bvr_attribute2                 in  varchar2
  ,p_bvr_attribute3                 in  varchar2
  ,p_bvr_attribute4                 in  varchar2
  ,p_bvr_attribute5                 in  varchar2
  ,p_bvr_attribute6                 in  varchar2
  ,p_bvr_attribute7                 in  varchar2
  ,p_bvr_attribute8                 in  varchar2
  ,p_bvr_attribute9                 in  varchar2
  ,p_bvr_attribute10                in  varchar2
  ,p_bvr_attribute11                in  varchar2
  ,p_bvr_attribute12                in  varchar2
  ,p_bvr_attribute13                in  varchar2
  ,p_bvr_attribute14                in  varchar2
  ,p_bvr_attribute15                in  varchar2
  ,p_bvr_attribute16                in  varchar2
  ,p_bvr_attribute17                in  varchar2
  ,p_bvr_attribute18                in  varchar2
  ,p_bvr_attribute19                in  varchar2
  ,p_bvr_attribute20                in  varchar2
  ,p_bvr_attribute21                in  varchar2
  ,p_bvr_attribute22                in  varchar2
  ,p_bvr_attribute23                in  varchar2
  ,p_bvr_attribute24                in  varchar2
  ,p_bvr_attribute25                in  varchar2
  ,p_bvr_attribute26                in  varchar2
  ,p_bvr_attribute27                in  varchar2
  ,p_bvr_attribute28                in  varchar2
  ,p_bvr_attribute29                in  varchar2
  ,p_bvr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_ordr_num                       in  number
  ,p_effective_date                 in  date
  );
--
end ben_bnft_vrbl_rt_bk1;

 

/
