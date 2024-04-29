--------------------------------------------------------
--  DDL for Package BEN_PAY_BASIS_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAY_BASIS_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: bepbrapi.pkh 120.0 2005/05/28 10:08:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PAY_BASIS_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PAY_BASIS_RATE_b
  (
   p_py_bss_rt_id                   in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_pay_basis_id                   in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_pbr_attribute_category         in  varchar2
  ,p_pbr_attribute1                 in  varchar2
  ,p_pbr_attribute2                 in  varchar2
  ,p_pbr_attribute3                 in  varchar2
  ,p_pbr_attribute4                 in  varchar2
  ,p_pbr_attribute5                 in  varchar2
  ,p_pbr_attribute6                 in  varchar2
  ,p_pbr_attribute7                 in  varchar2
  ,p_pbr_attribute8                 in  varchar2
  ,p_pbr_attribute9                 in  varchar2
  ,p_pbr_attribute10                in  varchar2
  ,p_pbr_attribute11                in  varchar2
  ,p_pbr_attribute12                in  varchar2
  ,p_pbr_attribute13                in  varchar2
  ,p_pbr_attribute14                in  varchar2
  ,p_pbr_attribute15                in  varchar2
  ,p_pbr_attribute16                in  varchar2
  ,p_pbr_attribute17                in  varchar2
  ,p_pbr_attribute18                in  varchar2
  ,p_pbr_attribute19                in  varchar2
  ,p_pbr_attribute20                in  varchar2
  ,p_pbr_attribute21                in  varchar2
  ,p_pbr_attribute22                in  varchar2
  ,p_pbr_attribute23                in  varchar2
  ,p_pbr_attribute24                in  varchar2
  ,p_pbr_attribute25                in  varchar2
  ,p_pbr_attribute26                in  varchar2
  ,p_pbr_attribute27                in  varchar2
  ,p_pbr_attribute28                in  varchar2
  ,p_pbr_attribute29                in  varchar2
  ,p_pbr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PAY_BASIS_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PAY_BASIS_RATE_a
  (
   p_py_bss_rt_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_pay_basis_id                   in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_pbr_attribute_category         in  varchar2
  ,p_pbr_attribute1                 in  varchar2
  ,p_pbr_attribute2                 in  varchar2
  ,p_pbr_attribute3                 in  varchar2
  ,p_pbr_attribute4                 in  varchar2
  ,p_pbr_attribute5                 in  varchar2
  ,p_pbr_attribute6                 in  varchar2
  ,p_pbr_attribute7                 in  varchar2
  ,p_pbr_attribute8                 in  varchar2
  ,p_pbr_attribute9                 in  varchar2
  ,p_pbr_attribute10                in  varchar2
  ,p_pbr_attribute11                in  varchar2
  ,p_pbr_attribute12                in  varchar2
  ,p_pbr_attribute13                in  varchar2
  ,p_pbr_attribute14                in  varchar2
  ,p_pbr_attribute15                in  varchar2
  ,p_pbr_attribute16                in  varchar2
  ,p_pbr_attribute17                in  varchar2
  ,p_pbr_attribute18                in  varchar2
  ,p_pbr_attribute19                in  varchar2
  ,p_pbr_attribute20                in  varchar2
  ,p_pbr_attribute21                in  varchar2
  ,p_pbr_attribute22                in  varchar2
  ,p_pbr_attribute23                in  varchar2
  ,p_pbr_attribute24                in  varchar2
  ,p_pbr_attribute25                in  varchar2
  ,p_pbr_attribute26                in  varchar2
  ,p_pbr_attribute27                in  varchar2
  ,p_pbr_attribute28                in  varchar2
  ,p_pbr_attribute29                in  varchar2
  ,p_pbr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_PAY_BASIS_RATE_bk2;

 

/
