--------------------------------------------------------
--  DDL for Package BEN_EPS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPS_RKI" AUTHID CURRENT_USER as
/* $Header: beepsrhi.pkh 120.1 2006/02/21 04:05:21 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_pstn_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_position_id                        in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_eps_attribute_category         in varchar2
 ,p_eps_attribute1                 in varchar2
 ,p_eps_attribute2                 in varchar2
 ,p_eps_attribute3                 in varchar2
 ,p_eps_attribute4                 in varchar2
 ,p_eps_attribute5                 in varchar2
 ,p_eps_attribute6                 in varchar2
 ,p_eps_attribute7                 in varchar2
 ,p_eps_attribute8                 in varchar2
 ,p_eps_attribute9                 in varchar2
 ,p_eps_attribute10                in varchar2
 ,p_eps_attribute11                in varchar2
 ,p_eps_attribute12                in varchar2
 ,p_eps_attribute13                in varchar2
 ,p_eps_attribute14                in varchar2
 ,p_eps_attribute15                in varchar2
 ,p_eps_attribute16                in varchar2
 ,p_eps_attribute17                in varchar2
 ,p_eps_attribute18                in varchar2
 ,p_eps_attribute19                in varchar2
 ,p_eps_attribute20                in varchar2
 ,p_eps_attribute21                in varchar2
 ,p_eps_attribute22                in varchar2
 ,p_eps_attribute23                in varchar2
 ,p_eps_attribute24                in varchar2
 ,p_eps_attribute25                in varchar2
 ,p_eps_attribute26                in varchar2
 ,p_eps_attribute27                in varchar2
 ,p_eps_attribute28                in varchar2
 ,p_eps_attribute29                in varchar2
 ,p_eps_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_eps_rki;

 

/
