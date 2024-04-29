--------------------------------------------------------
--  DDL for Package BEN_EQT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EQT_RKI" AUTHID CURRENT_USER as
/* $Header: beeqtrhi.pkh 120.0 2005/05/28 02:50:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_qual_titl_prte_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_qualification_type_id          in number
 ,p_title                          in varchar2
 ,p_eqt_attribute_category         in varchar2
 ,p_eqt_attribute1                 in varchar2
 ,p_eqt_attribute2                 in varchar2
 ,p_eqt_attribute3                 in varchar2
 ,p_eqt_attribute4                 in varchar2
 ,p_eqt_attribute5                 in varchar2
 ,p_eqt_attribute6                 in varchar2
 ,p_eqt_attribute7                 in varchar2
 ,p_eqt_attribute8                 in varchar2
 ,p_eqt_attribute9                 in varchar2
 ,p_eqt_attribute10                in varchar2
 ,p_eqt_attribute11                in varchar2
 ,p_eqt_attribute12                in varchar2
 ,p_eqt_attribute13                in varchar2
 ,p_eqt_attribute14                in varchar2
 ,p_eqt_attribute15                in varchar2
 ,p_eqt_attribute16                in varchar2
 ,p_eqt_attribute17                in varchar2
 ,p_eqt_attribute18                in varchar2
 ,p_eqt_attribute19                in varchar2
 ,p_eqt_attribute20                in varchar2
 ,p_eqt_attribute21                in varchar2
 ,p_eqt_attribute22                in varchar2
 ,p_eqt_attribute23                in varchar2
 ,p_eqt_attribute24                in varchar2
 ,p_eqt_attribute25                in varchar2
 ,p_eqt_attribute26                in varchar2
 ,p_eqt_attribute27                in varchar2
 ,p_eqt_attribute28                in varchar2
 ,p_eqt_attribute29                in varchar2
 ,p_eqt_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_eqt_rki;

 

/
