--------------------------------------------------------
--  DDL for Package BEN_EDG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDG_RKI" AUTHID CURRENT_USER as
/* $Header: beedgrhi.pkh 120.0 2005/05/28 01:58:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_dpnt_cvrd_othr_pgm_id     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_only_pls_subj_cobra_flag       in varchar2
 ,p_enrl_det_dt_cd                 in varchar2
 ,p_ordr_num                       in number
 ,p_pgm_id                         in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_edg_attribute_category         in varchar2
 ,p_edg_attribute1                 in varchar2
 ,p_edg_attribute2                 in varchar2
 ,p_edg_attribute3                 in varchar2
 ,p_edg_attribute4                 in varchar2
 ,p_edg_attribute5                 in varchar2
 ,p_edg_attribute6                 in varchar2
 ,p_edg_attribute7                 in varchar2
 ,p_edg_attribute8                 in varchar2
 ,p_edg_attribute9                 in varchar2
 ,p_edg_attribute10                in varchar2
 ,p_edg_attribute11                in varchar2
 ,p_edg_attribute12                in varchar2
 ,p_edg_attribute13                in varchar2
 ,p_edg_attribute14                in varchar2
 ,p_edg_attribute15                in varchar2
 ,p_edg_attribute16                in varchar2
 ,p_edg_attribute17                in varchar2
 ,p_edg_attribute18                in varchar2
 ,p_edg_attribute19                in varchar2
 ,p_edg_attribute20                in varchar2
 ,p_edg_attribute21                in varchar2
 ,p_edg_attribute22                in varchar2
 ,p_edg_attribute23                in varchar2
 ,p_edg_attribute24                in varchar2
 ,p_edg_attribute25                in varchar2
 ,p_edg_attribute26                in varchar2
 ,p_edg_attribute27                in varchar2
 ,p_edg_attribute28                in varchar2
 ,p_edg_attribute29                in varchar2
 ,p_edg_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_edg_rki;

 

/
