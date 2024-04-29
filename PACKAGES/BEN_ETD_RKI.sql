--------------------------------------------------------
--  DDL for Package BEN_ETD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ETD_RKI" AUTHID CURRENT_USER as
/* $Header: beetdrhi.pkh 120.0 2005/05/28 03:01:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_dpnt_othr_ptip_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_ptip_id                        in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_etd_attribute_category         in varchar2
 ,p_etd_attribute1                 in varchar2
 ,p_etd_attribute2                 in varchar2
 ,p_etd_attribute3                 in varchar2
 ,p_etd_attribute4                 in varchar2
 ,p_etd_attribute5                 in varchar2
 ,p_etd_attribute6                 in varchar2
 ,p_etd_attribute7                 in varchar2
 ,p_etd_attribute8                 in varchar2
 ,p_etd_attribute9                 in varchar2
 ,p_etd_attribute10                in varchar2
 ,p_etd_attribute11                in varchar2
 ,p_etd_attribute12                in varchar2
 ,p_etd_attribute13                in varchar2
 ,p_etd_attribute14                in varchar2
 ,p_etd_attribute15                in varchar2
 ,p_etd_attribute16                in varchar2
 ,p_etd_attribute17                in varchar2
 ,p_etd_attribute18                in varchar2
 ,p_etd_attribute19                in varchar2
 ,p_etd_attribute20                in varchar2
 ,p_etd_attribute21                in varchar2
 ,p_etd_attribute22                in varchar2
 ,p_etd_attribute23                in varchar2
 ,p_etd_attribute24                in varchar2
 ,p_etd_attribute25                in varchar2
 ,p_etd_attribute26                in varchar2
 ,p_etd_attribute27                in varchar2
 ,p_etd_attribute28                in varchar2
 ,p_etd_attribute29                in varchar2
 ,p_etd_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_etd_rki;

 

/
