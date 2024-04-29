--------------------------------------------------------
--  DDL for Package BEN_REGULATIONS_BODY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REGULATIONS_BODY_BK2" AUTHID CURRENT_USER as
/* $Header: berrbapi.pkh 120.0 2005/05/28 11:40:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_regulations_body_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_regulations_body_b
  (
   p_regn_for_regy_body_id          in  number
  ,p_regn_admin_cd                  in  varchar2
  ,p_regn_id                        in  number
  ,p_organization_id                in  number
  ,p_business_group_id              in  number
  ,p_rrb_attribute_category         in  varchar2
  ,p_rrb_attribute1                 in  varchar2
  ,p_rrb_attribute2                 in  varchar2
  ,p_rrb_attribute3                 in  varchar2
  ,p_rrb_attribute4                 in  varchar2
  ,p_rrb_attribute5                 in  varchar2
  ,p_rrb_attribute6                 in  varchar2
  ,p_rrb_attribute7                 in  varchar2
  ,p_rrb_attribute8                 in  varchar2
  ,p_rrb_attribute9                 in  varchar2
  ,p_rrb_attribute10                in  varchar2
  ,p_rrb_attribute11                in  varchar2
  ,p_rrb_attribute12                in  varchar2
  ,p_rrb_attribute13                in  varchar2
  ,p_rrb_attribute14                in  varchar2
  ,p_rrb_attribute15                in  varchar2
  ,p_rrb_attribute16                in  varchar2
  ,p_rrb_attribute17                in  varchar2
  ,p_rrb_attribute18                in  varchar2
  ,p_rrb_attribute19                in  varchar2
  ,p_rrb_attribute20                in  varchar2
  ,p_rrb_attribute21                in  varchar2
  ,p_rrb_attribute22                in  varchar2
  ,p_rrb_attribute23                in  varchar2
  ,p_rrb_attribute24                in  varchar2
  ,p_rrb_attribute25                in  varchar2
  ,p_rrb_attribute26                in  varchar2
  ,p_rrb_attribute27                in  varchar2
  ,p_rrb_attribute28                in  varchar2
  ,p_rrb_attribute29                in  varchar2
  ,p_rrb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_regulations_body_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_regulations_body_a
  (
   p_regn_for_regy_body_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_regn_admin_cd                  in  varchar2
  ,p_regn_id                        in  number
  ,p_organization_id                in  number
  ,p_business_group_id              in  number
  ,p_rrb_attribute_category         in  varchar2
  ,p_rrb_attribute1                 in  varchar2
  ,p_rrb_attribute2                 in  varchar2
  ,p_rrb_attribute3                 in  varchar2
  ,p_rrb_attribute4                 in  varchar2
  ,p_rrb_attribute5                 in  varchar2
  ,p_rrb_attribute6                 in  varchar2
  ,p_rrb_attribute7                 in  varchar2
  ,p_rrb_attribute8                 in  varchar2
  ,p_rrb_attribute9                 in  varchar2
  ,p_rrb_attribute10                in  varchar2
  ,p_rrb_attribute11                in  varchar2
  ,p_rrb_attribute12                in  varchar2
  ,p_rrb_attribute13                in  varchar2
  ,p_rrb_attribute14                in  varchar2
  ,p_rrb_attribute15                in  varchar2
  ,p_rrb_attribute16                in  varchar2
  ,p_rrb_attribute17                in  varchar2
  ,p_rrb_attribute18                in  varchar2
  ,p_rrb_attribute19                in  varchar2
  ,p_rrb_attribute20                in  varchar2
  ,p_rrb_attribute21                in  varchar2
  ,p_rrb_attribute22                in  varchar2
  ,p_rrb_attribute23                in  varchar2
  ,p_rrb_attribute24                in  varchar2
  ,p_rrb_attribute25                in  varchar2
  ,p_rrb_attribute26                in  varchar2
  ,p_rrb_attribute27                in  varchar2
  ,p_rrb_attribute28                in  varchar2
  ,p_rrb_attribute29                in  varchar2
  ,p_rrb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_regulations_body_bk2;

 

/
