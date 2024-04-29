--------------------------------------------------------
--  DDL for Package BEN_CPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPT_RKD" AUTHID CURRENT_USER as
/* $Header: becptrhi.pkh 120.0 2005/05/28 01:18:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cmbn_ptip_opt_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_cpt_attribute_category_o       in varchar2
 ,p_cpt_attribute1_o               in varchar2
 ,p_cpt_attribute2_o               in varchar2
 ,p_cpt_attribute3_o               in varchar2
 ,p_cpt_attribute4_o               in varchar2
 ,p_cpt_attribute5_o               in varchar2
 ,p_cpt_attribute6_o               in varchar2
 ,p_cpt_attribute7_o               in varchar2
 ,p_cpt_attribute8_o               in varchar2
 ,p_cpt_attribute9_o               in varchar2
 ,p_cpt_attribute10_o              in varchar2
 ,p_cpt_attribute11_o              in varchar2
 ,p_cpt_attribute12_o              in varchar2
 ,p_cpt_attribute13_o              in varchar2
 ,p_cpt_attribute14_o              in varchar2
 ,p_cpt_attribute15_o              in varchar2
 ,p_cpt_attribute16_o              in varchar2
 ,p_cpt_attribute17_o              in varchar2
 ,p_cpt_attribute18_o              in varchar2
 ,p_cpt_attribute19_o              in varchar2
 ,p_cpt_attribute20_o              in varchar2
 ,p_cpt_attribute21_o              in varchar2
 ,p_cpt_attribute22_o              in varchar2
 ,p_cpt_attribute23_o              in varchar2
 ,p_cpt_attribute24_o              in varchar2
 ,p_cpt_attribute25_o              in varchar2
 ,p_cpt_attribute26_o              in varchar2
 ,p_cpt_attribute27_o              in varchar2
 ,p_cpt_attribute28_o              in varchar2
 ,p_cpt_attribute29_o              in varchar2
 ,p_cpt_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_ptip_id_o                      in number
 ,p_pgm_id_o                       in number
 ,p_opt_id_o                       in number
  );
--
end ben_cpt_rkd;

 

/
