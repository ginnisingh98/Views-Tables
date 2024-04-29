--------------------------------------------------------
--  DDL for Package BEN_CPO_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPO_RKD" AUTHID CURRENT_USER as
/* $Header: becporhi.pkh 120.0 2005/05/28 01:16:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_popl_org_id                    in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_cstmr_num_o                    in number
 ,p_plcy_r_grp_o                     in varchar2
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_organization_id_o              in number
 ,p_person_id_o                    in number
 ,p_cpo_attribute_category_o       in varchar2
 ,p_cpo_attribute1_o               in varchar2
 ,p_cpo_attribute2_o               in varchar2
 ,p_cpo_attribute3_o               in varchar2
 ,p_cpo_attribute4_o               in varchar2
 ,p_cpo_attribute5_o               in varchar2
 ,p_cpo_attribute6_o               in varchar2
 ,p_cpo_attribute7_o               in varchar2
 ,p_cpo_attribute8_o               in varchar2
 ,p_cpo_attribute9_o               in varchar2
 ,p_cpo_attribute10_o              in varchar2
 ,p_cpo_attribute11_o              in varchar2
 ,p_cpo_attribute12_o              in varchar2
 ,p_cpo_attribute13_o              in varchar2
 ,p_cpo_attribute14_o              in varchar2
 ,p_cpo_attribute15_o              in varchar2
 ,p_cpo_attribute16_o              in varchar2
 ,p_cpo_attribute17_o              in varchar2
 ,p_cpo_attribute18_o              in varchar2
 ,p_cpo_attribute19_o              in varchar2
 ,p_cpo_attribute20_o              in varchar2
 ,p_cpo_attribute21_o              in varchar2
 ,p_cpo_attribute22_o              in varchar2
 ,p_cpo_attribute23_o              in varchar2
 ,p_cpo_attribute24_o              in varchar2
 ,p_cpo_attribute25_o              in varchar2
 ,p_cpo_attribute26_o              in varchar2
 ,p_cpo_attribute27_o              in varchar2
 ,p_cpo_attribute28_o              in varchar2
 ,p_cpo_attribute29_o              in varchar2
 ,p_cpo_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cpo_rkd;

 

/
