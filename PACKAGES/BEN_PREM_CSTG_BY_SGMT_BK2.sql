--------------------------------------------------------
--  DDL for Package BEN_PREM_CSTG_BY_SGMT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PREM_CSTG_BY_SGMT_BK2" AUTHID CURRENT_USER as
/* $Header: becbsapi.pkh 120.0 2005/05/28 00:56:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PREM_CSTG_BY_SGMT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PREM_CSTG_BY_SGMT_b
  (
   p_prem_cstg_by_sgmt_id           in  number
  ,p_sgmt_num                       in  number
  ,p_sgmt_cstg_mthd_cd              in  varchar2
  ,p_sgmt_cstg_mthd_rl              in  number
  ,p_business_group_id              in  number
  ,p_actl_prem_id                   in  number
  ,p_cbs_attribute_category         in  varchar2
  ,p_cbs_attribute1                 in  varchar2
  ,p_cbs_attribute2                 in  varchar2
  ,p_cbs_attribute3                 in  varchar2
  ,p_cbs_attribute4                 in  varchar2
  ,p_cbs_attribute5                 in  varchar2
  ,p_cbs_attribute6                 in  varchar2
  ,p_cbs_attribute7                 in  varchar2
  ,p_cbs_attribute8                 in  varchar2
  ,p_cbs_attribute9                 in  varchar2
  ,p_cbs_attribute10                in  varchar2
  ,p_cbs_attribute11                in  varchar2
  ,p_cbs_attribute12                in  varchar2
  ,p_cbs_attribute13                in  varchar2
  ,p_cbs_attribute14                in  varchar2
  ,p_cbs_attribute15                in  varchar2
  ,p_cbs_attribute16                in  varchar2
  ,p_cbs_attribute17                in  varchar2
  ,p_cbs_attribute18                in  varchar2
  ,p_cbs_attribute19                in  varchar2
  ,p_cbs_attribute20                in  varchar2
  ,p_cbs_attribute21                in  varchar2
  ,p_cbs_attribute22                in  varchar2
  ,p_cbs_attribute23                in  varchar2
  ,p_cbs_attribute24                in  varchar2
  ,p_cbs_attribute25                in  varchar2
  ,p_cbs_attribute26                in  varchar2
  ,p_cbs_attribute27                in  varchar2
  ,p_cbs_attribute28                in  varchar2
  ,p_cbs_attribute29                in  varchar2
  ,p_cbs_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PREM_CSTG_BY_SGMT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PREM_CSTG_BY_SGMT_a
  (
   p_prem_cstg_by_sgmt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_sgmt_num                       in  number
  ,p_sgmt_cstg_mthd_cd              in  varchar2
  ,p_sgmt_cstg_mthd_rl              in  number
  ,p_business_group_id              in  number
  ,p_actl_prem_id                   in  number
  ,p_cbs_attribute_category         in  varchar2
  ,p_cbs_attribute1                 in  varchar2
  ,p_cbs_attribute2                 in  varchar2
  ,p_cbs_attribute3                 in  varchar2
  ,p_cbs_attribute4                 in  varchar2
  ,p_cbs_attribute5                 in  varchar2
  ,p_cbs_attribute6                 in  varchar2
  ,p_cbs_attribute7                 in  varchar2
  ,p_cbs_attribute8                 in  varchar2
  ,p_cbs_attribute9                 in  varchar2
  ,p_cbs_attribute10                in  varchar2
  ,p_cbs_attribute11                in  varchar2
  ,p_cbs_attribute12                in  varchar2
  ,p_cbs_attribute13                in  varchar2
  ,p_cbs_attribute14                in  varchar2
  ,p_cbs_attribute15                in  varchar2
  ,p_cbs_attribute16                in  varchar2
  ,p_cbs_attribute17                in  varchar2
  ,p_cbs_attribute18                in  varchar2
  ,p_cbs_attribute19                in  varchar2
  ,p_cbs_attribute20                in  varchar2
  ,p_cbs_attribute21                in  varchar2
  ,p_cbs_attribute22                in  varchar2
  ,p_cbs_attribute23                in  varchar2
  ,p_cbs_attribute24                in  varchar2
  ,p_cbs_attribute25                in  varchar2
  ,p_cbs_attribute26                in  varchar2
  ,p_cbs_attribute27                in  varchar2
  ,p_cbs_attribute28                in  varchar2
  ,p_cbs_attribute29                in  varchar2
  ,p_cbs_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_PREM_CSTG_BY_SGMT_bk2;

 

/
