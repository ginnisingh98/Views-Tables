--------------------------------------------------------
--  DDL for Package BEN_WPN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WPN_RKU" AUTHID CURRENT_USER as
/* $Header: bewpnrhi.pkh 120.0.12010000.1 2008/07/29 13:09:39 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_wv_prtn_rsn_pl_id              in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pl_id                          in number
 ,p_dflt_flag                      in varchar2
 ,p_wv_prtn_rsn_cd                 in varchar2
 ,p_wpn_attribute_category         in varchar2
 ,p_wpn_attribute1                 in varchar2
 ,p_wpn_attribute2                 in varchar2
 ,p_wpn_attribute3                 in varchar2
 ,p_wpn_attribute4                 in varchar2
 ,p_wpn_attribute5                 in varchar2
 ,p_wpn_attribute6                 in varchar2
 ,p_wpn_attribute7                 in varchar2
 ,p_wpn_attribute8                 in varchar2
 ,p_wpn_attribute9                 in varchar2
 ,p_wpn_attribute10                in varchar2
 ,p_wpn_attribute11                in varchar2
 ,p_wpn_attribute12                in varchar2
 ,p_wpn_attribute13                in varchar2
 ,p_wpn_attribute14                in varchar2
 ,p_wpn_attribute15                in varchar2
 ,p_wpn_attribute16                in varchar2
 ,p_wpn_attribute17                in varchar2
 ,p_wpn_attribute18                in varchar2
 ,p_wpn_attribute19                in varchar2
 ,p_wpn_attribute20                in varchar2
 ,p_wpn_attribute21                in varchar2
 ,p_wpn_attribute22                in varchar2
 ,p_wpn_attribute23                in varchar2
 ,p_wpn_attribute24                in varchar2
 ,p_wpn_attribute25                in varchar2
 ,p_wpn_attribute26                in varchar2
 ,p_wpn_attribute27                in varchar2
 ,p_wpn_attribute28                in varchar2
 ,p_wpn_attribute29                in varchar2
 ,p_wpn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_dflt_flag_o                    in varchar2
 ,p_wv_prtn_rsn_cd_o               in varchar2
 ,p_wpn_attribute_category_o       in varchar2
 ,p_wpn_attribute1_o               in varchar2
 ,p_wpn_attribute2_o               in varchar2
 ,p_wpn_attribute3_o               in varchar2
 ,p_wpn_attribute4_o               in varchar2
 ,p_wpn_attribute5_o               in varchar2
 ,p_wpn_attribute6_o               in varchar2
 ,p_wpn_attribute7_o               in varchar2
 ,p_wpn_attribute8_o               in varchar2
 ,p_wpn_attribute9_o               in varchar2
 ,p_wpn_attribute10_o              in varchar2
 ,p_wpn_attribute11_o              in varchar2
 ,p_wpn_attribute12_o              in varchar2
 ,p_wpn_attribute13_o              in varchar2
 ,p_wpn_attribute14_o              in varchar2
 ,p_wpn_attribute15_o              in varchar2
 ,p_wpn_attribute16_o              in varchar2
 ,p_wpn_attribute17_o              in varchar2
 ,p_wpn_attribute18_o              in varchar2
 ,p_wpn_attribute19_o              in varchar2
 ,p_wpn_attribute20_o              in varchar2
 ,p_wpn_attribute21_o              in varchar2
 ,p_wpn_attribute22_o              in varchar2
 ,p_wpn_attribute23_o              in varchar2
 ,p_wpn_attribute24_o              in varchar2
 ,p_wpn_attribute25_o              in varchar2
 ,p_wpn_attribute26_o              in varchar2
 ,p_wpn_attribute27_o              in varchar2
 ,p_wpn_attribute28_o              in varchar2
 ,p_wpn_attribute29_o              in varchar2
 ,p_wpn_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_wpn_rku;

/
