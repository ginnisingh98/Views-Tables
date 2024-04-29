--------------------------------------------------------
--  DDL for Package BEN_EPM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPM_RKI" AUTHID CURRENT_USER as
/* $Header: beepmrhi.pkh 120.0 2005/05/28 02:40:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_enrld_anthr_pgm_rt_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_enrl_det_dt_cd                 in varchar2
 ,p_pgm_id                         in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_epm_attribute_category         in varchar2
 ,p_epm_attribute1                 in varchar2
 ,p_epm_attribute2                 in varchar2
 ,p_epm_attribute3                 in varchar2
 ,p_epm_attribute4                 in varchar2
 ,p_epm_attribute5                 in varchar2
 ,p_epm_attribute6                 in varchar2
 ,p_epm_attribute7                 in varchar2
 ,p_epm_attribute8                 in varchar2
 ,p_epm_attribute9                 in varchar2
 ,p_epm_attribute10                in varchar2
 ,p_epm_attribute11                in varchar2
 ,p_epm_attribute12                in varchar2
 ,p_epm_attribute13                in varchar2
 ,p_epm_attribute14                in varchar2
 ,p_epm_attribute15                in varchar2
 ,p_epm_attribute16                in varchar2
 ,p_epm_attribute17                in varchar2
 ,p_epm_attribute18                in varchar2
 ,p_epm_attribute19                in varchar2
 ,p_epm_attribute20                in varchar2
 ,p_epm_attribute21                in varchar2
 ,p_epm_attribute22                in varchar2
 ,p_epm_attribute23                in varchar2
 ,p_epm_attribute24                in varchar2
 ,p_epm_attribute25                in varchar2
 ,p_epm_attribute26                in varchar2
 ,p_epm_attribute27                in varchar2
 ,p_epm_attribute28                in varchar2
 ,p_epm_attribute29                in varchar2
 ,p_epm_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_epm_rki;

 

/
