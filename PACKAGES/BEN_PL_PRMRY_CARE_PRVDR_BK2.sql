--------------------------------------------------------
--  DDL for Package BEN_PL_PRMRY_CARE_PRVDR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_PRMRY_CARE_PRVDR_BK2" AUTHID CURRENT_USER as
/* $Header: bepcpapi.pkh 120.0 2005/05/28 10:13:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_pl_prmry_care_prvdr_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_prmry_care_prvdr_b
  (
   p_pl_pcp_id                      in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_pcp_strt_dt_cd                 in  varchar2
  ,p_pcp_dsgn_cd                    in  varchar2
  ,p_pcp_dpnt_dsgn_cd               in  varchar2
  ,p_pcp_rpstry_flag                in  varchar2
  ,p_pcp_can_keep_flag              in  varchar2
  ,p_pcp_radius                     in  number
  ,p_pcp_radius_uom                 in  varchar2
  ,p_pcp_radius_warn_flag           in  varchar2
  ,p_pcp_num_chgs                   in  number
  ,p_pcp_num_chgs_uom               in  varchar2
  ,p_pcp_attribute_category         in  varchar2
  ,p_pcp_attribute1                 in  varchar2
  ,p_pcp_attribute2                 in  varchar2
  ,p_pcp_attribute3                 in  varchar2
  ,p_pcp_attribute4                 in  varchar2
  ,p_pcp_attribute5                 in  varchar2
  ,p_pcp_attribute6                 in  varchar2
  ,p_pcp_attribute7                 in  varchar2
  ,p_pcp_attribute8                 in  varchar2
  ,p_pcp_attribute9                 in  varchar2
  ,p_pcp_attribute10                in  varchar2
  ,p_pcp_attribute11                in  varchar2
  ,p_pcp_attribute12                in  varchar2
  ,p_pcp_attribute13                in  varchar2
  ,p_pcp_attribute14                in  varchar2
  ,p_pcp_attribute15                in  varchar2
  ,p_pcp_attribute16                in  varchar2
  ,p_pcp_attribute17                in  varchar2
  ,p_pcp_attribute18                in  varchar2
  ,p_pcp_attribute19                in  varchar2
  ,p_pcp_attribute20                in  varchar2
  ,p_pcp_attribute21                in  varchar2
  ,p_pcp_attribute22                in  varchar2
  ,p_pcp_attribute23                in  varchar2
  ,p_pcp_attribute24                in  varchar2
  ,p_pcp_attribute25                in  varchar2
  ,p_pcp_attribute26                in  varchar2
  ,p_pcp_attribute27                in  varchar2
  ,p_pcp_attribute28                in  varchar2
  ,p_pcp_attribute29                in  varchar2
  ,p_pcp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_pl_prmry_care_prvdr_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_prmry_care_prvdr_a
  (
   p_pl_pcp_id                      in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_pcp_strt_dt_cd                 in  varchar2
  ,p_pcp_dsgn_cd                    in  varchar2
  ,p_pcp_dpnt_dsgn_cd               in  varchar2
  ,p_pcp_rpstry_flag                in  varchar2
  ,p_pcp_can_keep_flag              in  varchar2
  ,p_pcp_radius                     in  number
  ,p_pcp_radius_uom                 in  varchar2
  ,p_pcp_radius_warn_flag           in  varchar2
  ,p_pcp_num_chgs                   in  number
  ,p_pcp_num_chgs_uom               in  varchar2
  ,p_pcp_attribute_category         in  varchar2
  ,p_pcp_attribute1                 in  varchar2
  ,p_pcp_attribute2                 in  varchar2
  ,p_pcp_attribute3                 in  varchar2
  ,p_pcp_attribute4                 in  varchar2
  ,p_pcp_attribute5                 in  varchar2
  ,p_pcp_attribute6                 in  varchar2
  ,p_pcp_attribute7                 in  varchar2
  ,p_pcp_attribute8                 in  varchar2
  ,p_pcp_attribute9                 in  varchar2
  ,p_pcp_attribute10                in  varchar2
  ,p_pcp_attribute11                in  varchar2
  ,p_pcp_attribute12                in  varchar2
  ,p_pcp_attribute13                in  varchar2
  ,p_pcp_attribute14                in  varchar2
  ,p_pcp_attribute15                in  varchar2
  ,p_pcp_attribute16                in  varchar2
  ,p_pcp_attribute17                in  varchar2
  ,p_pcp_attribute18                in  varchar2
  ,p_pcp_attribute19                in  varchar2
  ,p_pcp_attribute20                in  varchar2
  ,p_pcp_attribute21                in  varchar2
  ,p_pcp_attribute22                in  varchar2
  ,p_pcp_attribute23                in  varchar2
  ,p_pcp_attribute24                in  varchar2
  ,p_pcp_attribute25                in  varchar2
  ,p_pcp_attribute26                in  varchar2
  ,p_pcp_attribute27                in  varchar2
  ,p_pcp_attribute28                in  varchar2
  ,p_pcp_attribute29                in  varchar2
  ,p_pcp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pl_prmry_care_prvdr_bk2;

 

/
