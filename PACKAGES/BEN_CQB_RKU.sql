--------------------------------------------------------
--  DDL for Package BEN_CQB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CQB_RKU" AUTHID CURRENT_USER as
/* $Header: becqbrhi.pkh 120.0 2005/05/28 01:19:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cbr_quald_bnf_id               in number
 ,p_quald_bnf_flag                 in varchar2
 ,p_cbr_elig_perd_strt_dt          in date
 ,p_cbr_elig_perd_end_dt           in date
 ,p_quald_bnf_person_id            in number
 ,p_pgm_id                         in number
 ,p_ptip_id                        in number
 ,p_pl_typ_id                      in number
 ,p_cvrd_emp_person_id             in number
 ,p_cbr_inelg_rsn_cd               in varchar2
 ,p_business_group_id              in number
 ,p_cqb_attribute_category         in varchar2
 ,p_cqb_attribute1                 in varchar2
 ,p_cqb_attribute2                 in varchar2
 ,p_cqb_attribute3                 in varchar2
 ,p_cqb_attribute4                 in varchar2
 ,p_cqb_attribute5                 in varchar2
 ,p_cqb_attribute6                 in varchar2
 ,p_cqb_attribute7                 in varchar2
 ,p_cqb_attribute8                 in varchar2
 ,p_cqb_attribute9                 in varchar2
 ,p_cqb_attribute10                in varchar2
 ,p_cqb_attribute11                in varchar2
 ,p_cqb_attribute12                in varchar2
 ,p_cqb_attribute13                in varchar2
 ,p_cqb_attribute14                in varchar2
 ,p_cqb_attribute15                in varchar2
 ,p_cqb_attribute16                in varchar2
 ,p_cqb_attribute17                in varchar2
 ,p_cqb_attribute18                in varchar2
 ,p_cqb_attribute19                in varchar2
 ,p_cqb_attribute20                in varchar2
 ,p_cqb_attribute21                in varchar2
 ,p_cqb_attribute22                in varchar2
 ,p_cqb_attribute23                in varchar2
 ,p_cqb_attribute24                in varchar2
 ,p_cqb_attribute25                in varchar2
 ,p_cqb_attribute26                in varchar2
 ,p_cqb_attribute27                in varchar2
 ,p_cqb_attribute28                in varchar2
 ,p_cqb_attribute29                in varchar2
 ,p_cqb_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_quald_bnf_flag_o               in varchar2
 ,p_cbr_elig_perd_strt_dt_o        in date
 ,p_cbr_elig_perd_end_dt_o         in date
 ,p_quald_bnf_person_id_o          in number
 ,p_pgm_id_o                       in number
 ,p_ptip_id_o                      in number
 ,p_pl_typ_id_o                    in number
 ,p_cvrd_emp_person_id_o           in number
 ,p_cbr_inelg_rsn_cd_o             in varchar2
 ,p_business_group_id_o            in number
 ,p_cqb_attribute_category_o       in varchar2
 ,p_cqb_attribute1_o               in varchar2
 ,p_cqb_attribute2_o               in varchar2
 ,p_cqb_attribute3_o               in varchar2
 ,p_cqb_attribute4_o               in varchar2
 ,p_cqb_attribute5_o               in varchar2
 ,p_cqb_attribute6_o               in varchar2
 ,p_cqb_attribute7_o               in varchar2
 ,p_cqb_attribute8_o               in varchar2
 ,p_cqb_attribute9_o               in varchar2
 ,p_cqb_attribute10_o              in varchar2
 ,p_cqb_attribute11_o              in varchar2
 ,p_cqb_attribute12_o              in varchar2
 ,p_cqb_attribute13_o              in varchar2
 ,p_cqb_attribute14_o              in varchar2
 ,p_cqb_attribute15_o              in varchar2
 ,p_cqb_attribute16_o              in varchar2
 ,p_cqb_attribute17_o              in varchar2
 ,p_cqb_attribute18_o              in varchar2
 ,p_cqb_attribute19_o              in varchar2
 ,p_cqb_attribute20_o              in varchar2
 ,p_cqb_attribute21_o              in varchar2
 ,p_cqb_attribute22_o              in varchar2
 ,p_cqb_attribute23_o              in varchar2
 ,p_cqb_attribute24_o              in varchar2
 ,p_cqb_attribute25_o              in varchar2
 ,p_cqb_attribute26_o              in varchar2
 ,p_cqb_attribute27_o              in varchar2
 ,p_cqb_attribute28_o              in varchar2
 ,p_cqb_attribute29_o              in varchar2
 ,p_cqb_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cqb_rku;

 

/
