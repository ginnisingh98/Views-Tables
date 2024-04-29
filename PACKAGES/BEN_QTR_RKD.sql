--------------------------------------------------------
--  DDL for Package BEN_QTR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_QTR_RKD" AUTHID CURRENT_USER as
/* $Header: beqtrrhi.pkh 120.0.12010000.1 2008/07/29 12:59:57 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_qual_titl_rt_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_qualification_type_id_o        in number
 ,p_title_o                        in varchar2
 ,p_qtr_attribute_category_o       in varchar2
 ,p_qtr_attribute1_o               in varchar2
 ,p_qtr_attribute2_o               in varchar2
 ,p_qtr_attribute3_o               in varchar2
 ,p_qtr_attribute4_o               in varchar2
 ,p_qtr_attribute5_o               in varchar2
 ,p_qtr_attribute6_o               in varchar2
 ,p_qtr_attribute7_o               in varchar2
 ,p_qtr_attribute8_o               in varchar2
 ,p_qtr_attribute9_o               in varchar2
 ,p_qtr_attribute10_o              in varchar2
 ,p_qtr_attribute11_o              in varchar2
 ,p_qtr_attribute12_o              in varchar2
 ,p_qtr_attribute13_o              in varchar2
 ,p_qtr_attribute14_o              in varchar2
 ,p_qtr_attribute15_o              in varchar2
 ,p_qtr_attribute16_o              in varchar2
 ,p_qtr_attribute17_o              in varchar2
 ,p_qtr_attribute18_o              in varchar2
 ,p_qtr_attribute19_o              in varchar2
 ,p_qtr_attribute20_o              in varchar2
 ,p_qtr_attribute21_o              in varchar2
 ,p_qtr_attribute22_o              in varchar2
 ,p_qtr_attribute23_o              in varchar2
 ,p_qtr_attribute24_o              in varchar2
 ,p_qtr_attribute25_o              in varchar2
 ,p_qtr_attribute26_o              in varchar2
 ,p_qtr_attribute27_o              in varchar2
 ,p_qtr_attribute28_o              in varchar2
 ,p_qtr_attribute29_o              in varchar2
 ,p_qtr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_qtr_rkd;

/
