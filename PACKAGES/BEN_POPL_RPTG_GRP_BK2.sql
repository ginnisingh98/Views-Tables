--------------------------------------------------------
--  DDL for Package BEN_POPL_RPTG_GRP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_RPTG_GRP_BK2" AUTHID CURRENT_USER as
/* $Header: bergrapi.pkh 120.0 2005/05/28 11:39:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_POPL_RPTG_GRP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_RPTG_GRP_b
  (
   p_popl_rptg_grp_id               in  number
  ,p_business_group_id              in  number
  ,p_rptg_grp_id                    in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_ordr_num                       in  number          --iRec
  ,p_rgr_attribute_category         in  varchar2
  ,p_rgr_attribute1                 in  varchar2
  ,p_rgr_attribute2                 in  varchar2
  ,p_rgr_attribute3                 in  varchar2
  ,p_rgr_attribute4                 in  varchar2
  ,p_rgr_attribute5                 in  varchar2
  ,p_rgr_attribute6                 in  varchar2
  ,p_rgr_attribute7                 in  varchar2
  ,p_rgr_attribute8                 in  varchar2
  ,p_rgr_attribute9                 in  varchar2
  ,p_rgr_attribute10                in  varchar2
  ,p_rgr_attribute11                in  varchar2
  ,p_rgr_attribute12                in  varchar2
  ,p_rgr_attribute13                in  varchar2
  ,p_rgr_attribute14                in  varchar2
  ,p_rgr_attribute15                in  varchar2
  ,p_rgr_attribute16                in  varchar2
  ,p_rgr_attribute17                in  varchar2
  ,p_rgr_attribute18                in  varchar2
  ,p_rgr_attribute19                in  varchar2
  ,p_rgr_attribute20                in  varchar2
  ,p_rgr_attribute21                in  varchar2
  ,p_rgr_attribute22                in  varchar2
  ,p_rgr_attribute23                in  varchar2
  ,p_rgr_attribute24                in  varchar2
  ,p_rgr_attribute25                in  varchar2
  ,p_rgr_attribute26                in  varchar2
  ,p_rgr_attribute27                in  varchar2
  ,p_rgr_attribute28                in  varchar2
  ,p_rgr_attribute29                in  varchar2
  ,p_rgr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_POPL_RPTG_GRP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_RPTG_GRP_a
  (
   p_popl_rptg_grp_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_rptg_grp_id                    in  number
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_ordr_num                       in  number         --iRec
  ,p_rgr_attribute_category         in  varchar2
  ,p_rgr_attribute1                 in  varchar2
  ,p_rgr_attribute2                 in  varchar2
  ,p_rgr_attribute3                 in  varchar2
  ,p_rgr_attribute4                 in  varchar2
  ,p_rgr_attribute5                 in  varchar2
  ,p_rgr_attribute6                 in  varchar2
  ,p_rgr_attribute7                 in  varchar2
  ,p_rgr_attribute8                 in  varchar2
  ,p_rgr_attribute9                 in  varchar2
  ,p_rgr_attribute10                in  varchar2
  ,p_rgr_attribute11                in  varchar2
  ,p_rgr_attribute12                in  varchar2
  ,p_rgr_attribute13                in  varchar2
  ,p_rgr_attribute14                in  varchar2
  ,p_rgr_attribute15                in  varchar2
  ,p_rgr_attribute16                in  varchar2
  ,p_rgr_attribute17                in  varchar2
  ,p_rgr_attribute18                in  varchar2
  ,p_rgr_attribute19                in  varchar2
  ,p_rgr_attribute20                in  varchar2
  ,p_rgr_attribute21                in  varchar2
  ,p_rgr_attribute22                in  varchar2
  ,p_rgr_attribute23                in  varchar2
  ,p_rgr_attribute24                in  varchar2
  ,p_rgr_attribute25                in  varchar2
  ,p_rgr_attribute26                in  varchar2
  ,p_rgr_attribute27                in  varchar2
  ,p_rgr_attribute28                in  varchar2
  ,p_rgr_attribute29                in  varchar2
  ,p_rgr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_POPL_RPTG_GRP_bk2;

 

/
