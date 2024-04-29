--------------------------------------------------------
--  DDL for Package BEN_POPL_ORG_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_ORG_BK2" AUTHID CURRENT_USER as
/* $Header: becpoapi.pkh 120.0 2005/05/28 01:15:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_POPL_ORG_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_ORG_b
  (
   p_popl_org_id                    in  number
  ,p_business_group_id              in  number
  ,p_cstmr_num                      in  number
  ,p_plcy_r_grp                     in  varchar2
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_organization_id                in  number
  ,p_person_id                      in  number
  ,p_cpo_attribute_category         in  varchar2
  ,p_cpo_attribute1                 in  varchar2
  ,p_cpo_attribute2                 in  varchar2
  ,p_cpo_attribute3                 in  varchar2
  ,p_cpo_attribute4                 in  varchar2
  ,p_cpo_attribute5                 in  varchar2
  ,p_cpo_attribute6                 in  varchar2
  ,p_cpo_attribute7                 in  varchar2
  ,p_cpo_attribute8                 in  varchar2
  ,p_cpo_attribute9                 in  varchar2
  ,p_cpo_attribute10                in  varchar2
  ,p_cpo_attribute11                in  varchar2
  ,p_cpo_attribute12                in  varchar2
  ,p_cpo_attribute13                in  varchar2
  ,p_cpo_attribute14                in  varchar2
  ,p_cpo_attribute15                in  varchar2
  ,p_cpo_attribute16                in  varchar2
  ,p_cpo_attribute17                in  varchar2
  ,p_cpo_attribute18                in  varchar2
  ,p_cpo_attribute19                in  varchar2
  ,p_cpo_attribute20                in  varchar2
  ,p_cpo_attribute21                in  varchar2
  ,p_cpo_attribute22                in  varchar2
  ,p_cpo_attribute23                in  varchar2
  ,p_cpo_attribute24                in  varchar2
  ,p_cpo_attribute25                in  varchar2
  ,p_cpo_attribute26                in  varchar2
  ,p_cpo_attribute27                in  varchar2
  ,p_cpo_attribute28                in  varchar2
  ,p_cpo_attribute29                in  varchar2
  ,p_cpo_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_POPL_ORG_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_ORG_a
  (
   p_popl_org_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_cstmr_num                      in  number
  ,p_plcy_r_grp                     in  varchar2
  ,p_pgm_id                         in  number
  ,p_pl_id                          in  number
  ,p_organization_id                in  number
  ,p_person_id                      in  number
  ,p_cpo_attribute_category         in  varchar2
  ,p_cpo_attribute1                 in  varchar2
  ,p_cpo_attribute2                 in  varchar2
  ,p_cpo_attribute3                 in  varchar2
  ,p_cpo_attribute4                 in  varchar2
  ,p_cpo_attribute5                 in  varchar2
  ,p_cpo_attribute6                 in  varchar2
  ,p_cpo_attribute7                 in  varchar2
  ,p_cpo_attribute8                 in  varchar2
  ,p_cpo_attribute9                 in  varchar2
  ,p_cpo_attribute10                in  varchar2
  ,p_cpo_attribute11                in  varchar2
  ,p_cpo_attribute12                in  varchar2
  ,p_cpo_attribute13                in  varchar2
  ,p_cpo_attribute14                in  varchar2
  ,p_cpo_attribute15                in  varchar2
  ,p_cpo_attribute16                in  varchar2
  ,p_cpo_attribute17                in  varchar2
  ,p_cpo_attribute18                in  varchar2
  ,p_cpo_attribute19                in  varchar2
  ,p_cpo_attribute20                in  varchar2
  ,p_cpo_attribute21                in  varchar2
  ,p_cpo_attribute22                in  varchar2
  ,p_cpo_attribute23                in  varchar2
  ,p_cpo_attribute24                in  varchar2
  ,p_cpo_attribute25                in  varchar2
  ,p_cpo_attribute26                in  varchar2
  ,p_cpo_attribute27                in  varchar2
  ,p_cpo_attribute28                in  varchar2
  ,p_cpo_attribute29                in  varchar2
  ,p_cpo_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_POPL_ORG_bk2;

 

/
