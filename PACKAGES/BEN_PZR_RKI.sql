--------------------------------------------------------
--  DDL for Package BEN_PZR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PZR_RKI" AUTHID CURRENT_USER as
/* $Header: bepzrrhi.pkh 120.0.12010000.1 2008/07/29 12:59:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pstl_zip_rt_id                 in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_pstl_zip_rng_id                in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_business_group_id              in number
 ,p_pzr_attribute_category         in varchar2
 ,p_pzr_attribute1                 in varchar2
 ,p_pzr_attribute2                 in varchar2
 ,p_pzr_attribute3                 in varchar2
 ,p_pzr_attribute4                 in varchar2
 ,p_pzr_attribute5                 in varchar2
 ,p_pzr_attribute6                 in varchar2
 ,p_pzr_attribute7                 in varchar2
 ,p_pzr_attribute8                 in varchar2
 ,p_pzr_attribute9                 in varchar2
 ,p_pzr_attribute10                in varchar2
 ,p_pzr_attribute11                in varchar2
 ,p_pzr_attribute12                in varchar2
 ,p_pzr_attribute13                in varchar2
 ,p_pzr_attribute14                in varchar2
 ,p_pzr_attribute15                in varchar2
 ,p_pzr_attribute16                in varchar2
 ,p_pzr_attribute17                in varchar2
 ,p_pzr_attribute18                in varchar2
 ,p_pzr_attribute19                in varchar2
 ,p_pzr_attribute20                in varchar2
 ,p_pzr_attribute21                in varchar2
 ,p_pzr_attribute22                in varchar2
 ,p_pzr_attribute23                in varchar2
 ,p_pzr_attribute24                in varchar2
 ,p_pzr_attribute25                in varchar2
 ,p_pzr_attribute26                in varchar2
 ,p_pzr_attribute27                in varchar2
 ,p_pzr_attribute28                in varchar2
 ,p_pzr_attribute29                in varchar2
 ,p_pzr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pzr_rki;

/
