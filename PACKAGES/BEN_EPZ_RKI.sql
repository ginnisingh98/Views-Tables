--------------------------------------------------------
--  DDL for Package BEN_EPZ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPZ_RKI" AUTHID CURRENT_USER as
/* $Header: beepzrhi.pkh 120.0 2005/05/28 02:48:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_pstl_cd_r_rng_prte_id     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_pstl_zip_rng_id                in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_epz_attribute_category         in varchar2
 ,p_epz_attribute1                 in varchar2
 ,p_epz_attribute2                 in varchar2
 ,p_epz_attribute3                 in varchar2
 ,p_epz_attribute4                 in varchar2
 ,p_epz_attribute5                 in varchar2
 ,p_epz_attribute6                 in varchar2
 ,p_epz_attribute7                 in varchar2
 ,p_epz_attribute8                 in varchar2
 ,p_epz_attribute9                 in varchar2
 ,p_epz_attribute10                in varchar2
 ,p_epz_attribute11                in varchar2
 ,p_epz_attribute12                in varchar2
 ,p_epz_attribute13                in varchar2
 ,p_epz_attribute14                in varchar2
 ,p_epz_attribute15                in varchar2
 ,p_epz_attribute16                in varchar2
 ,p_epz_attribute17                in varchar2
 ,p_epz_attribute18                in varchar2
 ,p_epz_attribute19                in varchar2
 ,p_epz_attribute20                in varchar2
 ,p_epz_attribute21                in varchar2
 ,p_epz_attribute22                in varchar2
 ,p_epz_attribute23                in varchar2
 ,p_epz_attribute24                in varchar2
 ,p_epz_attribute25                in varchar2
 ,p_epz_attribute26                in varchar2
 ,p_epz_attribute27                in varchar2
 ,p_epz_attribute28                in varchar2
 ,p_epz_attribute29                in varchar2
 ,p_epz_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_epz_rki;

 

/
