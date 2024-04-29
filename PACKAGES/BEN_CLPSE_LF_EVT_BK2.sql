--------------------------------------------------------
--  DDL for Package BEN_CLPSE_LF_EVT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLPSE_LF_EVT_BK2" AUTHID CURRENT_USER as
/* $Header: beclpapi.pkh 120.0 2005/05/28 01:04:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_clpse_lf_evt_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_clpse_lf_evt_b
  (p_clpse_lf_evt_id                in  number
  ,p_business_group_id              in  number
  ,p_seq                            in  number
  ,p_ler1_id                        in  number
  ,p_bool1_cd                       in  varchar2
  ,p_ler2_id                        in  number
  ,p_bool2_cd                       in  varchar2
  ,p_ler3_id                        in  number
  ,p_bool3_cd                       in  varchar2
  ,p_ler4_id                        in  number
  ,p_bool4_cd                       in  varchar2
  ,p_ler5_id                        in  number
  ,p_bool5_cd                       in  varchar2
  ,p_ler6_id                        in  number
  ,p_bool6_cd                       in  varchar2
  ,p_ler7_id                        in  number
  ,p_bool7_cd                       in  varchar2
  ,p_ler8_id                        in  number
  ,p_bool8_cd                       in  varchar2
  ,p_ler9_id                        in  number
  ,p_bool9_cd                       in  varchar2
  ,p_ler10_id                       in  number
  ,p_eval_cd                        in  varchar2
  ,p_eval_rl                        in  number
  ,p_tlrnc_dys_num                  in  number
  ,p_eval_ler_id                    in  number
  ,p_eval_ler_det_cd                in  varchar2
  ,p_eval_ler_det_rl                in  number
  ,p_clp_attribute_category         in  varchar2
  ,p_clp_attribute1                 in  varchar2
  ,p_clp_attribute2                 in  varchar2
  ,p_clp_attribute3                 in  varchar2
  ,p_clp_attribute4                 in  varchar2
  ,p_clp_attribute5                 in  varchar2
  ,p_clp_attribute6                 in  varchar2
  ,p_clp_attribute7                 in  varchar2
  ,p_clp_attribute8                 in  varchar2
  ,p_clp_attribute9                 in  varchar2
  ,p_clp_attribute10                in  varchar2
  ,p_clp_attribute11                in  varchar2
  ,p_clp_attribute12                in  varchar2
  ,p_clp_attribute13                in  varchar2
  ,p_clp_attribute14                in  varchar2
  ,p_clp_attribute15                in  varchar2
  ,p_clp_attribute16                in  varchar2
  ,p_clp_attribute17                in  varchar2
  ,p_clp_attribute18                in  varchar2
  ,p_clp_attribute19                in  varchar2
  ,p_clp_attribute20                in  varchar2
  ,p_clp_attribute21                in  varchar2
  ,p_clp_attribute22                in  varchar2
  ,p_clp_attribute23                in  varchar2
  ,p_clp_attribute24                in  varchar2
  ,p_clp_attribute25                in  varchar2
  ,p_clp_attribute26                in  varchar2
  ,p_clp_attribute27                in  varchar2
  ,p_clp_attribute28                in  varchar2
  ,p_clp_attribute29                in  varchar2
  ,p_clp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_clpse_lf_evt_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_clpse_lf_evt_a
  (p_clpse_lf_evt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_seq                            in  number
  ,p_ler1_id                        in  number
  ,p_bool1_cd                       in  varchar2
  ,p_ler2_id                        in  number
  ,p_bool2_cd                       in  varchar2
  ,p_ler3_id                        in  number
  ,p_bool3_cd                       in  varchar2
  ,p_ler4_id                        in  number
  ,p_bool4_cd                       in  varchar2
  ,p_ler5_id                        in  number
  ,p_bool5_cd                       in  varchar2
  ,p_ler6_id                        in  number
  ,p_bool6_cd                       in  varchar2
  ,p_ler7_id                        in  number
  ,p_bool7_cd                       in  varchar2
  ,p_ler8_id                        in  number
  ,p_bool8_cd                       in  varchar2
  ,p_ler9_id                        in  number
  ,p_bool9_cd                       in  varchar2
  ,p_ler10_id                       in  number
  ,p_eval_cd                        in  varchar2
  ,p_eval_rl                        in  number
  ,p_tlrnc_dys_num                  in  number
  ,p_eval_ler_id                    in  number
  ,p_eval_ler_det_cd                in  varchar2
  ,p_eval_ler_det_rl                in  number
  ,p_clp_attribute_category         in  varchar2
  ,p_clp_attribute1                 in  varchar2
  ,p_clp_attribute2                 in  varchar2
  ,p_clp_attribute3                 in  varchar2
  ,p_clp_attribute4                 in  varchar2
  ,p_clp_attribute5                 in  varchar2
  ,p_clp_attribute6                 in  varchar2
  ,p_clp_attribute7                 in  varchar2
  ,p_clp_attribute8                 in  varchar2
  ,p_clp_attribute9                 in  varchar2
  ,p_clp_attribute10                in  varchar2
  ,p_clp_attribute11                in  varchar2
  ,p_clp_attribute12                in  varchar2
  ,p_clp_attribute13                in  varchar2
  ,p_clp_attribute14                in  varchar2
  ,p_clp_attribute15                in  varchar2
  ,p_clp_attribute16                in  varchar2
  ,p_clp_attribute17                in  varchar2
  ,p_clp_attribute18                in  varchar2
  ,p_clp_attribute19                in  varchar2
  ,p_clp_attribute20                in  varchar2
  ,p_clp_attribute21                in  varchar2
  ,p_clp_attribute22                in  varchar2
  ,p_clp_attribute23                in  varchar2
  ,p_clp_attribute24                in  varchar2
  ,p_clp_attribute25                in  varchar2
  ,p_clp_attribute26                in  varchar2
  ,p_clp_attribute27                in  varchar2
  ,p_clp_attribute28                in  varchar2
  ,p_clp_attribute29                in  varchar2
  ,p_clp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_clpse_lf_evt_bk2;

 

/
