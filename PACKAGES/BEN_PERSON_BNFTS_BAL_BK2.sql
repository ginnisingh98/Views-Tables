--------------------------------------------------------
--  DDL for Package BEN_PERSON_BNFTS_BAL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_BNFTS_BAL_BK2" AUTHID CURRENT_USER as
/* $Header: bepbbapi.pkh 120.0 2005/05/28 10:02:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person_bnfts_bal_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_bnfts_bal_b
  (
   p_per_bnfts_bal_id               in  number
  ,p_val                            in  number
  ,p_bnfts_bal_id                   in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_pbb_attribute_category         in  varchar2
  ,p_pbb_attribute1                 in  varchar2
  ,p_pbb_attribute2                 in  varchar2
  ,p_pbb_attribute3                 in  varchar2
  ,p_pbb_attribute4                 in  varchar2
  ,p_pbb_attribute5                 in  varchar2
  ,p_pbb_attribute6                 in  varchar2
  ,p_pbb_attribute7                 in  varchar2
  ,p_pbb_attribute8                 in  varchar2
  ,p_pbb_attribute9                 in  varchar2
  ,p_pbb_attribute10                in  varchar2
  ,p_pbb_attribute11                in  varchar2
  ,p_pbb_attribute12                in  varchar2
  ,p_pbb_attribute13                in  varchar2
  ,p_pbb_attribute14                in  varchar2
  ,p_pbb_attribute15                in  varchar2
  ,p_pbb_attribute16                in  varchar2
  ,p_pbb_attribute17                in  varchar2
  ,p_pbb_attribute18                in  varchar2
  ,p_pbb_attribute19                in  varchar2
  ,p_pbb_attribute20                in  varchar2
  ,p_pbb_attribute21                in  varchar2
  ,p_pbb_attribute22                in  varchar2
  ,p_pbb_attribute23                in  varchar2
  ,p_pbb_attribute24                in  varchar2
  ,p_pbb_attribute25                in  varchar2
  ,p_pbb_attribute26                in  varchar2
  ,p_pbb_attribute27                in  varchar2
  ,p_pbb_attribute28                in  varchar2
  ,p_pbb_attribute29                in  varchar2
  ,p_pbb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person_bnfts_bal_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_bnfts_bal_a
  (
   p_per_bnfts_bal_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_val                            in  number
  ,p_bnfts_bal_id                   in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_pbb_attribute_category         in  varchar2
  ,p_pbb_attribute1                 in  varchar2
  ,p_pbb_attribute2                 in  varchar2
  ,p_pbb_attribute3                 in  varchar2
  ,p_pbb_attribute4                 in  varchar2
  ,p_pbb_attribute5                 in  varchar2
  ,p_pbb_attribute6                 in  varchar2
  ,p_pbb_attribute7                 in  varchar2
  ,p_pbb_attribute8                 in  varchar2
  ,p_pbb_attribute9                 in  varchar2
  ,p_pbb_attribute10                in  varchar2
  ,p_pbb_attribute11                in  varchar2
  ,p_pbb_attribute12                in  varchar2
  ,p_pbb_attribute13                in  varchar2
  ,p_pbb_attribute14                in  varchar2
  ,p_pbb_attribute15                in  varchar2
  ,p_pbb_attribute16                in  varchar2
  ,p_pbb_attribute17                in  varchar2
  ,p_pbb_attribute18                in  varchar2
  ,p_pbb_attribute19                in  varchar2
  ,p_pbb_attribute20                in  varchar2
  ,p_pbb_attribute21                in  varchar2
  ,p_pbb_attribute22                in  varchar2
  ,p_pbb_attribute23                in  varchar2
  ,p_pbb_attribute24                in  varchar2
  ,p_pbb_attribute25                in  varchar2
  ,p_pbb_attribute26                in  varchar2
  ,p_pbb_attribute27                in  varchar2
  ,p_pbb_attribute28                in  varchar2
  ,p_pbb_attribute29                in  varchar2
  ,p_pbb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_person_bnfts_bal_bk2;

 

/
