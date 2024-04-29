--------------------------------------------------------
--  DDL for Package BEN_BRG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BRG_RKD" AUTHID CURRENT_USER as
/* $Header: bebrgrhi.pkh 120.0.12010000.1 2008/07/29 11:00:50 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_benfts_grp_rt_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_benfts_grp_id_o                in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_brg_attribute_category_o       in varchar2
 ,p_brg_attribute1_o               in varchar2
 ,p_brg_attribute2_o               in varchar2
 ,p_brg_attribute3_o               in varchar2
 ,p_brg_attribute4_o               in varchar2
 ,p_brg_attribute5_o               in varchar2
 ,p_brg_attribute6_o               in varchar2
 ,p_brg_attribute7_o               in varchar2
 ,p_brg_attribute8_o               in varchar2
 ,p_brg_attribute9_o               in varchar2
 ,p_brg_attribute10_o              in varchar2
 ,p_brg_attribute11_o              in varchar2
 ,p_brg_attribute12_o              in varchar2
 ,p_brg_attribute13_o              in varchar2
 ,p_brg_attribute14_o              in varchar2
 ,p_brg_attribute15_o              in varchar2
 ,p_brg_attribute16_o              in varchar2
 ,p_brg_attribute17_o              in varchar2
 ,p_brg_attribute18_o              in varchar2
 ,p_brg_attribute19_o              in varchar2
 ,p_brg_attribute20_o              in varchar2
 ,p_brg_attribute21_o              in varchar2
 ,p_brg_attribute22_o              in varchar2
 ,p_brg_attribute23_o              in varchar2
 ,p_brg_attribute24_o              in varchar2
 ,p_brg_attribute25_o              in varchar2
 ,p_brg_attribute26_o              in varchar2
 ,p_brg_attribute27_o              in varchar2
 ,p_brg_attribute28_o              in varchar2
 ,p_brg_attribute29_o              in varchar2
 ,p_brg_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_brg_rkd;

/
