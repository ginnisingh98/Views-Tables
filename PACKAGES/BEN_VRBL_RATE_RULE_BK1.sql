--------------------------------------------------------
--  DDL for Package BEN_VRBL_RATE_RULE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_RATE_RULE_BK1" AUTHID CURRENT_USER as
/* $Header: bevrrapi.pkh 120.0 2005/05/28 12:13:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Vrbl_Rate_Rule_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Vrbl_Rate_Rule_b
  (
   p_drvbl_fctr_apls_flag           in  varchar2
  ,p_rt_trtmt_cd                    in  varchar2
  ,p_ordr_to_aply_num               in  number
  ,p_formula_id                     in  number
  ,p_acty_base_rt_id                in  number
  ,p_business_group_id              in  number
  ,p_vrr_attribute_category         in  varchar2
  ,p_vrr_attribute1                 in  varchar2
  ,p_vrr_attribute2                 in  varchar2
  ,p_vrr_attribute3                 in  varchar2
  ,p_vrr_attribute4                 in  varchar2
  ,p_vrr_attribute5                 in  varchar2
  ,p_vrr_attribute6                 in  varchar2
  ,p_vrr_attribute7                 in  varchar2
  ,p_vrr_attribute8                 in  varchar2
  ,p_vrr_attribute9                 in  varchar2
  ,p_vrr_attribute10                in  varchar2
  ,p_vrr_attribute11                in  varchar2
  ,p_vrr_attribute12                in  varchar2
  ,p_vrr_attribute13                in  varchar2
  ,p_vrr_attribute14                in  varchar2
  ,p_vrr_attribute15                in  varchar2
  ,p_vrr_attribute16                in  varchar2
  ,p_vrr_attribute17                in  varchar2
  ,p_vrr_attribute18                in  varchar2
  ,p_vrr_attribute19                in  varchar2
  ,p_vrr_attribute20                in  varchar2
  ,p_vrr_attribute21                in  varchar2
  ,p_vrr_attribute22                in  varchar2
  ,p_vrr_attribute23                in  varchar2
  ,p_vrr_attribute24                in  varchar2
  ,p_vrr_attribute25                in  varchar2
  ,p_vrr_attribute26                in  varchar2
  ,p_vrr_attribute27                in  varchar2
  ,p_vrr_attribute28                in  varchar2
  ,p_vrr_attribute29                in  varchar2
  ,p_vrr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Vrbl_Rate_Rule_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Vrbl_Rate_Rule_a
  (
   p_vrbl_rt_rl_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_drvbl_fctr_apls_flag           in  varchar2
  ,p_rt_trtmt_cd                    in  varchar2
  ,p_ordr_to_aply_num               in  number
  ,p_formula_id                     in  number
  ,p_acty_base_rt_id                in  number
  ,p_business_group_id              in  number
  ,p_vrr_attribute_category         in  varchar2
  ,p_vrr_attribute1                 in  varchar2
  ,p_vrr_attribute2                 in  varchar2
  ,p_vrr_attribute3                 in  varchar2
  ,p_vrr_attribute4                 in  varchar2
  ,p_vrr_attribute5                 in  varchar2
  ,p_vrr_attribute6                 in  varchar2
  ,p_vrr_attribute7                 in  varchar2
  ,p_vrr_attribute8                 in  varchar2
  ,p_vrr_attribute9                 in  varchar2
  ,p_vrr_attribute10                in  varchar2
  ,p_vrr_attribute11                in  varchar2
  ,p_vrr_attribute12                in  varchar2
  ,p_vrr_attribute13                in  varchar2
  ,p_vrr_attribute14                in  varchar2
  ,p_vrr_attribute15                in  varchar2
  ,p_vrr_attribute16                in  varchar2
  ,p_vrr_attribute17                in  varchar2
  ,p_vrr_attribute18                in  varchar2
  ,p_vrr_attribute19                in  varchar2
  ,p_vrr_attribute20                in  varchar2
  ,p_vrr_attribute21                in  varchar2
  ,p_vrr_attribute22                in  varchar2
  ,p_vrr_attribute23                in  varchar2
  ,p_vrr_attribute24                in  varchar2
  ,p_vrr_attribute25                in  varchar2
  ,p_vrr_attribute26                in  varchar2
  ,p_vrr_attribute27                in  varchar2
  ,p_vrr_attribute28                in  varchar2
  ,p_vrr_attribute29                in  varchar2
  ,p_vrr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Vrbl_Rate_Rule_bk1;

 

/
