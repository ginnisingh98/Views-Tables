--------------------------------------------------------
--  DDL for Package BEN_PST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PST_RKD" AUTHID CURRENT_USER as
/* $Header: bepstrhi.pkh 120.0.12010000.1 2008/07/29 12:57:38 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pstn_rt_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_position_id_o                      in number
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_pst_attribute_category_o       in varchar2
 ,p_pst_attribute1_o               in varchar2
 ,p_pst_attribute2_o               in varchar2
 ,p_pst_attribute3_o               in varchar2
 ,p_pst_attribute4_o               in varchar2
 ,p_pst_attribute5_o               in varchar2
 ,p_pst_attribute6_o               in varchar2
 ,p_pst_attribute7_o               in varchar2
 ,p_pst_attribute8_o               in varchar2
 ,p_pst_attribute9_o               in varchar2
 ,p_pst_attribute10_o              in varchar2
 ,p_pst_attribute11_o              in varchar2
 ,p_pst_attribute12_o              in varchar2
 ,p_pst_attribute13_o              in varchar2
 ,p_pst_attribute14_o              in varchar2
 ,p_pst_attribute15_o              in varchar2
 ,p_pst_attribute16_o              in varchar2
 ,p_pst_attribute17_o              in varchar2
 ,p_pst_attribute18_o              in varchar2
 ,p_pst_attribute19_o              in varchar2
 ,p_pst_attribute20_o              in varchar2
 ,p_pst_attribute21_o              in varchar2
 ,p_pst_attribute22_o              in varchar2
 ,p_pst_attribute23_o              in varchar2
 ,p_pst_attribute24_o              in varchar2
 ,p_pst_attribute25_o              in varchar2
 ,p_pst_attribute26_o              in varchar2
 ,p_pst_attribute27_o              in varchar2
 ,p_pst_attribute28_o              in varchar2
 ,p_pst_attribute29_o              in varchar2
 ,p_pst_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pst_rkd;

/
