--------------------------------------------------------
--  DDL for Package BEN_BTR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BTR_RKD" AUTHID CURRENT_USER as
/* $Header: bebtrrhi.pkh 120.0.12010000.1 2008/07/29 11:01:43 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_comp_lvl_acty_rt_id            in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_dflt_flag_o                    in varchar2
 ,p_comp_lvl_fctr_id_o             in number
 ,p_acty_base_rt_id_o              in number
 ,p_business_group_id_o            in number
 ,p_btr_attribute_category_o       in varchar2
 ,p_btr_attribute1_o               in varchar2
 ,p_btr_attribute2_o               in varchar2
 ,p_btr_attribute3_o               in varchar2
 ,p_btr_attribute4_o               in varchar2
 ,p_btr_attribute5_o               in varchar2
 ,p_btr_attribute6_o               in varchar2
 ,p_btr_attribute7_o               in varchar2
 ,p_btr_attribute8_o               in varchar2
 ,p_btr_attribute9_o               in varchar2
 ,p_btr_attribute10_o              in varchar2
 ,p_btr_attribute11_o              in varchar2
 ,p_btr_attribute12_o              in varchar2
 ,p_btr_attribute13_o              in varchar2
 ,p_btr_attribute14_o              in varchar2
 ,p_btr_attribute15_o              in varchar2
 ,p_btr_attribute16_o              in varchar2
 ,p_btr_attribute17_o              in varchar2
 ,p_btr_attribute18_o              in varchar2
 ,p_btr_attribute19_o              in varchar2
 ,p_btr_attribute20_o              in varchar2
 ,p_btr_attribute21_o              in varchar2
 ,p_btr_attribute22_o              in varchar2
 ,p_btr_attribute23_o              in varchar2
 ,p_btr_attribute24_o              in varchar2
 ,p_btr_attribute25_o              in varchar2
 ,p_btr_attribute26_o              in varchar2
 ,p_btr_attribute27_o              in varchar2
 ,p_btr_attribute28_o              in varchar2
 ,p_btr_attribute29_o              in varchar2
 ,p_btr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_btr_rkd;

/
