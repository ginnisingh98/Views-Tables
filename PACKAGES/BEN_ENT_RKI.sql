--------------------------------------------------------
--  DDL for Package BEN_ENT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENT_RKI" AUTHID CURRENT_USER as
/* $Header: beentrhi.pkh 120.0 2005/05/28 02:31:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_enrld_anthr_ptip_rt_id       in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_enrl_det_dt_cd                 in varchar2
 ,p_only_pls_subj_cobra_flag       in varchar2
 ,p_ptip_id                        in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_ent_attribute_category         in varchar2
 ,p_ent_attribute1                 in varchar2
 ,p_ent_attribute2                 in varchar2
 ,p_ent_attribute3                 in varchar2
 ,p_ent_attribute4                 in varchar2
 ,p_ent_attribute5                 in varchar2
 ,p_ent_attribute6                 in varchar2
 ,p_ent_attribute7                 in varchar2
 ,p_ent_attribute8                 in varchar2
 ,p_ent_attribute9                 in varchar2
 ,p_ent_attribute10                in varchar2
 ,p_ent_attribute11                in varchar2
 ,p_ent_attribute12                in varchar2
 ,p_ent_attribute13                in varchar2
 ,p_ent_attribute14                in varchar2
 ,p_ent_attribute15                in varchar2
 ,p_ent_attribute16                in varchar2
 ,p_ent_attribute17                in varchar2
 ,p_ent_attribute18                in varchar2
 ,p_ent_attribute19                in varchar2
 ,p_ent_attribute20                in varchar2
 ,p_ent_attribute21                in varchar2
 ,p_ent_attribute22                in varchar2
 ,p_ent_attribute23                in varchar2
 ,p_ent_attribute24                in varchar2
 ,p_ent_attribute25                in varchar2
 ,p_ent_attribute26                in varchar2
 ,p_ent_attribute27                in varchar2
 ,p_ent_attribute28                in varchar2
 ,p_ent_attribute29                in varchar2
 ,p_ent_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_ent_rki;

 

/
