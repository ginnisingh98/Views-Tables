--------------------------------------------------------
--  DDL for Package BEN_FTR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_FTR_RKI" AUTHID CURRENT_USER as
/* $Header: beftrrhi.pkh 120.0 2005/05/28 03:06:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_fl_tm_pt_tm_rt_id              in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_fl_tm_pt_tm_cd                 in varchar2
 ,p_vrbl_rt_prfl_id                in number
 ,p_ftr_attribute_category         in varchar2
 ,p_ftr_attribute1                 in varchar2
 ,p_ftr_attribute2                 in varchar2
 ,p_ftr_attribute3                 in varchar2
 ,p_ftr_attribute4                 in varchar2
 ,p_ftr_attribute5                 in varchar2
 ,p_ftr_attribute6                 in varchar2
 ,p_ftr_attribute7                 in varchar2
 ,p_ftr_attribute8                 in varchar2
 ,p_ftr_attribute9                 in varchar2
 ,p_ftr_attribute10                in varchar2
 ,p_ftr_attribute11                in varchar2
 ,p_ftr_attribute12                in varchar2
 ,p_ftr_attribute13                in varchar2
 ,p_ftr_attribute14                in varchar2
 ,p_ftr_attribute15                in varchar2
 ,p_ftr_attribute16                in varchar2
 ,p_ftr_attribute17                in varchar2
 ,p_ftr_attribute18                in varchar2
 ,p_ftr_attribute19                in varchar2
 ,p_ftr_attribute20                in varchar2
 ,p_ftr_attribute21                in varchar2
 ,p_ftr_attribute22                in varchar2
 ,p_ftr_attribute23                in varchar2
 ,p_ftr_attribute24                in varchar2
 ,p_ftr_attribute25                in varchar2
 ,p_ftr_attribute26                in varchar2
 ,p_ftr_attribute27                in varchar2
 ,p_ftr_attribute28                in varchar2
 ,p_ftr_attribute29                in varchar2
 ,p_ftr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_ftr_rki;

 

/
