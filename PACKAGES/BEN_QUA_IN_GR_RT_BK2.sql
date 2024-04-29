--------------------------------------------------------
--  DDL for Package BEN_QUA_IN_GR_RT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_QUA_IN_GR_RT_BK2" AUTHID CURRENT_USER as
/* $Header: beqigapi.pkh 120.0 2005/05/28 11:31:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_QUA_IN_GR_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_QUA_IN_GR_RT_b
  (
   p_qua_in_gr_rt_id                      in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_quar_in_grade_cd               in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_qig_attribute_category         in  varchar2
  ,p_qig_attribute1                 in  varchar2
  ,p_qig_attribute2                 in  varchar2
  ,p_qig_attribute3                 in  varchar2
  ,p_qig_attribute4                 in  varchar2
  ,p_qig_attribute5                 in  varchar2
  ,p_qig_attribute6                 in  varchar2
  ,p_qig_attribute7                 in  varchar2
  ,p_qig_attribute8                 in  varchar2
  ,p_qig_attribute9                 in  varchar2
  ,p_qig_attribute10                in  varchar2
  ,p_qig_attribute11                in  varchar2
  ,p_qig_attribute12                in  varchar2
  ,p_qig_attribute13                in  varchar2
  ,p_qig_attribute14                in  varchar2
  ,p_qig_attribute15                in  varchar2
  ,p_qig_attribute16                in  varchar2
  ,p_qig_attribute17                in  varchar2
  ,p_qig_attribute18                in  varchar2
  ,p_qig_attribute19                in  varchar2
  ,p_qig_attribute20                in  varchar2
  ,p_qig_attribute21                in  varchar2
  ,p_qig_attribute22                in  varchar2
  ,p_qig_attribute23                in  varchar2
  ,p_qig_attribute24                in  varchar2
  ,p_qig_attribute25                in  varchar2
  ,p_qig_attribute26                in  varchar2
  ,p_qig_attribute27                in  varchar2
  ,p_qig_attribute28                in  varchar2
  ,p_qig_attribute29                in  varchar2
  ,p_qig_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_QUA_IN_GR_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_QUA_IN_GR_RT_a
  (
   p_qua_in_gr_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_quar_in_grade_cd               in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_qig_attribute_category         in  varchar2
  ,p_qig_attribute1                 in  varchar2
  ,p_qig_attribute2                 in  varchar2
  ,p_qig_attribute3                 in  varchar2
  ,p_qig_attribute4                 in  varchar2
  ,p_qig_attribute5                 in  varchar2
  ,p_qig_attribute6                 in  varchar2
  ,p_qig_attribute7                 in  varchar2
  ,p_qig_attribute8                 in  varchar2
  ,p_qig_attribute9                 in  varchar2
  ,p_qig_attribute10                in  varchar2
  ,p_qig_attribute11                in  varchar2
  ,p_qig_attribute12                in  varchar2
  ,p_qig_attribute13                in  varchar2
  ,p_qig_attribute14                in  varchar2
  ,p_qig_attribute15                in  varchar2
  ,p_qig_attribute16                in  varchar2
  ,p_qig_attribute17                in  varchar2
  ,p_qig_attribute18                in  varchar2
  ,p_qig_attribute19                in  varchar2
  ,p_qig_attribute20                in  varchar2
  ,p_qig_attribute21                in  varchar2
  ,p_qig_attribute22                in  varchar2
  ,p_qig_attribute23                in  varchar2
  ,p_qig_attribute24                in  varchar2
  ,p_qig_attribute25                in  varchar2
  ,p_qig_attribute26                in  varchar2
  ,p_qig_attribute27                in  varchar2
  ,p_qig_attribute28                in  varchar2
  ,p_qig_attribute29                in  varchar2
  ,p_qig_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_QUA_IN_GR_RT_bk2;

 

/
