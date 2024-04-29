--------------------------------------------------------
--  DDL for Package BEN_ELV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELV_RKI" AUTHID CURRENT_USER as
/* $Header: beelvrhi.pkh 120.0 2005/05/28 02:24:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_lvg_rsn_prte_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_lvg_rsn_cd                     in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_elv_attribute_category         in varchar2
 ,p_elv_attribute1                 in varchar2
 ,p_elv_attribute2                 in varchar2
 ,p_elv_attribute3                 in varchar2
 ,p_elv_attribute4                 in varchar2
 ,p_elv_attribute5                 in varchar2
 ,p_elv_attribute6                 in varchar2
 ,p_elv_attribute7                 in varchar2
 ,p_elv_attribute8                 in varchar2
 ,p_elv_attribute9                 in varchar2
 ,p_elv_attribute10                in varchar2
 ,p_elv_attribute11                in varchar2
 ,p_elv_attribute12                in varchar2
 ,p_elv_attribute13                in varchar2
 ,p_elv_attribute14                in varchar2
 ,p_elv_attribute15                in varchar2
 ,p_elv_attribute16                in varchar2
 ,p_elv_attribute17                in varchar2
 ,p_elv_attribute18                in varchar2
 ,p_elv_attribute19                in varchar2
 ,p_elv_attribute20                in varchar2
 ,p_elv_attribute21                in varchar2
 ,p_elv_attribute22                in varchar2
 ,p_elv_attribute23                in varchar2
 ,p_elv_attribute24                in varchar2
 ,p_elv_attribute25                in varchar2
 ,p_elv_attribute26                in varchar2
 ,p_elv_attribute27                in varchar2
 ,p_elv_attribute28                in varchar2
 ,p_elv_attribute29                in varchar2
 ,p_elv_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_elv_rki;

 

/
