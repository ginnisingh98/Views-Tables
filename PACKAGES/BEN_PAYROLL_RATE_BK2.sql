--------------------------------------------------------
--  DDL for Package BEN_PAYROLL_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAYROLL_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: bepyrapi.pkh 120.0 2005/05/28 11:29:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PAYROLL_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PAYROLL_RATE_b
  (
   p_pyrl_rt_id                     in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_payroll_id                     in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_business_group_id              in  number
  ,p_pr_attribute_category          in  varchar2
  ,p_pr_attribute1                  in  varchar2
  ,p_pr_attribute2                  in  varchar2
  ,p_pr_attribute3                  in  varchar2
  ,p_pr_attribute4                  in  varchar2
  ,p_pr_attribute5                  in  varchar2
  ,p_pr_attribute6                  in  varchar2
  ,p_pr_attribute7                  in  varchar2
  ,p_pr_attribute8                  in  varchar2
  ,p_pr_attribute9                  in  varchar2
  ,p_pr_attribute10                 in  varchar2
  ,p_pr_attribute11                 in  varchar2
  ,p_pr_attribute12                 in  varchar2
  ,p_pr_attribute13                 in  varchar2
  ,p_pr_attribute14                 in  varchar2
  ,p_pr_attribute15                 in  varchar2
  ,p_pr_attribute16                 in  varchar2
  ,p_pr_attribute17                 in  varchar2
  ,p_pr_attribute18                 in  varchar2
  ,p_pr_attribute19                 in  varchar2
  ,p_pr_attribute20                 in  varchar2
  ,p_pr_attribute21                 in  varchar2
  ,p_pr_attribute22                 in  varchar2
  ,p_pr_attribute23                 in  varchar2
  ,p_pr_attribute24                 in  varchar2
  ,p_pr_attribute25                 in  varchar2
  ,p_pr_attribute26                 in  varchar2
  ,p_pr_attribute27                 in  varchar2
  ,p_pr_attribute28                 in  varchar2
  ,p_pr_attribute29                 in  varchar2
  ,p_pr_attribute30                 in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PAYROLL_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PAYROLL_RATE_a
  (
   p_pyrl_rt_id                     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_payroll_id                     in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_business_group_id              in  number
  ,p_pr_attribute_category          in  varchar2
  ,p_pr_attribute1                  in  varchar2
  ,p_pr_attribute2                  in  varchar2
  ,p_pr_attribute3                  in  varchar2
  ,p_pr_attribute4                  in  varchar2
  ,p_pr_attribute5                  in  varchar2
  ,p_pr_attribute6                  in  varchar2
  ,p_pr_attribute7                  in  varchar2
  ,p_pr_attribute8                  in  varchar2
  ,p_pr_attribute9                  in  varchar2
  ,p_pr_attribute10                 in  varchar2
  ,p_pr_attribute11                 in  varchar2
  ,p_pr_attribute12                 in  varchar2
  ,p_pr_attribute13                 in  varchar2
  ,p_pr_attribute14                 in  varchar2
  ,p_pr_attribute15                 in  varchar2
  ,p_pr_attribute16                 in  varchar2
  ,p_pr_attribute17                 in  varchar2
  ,p_pr_attribute18                 in  varchar2
  ,p_pr_attribute19                 in  varchar2
  ,p_pr_attribute20                 in  varchar2
  ,p_pr_attribute21                 in  varchar2
  ,p_pr_attribute22                 in  varchar2
  ,p_pr_attribute23                 in  varchar2
  ,p_pr_attribute24                 in  varchar2
  ,p_pr_attribute25                 in  varchar2
  ,p_pr_attribute26                 in  varchar2
  ,p_pr_attribute27                 in  varchar2
  ,p_pr_attribute28                 in  varchar2
  ,p_pr_attribute29                 in  varchar2
  ,p_pr_attribute30                 in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_PAYROLL_RATE_bk2;

 

/
