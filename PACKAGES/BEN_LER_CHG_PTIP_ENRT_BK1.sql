--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_PTIP_ENRT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_PTIP_ENRT_BK1" AUTHID CURRENT_USER as
/* $Header: belctapi.pkh 120.0 2005/05/28 03:18:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ler_chg_ptip_enrt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ler_chg_ptip_enrt_b
  (
   p_crnt_enrt_prclds_chg_flag      in  varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_enrt_rl                   in  varchar2
  ,p_enrt_cd                        in  varchar2
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_enrt_rl                        in  varchar2
  ,p_tco_chg_enrt_cd                in  varchar2
  ,p_ptip_id                        in  number
  ,p_ler_id                         in  number
  ,p_business_group_id              in  number
  ,p_lct_attribute_category         in  varchar2
  ,p_lct_attribute1                 in  varchar2
  ,p_lct_attribute2                 in  varchar2
  ,p_lct_attribute3                 in  varchar2
  ,p_lct_attribute4                 in  varchar2
  ,p_lct_attribute5                 in  varchar2
  ,p_lct_attribute6                 in  varchar2
  ,p_lct_attribute7                 in  varchar2
  ,p_lct_attribute8                 in  varchar2
  ,p_lct_attribute9                 in  varchar2
  ,p_lct_attribute10                in  varchar2
  ,p_lct_attribute11                in  varchar2
  ,p_lct_attribute12                in  varchar2
  ,p_lct_attribute13                in  varchar2
  ,p_lct_attribute14                in  varchar2
  ,p_lct_attribute15                in  varchar2
  ,p_lct_attribute16                in  varchar2
  ,p_lct_attribute17                in  varchar2
  ,p_lct_attribute18                in  varchar2
  ,p_lct_attribute19                in  varchar2
  ,p_lct_attribute20                in  varchar2
  ,p_lct_attribute21                in  varchar2
  ,p_lct_attribute22                in  varchar2
  ,p_lct_attribute23                in  varchar2
  ,p_lct_attribute24                in  varchar2
  ,p_lct_attribute25                in  varchar2
  ,p_lct_attribute26                in  varchar2
  ,p_lct_attribute27                in  varchar2
  ,p_lct_attribute28                in  varchar2
  ,p_lct_attribute29                in  varchar2
  ,p_lct_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ler_chg_ptip_enrt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ler_chg_ptip_enrt_a
  (
   p_ler_chg_ptip_enrt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_enrt_rl                   in  varchar2
  ,p_enrt_cd                        in  varchar2
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_enrt_rl                        in  varchar2
  ,p_tco_chg_enrt_cd                in  varchar2
  ,p_ptip_id                        in  number
  ,p_ler_id                         in  number
  ,p_business_group_id              in  number
  ,p_lct_attribute_category         in  varchar2
  ,p_lct_attribute1                 in  varchar2
  ,p_lct_attribute2                 in  varchar2
  ,p_lct_attribute3                 in  varchar2
  ,p_lct_attribute4                 in  varchar2
  ,p_lct_attribute5                 in  varchar2
  ,p_lct_attribute6                 in  varchar2
  ,p_lct_attribute7                 in  varchar2
  ,p_lct_attribute8                 in  varchar2
  ,p_lct_attribute9                 in  varchar2
  ,p_lct_attribute10                in  varchar2
  ,p_lct_attribute11                in  varchar2
  ,p_lct_attribute12                in  varchar2
  ,p_lct_attribute13                in  varchar2
  ,p_lct_attribute14                in  varchar2
  ,p_lct_attribute15                in  varchar2
  ,p_lct_attribute16                in  varchar2
  ,p_lct_attribute17                in  varchar2
  ,p_lct_attribute18                in  varchar2
  ,p_lct_attribute19                in  varchar2
  ,p_lct_attribute20                in  varchar2
  ,p_lct_attribute21                in  varchar2
  ,p_lct_attribute22                in  varchar2
  ,p_lct_attribute23                in  varchar2
  ,p_lct_attribute24                in  varchar2
  ,p_lct_attribute25                in  varchar2
  ,p_lct_attribute26                in  varchar2
  ,p_lct_attribute27                in  varchar2
  ,p_lct_attribute28                in  varchar2
  ,p_lct_attribute29                in  varchar2
  ,p_lct_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ler_chg_ptip_enrt_bk1;

 

/
