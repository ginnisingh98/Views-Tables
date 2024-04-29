--------------------------------------------------------
--  DDL for Package BEN_LOP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOP_RKD" AUTHID CURRENT_USER as
/* $Header: beloprhi.pkh 120.0 2005/05/28 03:27:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_chg_oipl_enrt_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_oipl_id_o                      in number
 ,p_ler_id_o                       in number
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_crnt_enrt_prclds_chg_flag_o    in varchar2
 ,p_enrt_cd_o                      in varchar2
 ,p_enrt_rl_o                      in number
 ,p_dflt_enrt_rl_o                 in number
 ,p_dflt_enrt_cd_o                 in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_stl_elig_cant_chg_flag_o       in varchar2
 ,p_auto_enrt_flag_o               in varchar2
 ,p_lop_attribute_category_o       in varchar2
 ,p_lop_attribute1_o               in varchar2
 ,p_lop_attribute2_o               in varchar2
 ,p_lop_attribute3_o               in varchar2
 ,p_lop_attribute4_o               in varchar2
 ,p_lop_attribute5_o               in varchar2
 ,p_lop_attribute6_o               in varchar2
 ,p_lop_attribute7_o               in varchar2
 ,p_lop_attribute8_o               in varchar2
 ,p_lop_attribute9_o               in varchar2
 ,p_lop_attribute10_o              in varchar2
 ,p_lop_attribute11_o              in varchar2
 ,p_lop_attribute12_o              in varchar2
 ,p_lop_attribute13_o              in varchar2
 ,p_lop_attribute14_o              in varchar2
 ,p_lop_attribute15_o              in varchar2
 ,p_lop_attribute16_o              in varchar2
 ,p_lop_attribute17_o              in varchar2
 ,p_lop_attribute18_o              in varchar2
 ,p_lop_attribute19_o              in varchar2
 ,p_lop_attribute20_o              in varchar2
 ,p_lop_attribute21_o              in varchar2
 ,p_lop_attribute22_o              in varchar2
 ,p_lop_attribute23_o              in varchar2
 ,p_lop_attribute24_o              in varchar2
 ,p_lop_attribute25_o              in varchar2
 ,p_lop_attribute26_o              in varchar2
 ,p_lop_attribute27_o              in varchar2
 ,p_lop_attribute28_o              in varchar2
 ,p_lop_attribute29_o              in varchar2
 ,p_lop_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lop_rkd;

 

/
