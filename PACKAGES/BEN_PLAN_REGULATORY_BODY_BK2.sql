--------------------------------------------------------
--  DDL for Package BEN_PLAN_REGULATORY_BODY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_REGULATORY_BODY_BK2" AUTHID CURRENT_USER as
/* $Header: beprbapi.pkh 120.0 2005/05/28 11:03:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_Regulatory_body_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Regulatory_body_b
  (
   p_pl_regy_bod_id                 in  number
  ,p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_rptg_grp_id                    in  number
  ,p_quald_dt                       in  date
  ,p_quald_flag                     in  varchar2
  ,p_regy_pl_name                   in  varchar2
  ,p_aprvd_trmn_dt                  in  date
  ,p_prb_attribute_category         in  varchar2
  ,p_prb_attribute1                 in  varchar2
  ,p_prb_attribute2                 in  varchar2
  ,p_prb_attribute3                 in  varchar2
  ,p_prb_attribute4                 in  varchar2
  ,p_prb_attribute5                 in  varchar2
  ,p_prb_attribute6                 in  varchar2
  ,p_prb_attribute7                 in  varchar2
  ,p_prb_attribute8                 in  varchar2
  ,p_prb_attribute9                 in  varchar2
  ,p_prb_attribute10                in  varchar2
  ,p_prb_attribute11                in  varchar2
  ,p_prb_attribute12                in  varchar2
  ,p_prb_attribute13                in  varchar2
  ,p_prb_attribute14                in  varchar2
  ,p_prb_attribute15                in  varchar2
  ,p_prb_attribute16                in  varchar2
  ,p_prb_attribute17                in  varchar2
  ,p_prb_attribute18                in  varchar2
  ,p_prb_attribute19                in  varchar2
  ,p_prb_attribute20                in  varchar2
  ,p_prb_attribute21                in  varchar2
  ,p_prb_attribute22                in  varchar2
  ,p_prb_attribute23                in  varchar2
  ,p_prb_attribute24                in  varchar2
  ,p_prb_attribute25                in  varchar2
  ,p_prb_attribute26                in  varchar2
  ,p_prb_attribute27                in  varchar2
  ,p_prb_attribute28                in  varchar2
  ,p_prb_attribute29                in  varchar2
  ,p_prb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Plan_Regulatory_body_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_Regulatory_body_a
  (
   p_pl_regy_bod_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_rptg_grp_id                    in  number
  ,p_quald_dt                       in  date
  ,p_quald_flag                     in  varchar2
  ,p_regy_pl_name                   in  varchar2
  ,p_aprvd_trmn_dt                  in  date
  ,p_prb_attribute_category         in  varchar2
  ,p_prb_attribute1                 in  varchar2
  ,p_prb_attribute2                 in  varchar2
  ,p_prb_attribute3                 in  varchar2
  ,p_prb_attribute4                 in  varchar2
  ,p_prb_attribute5                 in  varchar2
  ,p_prb_attribute6                 in  varchar2
  ,p_prb_attribute7                 in  varchar2
  ,p_prb_attribute8                 in  varchar2
  ,p_prb_attribute9                 in  varchar2
  ,p_prb_attribute10                in  varchar2
  ,p_prb_attribute11                in  varchar2
  ,p_prb_attribute12                in  varchar2
  ,p_prb_attribute13                in  varchar2
  ,p_prb_attribute14                in  varchar2
  ,p_prb_attribute15                in  varchar2
  ,p_prb_attribute16                in  varchar2
  ,p_prb_attribute17                in  varchar2
  ,p_prb_attribute18                in  varchar2
  ,p_prb_attribute19                in  varchar2
  ,p_prb_attribute20                in  varchar2
  ,p_prb_attribute21                in  varchar2
  ,p_prb_attribute22                in  varchar2
  ,p_prb_attribute23                in  varchar2
  ,p_prb_attribute24                in  varchar2
  ,p_prb_attribute25                in  varchar2
  ,p_prb_attribute26                in  varchar2
  ,p_prb_attribute27                in  varchar2
  ,p_prb_attribute28                in  varchar2
  ,p_prb_attribute29                in  varchar2
  ,p_prb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Plan_Regulatory_body_bk2;

 

/
