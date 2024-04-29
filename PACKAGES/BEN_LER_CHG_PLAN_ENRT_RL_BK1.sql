--------------------------------------------------------
--  DDL for Package BEN_LER_CHG_PLAN_ENRT_RL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_CHG_PLAN_ENRT_RL_BK1" AUTHID CURRENT_USER as
/* $Header: belorapi.pkh 120.0 2005/05/28 03:28:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Ler_Chg_Plan_Enrt_Rl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ler_Chg_Plan_Enrt_Rl_b
  (
   p_business_group_id              in  number
  ,p_formula_id                     in  number
  ,p_ler_chg_plip_enrt_id           in  number
  ,p_ordr_to_aply_num               in  number
  ,p_lor_attribute_category         in  varchar2
  ,p_lor_attribute1                 in  varchar2
  ,p_lor_attribute2                 in  varchar2
  ,p_lor_attribute3                 in  varchar2
  ,p_lor_attribute4                 in  varchar2
  ,p_lor_attribute5                 in  varchar2
  ,p_lor_attribute6                 in  varchar2
  ,p_lor_attribute7                 in  varchar2
  ,p_lor_attribute8                 in  varchar2
  ,p_lor_attribute9                 in  varchar2
  ,p_lor_attribute10                in  varchar2
  ,p_lor_attribute11                in  varchar2
  ,p_lor_attribute12                in  varchar2
  ,p_lor_attribute13                in  varchar2
  ,p_lor_attribute14                in  varchar2
  ,p_lor_attribute15                in  varchar2
  ,p_lor_attribute16                in  varchar2
  ,p_lor_attribute17                in  varchar2
  ,p_lor_attribute18                in  varchar2
  ,p_lor_attribute19                in  varchar2
  ,p_lor_attribute20                in  varchar2
  ,p_lor_attribute21                in  varchar2
  ,p_lor_attribute22                in  varchar2
  ,p_lor_attribute23                in  varchar2
  ,p_lor_attribute24                in  varchar2
  ,p_lor_attribute25                in  varchar2
  ,p_lor_attribute26                in  varchar2
  ,p_lor_attribute27                in  varchar2
  ,p_lor_attribute28                in  varchar2
  ,p_lor_attribute29                in  varchar2
  ,p_lor_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Ler_Chg_Plan_Enrt_Rl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ler_Chg_Plan_Enrt_Rl_a
  (
   p_ler_chg_plip_enrt_rl_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_formula_id                     in  number
  ,p_ler_chg_plip_enrt_id           in  number
  ,p_ordr_to_aply_num               in  number
  ,p_lor_attribute_category         in  varchar2
  ,p_lor_attribute1                 in  varchar2
  ,p_lor_attribute2                 in  varchar2
  ,p_lor_attribute3                 in  varchar2
  ,p_lor_attribute4                 in  varchar2
  ,p_lor_attribute5                 in  varchar2
  ,p_lor_attribute6                 in  varchar2
  ,p_lor_attribute7                 in  varchar2
  ,p_lor_attribute8                 in  varchar2
  ,p_lor_attribute9                 in  varchar2
  ,p_lor_attribute10                in  varchar2
  ,p_lor_attribute11                in  varchar2
  ,p_lor_attribute12                in  varchar2
  ,p_lor_attribute13                in  varchar2
  ,p_lor_attribute14                in  varchar2
  ,p_lor_attribute15                in  varchar2
  ,p_lor_attribute16                in  varchar2
  ,p_lor_attribute17                in  varchar2
  ,p_lor_attribute18                in  varchar2
  ,p_lor_attribute19                in  varchar2
  ,p_lor_attribute20                in  varchar2
  ,p_lor_attribute21                in  varchar2
  ,p_lor_attribute22                in  varchar2
  ,p_lor_attribute23                in  varchar2
  ,p_lor_attribute24                in  varchar2
  ,p_lor_attribute25                in  varchar2
  ,p_lor_attribute26                in  varchar2
  ,p_lor_attribute27                in  varchar2
  ,p_lor_attribute28                in  varchar2
  ,p_lor_attribute29                in  varchar2
  ,p_lor_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Ler_Chg_Plan_Enrt_Rl_bk1;

 

/
