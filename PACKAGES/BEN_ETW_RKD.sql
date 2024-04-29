--------------------------------------------------------
--  DDL for Package BEN_ETW_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ETW_RKD" AUTHID CURRENT_USER as
/* $Header: beetwrhi.pkh 120.0 2005/05/28 03:04:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_per_wv_pl_typ_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_etw_rkd;

 

/
