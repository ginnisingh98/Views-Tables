--------------------------------------------------------
--  DDL for Package BEN_EPN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPN_RKI" AUTHID CURRENT_USER as
/* $Header: beepnrhi.pkh 120.0 2005/05/28 02:41:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_prbtn_perd_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_probation_period               in number
 ,p_probation_unit                 in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_epn_attribute_category         in varchar2
 ,p_epn_attribute1                 in varchar2
 ,p_epn_attribute2                 in varchar2
 ,p_epn_attribute3                 in varchar2
 ,p_epn_attribute4                 in varchar2
 ,p_epn_attribute5                 in varchar2
 ,p_epn_attribute6                 in varchar2
 ,p_epn_attribute7                 in varchar2
 ,p_epn_attribute8                 in varchar2
 ,p_epn_attribute9                 in varchar2
 ,p_epn_attribute10                in varchar2
 ,p_epn_attribute11                in varchar2
 ,p_epn_attribute12                in varchar2
 ,p_epn_attribute13                in varchar2
 ,p_epn_attribute14                in varchar2
 ,p_epn_attribute15                in varchar2
 ,p_epn_attribute16                in varchar2
 ,p_epn_attribute17                in varchar2
 ,p_epn_attribute18                in varchar2
 ,p_epn_attribute19                in varchar2
 ,p_epn_attribute20                in varchar2
 ,p_epn_attribute21                in varchar2
 ,p_epn_attribute22                in varchar2
 ,p_epn_attribute23                in varchar2
 ,p_epn_attribute24                in varchar2
 ,p_epn_attribute25                in varchar2
 ,p_epn_attribute26                in varchar2
 ,p_epn_attribute27                in varchar2
 ,p_epn_attribute28                in varchar2
 ,p_epn_attribute29                in varchar2
 ,p_epn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_epn_rki;

 

/
