--------------------------------------------------------
--  DDL for Package BEN_CQB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CQB_RKD" AUTHID CURRENT_USER as
/* $Header: becqbrhi.pkh 120.0 2005/05/28 01:19:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cbr_quald_bnf_id               in number
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
end ben_cqb_rkd;

 

/
