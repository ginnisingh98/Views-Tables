--------------------------------------------------------
--  DDL for Package BEN_CRP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRP_RKU" AUTHID CURRENT_USER as
/* $Header: becrprhi.pkh 120.0 2005/05/28 01:22:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cbr_per_in_ler_id              in number
 ,p_init_evt_flag                  in varchar2
 ,p_cnt_num                        in number
 ,p_per_in_ler_id                  in number
 ,p_cbr_quald_bnf_id               in number
 ,p_prvs_elig_perd_end_dt          in date
 ,p_business_group_id              in number
 ,p_crp_attribute_category         in varchar2
 ,p_crp_attribute1                 in varchar2
 ,p_crp_attribute2                 in varchar2
 ,p_crp_attribute3                 in varchar2
 ,p_crp_attribute4                 in varchar2
 ,p_crp_attribute5                 in varchar2
 ,p_crp_attribute6                 in varchar2
 ,p_crp_attribute7                 in varchar2
 ,p_crp_attribute8                 in varchar2
 ,p_crp_attribute9                 in varchar2
 ,p_crp_attribute10                in varchar2
 ,p_crp_attribute11                in varchar2
 ,p_crp_attribute12                in varchar2
 ,p_crp_attribute13                in varchar2
 ,p_crp_attribute14                in varchar2
 ,p_crp_attribute15                in varchar2
 ,p_crp_attribute16                in varchar2
 ,p_crp_attribute17                in varchar2
 ,p_crp_attribute18                in varchar2
 ,p_crp_attribute19                in varchar2
 ,p_crp_attribute20                in varchar2
 ,p_crp_attribute21                in varchar2
 ,p_crp_attribute22                in varchar2
 ,p_crp_attribute23                in varchar2
 ,p_crp_attribute24                in varchar2
 ,p_crp_attribute25                in varchar2
 ,p_crp_attribute26                in varchar2
 ,p_crp_attribute27                in varchar2
 ,p_crp_attribute28                in varchar2
 ,p_crp_attribute29                in varchar2
 ,p_crp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
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
end ben_crp_rku;

 

/
