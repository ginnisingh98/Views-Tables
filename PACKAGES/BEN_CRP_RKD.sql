--------------------------------------------------------
--  DDL for Package BEN_CRP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRP_RKD" AUTHID CURRENT_USER as
/* $Header: becrprhi.pkh 120.0 2005/05/28 01:22:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cbr_per_in_ler_id              in number
 ,p_init_evt_flag_o                in varchar2
 ,p_cnt_num_o                      in number
 ,p_per_in_ler_id_o                in number
 ,p_cbr_quald_bnf_id_o             in number
 ,p_prvs_elig_perd_end_dt_o        in date
 ,p_business_group_id_o            in number
 ,p_crp_attribute_category_o       in varchar2
 ,p_crp_attribute1_o               in varchar2
 ,p_crp_attribute2_o               in varchar2
 ,p_crp_attribute3_o               in varchar2
 ,p_crp_attribute4_o               in varchar2
 ,p_crp_attribute5_o               in varchar2
 ,p_crp_attribute6_o               in varchar2
 ,p_crp_attribute7_o               in varchar2
 ,p_crp_attribute8_o               in varchar2
 ,p_crp_attribute9_o               in varchar2
 ,p_crp_attribute10_o              in varchar2
 ,p_crp_attribute11_o              in varchar2
 ,p_crp_attribute12_o              in varchar2
 ,p_crp_attribute13_o              in varchar2
 ,p_crp_attribute14_o              in varchar2
 ,p_crp_attribute15_o              in varchar2
 ,p_crp_attribute16_o              in varchar2
 ,p_crp_attribute17_o              in varchar2
 ,p_crp_attribute18_o              in varchar2
 ,p_crp_attribute19_o              in varchar2
 ,p_crp_attribute20_o              in varchar2
 ,p_crp_attribute21_o              in varchar2
 ,p_crp_attribute22_o              in varchar2
 ,p_crp_attribute23_o              in varchar2
 ,p_crp_attribute24_o              in varchar2
 ,p_crp_attribute25_o              in varchar2
 ,p_crp_attribute26_o              in varchar2
 ,p_crp_attribute27_o              in varchar2
 ,p_crp_attribute28_o              in varchar2
 ,p_crp_attribute29_o              in varchar2
 ,p_crp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_crp_rkd;

 

/
