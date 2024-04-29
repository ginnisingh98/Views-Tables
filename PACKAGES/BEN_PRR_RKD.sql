--------------------------------------------------------
--  DDL for Package BEN_PRR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRR_RKD" AUTHID CURRENT_USER as
/* $Header: beprrrhi.pkh 120.0.12010000.1 2008/07/29 12:55:13 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_perf_rtng_rt_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_event_type_o           	   in varchar2
 ,p_perf_rtng_cd_o                 in varchar2
 ,p_prr_attribute_category_o       in varchar2
 ,p_prr_attribute1_o               in varchar2
 ,p_prr_attribute2_o               in varchar2
 ,p_prr_attribute3_o               in varchar2
 ,p_prr_attribute4_o               in varchar2
 ,p_prr_attribute5_o               in varchar2
 ,p_prr_attribute6_o               in varchar2
 ,p_prr_attribute7_o               in varchar2
 ,p_prr_attribute8_o               in varchar2
 ,p_prr_attribute9_o               in varchar2
 ,p_prr_attribute10_o              in varchar2
 ,p_prr_attribute11_o              in varchar2
 ,p_prr_attribute12_o              in varchar2
 ,p_prr_attribute13_o              in varchar2
 ,p_prr_attribute14_o              in varchar2
 ,p_prr_attribute15_o              in varchar2
 ,p_prr_attribute16_o              in varchar2
 ,p_prr_attribute17_o              in varchar2
 ,p_prr_attribute18_o              in varchar2
 ,p_prr_attribute19_o              in varchar2
 ,p_prr_attribute20_o              in varchar2
 ,p_prr_attribute21_o              in varchar2
 ,p_prr_attribute22_o              in varchar2
 ,p_prr_attribute23_o              in varchar2
 ,p_prr_attribute24_o              in varchar2
 ,p_prr_attribute25_o              in varchar2
 ,p_prr_attribute26_o              in varchar2
 ,p_prr_attribute27_o              in varchar2
 ,p_prr_attribute28_o              in varchar2
 ,p_prr_attribute29_o              in varchar2
 ,p_prr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_prr_rkd;

/
