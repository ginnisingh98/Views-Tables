--------------------------------------------------------
--  DDL for Package BEN_DESIGN_RQMT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DESIGN_RQMT_BK1" AUTHID CURRENT_USER as
/* $Header: beddrapi.pkh 120.0 2005/05/28 01:35:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_design_rqmt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_design_rqmt_b
  (
   p_mn_dpnts_rqd_num               in  number
  ,p_mx_dpnts_alwd_num              in  number
  ,p_no_mn_num_dfnd_flag            in  varchar2
  ,p_no_mx_num_dfnd_flag            in  varchar2
  ,p_cvr_all_elig_flag              in  varchar2
  ,p_oipl_id                        in  number
  ,p_pl_id                          in  number
  ,p_opt_id                         in  number
  ,p_grp_rlshp_cd                   in  varchar2
  ,p_dsgn_typ_cd                    in  varchar2
  ,p_business_group_id              in  number
  ,p_ddr_attribute_category         in  varchar2
  ,p_ddr_attribute1                 in  varchar2
  ,p_ddr_attribute2                 in  varchar2
  ,p_ddr_attribute3                 in  varchar2
  ,p_ddr_attribute4                 in  varchar2
  ,p_ddr_attribute5                 in  varchar2
  ,p_ddr_attribute6                 in  varchar2
  ,p_ddr_attribute7                 in  varchar2
  ,p_ddr_attribute8                 in  varchar2
  ,p_ddr_attribute9                 in  varchar2
  ,p_ddr_attribute10                in  varchar2
  ,p_ddr_attribute11                in  varchar2
  ,p_ddr_attribute12                in  varchar2
  ,p_ddr_attribute13                in  varchar2
  ,p_ddr_attribute14                in  varchar2
  ,p_ddr_attribute15                in  varchar2
  ,p_ddr_attribute16                in  varchar2
  ,p_ddr_attribute17                in  varchar2
  ,p_ddr_attribute18                in  varchar2
  ,p_ddr_attribute19                in  varchar2
  ,p_ddr_attribute20                in  varchar2
  ,p_ddr_attribute21                in  varchar2
  ,p_ddr_attribute22                in  varchar2
  ,p_ddr_attribute23                in  varchar2
  ,p_ddr_attribute24                in  varchar2
  ,p_ddr_attribute25                in  varchar2
  ,p_ddr_attribute26                in  varchar2
  ,p_ddr_attribute27                in  varchar2
  ,p_ddr_attribute28                in  varchar2
  ,p_ddr_attribute29                in  varchar2
  ,p_ddr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_design_rqmt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_design_rqmt_a
  (
   p_dsgn_rqmt_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_mn_dpnts_rqd_num               in  number
  ,p_mx_dpnts_alwd_num              in  number
  ,p_no_mn_num_dfnd_flag            in  varchar2
  ,p_no_mx_num_dfnd_flag            in  varchar2
  ,p_cvr_all_elig_flag              in  varchar2
  ,p_oipl_id                        in  number
  ,p_pl_id                          in  number
  ,p_opt_id                         in  number
  ,p_grp_rlshp_cd                   in  varchar2
  ,p_dsgn_typ_cd                    in  varchar2
  ,p_business_group_id              in  number
  ,p_ddr_attribute_category         in  varchar2
  ,p_ddr_attribute1                 in  varchar2
  ,p_ddr_attribute2                 in  varchar2
  ,p_ddr_attribute3                 in  varchar2
  ,p_ddr_attribute4                 in  varchar2
  ,p_ddr_attribute5                 in  varchar2
  ,p_ddr_attribute6                 in  varchar2
  ,p_ddr_attribute7                 in  varchar2
  ,p_ddr_attribute8                 in  varchar2
  ,p_ddr_attribute9                 in  varchar2
  ,p_ddr_attribute10                in  varchar2
  ,p_ddr_attribute11                in  varchar2
  ,p_ddr_attribute12                in  varchar2
  ,p_ddr_attribute13                in  varchar2
  ,p_ddr_attribute14                in  varchar2
  ,p_ddr_attribute15                in  varchar2
  ,p_ddr_attribute16                in  varchar2
  ,p_ddr_attribute17                in  varchar2
  ,p_ddr_attribute18                in  varchar2
  ,p_ddr_attribute19                in  varchar2
  ,p_ddr_attribute20                in  varchar2
  ,p_ddr_attribute21                in  varchar2
  ,p_ddr_attribute22                in  varchar2
  ,p_ddr_attribute23                in  varchar2
  ,p_ddr_attribute24                in  varchar2
  ,p_ddr_attribute25                in  varchar2
  ,p_ddr_attribute26                in  varchar2
  ,p_ddr_attribute27                in  varchar2
  ,p_ddr_attribute28                in  varchar2
  ,p_ddr_attribute29                in  varchar2
  ,p_ddr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_design_rqmt_bk1;

 

/
