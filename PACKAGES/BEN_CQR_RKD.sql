--------------------------------------------------------
--  DDL for Package BEN_CQR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CQR_RKD" AUTHID CURRENT_USER as
/* $Header: becqrrhi.pkh 120.0 2005/05/28 01:20:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cbr_quald_bnf_rt_id            in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_quald_bnf_flag_o               in varchar2
 ,p_ordr_num_o                     in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_pgm_id_o                       in number
 ,p_ptip_id_o                      in number
 ,p_business_group_id_o            in number
 ,p_cqr_attribute_category_o       in varchar2
 ,p_cqr_attribute1_o               in varchar2
 ,p_cqr_attribute2_o               in varchar2
 ,p_cqr_attribute3_o               in varchar2
 ,p_cqr_attribute4_o               in varchar2
 ,p_cqr_attribute5_o               in varchar2
 ,p_cqr_attribute6_o               in varchar2
 ,p_cqr_attribute7_o               in varchar2
 ,p_cqr_attribute8_o               in varchar2
 ,p_cqr_attribute9_o               in varchar2
 ,p_cqr_attribute10_o              in varchar2
 ,p_cqr_attribute11_o              in varchar2
 ,p_cqr_attribute12_o              in varchar2
 ,p_cqr_attribute13_o              in varchar2
 ,p_cqr_attribute14_o              in varchar2
 ,p_cqr_attribute15_o              in varchar2
 ,p_cqr_attribute16_o              in varchar2
 ,p_cqr_attribute17_o              in varchar2
 ,p_cqr_attribute18_o              in varchar2
 ,p_cqr_attribute19_o              in varchar2
 ,p_cqr_attribute20_o              in varchar2
 ,p_cqr_attribute21_o              in varchar2
 ,p_cqr_attribute22_o              in varchar2
 ,p_cqr_attribute23_o              in varchar2
 ,p_cqr_attribute24_o              in varchar2
 ,p_cqr_attribute25_o              in varchar2
 ,p_cqr_attribute26_o              in varchar2
 ,p_cqr_attribute27_o              in varchar2
 ,p_cqr_attribute28_o              in varchar2
 ,p_cqr_attribute29_o              in varchar2
 ,p_cqr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cqr_rkd;

 

/
