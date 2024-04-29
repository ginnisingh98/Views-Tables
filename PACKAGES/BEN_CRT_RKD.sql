--------------------------------------------------------
--  DDL for Package BEN_CRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRT_RKD" AUTHID CURRENT_USER as
/* $Header: becrtrhi.pkh 120.0 2005/05/28 01:23:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_crt_ordr_id                    in number
 ,p_crt_ordr_typ_cd_o              in varchar2
 ,p_apls_perd_endg_dt_o            in date
 ,p_apls_perd_strtg_dt_o           in date
 ,p_crt_ident_o                    in varchar2
 ,p_description_o                  in varchar2
 ,p_detd_qlfd_ordr_dt_o            in date
 ,p_issue_dt_o                     in date
 ,p_qdro_amt_o                     in number
 ,p_qdro_dstr_mthd_cd_o            in varchar2
 ,p_qdro_pct_o                     in number
 ,p_rcvd_dt_o                      in date
 ,p_uom_o                          in varchar2
 ,p_crt_issng_o                    in varchar2
 ,p_pl_id_o                        in number
 ,p_person_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_crt_attribute_category_o       in varchar2
 ,p_crt_attribute1_o               in varchar2
 ,p_crt_attribute2_o               in varchar2
 ,p_crt_attribute3_o               in varchar2
 ,p_crt_attribute4_o               in varchar2
 ,p_crt_attribute5_o               in varchar2
 ,p_crt_attribute6_o               in varchar2
 ,p_crt_attribute7_o               in varchar2
 ,p_crt_attribute8_o               in varchar2
 ,p_crt_attribute9_o               in varchar2
 ,p_crt_attribute10_o              in varchar2
 ,p_crt_attribute11_o              in varchar2
 ,p_crt_attribute12_o              in varchar2
 ,p_crt_attribute13_o              in varchar2
 ,p_crt_attribute14_o              in varchar2
 ,p_crt_attribute15_o              in varchar2
 ,p_crt_attribute16_o              in varchar2
 ,p_crt_attribute17_o              in varchar2
 ,p_crt_attribute18_o              in varchar2
 ,p_crt_attribute19_o              in varchar2
 ,p_crt_attribute20_o              in varchar2
 ,p_crt_attribute21_o              in varchar2
 ,p_crt_attribute22_o              in varchar2
 ,p_crt_attribute23_o              in varchar2
 ,p_crt_attribute24_o              in varchar2
 ,p_crt_attribute25_o              in varchar2
 ,p_crt_attribute26_o              in varchar2
 ,p_crt_attribute27_o              in varchar2
 ,p_crt_attribute28_o              in varchar2
 ,p_crt_attribute29_o              in varchar2
 ,p_crt_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_qdro_num_pymt_val_o            in number
 ,p_qdro_per_perd_cd_o             in varchar2
 ,p_pl_typ_id_o                    in number
  );
--
end ben_crt_rkd;

 

/
