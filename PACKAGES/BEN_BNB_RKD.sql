--------------------------------------------------------
--  DDL for Package BEN_BNB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNB_RKD" AUTHID CURRENT_USER as
/* $Header: bebnbrhi.pkh 120.0 2005/05/28 00:44:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_bnfts_bal_id                   in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_bnfts_bal_usg_cd_o             in varchar2
 ,p_bnfts_bal_desc_o               in varchar2
 ,p_uom_o                          in varchar2
 ,p_nnmntry_uom_o                  in varchar2
 ,p_business_group_id_o            in number
 ,p_bnb_attribute_category_o       in varchar2
 ,p_bnb_attribute1_o               in varchar2
 ,p_bnb_attribute2_o               in varchar2
 ,p_bnb_attribute3_o               in varchar2
 ,p_bnb_attribute4_o               in varchar2
 ,p_bnb_attribute5_o               in varchar2
 ,p_bnb_attribute6_o               in varchar2
 ,p_bnb_attribute7_o               in varchar2
 ,p_bnb_attribute8_o               in varchar2
 ,p_bnb_attribute9_o               in varchar2
 ,p_bnb_attribute10_o              in varchar2
 ,p_bnb_attribute11_o              in varchar2
 ,p_bnb_attribute12_o              in varchar2
 ,p_bnb_attribute13_o              in varchar2
 ,p_bnb_attribute14_o              in varchar2
 ,p_bnb_attribute15_o              in varchar2
 ,p_bnb_attribute16_o              in varchar2
 ,p_bnb_attribute17_o              in varchar2
 ,p_bnb_attribute18_o              in varchar2
 ,p_bnb_attribute19_o              in varchar2
 ,p_bnb_attribute20_o              in varchar2
 ,p_bnb_attribute21_o              in varchar2
 ,p_bnb_attribute22_o              in varchar2
 ,p_bnb_attribute23_o              in varchar2
 ,p_bnb_attribute24_o              in varchar2
 ,p_bnb_attribute25_o              in varchar2
 ,p_bnb_attribute26_o              in varchar2
 ,p_bnb_attribute27_o              in varchar2
 ,p_bnb_attribute28_o              in varchar2
 ,p_bnb_attribute29_o              in varchar2
 ,p_bnb_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_bnb_rkd;

 

/
