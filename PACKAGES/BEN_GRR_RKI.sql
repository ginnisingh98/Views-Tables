--------------------------------------------------------
--  DDL for Package BEN_GRR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GRR_RKI" AUTHID CURRENT_USER as
/* $Header: begrrrhi.pkh 120.0 2005/05/28 03:09:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_grade_rt_id                    in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_grade_id                       in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_grr_attribute_category         in varchar2
 ,p_grr_attribute1                 in varchar2
 ,p_grr_attribute2                 in varchar2
 ,p_grr_attribute3                 in varchar2
 ,p_grr_attribute4                 in varchar2
 ,p_grr_attribute5                 in varchar2
 ,p_grr_attribute6                 in varchar2
 ,p_grr_attribute7                 in varchar2
 ,p_grr_attribute8                 in varchar2
 ,p_grr_attribute9                 in varchar2
 ,p_grr_attribute10                in varchar2
 ,p_grr_attribute11                in varchar2
 ,p_grr_attribute12                in varchar2
 ,p_grr_attribute13                in varchar2
 ,p_grr_attribute14                in varchar2
 ,p_grr_attribute15                in varchar2
 ,p_grr_attribute16                in varchar2
 ,p_grr_attribute17                in varchar2
 ,p_grr_attribute18                in varchar2
 ,p_grr_attribute19                in varchar2
 ,p_grr_attribute20                in varchar2
 ,p_grr_attribute21                in varchar2
 ,p_grr_attribute22                in varchar2
 ,p_grr_attribute23                in varchar2
 ,p_grr_attribute24                in varchar2
 ,p_grr_attribute25                in varchar2
 ,p_grr_attribute26                in varchar2
 ,p_grr_attribute27                in varchar2
 ,p_grr_attribute28                in varchar2
 ,p_grr_attribute29                in varchar2
 ,p_grr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_grr_rki;

 

/
