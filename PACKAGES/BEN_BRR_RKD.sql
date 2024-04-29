--------------------------------------------------------
--  DDL for Package BEN_BRR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BRR_RKD" AUTHID CURRENT_USER as
/* $Header: bebrrrhi.pkh 120.0.12010000.1 2008/07/29 11:01:27 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_bnft_vrbl_rt_rl_id             in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_to_aply_num_o             in number
 ,p_cvg_amt_calc_mthd_id_o         in number
 ,p_formula_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_brr_attribute_category_o       in varchar2
 ,p_brr_attribute1_o               in varchar2
 ,p_brr_attribute2_o               in varchar2
 ,p_brr_attribute3_o               in varchar2
 ,p_brr_attribute4_o               in varchar2
 ,p_brr_attribute5_o               in varchar2
 ,p_brr_attribute6_o               in varchar2
 ,p_brr_attribute7_o               in varchar2
 ,p_brr_attribute8_o               in varchar2
 ,p_brr_attribute9_o               in varchar2
 ,p_brr_attribute10_o              in varchar2
 ,p_brr_attribute11_o              in varchar2
 ,p_brr_attribute12_o              in varchar2
 ,p_brr_attribute13_o              in varchar2
 ,p_brr_attribute14_o              in varchar2
 ,p_brr_attribute15_o              in varchar2
 ,p_brr_attribute16_o              in varchar2
 ,p_brr_attribute17_o              in varchar2
 ,p_brr_attribute18_o              in varchar2
 ,p_brr_attribute19_o              in varchar2
 ,p_brr_attribute20_o              in varchar2
 ,p_brr_attribute21_o              in varchar2
 ,p_brr_attribute22_o              in varchar2
 ,p_brr_attribute23_o              in varchar2
 ,p_brr_attribute24_o              in varchar2
 ,p_brr_attribute25_o              in varchar2
 ,p_brr_attribute26_o              in varchar2
 ,p_brr_attribute27_o              in varchar2
 ,p_brr_attribute28_o              in varchar2
 ,p_brr_attribute29_o              in varchar2
 ,p_brr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_brr_rkd;

/
