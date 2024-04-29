--------------------------------------------------------
--  DDL for Package BEN_PBN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBN_RKU" AUTHID CURRENT_USER as
/* $Header: bepbnrhi.pkh 120.0.12000000.1 2007/01/19 20:00:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pl_bnf_id                      in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_prtt_enrt_rslt_id              in number
 ,p_bnf_person_id                  in number
 ,p_organization_id                in number
 ,p_ttee_person_id                 in number
 ,p_prmry_cntngnt_cd               in varchar2
 ,p_pct_dsgd_num                   in number
 ,p_amt_dsgd_val                   in number
 ,p_amt_dsgd_uom                   in varchar2
 ,p_dsgn_strt_dt                   in date
 ,p_dsgn_thru_dt                   in date
 ,p_addl_instrn_txt                in varchar2
 ,p_pbn_attribute_category         in varchar2
 ,p_pbn_attribute1                 in varchar2
 ,p_pbn_attribute2                 in varchar2
 ,p_pbn_attribute3                 in varchar2
 ,p_pbn_attribute4                 in varchar2
 ,p_pbn_attribute5                 in varchar2
 ,p_pbn_attribute6                 in varchar2
 ,p_pbn_attribute7                 in varchar2
 ,p_pbn_attribute8                 in varchar2
 ,p_pbn_attribute9                 in varchar2
 ,p_pbn_attribute10                in varchar2
 ,p_pbn_attribute11                in varchar2
 ,p_pbn_attribute12                in varchar2
 ,p_pbn_attribute13                in varchar2
 ,p_pbn_attribute14                in varchar2
 ,p_pbn_attribute15                in varchar2
 ,p_pbn_attribute16                in varchar2
 ,p_pbn_attribute17                in varchar2
 ,p_pbn_attribute18                in varchar2
 ,p_pbn_attribute19                in varchar2
 ,p_pbn_attribute20                in varchar2
 ,p_pbn_attribute21                in varchar2
 ,p_pbn_attribute22                in varchar2
 ,p_pbn_attribute23                in varchar2
 ,p_pbn_attribute24                in varchar2
 ,p_pbn_attribute25                in varchar2
 ,p_pbn_attribute26                in varchar2
 ,p_pbn_attribute27                in varchar2
 ,p_pbn_attribute28                in varchar2
 ,p_pbn_attribute29                in varchar2
 ,p_pbn_attribute30                in varchar2
 ,p_request_id                     in  number
 ,p_program_application_id         in  number
 ,p_program_id                     in  number
 ,p_program_update_date            in  date
 ,p_object_version_number          in number
 ,p_per_in_ler_id                  in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_prtt_enrt_rslt_id_o            in number
 ,p_bnf_person_id_o                in number
 ,p_organization_id_o              in number
 ,p_ttee_person_id_o               in number
 ,p_prmry_cntngnt_cd_o             in varchar2
 ,p_pct_dsgd_num_o                 in number
 ,p_amt_dsgd_val_o                 in number
 ,p_amt_dsgd_uom_o                 in varchar2
 ,p_dsgn_strt_dt_o                 in date
 ,p_dsgn_thru_dt_o                 in date
 ,p_addl_instrn_txt_o              in varchar2
 ,p_pbn_attribute_category_o       in varchar2
 ,p_pbn_attribute1_o               in varchar2
 ,p_pbn_attribute2_o               in varchar2
 ,p_pbn_attribute3_o               in varchar2
 ,p_pbn_attribute4_o               in varchar2
 ,p_pbn_attribute5_o               in varchar2
 ,p_pbn_attribute6_o               in varchar2
 ,p_pbn_attribute7_o               in varchar2
 ,p_pbn_attribute8_o               in varchar2
 ,p_pbn_attribute9_o               in varchar2
 ,p_pbn_attribute10_o              in varchar2
 ,p_pbn_attribute11_o              in varchar2
 ,p_pbn_attribute12_o              in varchar2
 ,p_pbn_attribute13_o              in varchar2
 ,p_pbn_attribute14_o              in varchar2
 ,p_pbn_attribute15_o              in varchar2
 ,p_pbn_attribute16_o              in varchar2
 ,p_pbn_attribute17_o              in varchar2
 ,p_pbn_attribute18_o              in varchar2
 ,p_pbn_attribute19_o              in varchar2
 ,p_pbn_attribute20_o              in varchar2
 ,p_pbn_attribute21_o              in varchar2
 ,p_pbn_attribute22_o              in varchar2
 ,p_pbn_attribute23_o              in varchar2
 ,p_pbn_attribute24_o              in varchar2
 ,p_pbn_attribute25_o              in varchar2
 ,p_pbn_attribute26_o              in varchar2
 ,p_pbn_attribute27_o              in varchar2
 ,p_pbn_attribute28_o              in varchar2
 ,p_pbn_attribute29_o              in varchar2
 ,p_pbn_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
 ,p_per_in_ler_id_o                in number
  );
--
end ben_pbn_rku;

 

/
