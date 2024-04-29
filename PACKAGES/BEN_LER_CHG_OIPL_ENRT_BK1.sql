--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_OIPL_ENRT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_OIPL_ENRT_BK1" AUTHID CURRENT_USER as
/* $Header: belopapi.pkh 120.0 2005/05/28 03:27:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Ler_Chg_Oipl_Enrt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ler_Chg_Oipl_Enrt_b
  (
   p_business_group_id              in  number
  ,p_oipl_id                        in  number
  ,p_ler_id                         in  number
  ,p_auto_enrt_mthd_rl              in  number
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2
  ,p_enrt_cd                        in  varchar2
  ,p_enrt_rl                        in  number
  ,p_dflt_enrt_rl                   in  number
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2
  ,p_auto_enrt_flag                 in  varchar2
  ,p_lop_attribute_category         in  varchar2
  ,p_lop_attribute1                 in  varchar2
  ,p_lop_attribute2                 in  varchar2
  ,p_lop_attribute3                 in  varchar2
  ,p_lop_attribute4                 in  varchar2
  ,p_lop_attribute5                 in  varchar2
  ,p_lop_attribute6                 in  varchar2
  ,p_lop_attribute7                 in  varchar2
  ,p_lop_attribute8                 in  varchar2
  ,p_lop_attribute9                 in  varchar2
  ,p_lop_attribute10                in  varchar2
  ,p_lop_attribute11                in  varchar2
  ,p_lop_attribute12                in  varchar2
  ,p_lop_attribute13                in  varchar2
  ,p_lop_attribute14                in  varchar2
  ,p_lop_attribute15                in  varchar2
  ,p_lop_attribute16                in  varchar2
  ,p_lop_attribute17                in  varchar2
  ,p_lop_attribute18                in  varchar2
  ,p_lop_attribute19                in  varchar2
  ,p_lop_attribute20                in  varchar2
  ,p_lop_attribute21                in  varchar2
  ,p_lop_attribute22                in  varchar2
  ,p_lop_attribute23                in  varchar2
  ,p_lop_attribute24                in  varchar2
  ,p_lop_attribute25                in  varchar2
  ,p_lop_attribute26                in  varchar2
  ,p_lop_attribute27                in  varchar2
  ,p_lop_attribute28                in  varchar2
  ,p_lop_attribute29                in  varchar2
  ,p_lop_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Ler_Chg_Oipl_Enrt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ler_Chg_Oipl_Enrt_a
  (
   p_ler_chg_oipl_enrt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_oipl_id                        in  number
  ,p_ler_id                         in  number
  ,p_auto_enrt_mthd_rl              in  number
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2
  ,p_enrt_cd                        in  varchar2
  ,p_enrt_rl                        in  number
  ,p_dflt_enrt_rl                   in  number
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2
  ,p_auto_enrt_flag                 in  varchar2
  ,p_lop_attribute_category         in  varchar2
  ,p_lop_attribute1                 in  varchar2
  ,p_lop_attribute2                 in  varchar2
  ,p_lop_attribute3                 in  varchar2
  ,p_lop_attribute4                 in  varchar2
  ,p_lop_attribute5                 in  varchar2
  ,p_lop_attribute6                 in  varchar2
  ,p_lop_attribute7                 in  varchar2
  ,p_lop_attribute8                 in  varchar2
  ,p_lop_attribute9                 in  varchar2
  ,p_lop_attribute10                in  varchar2
  ,p_lop_attribute11                in  varchar2
  ,p_lop_attribute12                in  varchar2
  ,p_lop_attribute13                in  varchar2
  ,p_lop_attribute14                in  varchar2
  ,p_lop_attribute15                in  varchar2
  ,p_lop_attribute16                in  varchar2
  ,p_lop_attribute17                in  varchar2
  ,p_lop_attribute18                in  varchar2
  ,p_lop_attribute19                in  varchar2
  ,p_lop_attribute20                in  varchar2
  ,p_lop_attribute21                in  varchar2
  ,p_lop_attribute22                in  varchar2
  ,p_lop_attribute23                in  varchar2
  ,p_lop_attribute24                in  varchar2
  ,p_lop_attribute25                in  varchar2
  ,p_lop_attribute26                in  varchar2
  ,p_lop_attribute27                in  varchar2
  ,p_lop_attribute28                in  varchar2
  ,p_lop_attribute29                in  varchar2
  ,p_lop_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Ler_Chg_Oipl_Enrt_bk1;

 

/