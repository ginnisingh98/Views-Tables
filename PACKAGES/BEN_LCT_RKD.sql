--------------------------------------------------------
--  DDL for Package BEN_LCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LCT_RKD" AUTHID CURRENT_USER as
/* $Header: belctrhi.pkh 120.0 2005/05/28 03:19:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_chg_ptip_enrt_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_crnt_enrt_prclds_chg_flag_o    in varchar2
 ,p_stl_elig_cant_chg_flag_o       in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_dflt_enrt_cd_o                 in varchar2
 ,p_dflt_enrt_rl_o                 in varchar2
 ,p_enrt_cd_o                      in varchar2
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_enrt_rl_o                      in varchar2
 ,p_tco_chg_enrt_cd_o              in varchar2
 ,p_ptip_id_o                      in number
 ,p_ler_id_o                       in number
 ,p_business_group_id_o            in number
 ,p_lct_attribute_category_o       in varchar2
 ,p_lct_attribute1_o               in varchar2
 ,p_lct_attribute2_o               in varchar2
 ,p_lct_attribute3_o               in varchar2
 ,p_lct_attribute4_o               in varchar2
 ,p_lct_attribute5_o               in varchar2
 ,p_lct_attribute6_o               in varchar2
 ,p_lct_attribute7_o               in varchar2
 ,p_lct_attribute8_o               in varchar2
 ,p_lct_attribute9_o               in varchar2
 ,p_lct_attribute10_o              in varchar2
 ,p_lct_attribute11_o              in varchar2
 ,p_lct_attribute12_o              in varchar2
 ,p_lct_attribute13_o              in varchar2
 ,p_lct_attribute14_o              in varchar2
 ,p_lct_attribute15_o              in varchar2
 ,p_lct_attribute16_o              in varchar2
 ,p_lct_attribute17_o              in varchar2
 ,p_lct_attribute18_o              in varchar2
 ,p_lct_attribute19_o              in varchar2
 ,p_lct_attribute20_o              in varchar2
 ,p_lct_attribute21_o              in varchar2
 ,p_lct_attribute22_o              in varchar2
 ,p_lct_attribute23_o              in varchar2
 ,p_lct_attribute24_o              in varchar2
 ,p_lct_attribute25_o              in varchar2
 ,p_lct_attribute26_o              in varchar2
 ,p_lct_attribute27_o              in varchar2
 ,p_lct_attribute28_o              in varchar2
 ,p_lct_attribute29_o              in varchar2
 ,p_lct_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lct_rkd;

 

/
