--------------------------------------------------------
--  DDL for Package BEN_EPP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPP_RKI" AUTHID CURRENT_USER as
/* $Header: beepprhi.pkh 120.0 2005/05/28 02:43:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_prtt_anthr_pl_prte_id     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_eligy_prfl_id                  in number
 ,p_pl_id                          in number
 ,p_business_group_id              in number
 ,p_epp_attribute_category         in varchar2
 ,p_epp_attribute1                 in varchar2
 ,p_epp_attribute2                 in varchar2
 ,p_epp_attribute3                 in varchar2
 ,p_epp_attribute4                 in varchar2
 ,p_epp_attribute5                 in varchar2
 ,p_epp_attribute6                 in varchar2
 ,p_epp_attribute7                 in varchar2
 ,p_epp_attribute8                 in varchar2
 ,p_epp_attribute9                 in varchar2
 ,p_epp_attribute10                in varchar2
 ,p_epp_attribute11                in varchar2
 ,p_epp_attribute12                in varchar2
 ,p_epp_attribute13                in varchar2
 ,p_epp_attribute14                in varchar2
 ,p_epp_attribute15                in varchar2
 ,p_epp_attribute16                in varchar2
 ,p_epp_attribute17                in varchar2
 ,p_epp_attribute18                in varchar2
 ,p_epp_attribute19                in varchar2
 ,p_epp_attribute20                in varchar2
 ,p_epp_attribute21                in varchar2
 ,p_epp_attribute22                in varchar2
 ,p_epp_attribute23                in varchar2
 ,p_epp_attribute24                in varchar2
 ,p_epp_attribute25                in varchar2
 ,p_epp_attribute26                in varchar2
 ,p_epp_attribute27                in varchar2
 ,p_epp_attribute28                in varchar2
 ,p_epp_attribute29                in varchar2
 ,p_epp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_epp_rki;

 

/
