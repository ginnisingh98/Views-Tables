--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_PLAN_ENRT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_PLAN_ENRT_BK1" AUTHID CURRENT_USER as
/* $Header: belprapi.pkh 120.0 2005/05/28 03:32:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ler_chg_plan_enrt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ler_chg_plan_enrt_b
  (
   p_business_group_id              in  number
  ,p_plip_id                        in  number
  ,p_ler_id                         in  number
  ,p_tco_chg_enrt_cd                in  varchar2
  ,p_auto_enrt_mthd_rl              in  number
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_enrt_rl                   in  number
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2
  ,p_enrt_rl                        in  number
  ,p_enrt_cd                        in  varchar2
  ,p_lpr_attribute_category         in  varchar2
  ,p_lpr_attribute1                 in  varchar2
  ,p_lpr_attribute2                 in  varchar2
  ,p_lpr_attribute3                 in  varchar2
  ,p_lpr_attribute4                 in  varchar2
  ,p_lpr_attribute5                 in  varchar2
  ,p_lpr_attribute6                 in  varchar2
  ,p_lpr_attribute7                 in  varchar2
  ,p_lpr_attribute8                 in  varchar2
  ,p_lpr_attribute9                 in  varchar2
  ,p_lpr_attribute10                in  varchar2
  ,p_lpr_attribute11                in  varchar2
  ,p_lpr_attribute12                in  varchar2
  ,p_lpr_attribute13                in  varchar2
  ,p_lpr_attribute14                in  varchar2
  ,p_lpr_attribute15                in  varchar2
  ,p_lpr_attribute16                in  varchar2
  ,p_lpr_attribute17                in  varchar2
  ,p_lpr_attribute18                in  varchar2
  ,p_lpr_attribute19                in  varchar2
  ,p_lpr_attribute20                in  varchar2
  ,p_lpr_attribute21                in  varchar2
  ,p_lpr_attribute22                in  varchar2
  ,p_lpr_attribute23                in  varchar2
  ,p_lpr_attribute24                in  varchar2
  ,p_lpr_attribute25                in  varchar2
  ,p_lpr_attribute26                in  varchar2
  ,p_lpr_attribute27                in  varchar2
  ,p_lpr_attribute28                in  varchar2
  ,p_lpr_attribute29                in  varchar2
  ,p_lpr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ler_chg_plan_enrt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ler_chg_plan_enrt_a
  (
   p_ler_chg_plip_enrt_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_plip_id                        in  number
  ,p_ler_id                         in  number
  ,p_tco_chg_enrt_cd                in  varchar2
  ,p_auto_enrt_mthd_rl              in  number
  ,p_crnt_enrt_prclds_chg_flag      in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_dflt_enrt_cd                   in  varchar2
  ,p_dflt_enrt_rl                   in  number
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_stl_elig_cant_chg_flag         in  varchar2
  ,p_enrt_rl                        in  number
  ,p_enrt_cd                        in  varchar2
  ,p_lpr_attribute_category         in  varchar2
  ,p_lpr_attribute1                 in  varchar2
  ,p_lpr_attribute2                 in  varchar2
  ,p_lpr_attribute3                 in  varchar2
  ,p_lpr_attribute4                 in  varchar2
  ,p_lpr_attribute5                 in  varchar2
  ,p_lpr_attribute6                 in  varchar2
  ,p_lpr_attribute7                 in  varchar2
  ,p_lpr_attribute8                 in  varchar2
  ,p_lpr_attribute9                 in  varchar2
  ,p_lpr_attribute10                in  varchar2
  ,p_lpr_attribute11                in  varchar2
  ,p_lpr_attribute12                in  varchar2
  ,p_lpr_attribute13                in  varchar2
  ,p_lpr_attribute14                in  varchar2
  ,p_lpr_attribute15                in  varchar2
  ,p_lpr_attribute16                in  varchar2
  ,p_lpr_attribute17                in  varchar2
  ,p_lpr_attribute18                in  varchar2
  ,p_lpr_attribute19                in  varchar2
  ,p_lpr_attribute20                in  varchar2
  ,p_lpr_attribute21                in  varchar2
  ,p_lpr_attribute22                in  varchar2
  ,p_lpr_attribute23                in  varchar2
  ,p_lpr_attribute24                in  varchar2
  ,p_lpr_attribute25                in  varchar2
  ,p_lpr_attribute26                in  varchar2
  ,p_lpr_attribute27                in  varchar2
  ,p_lpr_attribute28                in  varchar2
  ,p_lpr_attribute29                in  varchar2
  ,p_lpr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ler_chg_plan_enrt_bk1;

 

/
