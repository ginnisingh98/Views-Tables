--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_OIPL_ENRT_RL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_OIPL_ENRT_RL_BK2" AUTHID CURRENT_USER as
/* $Header: belouapi.pkh 120.0 2005/05/28 03:29:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Chg_Oipl_Enrt_Rl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Chg_Oipl_Enrt_Rl_b
  (
   p_ler_chg_oipl_enrt_rl_id        in  number
  ,p_business_group_id              in  number
  ,p_formula_id                     in  number
  ,p_ler_chg_oipl_enrt_id           in  number
  ,p_ordr_to_aply_num               in  number
  ,p_lou_attribute_category         in  varchar2
  ,p_lou_attribute1                 in  varchar2
  ,p_lou_attribute2                 in  varchar2
  ,p_lou_attribute3                 in  varchar2
  ,p_lou_attribute4                 in  varchar2
  ,p_lou_attribute5                 in  varchar2
  ,p_lou_attribute6                 in  varchar2
  ,p_lou_attribute7                 in  varchar2
  ,p_lou_attribute8                 in  varchar2
  ,p_lou_attribute9                 in  varchar2
  ,p_lou_attribute10                in  varchar2
  ,p_lou_attribute11                in  varchar2
  ,p_lou_attribute12                in  varchar2
  ,p_lou_attribute13                in  varchar2
  ,p_lou_attribute14                in  varchar2
  ,p_lou_attribute15                in  varchar2
  ,p_lou_attribute16                in  varchar2
  ,p_lou_attribute17                in  varchar2
  ,p_lou_attribute18                in  varchar2
  ,p_lou_attribute19                in  varchar2
  ,p_lou_attribute20                in  varchar2
  ,p_lou_attribute21                in  varchar2
  ,p_lou_attribute22                in  varchar2
  ,p_lou_attribute23                in  varchar2
  ,p_lou_attribute24                in  varchar2
  ,p_lou_attribute25                in  varchar2
  ,p_lou_attribute26                in  varchar2
  ,p_lou_attribute27                in  varchar2
  ,p_lou_attribute28                in  varchar2
  ,p_lou_attribute29                in  varchar2
  ,p_lou_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Ler_Chg_Oipl_Enrt_Rl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Chg_Oipl_Enrt_Rl_a
  (
   p_ler_chg_oipl_enrt_rl_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_formula_id                     in  number
  ,p_ler_chg_oipl_enrt_id           in  number
  ,p_ordr_to_aply_num               in  number
  ,p_lou_attribute_category         in  varchar2
  ,p_lou_attribute1                 in  varchar2
  ,p_lou_attribute2                 in  varchar2
  ,p_lou_attribute3                 in  varchar2
  ,p_lou_attribute4                 in  varchar2
  ,p_lou_attribute5                 in  varchar2
  ,p_lou_attribute6                 in  varchar2
  ,p_lou_attribute7                 in  varchar2
  ,p_lou_attribute8                 in  varchar2
  ,p_lou_attribute9                 in  varchar2
  ,p_lou_attribute10                in  varchar2
  ,p_lou_attribute11                in  varchar2
  ,p_lou_attribute12                in  varchar2
  ,p_lou_attribute13                in  varchar2
  ,p_lou_attribute14                in  varchar2
  ,p_lou_attribute15                in  varchar2
  ,p_lou_attribute16                in  varchar2
  ,p_lou_attribute17                in  varchar2
  ,p_lou_attribute18                in  varchar2
  ,p_lou_attribute19                in  varchar2
  ,p_lou_attribute20                in  varchar2
  ,p_lou_attribute21                in  varchar2
  ,p_lou_attribute22                in  varchar2
  ,p_lou_attribute23                in  varchar2
  ,p_lou_attribute24                in  varchar2
  ,p_lou_attribute25                in  varchar2
  ,p_lou_attribute26                in  varchar2
  ,p_lou_attribute27                in  varchar2
  ,p_lou_attribute28                in  varchar2
  ,p_lou_attribute29                in  varchar2
  ,p_lou_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Ler_Chg_Oipl_Enrt_Rl_bk2;

 

/
