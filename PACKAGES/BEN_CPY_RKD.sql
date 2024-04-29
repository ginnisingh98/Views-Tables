--------------------------------------------------------
--  DDL for Package BEN_CPY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPY_RKD" AUTHID CURRENT_USER as
/* $Header: becpyrhi.pkh 120.0 2005/05/28 01:19:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_popl_yr_perd_id                in number
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
end ben_cpy_rkd;

 

/
