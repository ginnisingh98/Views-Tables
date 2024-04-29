--------------------------------------------------------
--  DDL for Package BEN_PBN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBN_RKI" AUTHID CURRENT_USER as
/* $Header: bepbnrhi.pkh 120.0.12000000.1 2007/01/19 20:00:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pbn_rki;

 

/
