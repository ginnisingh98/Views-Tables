--------------------------------------------------------
--  DDL for Package BEN_SAR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SAR_RKD" AUTHID CURRENT_USER as
/* $Header: besarrhi.pkh 120.0.12010000.1 2008/07/29 13:03:20 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_svc_area_rt_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_svc_area_id_o                  in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_business_group_id_o            in number
 ,p_sar_attribute_category_o       in varchar2
 ,p_sar_attribute1_o               in varchar2
 ,p_sar_attribute2_o               in varchar2
 ,p_sar_attribute3_o               in varchar2
 ,p_sar_attribute4_o               in varchar2
 ,p_sar_attribute5_o               in varchar2
 ,p_sar_attribute6_o               in varchar2
 ,p_sar_attribute7_o               in varchar2
 ,p_sar_attribute8_o               in varchar2
 ,p_sar_attribute9_o               in varchar2
 ,p_sar_attribute10_o              in varchar2
 ,p_sar_attribute11_o              in varchar2
 ,p_sar_attribute12_o              in varchar2
 ,p_sar_attribute13_o              in varchar2
 ,p_sar_attribute14_o              in varchar2
 ,p_sar_attribute15_o              in varchar2
 ,p_sar_attribute16_o              in varchar2
 ,p_sar_attribute17_o              in varchar2
 ,p_sar_attribute18_o              in varchar2
 ,p_sar_attribute19_o              in varchar2
 ,p_sar_attribute20_o              in varchar2
 ,p_sar_attribute21_o              in varchar2
 ,p_sar_attribute22_o              in varchar2
 ,p_sar_attribute23_o              in varchar2
 ,p_sar_attribute24_o              in varchar2
 ,p_sar_attribute25_o              in varchar2
 ,p_sar_attribute26_o              in varchar2
 ,p_sar_attribute27_o              in varchar2
 ,p_sar_attribute28_o              in varchar2
 ,p_sar_attribute29_o              in varchar2
 ,p_sar_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_sar_rkd;

/
