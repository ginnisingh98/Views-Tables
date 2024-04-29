--------------------------------------------------------
--  DDL for Package BEN_CPY_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPY_RKI" AUTHID CURRENT_USER as
/* $Header: becpyrhi.pkh 120.0 2005/05/28 01:19:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_popl_yr_perd_id                in number
 ,p_yr_perd_id                     in number
 ,p_business_group_id              in number
 ,p_pl_id                          in number
 ,p_pgm_id                         in number
 ,p_ordr_num                       in number
 ,p_acpt_clm_rqsts_thru_dt         in date
 ,p_py_clms_thru_dt                in date
 ,p_cpy_attribute_category         in varchar2
 ,p_cpy_attribute1                 in varchar2
 ,p_cpy_attribute2                 in varchar2
 ,p_cpy_attribute3                 in varchar2
 ,p_cpy_attribute4                 in varchar2
 ,p_cpy_attribute5                 in varchar2
 ,p_cpy_attribute6                 in varchar2
 ,p_cpy_attribute7                 in varchar2
 ,p_cpy_attribute8                 in varchar2
 ,p_cpy_attribute9                 in varchar2
 ,p_cpy_attribute10                in varchar2
 ,p_cpy_attribute11                in varchar2
 ,p_cpy_attribute12                in varchar2
 ,p_cpy_attribute13                in varchar2
 ,p_cpy_attribute14                in varchar2
 ,p_cpy_attribute15                in varchar2
 ,p_cpy_attribute16                in varchar2
 ,p_cpy_attribute17                in varchar2
 ,p_cpy_attribute18                in varchar2
 ,p_cpy_attribute19                in varchar2
 ,p_cpy_attribute20                in varchar2
 ,p_cpy_attribute21                in varchar2
 ,p_cpy_attribute22                in varchar2
 ,p_cpy_attribute23                in varchar2
 ,p_cpy_attribute24                in varchar2
 ,p_cpy_attribute25                in varchar2
 ,p_cpy_attribute26                in varchar2
 ,p_cpy_attribute27                in varchar2
 ,p_cpy_attribute28                in varchar2
 ,p_cpy_attribute29                in varchar2
 ,p_cpy_attribute30                in varchar2
 ,p_object_version_number          in number
  );
end ben_cpy_rki;

 

/
