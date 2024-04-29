--------------------------------------------------------
--  DDL for Package BEN_CSS_RLTD_PER_IN_LER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CSS_RLTD_PER_IN_LER_BK2" AUTHID CURRENT_USER as
/* $Header: becsrapi.pkh 120.0 2005/05/28 01:24:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Css_Rltd_Per_in_Ler_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Css_Rltd_Per_in_Ler_b
  (
   p_css_rltd_per_per_in_ler_id     in  number
  ,p_ordr_to_prcs_num               in  number
  ,p_ler_id                         in  number
  ,p_rsltg_ler_id                   in  number
  ,p_business_group_id              in  number
  ,p_csr_attribute_category         in  varchar2
  ,p_csr_attribute1                 in  varchar2
  ,p_csr_attribute2                 in  varchar2
  ,p_csr_attribute3                 in  varchar2
  ,p_csr_attribute4                 in  varchar2
  ,p_csr_attribute5                 in  varchar2
  ,p_csr_attribute6                 in  varchar2
  ,p_csr_attribute7                 in  varchar2
  ,p_csr_attribute8                 in  varchar2
  ,p_csr_attribute9                 in  varchar2
  ,p_csr_attribute10                in  varchar2
  ,p_csr_attribute11                in  varchar2
  ,p_csr_attribute12                in  varchar2
  ,p_csr_attribute13                in  varchar2
  ,p_csr_attribute14                in  varchar2
  ,p_csr_attribute15                in  varchar2
  ,p_csr_attribute16                in  varchar2
  ,p_csr_attribute17                in  varchar2
  ,p_csr_attribute18                in  varchar2
  ,p_csr_attribute19                in  varchar2
  ,p_csr_attribute20                in  varchar2
  ,p_csr_attribute21                in  varchar2
  ,p_csr_attribute22                in  varchar2
  ,p_csr_attribute23                in  varchar2
  ,p_csr_attribute24                in  varchar2
  ,p_csr_attribute25                in  varchar2
  ,p_csr_attribute26                in  varchar2
  ,p_csr_attribute27                in  varchar2
  ,p_csr_attribute28                in  varchar2
  ,p_csr_attribute29                in  varchar2
  ,p_csr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Css_Rltd_Per_in_Ler_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Css_Rltd_Per_in_Ler_a
  (
   p_css_rltd_per_per_in_ler_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_to_prcs_num               in  number
  ,p_ler_id                         in  number
  ,p_rsltg_ler_id                   in  number
  ,p_business_group_id              in  number
  ,p_csr_attribute_category         in  varchar2
  ,p_csr_attribute1                 in  varchar2
  ,p_csr_attribute2                 in  varchar2
  ,p_csr_attribute3                 in  varchar2
  ,p_csr_attribute4                 in  varchar2
  ,p_csr_attribute5                 in  varchar2
  ,p_csr_attribute6                 in  varchar2
  ,p_csr_attribute7                 in  varchar2
  ,p_csr_attribute8                 in  varchar2
  ,p_csr_attribute9                 in  varchar2
  ,p_csr_attribute10                in  varchar2
  ,p_csr_attribute11                in  varchar2
  ,p_csr_attribute12                in  varchar2
  ,p_csr_attribute13                in  varchar2
  ,p_csr_attribute14                in  varchar2
  ,p_csr_attribute15                in  varchar2
  ,p_csr_attribute16                in  varchar2
  ,p_csr_attribute17                in  varchar2
  ,p_csr_attribute18                in  varchar2
  ,p_csr_attribute19                in  varchar2
  ,p_csr_attribute20                in  varchar2
  ,p_csr_attribute21                in  varchar2
  ,p_csr_attribute22                in  varchar2
  ,p_csr_attribute23                in  varchar2
  ,p_csr_attribute24                in  varchar2
  ,p_csr_attribute25                in  varchar2
  ,p_csr_attribute26                in  varchar2
  ,p_csr_attribute27                in  varchar2
  ,p_csr_attribute28                in  varchar2
  ,p_csr_attribute29                in  varchar2
  ,p_csr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Css_Rltd_Per_in_Ler_bk2;

 

/
