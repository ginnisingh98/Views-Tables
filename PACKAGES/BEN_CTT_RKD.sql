--------------------------------------------------------
--  DDL for Package BEN_CTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTT_RKD" AUTHID CURRENT_USER as
/* $Header: becttrhi.pkh 120.0 2005/05/28 01:27:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cm_typ_trgr_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_cm_typ_trgr_rl_o               in number
 ,p_cm_trgr_id_o                   in number
 ,p_cm_typ_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_ctt_attribute_category_o       in varchar2
 ,p_ctt_attribute1_o               in varchar2
 ,p_ctt_attribute2_o               in varchar2
 ,p_ctt_attribute3_o               in varchar2
 ,p_ctt_attribute4_o               in varchar2
 ,p_ctt_attribute5_o               in varchar2
 ,p_ctt_attribute6_o               in varchar2
 ,p_ctt_attribute7_o               in varchar2
 ,p_ctt_attribute8_o               in varchar2
 ,p_ctt_attribute9_o               in varchar2
 ,p_ctt_attribute10_o              in varchar2
 ,p_ctt_attribute11_o              in varchar2
 ,p_ctt_attribute12_o              in varchar2
 ,p_ctt_attribute13_o              in varchar2
 ,p_ctt_attribute14_o              in varchar2
 ,p_ctt_attribute15_o              in varchar2
 ,p_ctt_attribute16_o              in varchar2
 ,p_ctt_attribute17_o              in varchar2
 ,p_ctt_attribute18_o              in varchar2
 ,p_ctt_attribute19_o              in varchar2
 ,p_ctt_attribute20_o              in varchar2
 ,p_ctt_attribute21_o              in varchar2
 ,p_ctt_attribute22_o              in varchar2
 ,p_ctt_attribute23_o              in varchar2
 ,p_ctt_attribute24_o              in varchar2
 ,p_ctt_attribute25_o              in varchar2
 ,p_ctt_attribute26_o              in varchar2
 ,p_ctt_attribute27_o              in varchar2
 ,p_ctt_attribute28_o              in varchar2
 ,p_ctt_attribute29_o              in varchar2
 ,p_ctt_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ctt_rkd;

 

/