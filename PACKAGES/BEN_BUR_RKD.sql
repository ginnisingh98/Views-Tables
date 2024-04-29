--------------------------------------------------------
--  DDL for Package BEN_BUR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BUR_RKD" AUTHID CURRENT_USER as
/* $Header: beburrhi.pkh 120.0.12010000.1 2008/07/29 11:02:11 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_brgng_unit_rt_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_brgng_unit_cd_o                in varchar2
 ,p_business_group_id_o            in number
 ,p_bur_attribute_category_o       in varchar2
 ,p_bur_attribute1_o               in varchar2
 ,p_bur_attribute2_o               in varchar2
 ,p_bur_attribute3_o               in varchar2
 ,p_bur_attribute4_o               in varchar2
 ,p_bur_attribute5_o               in varchar2
 ,p_bur_attribute6_o               in varchar2
 ,p_bur_attribute7_o               in varchar2
 ,p_bur_attribute8_o               in varchar2
 ,p_bur_attribute9_o               in varchar2
 ,p_bur_attribute10_o              in varchar2
 ,p_bur_attribute11_o              in varchar2
 ,p_bur_attribute12_o              in varchar2
 ,p_bur_attribute13_o              in varchar2
 ,p_bur_attribute14_o              in varchar2
 ,p_bur_attribute15_o              in varchar2
 ,p_bur_attribute16_o              in varchar2
 ,p_bur_attribute17_o              in varchar2
 ,p_bur_attribute18_o              in varchar2
 ,p_bur_attribute19_o              in varchar2
 ,p_bur_attribute20_o              in varchar2
 ,p_bur_attribute21_o              in varchar2
 ,p_bur_attribute22_o              in varchar2
 ,p_bur_attribute23_o              in varchar2
 ,p_bur_attribute24_o              in varchar2
 ,p_bur_attribute25_o              in varchar2
 ,p_bur_attribute26_o              in varchar2
 ,p_bur_attribute27_o              in varchar2
 ,p_bur_attribute28_o              in varchar2
 ,p_bur_attribute29_o              in varchar2
 ,p_bur_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_bur_rkd;

/
