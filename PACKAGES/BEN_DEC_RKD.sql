--------------------------------------------------------
--  DDL for Package BEN_DEC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DEC_RKD" AUTHID CURRENT_USER as
/* $Header: bedecrhi.pkh 120.0 2005/05/28 01:36:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dsgntr_enrld_cvg_id            in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_dsgntr_crntly_enrld_flag_o     in varchar2
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_business_group_id_o            in number
 ,p_dec_attribute_category_o       in varchar2
 ,p_dec_attribute1_o               in varchar2
 ,p_dec_attribute2_o               in varchar2
 ,p_dec_attribute3_o               in varchar2
 ,p_dec_attribute4_o               in varchar2
 ,p_dec_attribute5_o               in varchar2
 ,p_dec_attribute6_o               in varchar2
 ,p_dec_attribute7_o               in varchar2
 ,p_dec_attribute8_o               in varchar2
 ,p_dec_attribute9_o               in varchar2
 ,p_dec_attribute10_o              in varchar2
 ,p_dec_attribute11_o              in varchar2
 ,p_dec_attribute12_o              in varchar2
 ,p_dec_attribute13_o              in varchar2
 ,p_dec_attribute14_o              in varchar2
 ,p_dec_attribute15_o              in varchar2
 ,p_dec_attribute16_o              in varchar2
 ,p_dec_attribute17_o              in varchar2
 ,p_dec_attribute18_o              in varchar2
 ,p_dec_attribute19_o              in varchar2
 ,p_dec_attribute20_o              in varchar2
 ,p_dec_attribute21_o              in varchar2
 ,p_dec_attribute22_o              in varchar2
 ,p_dec_attribute23_o              in varchar2
 ,p_dec_attribute24_o              in varchar2
 ,p_dec_attribute25_o              in varchar2
 ,p_dec_attribute26_o              in varchar2
 ,p_dec_attribute27_o              in varchar2
 ,p_dec_attribute28_o              in varchar2
 ,p_dec_attribute29_o              in varchar2
 ,p_dec_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dec_rkd;

 

/
