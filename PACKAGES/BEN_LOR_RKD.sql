--------------------------------------------------------
--  DDL for Package BEN_LOR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOR_RKD" AUTHID CURRENT_USER as
/* $Header: belorrhi.pkh 120.0 2005/05/28 03:28:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_chg_plip_enrt_rl_id        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_formula_id_o          in number
 ,p_ler_chg_plip_enrt_id_o         in number
 ,p_ordr_to_aply_num_o             in number
 ,p_lor_attribute_category_o       in varchar2
 ,p_lor_attribute1_o               in varchar2
 ,p_lor_attribute2_o               in varchar2
 ,p_lor_attribute3_o               in varchar2
 ,p_lor_attribute4_o               in varchar2
 ,p_lor_attribute5_o               in varchar2
 ,p_lor_attribute6_o               in varchar2
 ,p_lor_attribute7_o               in varchar2
 ,p_lor_attribute8_o               in varchar2
 ,p_lor_attribute9_o               in varchar2
 ,p_lor_attribute10_o              in varchar2
 ,p_lor_attribute11_o              in varchar2
 ,p_lor_attribute12_o              in varchar2
 ,p_lor_attribute13_o              in varchar2
 ,p_lor_attribute14_o              in varchar2
 ,p_lor_attribute15_o              in varchar2
 ,p_lor_attribute16_o              in varchar2
 ,p_lor_attribute17_o              in varchar2
 ,p_lor_attribute18_o              in varchar2
 ,p_lor_attribute19_o              in varchar2
 ,p_lor_attribute20_o              in varchar2
 ,p_lor_attribute21_o              in varchar2
 ,p_lor_attribute22_o              in varchar2
 ,p_lor_attribute23_o              in varchar2
 ,p_lor_attribute24_o              in varchar2
 ,p_lor_attribute25_o              in varchar2
 ,p_lor_attribute26_o              in varchar2
 ,p_lor_attribute27_o              in varchar2
 ,p_lor_attribute28_o              in varchar2
 ,p_lor_attribute29_o              in varchar2
 ,p_lor_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lor_rkd;

 

/
