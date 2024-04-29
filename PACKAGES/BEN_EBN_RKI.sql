--------------------------------------------------------
--  DDL for Package BEN_EBN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EBN_RKI" AUTHID CURRENT_USER as
/* $Header: beebnrhi.pkh 120.0 2005/05/28 01:47:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_benfts_grp_prte_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_benfts_grp_id                  in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_ebn_attribute_category         in varchar2
 ,p_ebn_attribute1                 in varchar2
 ,p_ebn_attribute2                 in varchar2
 ,p_ebn_attribute3                 in varchar2
 ,p_ebn_attribute4                 in varchar2
 ,p_ebn_attribute5                 in varchar2
 ,p_ebn_attribute6                 in varchar2
 ,p_ebn_attribute7                 in varchar2
 ,p_ebn_attribute8                 in varchar2
 ,p_ebn_attribute9                 in varchar2
 ,p_ebn_attribute10                in varchar2
 ,p_ebn_attribute11                in varchar2
 ,p_ebn_attribute12                in varchar2
 ,p_ebn_attribute13                in varchar2
 ,p_ebn_attribute14                in varchar2
 ,p_ebn_attribute15                in varchar2
 ,p_ebn_attribute16                in varchar2
 ,p_ebn_attribute17                in varchar2
 ,p_ebn_attribute18                in varchar2
 ,p_ebn_attribute19                in varchar2
 ,p_ebn_attribute20                in varchar2
 ,p_ebn_attribute21                in varchar2
 ,p_ebn_attribute22                in varchar2
 ,p_ebn_attribute23                in varchar2
 ,p_ebn_attribute24                in varchar2
 ,p_ebn_attribute25                in varchar2
 ,p_ebn_attribute26                in varchar2
 ,p_ebn_attribute27                in varchar2
 ,p_ebn_attribute28                in varchar2
 ,p_ebn_attribute29                in varchar2
 ,p_ebn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_ebn_rki;

 

/
