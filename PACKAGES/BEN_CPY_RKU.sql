--------------------------------------------------------
--  DDL for Package BEN_CPY_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPY_RKU" AUTHID CURRENT_USER as
/* $Header: becpyrhi.pkh 120.0 2005/05/28 01:19:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
 ,p_yr_perd_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_pgm_id_o                       in number
 ,p_ordr_num_o                     in number
 ,p_acpt_clm_rqsts_thru_dt_o       in date
 ,p_py_clms_thru_dt_o              in date
 ,p_cpy_attribute_category_o       in varchar2
 ,p_cpy_attribute1_o               in varchar2
 ,p_cpy_attribute2_o               in varchar2
 ,p_cpy_attribute3_o               in varchar2
 ,p_cpy_attribute4_o               in varchar2
 ,p_cpy_attribute5_o               in varchar2
 ,p_cpy_attribute6_o               in varchar2
 ,p_cpy_attribute7_o               in varchar2
 ,p_cpy_attribute8_o               in varchar2
 ,p_cpy_attribute9_o               in varchar2
 ,p_cpy_attribute10_o              in varchar2
 ,p_cpy_attribute11_o              in varchar2
 ,p_cpy_attribute12_o              in varchar2
 ,p_cpy_attribute13_o              in varchar2
 ,p_cpy_attribute14_o              in varchar2
 ,p_cpy_attribute15_o              in varchar2
 ,p_cpy_attribute16_o              in varchar2
 ,p_cpy_attribute17_o              in varchar2
 ,p_cpy_attribute18_o              in varchar2
 ,p_cpy_attribute19_o              in varchar2
 ,p_cpy_attribute20_o              in varchar2
 ,p_cpy_attribute21_o              in varchar2
 ,p_cpy_attribute22_o              in varchar2
 ,p_cpy_attribute23_o              in varchar2
 ,p_cpy_attribute24_o              in varchar2
 ,p_cpy_attribute25_o              in varchar2
 ,p_cpy_attribute26_o              in varchar2
 ,p_cpy_attribute27_o              in varchar2
 ,p_cpy_attribute28_o              in varchar2
 ,p_cpy_attribute29_o              in varchar2
 ,p_cpy_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cpy_rku;

 

/
