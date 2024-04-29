--------------------------------------------------------
--  DDL for Package BEN_EPG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPG_RKI" AUTHID CURRENT_USER as
/* $Header: beepgrhi.pkh 120.0 2005/05/28 02:39:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_ppl_grp_prte_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_eligy_prfl_id                  in number
 ,p_people_group_id                in number
 ,p_business_group_id              in number
 ,p_epg_attribute_category         in varchar2
 ,p_epg_attribute1                 in varchar2
 ,p_epg_attribute2                 in varchar2
 ,p_epg_attribute3                 in varchar2
 ,p_epg_attribute4                 in varchar2
 ,p_epg_attribute5                 in varchar2
 ,p_epg_attribute6                 in varchar2
 ,p_epg_attribute7                 in varchar2
 ,p_epg_attribute8                 in varchar2
 ,p_epg_attribute9                 in varchar2
 ,p_epg_attribute10                in varchar2
 ,p_epg_attribute11                in varchar2
 ,p_epg_attribute12                in varchar2
 ,p_epg_attribute13                in varchar2
 ,p_epg_attribute14                in varchar2
 ,p_epg_attribute15                in varchar2
 ,p_epg_attribute16                in varchar2
 ,p_epg_attribute17                in varchar2
 ,p_epg_attribute18                in varchar2
 ,p_epg_attribute19                in varchar2
 ,p_epg_attribute20                in varchar2
 ,p_epg_attribute21                in varchar2
 ,p_epg_attribute22                in varchar2
 ,p_epg_attribute23                in varchar2
 ,p_epg_attribute24                in varchar2
 ,p_epg_attribute25                in varchar2
 ,p_epg_attribute26                in varchar2
 ,p_epg_attribute27                in varchar2
 ,p_epg_attribute28                in varchar2
 ,p_epg_attribute29                in varchar2
 ,p_epg_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_epg_rki;

 

/
