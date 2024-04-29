--------------------------------------------------------
--  DDL for Package BEN_DOT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DOT_RKI" AUTHID CURRENT_USER as
/* $Header: bedotrhi.pkh 120.0 2005/05/28 01:38:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_dpnt_othr_ptip_rt_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_ptip_id                        in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_dot_attribute_category         in varchar2
 ,p_dot_attribute1                 in varchar2
 ,p_dot_attribute2                 in varchar2
 ,p_dot_attribute3                 in varchar2
 ,p_dot_attribute4                 in varchar2
 ,p_dot_attribute5                 in varchar2
 ,p_dot_attribute6                 in varchar2
 ,p_dot_attribute7                 in varchar2
 ,p_dot_attribute8                 in varchar2
 ,p_dot_attribute9                 in varchar2
 ,p_dot_attribute10                in varchar2
 ,p_dot_attribute11                in varchar2
 ,p_dot_attribute12                in varchar2
 ,p_dot_attribute13                in varchar2
 ,p_dot_attribute14                in varchar2
 ,p_dot_attribute15                in varchar2
 ,p_dot_attribute16                in varchar2
 ,p_dot_attribute17                in varchar2
 ,p_dot_attribute18                in varchar2
 ,p_dot_attribute19                in varchar2
 ,p_dot_attribute20                in varchar2
 ,p_dot_attribute21                in varchar2
 ,p_dot_attribute22                in varchar2
 ,p_dot_attribute23                in varchar2
 ,p_dot_attribute24                in varchar2
 ,p_dot_attribute25                in varchar2
 ,p_dot_attribute26                in varchar2
 ,p_dot_attribute27                in varchar2
 ,p_dot_attribute28                in varchar2
 ,p_dot_attribute29                in varchar2
 ,p_dot_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_dot_rki;

 

/
