--------------------------------------------------------
--  DDL for Package BEN_PLAN_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: beptpapi.pkh 120.0 2005/05/28 11:22:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PLAN_TYPE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_PLAN_TYPE_b
  (
   p_name                           in  varchar2
  ,p_mx_enrl_alwd_num               in  number
  ,p_mn_enrl_rqd_num                in  number
  ,p_pl_typ_stat_cd                 in  varchar2
  ,p_opt_typ_cd                     in  varchar2
  ,p_opt_dsply_fmt_cd               in  varchar2
  ,p_comp_typ_cd                    in  varchar2
  ,p_ivr_ident                      in  varchar2
  ,p_no_mx_enrl_num_dfnd_flag       in  varchar2
  ,p_no_mn_enrl_num_dfnd_flag       in  varchar2
  ,p_business_group_id              in  number
  ,p_ptp_attribute_category         in  varchar2
  ,p_ptp_attribute1                 in  varchar2
  ,p_ptp_attribute2                 in  varchar2
  ,p_ptp_attribute3                 in  varchar2
  ,p_ptp_attribute4                 in  varchar2
  ,p_ptp_attribute5                 in  varchar2
  ,p_ptp_attribute6                 in  varchar2
  ,p_ptp_attribute7                 in  varchar2
  ,p_ptp_attribute8                 in  varchar2
  ,p_ptp_attribute9                 in  varchar2
  ,p_ptp_attribute10                in  varchar2
  ,p_ptp_attribute11                in  varchar2
  ,p_ptp_attribute12                in  varchar2
  ,p_ptp_attribute13                in  varchar2
  ,p_ptp_attribute14                in  varchar2
  ,p_ptp_attribute15                in  varchar2
  ,p_ptp_attribute16                in  varchar2
  ,p_ptp_attribute17                in  varchar2
  ,p_ptp_attribute18                in  varchar2
  ,p_ptp_attribute19                in  varchar2
  ,p_ptp_attribute20                in  varchar2
  ,p_ptp_attribute21                in  varchar2
  ,p_ptp_attribute22                in  varchar2
  ,p_ptp_attribute23                in  varchar2
  ,p_ptp_attribute24                in  varchar2
  ,p_ptp_attribute25                in  varchar2
  ,p_ptp_attribute26                in  varchar2
  ,p_ptp_attribute27                in  varchar2
  ,p_ptp_attribute28                in  varchar2
  ,p_ptp_attribute29                in  varchar2
  ,p_ptp_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_short_name             in  varchar2
  ,p_short_code             in  varchar2
    ,p_legislation_code             in  varchar2
    ,p_legislation_subgroup             in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PLAN_TYPE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_PLAN_TYPE_a
  (
   p_pl_typ_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_name                           in  varchar2
  ,p_mx_enrl_alwd_num               in  number
  ,p_mn_enrl_rqd_num                in  number
  ,p_pl_typ_stat_cd                 in  varchar2
  ,p_opt_typ_cd                     in  varchar2
  ,p_opt_dsply_fmt_cd               in  varchar2
  ,p_comp_typ_cd                    in  varchar2
  ,p_ivr_ident                      in  varchar2
  ,p_no_mx_enrl_num_dfnd_flag       in  varchar2
  ,p_no_mn_enrl_num_dfnd_flag       in  varchar2
  ,p_business_group_id              in  number
  ,p_ptp_attribute_category         in  varchar2
  ,p_ptp_attribute1                 in  varchar2
  ,p_ptp_attribute2                 in  varchar2
  ,p_ptp_attribute3                 in  varchar2
  ,p_ptp_attribute4                 in  varchar2
  ,p_ptp_attribute5                 in  varchar2
  ,p_ptp_attribute6                 in  varchar2
  ,p_ptp_attribute7                 in  varchar2
  ,p_ptp_attribute8                 in  varchar2
  ,p_ptp_attribute9                 in  varchar2
  ,p_ptp_attribute10                in  varchar2
  ,p_ptp_attribute11                in  varchar2
  ,p_ptp_attribute12                in  varchar2
  ,p_ptp_attribute13                in  varchar2
  ,p_ptp_attribute14                in  varchar2
  ,p_ptp_attribute15                in  varchar2
  ,p_ptp_attribute16                in  varchar2
  ,p_ptp_attribute17                in  varchar2
  ,p_ptp_attribute18                in  varchar2
  ,p_ptp_attribute19                in  varchar2
  ,p_ptp_attribute20                in  varchar2
  ,p_ptp_attribute21                in  varchar2
  ,p_ptp_attribute22                in  varchar2
  ,p_ptp_attribute23                in  varchar2
  ,p_ptp_attribute24                in  varchar2
  ,p_ptp_attribute25                in  varchar2
  ,p_ptp_attribute26                in  varchar2
  ,p_ptp_attribute27                in  varchar2
  ,p_ptp_attribute28                in  varchar2
  ,p_ptp_attribute29                in  varchar2
  ,p_ptp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_short_name             in  varchar2
  ,p_short_code             in  varchar2
    ,p_legislation_code             in  varchar2
    ,p_legislation_subgroup             in  varchar2
  );
--
end ben_PLAN_TYPE_bk1;

 

/
