--------------------------------------------------------
--  DDL for Package BEN_ETW_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ETW_RKU" AUTHID CURRENT_USER as
/* $Header: beetwrhi.pkh 120.0 2005/05/28 03:04:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_per_wv_pl_typ_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_pl_typ_id                      in number
 ,p_elig_per_id                    in number
 ,p_wv_cftn_typ_cd                 in varchar2
 ,p_wv_prtn_rsn_cd                 in varchar2
 ,p_wvd_flag                       in varchar2
 ,p_business_group_id              in number
 ,p_etw_attribute_category         in varchar2
 ,p_etw_attribute1                 in varchar2
 ,p_etw_attribute2                 in varchar2
 ,p_etw_attribute3                 in varchar2
 ,p_etw_attribute4                 in varchar2
 ,p_etw_attribute5                 in varchar2
 ,p_etw_attribute6                 in varchar2
 ,p_etw_attribute7                 in varchar2
 ,p_etw_attribute8                 in varchar2
 ,p_etw_attribute9                 in varchar2
 ,p_etw_attribute10                in varchar2
 ,p_etw_attribute11                in varchar2
 ,p_etw_attribute12                in varchar2
 ,p_etw_attribute13                in varchar2
 ,p_etw_attribute14                in varchar2
 ,p_etw_attribute15                in varchar2
 ,p_etw_attribute16                in varchar2
 ,p_etw_attribute17                in varchar2
 ,p_etw_attribute18                in varchar2
 ,p_etw_attribute19                in varchar2
 ,p_etw_attribute20                in varchar2
 ,p_etw_attribute21                in varchar2
 ,p_etw_attribute22                in varchar2
 ,p_etw_attribute23                in varchar2
 ,p_etw_attribute24                in varchar2
 ,p_etw_attribute25                in varchar2
 ,p_etw_attribute26                in varchar2
 ,p_etw_attribute27                in varchar2
 ,p_etw_attribute28                in varchar2
 ,p_etw_attribute29                in varchar2
 ,p_etw_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_pl_typ_id_o                    in number
 ,p_elig_per_id_o                  in number
 ,p_wv_cftn_typ_cd_o               in varchar2
 ,p_wv_prtn_rsn_cd_o               in varchar2
 ,p_wvd_flag_o                     in varchar2
 ,p_business_group_id_o            in number
 ,p_etw_attribute_category_o       in varchar2
 ,p_etw_attribute1_o               in varchar2
 ,p_etw_attribute2_o               in varchar2
 ,p_etw_attribute3_o               in varchar2
 ,p_etw_attribute4_o               in varchar2
 ,p_etw_attribute5_o               in varchar2
 ,p_etw_attribute6_o               in varchar2
 ,p_etw_attribute7_o               in varchar2
 ,p_etw_attribute8_o               in varchar2
 ,p_etw_attribute9_o               in varchar2
 ,p_etw_attribute10_o              in varchar2
 ,p_etw_attribute11_o              in varchar2
 ,p_etw_attribute12_o              in varchar2
 ,p_etw_attribute13_o              in varchar2
 ,p_etw_attribute14_o              in varchar2
 ,p_etw_attribute15_o              in varchar2
 ,p_etw_attribute16_o              in varchar2
 ,p_etw_attribute17_o              in varchar2
 ,p_etw_attribute18_o              in varchar2
 ,p_etw_attribute19_o              in varchar2
 ,p_etw_attribute20_o              in varchar2
 ,p_etw_attribute21_o              in varchar2
 ,p_etw_attribute22_o              in varchar2
 ,p_etw_attribute23_o              in varchar2
 ,p_etw_attribute24_o              in varchar2
 ,p_etw_attribute25_o              in varchar2
 ,p_etw_attribute26_o              in varchar2
 ,p_etw_attribute27_o              in varchar2
 ,p_etw_attribute28_o              in varchar2
 ,p_etw_attribute29_o              in varchar2
 ,p_etw_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_etw_rku;

 

/
