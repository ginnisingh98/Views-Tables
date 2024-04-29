--------------------------------------------------------
--  DDL for Package BEN_PAP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PAP_RKI" AUTHID CURRENT_USER as
/* $Header: bepaprhi.pkh 120.0 2005/05/28 10:01:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_prtt_anthr_pl_rt_id     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_pl_id                          in number
 ,p_business_group_id              in number
 ,p_pap_attribute_category         in varchar2
 ,p_pap_attribute1                 in varchar2
 ,p_pap_attribute2                 in varchar2
 ,p_pap_attribute3                 in varchar2
 ,p_pap_attribute4                 in varchar2
 ,p_pap_attribute5                 in varchar2
 ,p_pap_attribute6                 in varchar2
 ,p_pap_attribute7                 in varchar2
 ,p_pap_attribute8                 in varchar2
 ,p_pap_attribute9                 in varchar2
 ,p_pap_attribute10                in varchar2
 ,p_pap_attribute11                in varchar2
 ,p_pap_attribute12                in varchar2
 ,p_pap_attribute13                in varchar2
 ,p_pap_attribute14                in varchar2
 ,p_pap_attribute15                in varchar2
 ,p_pap_attribute16                in varchar2
 ,p_pap_attribute17                in varchar2
 ,p_pap_attribute18                in varchar2
 ,p_pap_attribute19                in varchar2
 ,p_pap_attribute20                in varchar2
 ,p_pap_attribute21                in varchar2
 ,p_pap_attribute22                in varchar2
 ,p_pap_attribute23                in varchar2
 ,p_pap_attribute24                in varchar2
 ,p_pap_attribute25                in varchar2
 ,p_pap_attribute26                in varchar2
 ,p_pap_attribute27                in varchar2
 ,p_pap_attribute28                in varchar2
 ,p_pap_attribute29                in varchar2
 ,p_pap_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pap_rki;

 

/
