--------------------------------------------------------
--  DDL for Package BEN_LER_PER_INFO_CS_LER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_PER_INFO_CS_LER_BK2" AUTHID CURRENT_USER as
/* $Header: belplapi.pkh 120.0 2005/05/28 03:30:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Per_Info_Cs_Ler_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Per_Info_Cs_Ler_b
  (
   p_ler_per_info_cs_ler_id         in  number
  ,p_ler_per_info_cs_ler_rl         in  number
  ,p_per_info_chg_cs_ler_id         in  number
  ,p_ler_id                         in  number
  ,p_business_group_id              in  number
  ,p_lpl_attribute_category         in  varchar2
  ,p_lpl_attribute1                 in  varchar2
  ,p_lpl_attribute2                 in  varchar2
  ,p_lpl_attribute3                 in  varchar2
  ,p_lpl_attribute4                 in  varchar2
  ,p_lpl_attribute5                 in  varchar2
  ,p_lpl_attribute6                 in  varchar2
  ,p_lpl_attribute7                 in  varchar2
  ,p_lpl_attribute8                 in  varchar2
  ,p_lpl_attribute9                 in  varchar2
  ,p_lpl_attribute10                in  varchar2
  ,p_lpl_attribute11                in  varchar2
  ,p_lpl_attribute12                in  varchar2
  ,p_lpl_attribute13                in  varchar2
  ,p_lpl_attribute14                in  varchar2
  ,p_lpl_attribute15                in  varchar2
  ,p_lpl_attribute16                in  varchar2
  ,p_lpl_attribute17                in  varchar2
  ,p_lpl_attribute18                in  varchar2
  ,p_lpl_attribute19                in  varchar2
  ,p_lpl_attribute20                in  varchar2
  ,p_lpl_attribute21                in  varchar2
  ,p_lpl_attribute22                in  varchar2
  ,p_lpl_attribute23                in  varchar2
  ,p_lpl_attribute24                in  varchar2
  ,p_lpl_attribute25                in  varchar2
  ,p_lpl_attribute26                in  varchar2
  ,p_lpl_attribute27                in  varchar2
  ,p_lpl_attribute28                in  varchar2
  ,p_lpl_attribute29                in  varchar2
  ,p_lpl_attribute30                in  varchar2
  ,p_chg_mandatory_cd                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Per_Info_Cs_Ler_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Per_Info_Cs_Ler_a
  (
   p_ler_per_info_cs_ler_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ler_per_info_cs_ler_rl         in  number
  ,p_per_info_chg_cs_ler_id         in  number
  ,p_ler_id                         in  number
  ,p_business_group_id              in  number
  ,p_lpl_attribute_category         in  varchar2
  ,p_lpl_attribute1                 in  varchar2
  ,p_lpl_attribute2                 in  varchar2
  ,p_lpl_attribute3                 in  varchar2
  ,p_lpl_attribute4                 in  varchar2
  ,p_lpl_attribute5                 in  varchar2
  ,p_lpl_attribute6                 in  varchar2
  ,p_lpl_attribute7                 in  varchar2
  ,p_lpl_attribute8                 in  varchar2
  ,p_lpl_attribute9                 in  varchar2
  ,p_lpl_attribute10                in  varchar2
  ,p_lpl_attribute11                in  varchar2
  ,p_lpl_attribute12                in  varchar2
  ,p_lpl_attribute13                in  varchar2
  ,p_lpl_attribute14                in  varchar2
  ,p_lpl_attribute15                in  varchar2
  ,p_lpl_attribute16                in  varchar2
  ,p_lpl_attribute17                in  varchar2
  ,p_lpl_attribute18                in  varchar2
  ,p_lpl_attribute19                in  varchar2
  ,p_lpl_attribute20                in  varchar2
  ,p_lpl_attribute21                in  varchar2
  ,p_lpl_attribute22                in  varchar2
  ,p_lpl_attribute23                in  varchar2
  ,p_lpl_attribute24                in  varchar2
  ,p_lpl_attribute25                in  varchar2
  ,p_lpl_attribute26                in  varchar2
  ,p_lpl_attribute27                in  varchar2
  ,p_lpl_attribute28                in  varchar2
  ,p_lpl_attribute29                in  varchar2
  ,p_lpl_attribute30                in  varchar2
  ,p_chg_mandatory_cd                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Ler_Per_Info_Cs_Ler_bk2;

 

/
