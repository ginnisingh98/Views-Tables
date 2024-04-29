--------------------------------------------------------
--  DDL for Package BEN_LER_RLTD_PER_CS_LER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_RLTD_PER_CS_LER_BK2" AUTHID CURRENT_USER as
/* $Header: belrcapi.pkh 120.0 2005/05/28 03:33:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Rltd_Per_Cs_Ler_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Rltd_Per_Cs_Ler_b
  (
   p_ler_rltd_per_cs_ler_id         in  number
  ,p_ler_rltd_per_cs_chg_rl         in  number
  ,p_ler_id                         in  number
  ,p_rltd_per_chg_cs_ler_id         in  number
  ,p_business_group_id              in  number
  ,p_lrc_attribute_category         in  varchar2
  ,p_lrc_attribute1                 in  varchar2
  ,p_lrc_attribute2                 in  varchar2
  ,p_lrc_attribute3                 in  varchar2
  ,p_lrc_attribute4                 in  varchar2
  ,p_lrc_attribute5                 in  varchar2
  ,p_lrc_attribute6                 in  varchar2
  ,p_lrc_attribute7                 in  varchar2
  ,p_lrc_attribute8                 in  varchar2
  ,p_lrc_attribute9                 in  varchar2
  ,p_lrc_attribute10                in  varchar2
  ,p_lrc_attribute11                in  varchar2
  ,p_lrc_attribute12                in  varchar2
  ,p_lrc_attribute13                in  varchar2
  ,p_lrc_attribute14                in  varchar2
  ,p_lrc_attribute15                in  varchar2
  ,p_lrc_attribute16                in  varchar2
  ,p_lrc_attribute17                in  varchar2
  ,p_lrc_attribute18                in  varchar2
  ,p_lrc_attribute19                in  varchar2
  ,p_lrc_attribute20                in  varchar2
  ,p_lrc_attribute21                in  varchar2
  ,p_lrc_attribute22                in  varchar2
  ,p_lrc_attribute23                in  varchar2
  ,p_lrc_attribute24                in  varchar2
  ,p_lrc_attribute25                in  varchar2
  ,p_lrc_attribute26                in  varchar2
  ,p_lrc_attribute27                in  varchar2
  ,p_lrc_attribute28                in  varchar2
  ,p_lrc_attribute29                in  varchar2
  ,p_lrc_attribute30                in  varchar2
  ,p_chg_mandatory_cd                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Rltd_Per_Cs_Ler_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Rltd_Per_Cs_Ler_a
  (
   p_ler_rltd_per_cs_ler_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ler_rltd_per_cs_chg_rl         in  number
  ,p_ler_id                         in  number
  ,p_rltd_per_chg_cs_ler_id         in  number
  ,p_business_group_id              in  number
  ,p_lrc_attribute_category         in  varchar2
  ,p_lrc_attribute1                 in  varchar2
  ,p_lrc_attribute2                 in  varchar2
  ,p_lrc_attribute3                 in  varchar2
  ,p_lrc_attribute4                 in  varchar2
  ,p_lrc_attribute5                 in  varchar2
  ,p_lrc_attribute6                 in  varchar2
  ,p_lrc_attribute7                 in  varchar2
  ,p_lrc_attribute8                 in  varchar2
  ,p_lrc_attribute9                 in  varchar2
  ,p_lrc_attribute10                in  varchar2
  ,p_lrc_attribute11                in  varchar2
  ,p_lrc_attribute12                in  varchar2
  ,p_lrc_attribute13                in  varchar2
  ,p_lrc_attribute14                in  varchar2
  ,p_lrc_attribute15                in  varchar2
  ,p_lrc_attribute16                in  varchar2
  ,p_lrc_attribute17                in  varchar2
  ,p_lrc_attribute18                in  varchar2
  ,p_lrc_attribute19                in  varchar2
  ,p_lrc_attribute20                in  varchar2
  ,p_lrc_attribute21                in  varchar2
  ,p_lrc_attribute22                in  varchar2
  ,p_lrc_attribute23                in  varchar2
  ,p_lrc_attribute24                in  varchar2
  ,p_lrc_attribute25                in  varchar2
  ,p_lrc_attribute26                in  varchar2
  ,p_lrc_attribute27                in  varchar2
  ,p_lrc_attribute28                in  varchar2
  ,p_lrc_attribute29                in  varchar2
  ,p_lrc_attribute30                in  varchar2
  ,p_chg_mandatory_cd                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Ler_Rltd_Per_Cs_Ler_bk2;

 

/