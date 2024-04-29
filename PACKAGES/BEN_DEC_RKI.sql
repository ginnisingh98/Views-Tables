--------------------------------------------------------
--  DDL for Package BEN_DEC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DEC_RKI" AUTHID CURRENT_USER as
/* $Header: bedecrhi.pkh 120.0 2005/05/28 01:36:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_dsgntr_enrld_cvg_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_dsgntr_crntly_enrld_flag       in varchar2
 ,p_dpnt_cvg_eligy_prfl_id         in number
 ,p_business_group_id              in number
 ,p_dec_attribute_category         in varchar2
 ,p_dec_attribute1                 in varchar2
 ,p_dec_attribute2                 in varchar2
 ,p_dec_attribute3                 in varchar2
 ,p_dec_attribute4                 in varchar2
 ,p_dec_attribute5                 in varchar2
 ,p_dec_attribute6                 in varchar2
 ,p_dec_attribute7                 in varchar2
 ,p_dec_attribute8                 in varchar2
 ,p_dec_attribute9                 in varchar2
 ,p_dec_attribute10                in varchar2
 ,p_dec_attribute11                in varchar2
 ,p_dec_attribute12                in varchar2
 ,p_dec_attribute13                in varchar2
 ,p_dec_attribute14                in varchar2
 ,p_dec_attribute15                in varchar2
 ,p_dec_attribute16                in varchar2
 ,p_dec_attribute17                in varchar2
 ,p_dec_attribute18                in varchar2
 ,p_dec_attribute19                in varchar2
 ,p_dec_attribute20                in varchar2
 ,p_dec_attribute21                in varchar2
 ,p_dec_attribute22                in varchar2
 ,p_dec_attribute23                in varchar2
 ,p_dec_attribute24                in varchar2
 ,p_dec_attribute25                in varchar2
 ,p_dec_attribute26                in varchar2
 ,p_dec_attribute27                in varchar2
 ,p_dec_attribute28                in varchar2
 ,p_dec_attribute29                in varchar2
 ,p_dec_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_dec_rki;

 

/
