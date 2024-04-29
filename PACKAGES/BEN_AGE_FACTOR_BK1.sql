--------------------------------------------------------
--  DDL for Package BEN_AGE_FACTOR_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AGE_FACTOR_BK1" AUTHID CURRENT_USER as
/* $Header: beagfapi.pkh 120.0 2005/05/28 00:22:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_age_factor_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_age_factor_b
  (
   p_name                           in  varchar2
  ,p_mx_age_num                     in  number
  ,p_mn_age_num                     in  number
  ,p_age_uom                        in  varchar2
  ,p_no_mn_age_flag                 in  varchar2
  ,p_no_mx_age_flag                 in  varchar2
  ,p_age_to_use_cd                  in  varchar2
  ,p_age_det_cd                     in  varchar2
  ,p_age_det_rl                     in  number
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_age_calc_rl                    in  number
  ,p_business_group_id              in  number
  ,p_agf_attribute_category         in  varchar2
  ,p_agf_attribute1                 in  varchar2
  ,p_agf_attribute2                 in  varchar2
  ,p_agf_attribute3                 in  varchar2
  ,p_agf_attribute4                 in  varchar2
  ,p_agf_attribute5                 in  varchar2
  ,p_agf_attribute6                 in  varchar2
  ,p_agf_attribute7                 in  varchar2
  ,p_agf_attribute8                 in  varchar2
  ,p_agf_attribute9                 in  varchar2
  ,p_agf_attribute10                in  varchar2
  ,p_agf_attribute11                in  varchar2
  ,p_agf_attribute12                in  varchar2
  ,p_agf_attribute13                in  varchar2
  ,p_agf_attribute14                in  varchar2
  ,p_agf_attribute15                in  varchar2
  ,p_agf_attribute16                in  varchar2
  ,p_agf_attribute17                in  varchar2
  ,p_agf_attribute18                in  varchar2
  ,p_agf_attribute19                in  varchar2
  ,p_agf_attribute20                in  varchar2
  ,p_agf_attribute21                in  varchar2
  ,p_agf_attribute22                in  varchar2
  ,p_agf_attribute23                in  varchar2
  ,p_agf_attribute24                in  varchar2
  ,p_agf_attribute25                in  varchar2
  ,p_agf_attribute26                in  varchar2
  ,p_agf_attribute27                in  varchar2
  ,p_agf_attribute28                in  varchar2
  ,p_agf_attribute29                in  varchar2
  ,p_agf_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_age_factor_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_age_factor_a
  (
   p_age_fctr_id                    in  number
  ,p_name                           in  varchar2
  ,p_mx_age_num                     in  number
  ,p_mn_age_num                     in  number
  ,p_age_uom                        in  varchar2
  ,p_no_mn_age_flag                 in  varchar2
  ,p_no_mx_age_flag                 in  varchar2
  ,p_age_to_use_cd                  in  varchar2
  ,p_age_det_cd                     in  varchar2
  ,p_age_det_rl                     in  number
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_age_calc_rl                    in  number
  ,p_business_group_id              in  number
  ,p_agf_attribute_category         in  varchar2
  ,p_agf_attribute1                 in  varchar2
  ,p_agf_attribute2                 in  varchar2
  ,p_agf_attribute3                 in  varchar2
  ,p_agf_attribute4                 in  varchar2
  ,p_agf_attribute5                 in  varchar2
  ,p_agf_attribute6                 in  varchar2
  ,p_agf_attribute7                 in  varchar2
  ,p_agf_attribute8                 in  varchar2
  ,p_agf_attribute9                 in  varchar2
  ,p_agf_attribute10                in  varchar2
  ,p_agf_attribute11                in  varchar2
  ,p_agf_attribute12                in  varchar2
  ,p_agf_attribute13                in  varchar2
  ,p_agf_attribute14                in  varchar2
  ,p_agf_attribute15                in  varchar2
  ,p_agf_attribute16                in  varchar2
  ,p_agf_attribute17                in  varchar2
  ,p_agf_attribute18                in  varchar2
  ,p_agf_attribute19                in  varchar2
  ,p_agf_attribute20                in  varchar2
  ,p_agf_attribute21                in  varchar2
  ,p_agf_attribute22                in  varchar2
  ,p_agf_attribute23                in  varchar2
  ,p_agf_attribute24                in  varchar2
  ,p_agf_attribute25                in  varchar2
  ,p_agf_attribute26                in  varchar2
  ,p_agf_attribute27                in  varchar2
  ,p_agf_attribute28                in  varchar2
  ,p_agf_attribute29                in  varchar2
  ,p_agf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_age_factor_bk1;

 

/
