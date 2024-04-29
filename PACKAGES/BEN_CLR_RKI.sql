--------------------------------------------------------
--  DDL for Package BEN_CLR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLR_RKI" AUTHID CURRENT_USER as
/* $Header: beclrrhi.pkh 120.0 2005/05/28 01:05:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_comp_lvl_rt_id                 in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_comp_lvl_fctr_id               in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_clr_attribute_category         in varchar2
 ,p_clr_attribute1                 in varchar2
 ,p_clr_attribute2                 in varchar2
 ,p_clr_attribute3                 in varchar2
 ,p_clr_attribute4                 in varchar2
 ,p_clr_attribute5                 in varchar2
 ,p_clr_attribute6                 in varchar2
 ,p_clr_attribute7                 in varchar2
 ,p_clr_attribute8                 in varchar2
 ,p_clr_attribute9                 in varchar2
 ,p_clr_attribute10                in varchar2
 ,p_clr_attribute11                in varchar2
 ,p_clr_attribute12                in varchar2
 ,p_clr_attribute13                in varchar2
 ,p_clr_attribute14                in varchar2
 ,p_clr_attribute15                in varchar2
 ,p_clr_attribute16                in varchar2
 ,p_clr_attribute17                in varchar2
 ,p_clr_attribute18                in varchar2
 ,p_clr_attribute19                in varchar2
 ,p_clr_attribute20                in varchar2
 ,p_clr_attribute21                in varchar2
 ,p_clr_attribute22                in varchar2
 ,p_clr_attribute23                in varchar2
 ,p_clr_attribute24                in varchar2
 ,p_clr_attribute25                in varchar2
 ,p_clr_attribute26                in varchar2
 ,p_clr_attribute27                in varchar2
 ,p_clr_attribute28                in varchar2
 ,p_clr_attribute29                in varchar2
 ,p_clr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_clr_rki;

 

/
