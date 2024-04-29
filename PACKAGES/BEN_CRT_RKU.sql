--------------------------------------------------------
--  DDL for Package BEN_CRT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRT_RKU" AUTHID CURRENT_USER as
/* $Header: becrtrhi.pkh 120.0 2005/05/28 01:23:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_crt_ordr_id                    in number
 ,p_crt_ordr_typ_cd                in varchar2
 ,p_apls_perd_endg_dt              in date
 ,p_apls_perd_strtg_dt             in date
 ,p_crt_ident                      in varchar2
 ,p_description                    in varchar2
 ,p_detd_qlfd_ordr_dt              in date
 ,p_issue_dt                       in date
 ,p_qdro_amt                       in number
 ,p_qdro_dstr_mthd_cd              in varchar2
 ,p_qdro_pct                       in number
 ,p_rcvd_dt                        in date
 ,p_uom                            in varchar2
 ,p_crt_issng                      in varchar2
 ,p_pl_id                          in number
 ,p_person_id                      in number
 ,p_business_group_id              in number
 ,p_crt_attribute_category         in varchar2
 ,p_crt_attribute1                 in varchar2
 ,p_crt_attribute2                 in varchar2
 ,p_crt_attribute3                 in varchar2
 ,p_crt_attribute4                 in varchar2
 ,p_crt_attribute5                 in varchar2
 ,p_crt_attribute6                 in varchar2
 ,p_crt_attribute7                 in varchar2
 ,p_crt_attribute8                 in varchar2
 ,p_crt_attribute9                 in varchar2
 ,p_crt_attribute10                in varchar2
 ,p_crt_attribute11                in varchar2
 ,p_crt_attribute12                in varchar2
 ,p_crt_attribute13                in varchar2
 ,p_crt_attribute14                in varchar2
 ,p_crt_attribute15                in varchar2
 ,p_crt_attribute16                in varchar2
 ,p_crt_attribute17                in varchar2
 ,p_crt_attribute18                in varchar2
 ,p_crt_attribute19                in varchar2
 ,p_crt_attribute20                in varchar2
 ,p_crt_attribute21                in varchar2
 ,p_crt_attribute22                in varchar2
 ,p_crt_attribute23                in varchar2
 ,p_crt_attribute24                in varchar2
 ,p_crt_attribute25                in varchar2
 ,p_crt_attribute26                in varchar2
 ,p_crt_attribute27                in varchar2
 ,p_crt_attribute28                in varchar2
 ,p_crt_attribute29                in varchar2
 ,p_crt_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_qdro_num_pymt_val              in number
 ,p_qdro_per_perd_cd               in varchar2
 ,p_pl_typ_id                      in number
 ,p_effective_date                 in date
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
end ben_crt_rku;

 

/
