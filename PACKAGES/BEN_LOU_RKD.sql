--------------------------------------------------------
--  DDL for Package BEN_LOU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOU_RKD" AUTHID CURRENT_USER as
/* $Header: belourhi.pkh 120.0 2005/05/28 03:29:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_chg_oipl_enrt_rl_id        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_formula_id_o          in number
 ,p_ler_chg_oipl_enrt_id_o         in number
 ,p_ordr_to_aply_num_o             in number
 ,p_lou_attribute_category_o       in varchar2
 ,p_lou_attribute1_o               in varchar2
 ,p_lou_attribute2_o               in varchar2
 ,p_lou_attribute3_o               in varchar2
 ,p_lou_attribute4_o               in varchar2
 ,p_lou_attribute5_o               in varchar2
 ,p_lou_attribute6_o               in varchar2
 ,p_lou_attribute7_o               in varchar2
 ,p_lou_attribute8_o               in varchar2
 ,p_lou_attribute9_o               in varchar2
 ,p_lou_attribute10_o              in varchar2
 ,p_lou_attribute11_o              in varchar2
 ,p_lou_attribute12_o              in varchar2
 ,p_lou_attribute13_o              in varchar2
 ,p_lou_attribute14_o              in varchar2
 ,p_lou_attribute15_o              in varchar2
 ,p_lou_attribute16_o              in varchar2
 ,p_lou_attribute17_o              in varchar2
 ,p_lou_attribute18_o              in varchar2
 ,p_lou_attribute19_o              in varchar2
 ,p_lou_attribute20_o              in varchar2
 ,p_lou_attribute21_o              in varchar2
 ,p_lou_attribute22_o              in varchar2
 ,p_lou_attribute23_o              in varchar2
 ,p_lou_attribute24_o              in varchar2
 ,p_lou_attribute25_o              in varchar2
 ,p_lou_attribute26_o              in varchar2
 ,p_lou_attribute27_o              in varchar2
 ,p_lou_attribute28_o              in varchar2
 ,p_lou_attribute29_o              in varchar2
 ,p_lou_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lou_rkd;

 

/
