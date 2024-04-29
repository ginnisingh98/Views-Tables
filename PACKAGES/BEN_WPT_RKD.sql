--------------------------------------------------------
--  DDL for Package BEN_WPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WPT_RKD" AUTHID CURRENT_USER as
/* $Header: bewptrhi.pkh 120.0.12010000.1 2008/07/29 13:09:53 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_wv_prtn_rsn_ptip_id            in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_ptip_id_o                      in number
 ,p_dflt_flag_o                    in varchar2
 ,p_wv_prtn_rsn_cd_o               in varchar2
 ,p_wpt_attribute_category_o       in varchar2
 ,p_wpt_attribute1_o               in varchar2
 ,p_wpt_attribute2_o               in varchar2
 ,p_wpt_attribute3_o               in varchar2
 ,p_wpt_attribute4_o               in varchar2
 ,p_wpt_attribute5_o               in varchar2
 ,p_wpt_attribute6_o               in varchar2
 ,p_wpt_attribute7_o               in varchar2
 ,p_wpt_attribute8_o               in varchar2
 ,p_wpt_attribute9_o               in varchar2
 ,p_wpt_attribute10_o              in varchar2
 ,p_wpt_attribute11_o              in varchar2
 ,p_wpt_attribute12_o              in varchar2
 ,p_wpt_attribute13_o              in varchar2
 ,p_wpt_attribute14_o              in varchar2
 ,p_wpt_attribute15_o              in varchar2
 ,p_wpt_attribute16_o              in varchar2
 ,p_wpt_attribute17_o              in varchar2
 ,p_wpt_attribute18_o              in varchar2
 ,p_wpt_attribute19_o              in varchar2
 ,p_wpt_attribute20_o              in varchar2
 ,p_wpt_attribute21_o              in varchar2
 ,p_wpt_attribute22_o              in varchar2
 ,p_wpt_attribute23_o              in varchar2
 ,p_wpt_attribute24_o              in varchar2
 ,p_wpt_attribute25_o              in varchar2
 ,p_wpt_attribute26_o              in varchar2
 ,p_wpt_attribute27_o              in varchar2
 ,p_wpt_attribute28_o              in varchar2
 ,p_wpt_attribute29_o              in varchar2
 ,p_wpt_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_wpt_rkd;

/
