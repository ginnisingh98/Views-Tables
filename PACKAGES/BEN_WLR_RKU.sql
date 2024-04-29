--------------------------------------------------------
--  DDL for Package BEN_WLR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WLR_RKU" AUTHID CURRENT_USER as
/* $Header: bewlrrhi.pkh 120.0.12010000.1 2008/07/29 13:09:25 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_wk_loc_rt_id                   in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_location_id                    in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_wlr_attribute_category         in varchar2
 ,p_wlr_attribute1                 in varchar2
 ,p_wlr_attribute2                 in varchar2
 ,p_wlr_attribute3                 in varchar2
 ,p_wlr_attribute4                 in varchar2
 ,p_wlr_attribute5                 in varchar2
 ,p_wlr_attribute6                 in varchar2
 ,p_wlr_attribute7                 in varchar2
 ,p_wlr_attribute8                 in varchar2
 ,p_wlr_attribute9                 in varchar2
 ,p_wlr_attribute10                in varchar2
 ,p_wlr_attribute11                in varchar2
 ,p_wlr_attribute12                in varchar2
 ,p_wlr_attribute13                in varchar2
 ,p_wlr_attribute14                in varchar2
 ,p_wlr_attribute15                in varchar2
 ,p_wlr_attribute16                in varchar2
 ,p_wlr_attribute17                in varchar2
 ,p_wlr_attribute18                in varchar2
 ,p_wlr_attribute19                in varchar2
 ,p_wlr_attribute20                in varchar2
 ,p_wlr_attribute21                in varchar2
 ,p_wlr_attribute22                in varchar2
 ,p_wlr_attribute23                in varchar2
 ,p_wlr_attribute24                in varchar2
 ,p_wlr_attribute25                in varchar2
 ,p_wlr_attribute26                in varchar2
 ,p_wlr_attribute27                in varchar2
 ,p_wlr_attribute28                in varchar2
 ,p_wlr_attribute29                in varchar2
 ,p_wlr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_location_id_o                  in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_wlr_attribute_category_o       in varchar2
 ,p_wlr_attribute1_o               in varchar2
 ,p_wlr_attribute2_o               in varchar2
 ,p_wlr_attribute3_o               in varchar2
 ,p_wlr_attribute4_o               in varchar2
 ,p_wlr_attribute5_o               in varchar2
 ,p_wlr_attribute6_o               in varchar2
 ,p_wlr_attribute7_o               in varchar2
 ,p_wlr_attribute8_o               in varchar2
 ,p_wlr_attribute9_o               in varchar2
 ,p_wlr_attribute10_o              in varchar2
 ,p_wlr_attribute11_o              in varchar2
 ,p_wlr_attribute12_o              in varchar2
 ,p_wlr_attribute13_o              in varchar2
 ,p_wlr_attribute14_o              in varchar2
 ,p_wlr_attribute15_o              in varchar2
 ,p_wlr_attribute16_o              in varchar2
 ,p_wlr_attribute17_o              in varchar2
 ,p_wlr_attribute18_o              in varchar2
 ,p_wlr_attribute19_o              in varchar2
 ,p_wlr_attribute20_o              in varchar2
 ,p_wlr_attribute21_o              in varchar2
 ,p_wlr_attribute22_o              in varchar2
 ,p_wlr_attribute23_o              in varchar2
 ,p_wlr_attribute24_o              in varchar2
 ,p_wlr_attribute25_o              in varchar2
 ,p_wlr_attribute26_o              in varchar2
 ,p_wlr_attribute27_o              in varchar2
 ,p_wlr_attribute28_o              in varchar2
 ,p_wlr_attribute29_o              in varchar2
 ,p_wlr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_wlr_rku;

/