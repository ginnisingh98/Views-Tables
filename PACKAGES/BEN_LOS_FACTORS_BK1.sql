--------------------------------------------------------
--  DDL for Package BEN_LOS_FACTORS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOS_FACTORS_BK1" AUTHID CURRENT_USER as
/* $Header: belsfapi.pkh 120.0 2005/05/28 03:37:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_LOS_FACTORS_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_LOS_FACTORS_b
  (
   p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_los_det_cd                     in  varchar2
  ,p_los_det_rl                     in  number
  ,p_mn_los_num                     in  number
  ,p_mx_los_num                     in  number
  ,p_no_mx_los_num_apls_flag        in  varchar2
  ,p_no_mn_los_num_apls_flag        in  varchar2
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_los_dt_to_use_cd               in  varchar2
  ,p_los_dt_to_use_rl               in  number
  ,p_los_uom                        in  varchar2
  ,p_los_calc_rl                    in  number
  ,p_los_alt_val_to_use_cd          in  varchar2
  ,p_lsf_attribute_category         in  varchar2
  ,p_lsf_attribute1                 in  varchar2
  ,p_lsf_attribute2                 in  varchar2
  ,p_lsf_attribute3                 in  varchar2
  ,p_lsf_attribute4                 in  varchar2
  ,p_lsf_attribute5                 in  varchar2
  ,p_lsf_attribute6                 in  varchar2
  ,p_lsf_attribute7                 in  varchar2
  ,p_lsf_attribute8                 in  varchar2
  ,p_lsf_attribute9                 in  varchar2
  ,p_lsf_attribute10                in  varchar2
  ,p_lsf_attribute11                in  varchar2
  ,p_lsf_attribute12                in  varchar2
  ,p_lsf_attribute13                in  varchar2
  ,p_lsf_attribute14                in  varchar2
  ,p_lsf_attribute15                in  varchar2
  ,p_lsf_attribute16                in  varchar2
  ,p_lsf_attribute17                in  varchar2
  ,p_lsf_attribute18                in  varchar2
  ,p_lsf_attribute19                in  varchar2
  ,p_lsf_attribute20                in  varchar2
  ,p_lsf_attribute21                in  varchar2
  ,p_lsf_attribute22                in  varchar2
  ,p_lsf_attribute23                in  varchar2
  ,p_lsf_attribute24                in  varchar2
  ,p_lsf_attribute25                in  varchar2
  ,p_lsf_attribute26                in  varchar2
  ,p_lsf_attribute27                in  varchar2
  ,p_lsf_attribute28                in  varchar2
  ,p_lsf_attribute29                in  varchar2
  ,p_lsf_attribute30                in  varchar2
  ,p_use_overid_svc_dt_flag         in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_LOS_FACTORS_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_LOS_FACTORS_a
  (
   p_los_fctr_id                    in  number
  ,p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_los_det_cd                     in  varchar2
  ,p_los_det_rl                     in  number
  ,p_mn_los_num                     in  number
  ,p_mx_los_num                     in  number
  ,p_no_mx_los_num_apls_flag        in  varchar2
  ,p_no_mn_los_num_apls_flag        in  varchar2
  ,p_rndg_cd                        in  varchar2
  ,p_rndg_rl                        in  number
  ,p_los_dt_to_use_cd               in  varchar2
  ,p_los_dt_to_use_rl               in  number
  ,p_los_uom                        in  varchar2
  ,p_los_calc_rl                    in  number
  ,p_los_alt_val_to_use_cd          in  varchar2
  ,p_lsf_attribute_category         in  varchar2
  ,p_lsf_attribute1                 in  varchar2
  ,p_lsf_attribute2                 in  varchar2
  ,p_lsf_attribute3                 in  varchar2
  ,p_lsf_attribute4                 in  varchar2
  ,p_lsf_attribute5                 in  varchar2
  ,p_lsf_attribute6                 in  varchar2
  ,p_lsf_attribute7                 in  varchar2
  ,p_lsf_attribute8                 in  varchar2
  ,p_lsf_attribute9                 in  varchar2
  ,p_lsf_attribute10                in  varchar2
  ,p_lsf_attribute11                in  varchar2
  ,p_lsf_attribute12                in  varchar2
  ,p_lsf_attribute13                in  varchar2
  ,p_lsf_attribute14                in  varchar2
  ,p_lsf_attribute15                in  varchar2
  ,p_lsf_attribute16                in  varchar2
  ,p_lsf_attribute17                in  varchar2
  ,p_lsf_attribute18                in  varchar2
  ,p_lsf_attribute19                in  varchar2
  ,p_lsf_attribute20                in  varchar2
  ,p_lsf_attribute21                in  varchar2
  ,p_lsf_attribute22                in  varchar2
  ,p_lsf_attribute23                in  varchar2
  ,p_lsf_attribute24                in  varchar2
  ,p_lsf_attribute25                in  varchar2
  ,p_lsf_attribute26                in  varchar2
  ,p_lsf_attribute27                in  varchar2
  ,p_lsf_attribute28                in  varchar2
  ,p_lsf_attribute29                in  varchar2
  ,p_lsf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_use_overid_svc_dt_flag         in  varchar2
  ,p_effective_date                 in  date
  );
--
end ben_LOS_FACTORS_bk1;

 

/
